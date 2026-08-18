import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../../../core/services/get_it.dart';
import '../../../auth/data/datasource/local/user_local_data_source.dart';
import '../../data/datasource/chat_realtime_datasource.dart';
import '../../data/datasource/remote/chat_remote_datasource.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/models/chat_session_model.dart';

part 'chat_event.dart';
part 'chat_state.dart';

/// `support:{role}:{mobile_users.id}` (MOBILE_CHAT_PROMPT §2) —
/// null while there is no logged-in user.
String? buildSupportSessionKey() {
  final local = getIt<UserLocalDatasource>();
  final role = local.getRole();
  final userId = local.getCachedUser()?.id;
  if (role.isEmpty || userId == null) return null;
  return 'support:$role:$userId';
}

/// Joriy mobil foydalanuvchi id'si — `direct:*` suhbatda "meniki" xabarni
/// aniqlash uchun (ikkala tomon ham `author_audience: mobile`).
int? currentMobileUserId() => getIt<UserLocalDatasource>().getCachedUser()?.id;

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRealtimeDatasource realtime;
  final ChatRemoteDatasource remote;

  static const _pageSize = 50;

  StreamSubscription<ChatMessageModel>? _messageSub;
  StreamSubscription<bool>? _connectionSub;
  StreamSubscription<Map<String, dynamic>>? _typingSub;
  StreamSubscription<Map<String, dynamic>>? _presenceSub;
  StreamSubscription<Map<String, dynamic>>? _assignedSub;
  StreamSubscription<String>? _errorSub;

  ChatBloc(this.realtime, this.remote) : super(const ChatState()) {
    on<ConnectChatEvent>(_onConnect);
    on<DisconnectChatEvent>(_onDisconnect);
    on<LoadHistoryEvent>(_onLoadHistory);
    on<LoadMoreHistoryEvent>(_onLoadMore);
    on<SendChatMessageEvent>(_onSendMessage);
    on<SendAttachmentEvent>(_onSendAttachment);
    on<RetryMessageEvent>(_onRetry);
    on<UserTypingEvent>(_onUserTyping);
    on<LoadChatsEvent>(_onLoadChats);
    on<ChatScreenOpenedEvent>(_onScreenOpened);
    on<ChatScreenClosedEvent>(_onScreenClosed);
    on<_MessageReceived>(_onMessageReceived);
    on<_OperatorAssigned>(_onOperatorAssigned);
    on<_ConnectionChanged>(_onConnectionChanged);
    on<_OperatorTyping>(_onOperatorTyping);
    on<_OperatorPresenceChanged>(_onOperatorPresence);
    on<_ChatErrored>(_onChatErrored);

    _messageSub = realtime.onMessage.listen((m) => add(_MessageReceived(m)));
    _connectionSub = realtime.onConnectionChanged.listen(
      (c) => add(_ConnectionChanged(c)),
    );
    _typingSub = realtime.onTyping.listen((d) {
      if (!_isOwnSession(d)) return;
      // Support: faqat operator (staff). Direct: suhbatdosh — o'zimdan boshqa
      // har qanday `mobile` qatnashuvchi (ikkalasi ham 'mobile' audience).
      final isPeer = d['audience'] == 'staff' ||
          (state.isDirect && (d['userId'] as num?)?.toInt() != _myUserId);
      if (isPeer) add(_OperatorTyping(d['is_typing'] as bool? ?? false));
    });
    _presenceSub = realtime.onPresence.listen((d) {
      if (!_isOwnSession(d)) return;
      final isPeer = d['audience'] == 'staff' ||
          (state.isDirect && (d['userId'] as num?)?.toInt() != _myUserId);
      if (isPeer) add(_OperatorPresenceChanged(d['joined'] as bool? ?? false));
    });
    _assignedSub = realtime.onAssigned.listen((d) {
      if (d['session_key'] != state.sessionKey) return;
      final assigned = d['assigned'];
      final name =
          assigned is Map ? assigned['user_name']?.toString() ?? '' : '';
      if (name.isNotEmpty) add(_OperatorAssigned(name));
    });
    _errorSub = realtime.onError.listen((e) => add(_ChatErrored(e)));
  }

  int? get _myUserId => currentMobileUserId();

  /// Socket eventlari barcha sessiyalar uchun bitta oqimda keladi; ilovada
  /// support va direct suhbatlar uchun alohida bloc bor, shuning uchun har biri
  /// faqat o'z `session_key`ini oladi (kalitsiz eventlar — eski backend — o'tadi).
  bool _isOwnSession(Map<String, dynamic> payload) {
    final key = payload['session_key'] as String?;
    return key == null || key == state.sessionKey;
  }

  /// Xabar meniki (o'ng tomonda) — direct suhbatda `author_id` bo'yicha.
  bool _isMine(ChatMessageModel m) {
    if (m.authorAudience != 'mobile') return false;
    final me = _myUserId;
    if (!state.isDirect || me == null || m.authorId == null) return true;
    return m.authorId == me;
  }

  @override
  Future<void> close() async {
    await _messageSub?.cancel();
    await _connectionSub?.cancel();
    await _typingSub?.cancel();
    await _presenceSub?.cancel();
    await _assignedSub?.cancel();
    await _errorSub?.cancel();
    return super.close();
  }

  void _onConnect(ConnectChatEvent event, Emitter<ChatState> emit) {
    // Re-connecting to the same session (screen re-open, app resume) keeps
    // messages/unread on screen; a different key (new login) starts fresh.
    if (state.sessionKey != event.sessionKey) {
      emit(
        ChatState(
          sessionKey: event.sessionKey,
          historyStatus: FormzSubmissionStatus.inProgress,
        ),
      );
    }
    // connect() re-emits `true` when already live, so the connection listener
    // handles join + history for both fresh and existing sockets.
    realtime.connect();
  }

  void _onDisconnect(DisconnectChatEvent event, Emitter<ChatState> emit) {
    if (state.sessionKey.isNotEmpty) realtime.leaveSession(state.sessionKey);
    realtime.disconnect();
  }

  /// Latest page, merged by id with what's on screen (§8 reconnect contract):
  /// already-paginated older messages stay, pendings that the server already
  /// has (matched by client_msg_id or text) are dropped, the rest re-sent.
  Future<void> _onLoadHistory(
    LoadHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state.sessionKey.isEmpty) return;
    emit(state.copyWith(historyStatus: FormzSubmissionStatus.inProgress));
    final fetched = await realtime.fetchHistory(
      state.sessionKey,
      limit: _pageSize,
    );

    final fetchedIds = fetched.map((m) => m.id).whereType<int>().toSet();
    final firstFetchedId = fetched.isEmpty ? null : fetched.first.id;
    final olderExisting =
        state.messages
            .where(
              (m) =>
                  m.id != null &&
                  !fetchedIds.contains(m.id) &&
                  (firstFetchedId == null || m.id! < firstFetchedId),
            )
            .toList();

    bool deliveredByServer(ChatMessageModel pending) => fetched.any(
      (f) =>
          _isMine(f) &&
          (f.localId != null
              ? f.localId == pending.localId
              : f.text == pending.text &&
                  f.attachmentUrl == pending.attachmentUrl),
    );
    final pendings =
        state.messages
            .where((m) => m.id == null && !deliveredByServer(m))
            .toList();

    emit(
      state.copyWith(
        messages: [...olderExisting, ...fetched, ...pendings],
        historyStatus: FormzSubmissionStatus.success,
        hasMore:
            olderExisting.isEmpty ? fetched.length >= _pageSize : state.hasMore,
      ),
    );

    // Offline queue flush: re-send what the server still doesn't have.
    if (realtime.isConnected) {
      for (final m in pendings.where((m) => m.isPending)) {
        _emitToSocket(m);
      }
    }
  }

  Future<void> _onLoadMore(
    LoadMoreHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state.sessionKey.isEmpty ||
        !state.hasMore ||
        state.loadMoreStatus == FormzSubmissionStatus.inProgress ||
        state.historyStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    final oldest = state.messages.where((m) => m.id != null).firstOrNull;
    if (oldest == null) return;

    emit(state.copyWith(loadMoreStatus: FormzSubmissionStatus.inProgress));
    final fetched = await realtime.fetchHistory(
      state.sessionKey,
      limit: _pageSize,
      beforeId: oldest.id,
    );
    final existingIds = state.messages.map((m) => m.id).whereType<int>().toSet();
    final older = fetched.where((m) => !existingIds.contains(m.id)).toList();
    emit(
      state.copyWith(
        messages: [...older, ...state.messages],
        loadMoreStatus: FormzSubmissionStatus.success,
        hasMore: fetched.length >= _pageSize,
      ),
    );
  }

  void _onSendMessage(SendChatMessageEvent event, Emitter<ChatState> emit) {
    final text = event.text.trim();
    if (text.isEmpty || state.sessionKey.isEmpty) return;
    final pending = ChatMessageModel(
      sessionKey: state.sessionKey,
      authorAudience: 'mobile',
      text: text,
      at: DateTime.now(),
      localId: DateTime.now().microsecondsSinceEpoch.toString(),
      sendStatus: ChatSendStatus.sending,
    );
    emit(state.copyWith(messages: [...state.messages, pending]));
    if (realtime.isConnected) _emitToSocket(pending);
    realtime.sendTyping(state.sessionKey, false);
  }

  Future<void> _onSendAttachment(
    SendAttachmentEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state.sessionKey.isEmpty) return;
    emit(state.copyWith(uploadStatus: FormzSubmissionStatus.inProgress));
    final result = await remote.uploadFile(event.path);
    result.fold(
      (failure) => emit(
        state.copyWith(
          uploadStatus: FormzSubmissionStatus.failure,
          // 404 = POST /mobile/chat/upload backend'da hali yo'q (TODO-1).
          error:
              failure.errorCode == 404
                  ? 'Fayl yuborish hozircha mavjud emas — '
                      'tez orada qo\'shiladi. Matn yozib yuborishingiz mumkin.'
                  : failure.errorMessage,
        ),
      ),
      (uploaded) {
        final caption = event.caption?.trim();
        final pending = ChatMessageModel(
          sessionKey: state.sessionKey,
          authorAudience: 'mobile',
          text: (caption?.isEmpty ?? true) ? null : caption,
          attachmentUrl: uploaded.url,
          // Server aniqlagan tur ustun; bo'lmasa kengaytmadan chiqaramiz.
          attachmentType: uploaded.type ?? chatMimeType(event.path),
          at: DateTime.now(),
          localId: DateTime.now().microsecondsSinceEpoch.toString(),
          sendStatus: ChatSendStatus.sending,
        );
        emit(
          state.copyWith(
            uploadStatus: FormzSubmissionStatus.success,
            messages: [...state.messages, pending],
          ),
        );
        if (realtime.isConnected) _emitToSocket(pending);
      },
    );
    emit(state.copyWith(uploadStatus: FormzSubmissionStatus.initial));
  }

  void _onRetry(RetryMessageEvent event, Emitter<ChatState> emit) {
    final updated =
        state.messages
            .map(
              (m) =>
                  m.localId == event.localId &&
                          m.sendStatus == ChatSendStatus.failed
                      ? m.copyWith(sendStatus: ChatSendStatus.sending)
                      : m,
            )
            .toList();
    emit(state.copyWith(messages: updated));
    final msg = updated.where((m) => m.localId == event.localId).firstOrNull;
    if (msg != null && realtime.isConnected) _emitToSocket(msg);
  }

  void _onUserTyping(UserTypingEvent event, Emitter<ChatState> emit) {
    if (state.sessionKey.isEmpty) return;
    realtime.sendTyping(state.sessionKey, event.isTyping);
  }

  Future<void> _onLoadChats(LoadChatsEvent event, Emitter<ChatState> emit) async {
    emit(state.copyWith(chatsStatus: FormzSubmissionStatus.inProgress));
    final result = await remote.getChats();
    result.fold(
      (failure) => emit(
        state.copyWith(
          chatsStatus: FormzSubmissionStatus.failure,
          error: failure.errorMessage,
        ),
      ),
      (list) {
        // Operator suhbati doim birinchi (§7.1), qolganlari — yangi xabar bo'yicha.
        final sorted = [...list]..sort((a, b) {
            if (a.isSupport != b.isSupport) return a.isSupport ? -1 : 1;
            final at = a.lastMessageAt;
            final bt = b.lastMessageAt;
            if (at == null && bt == null) return 0;
            if (at == null) return 1;
            if (bt == null) return -1;
            return bt.compareTo(at);
          });
        emit(state.copyWith(
          chats: sorted,
          chatsStatus: FormzSubmissionStatus.success,
        ));
      },
    );
  }

  /// Ekran uchun: xabar joriy foydalanuvchiniki (o'ng tomonda chiziladi).
  bool isMineMessage(ChatMessageModel m) => _isMine(m);

  void _onScreenOpened(ChatScreenOpenedEvent event, Emitter<ChatState> emit) {
    emit(state.copyWith(screenOpen: true, unreadCount: 0));
  }

  void _onScreenClosed(ChatScreenClosedEvent event, Emitter<ChatState> emit) {
    emit(state.copyWith(screenOpen: false, operatorTyping: false));
  }

  void _onConnectionChanged(_ConnectionChanged event, Emitter<ChatState> emit) {
    emit(state.copyWith(connected: event.connected));
    if (event.connected && state.sessionKey.isNotEmpty) {
      realtime.joinSession(state.sessionKey);
      add(const LoadHistoryEvent());
    }
  }

  void _onMessageReceived(_MessageReceived event, Emitter<ChatState> emit) {
    final m = event.message;
    if (m.sessionKey != state.sessionKey) return;

    final sessionStatus = m.sessionStatus ?? state.sessionStatus;
    if (m.id != null && state.messages.any((e) => e.id == m.id)) {
      emit(state.copyWith(sessionStatus: sessionStatus));
      return;
    }

    // Own echo → resolve the matching optimistic bubble (⏳ → ✓) instead of
    // appending a duplicate. Matched by client_msg_id (TODO-3) or by content.
    if (_isMine(m)) {
      final idx = state.messages.indexWhere(
        (e) =>
            e.id == null &&
            (m.localId != null
                ? e.localId == m.localId
                : e.text == m.text && e.attachmentUrl == m.attachmentUrl),
      );
      if (idx != -1) {
        final updated = [...state.messages];
        updated[idx] = m;
        emit(
          state.copyWith(messages: updated, sessionStatus: sessionStatus),
        );
        return;
      }
    }

    // Suhbatdosh xabari: support'da operator (staff), direct'da nomzod.
    final fromPeer = !_isMine(m) && !m.isSystem;
    emit(
      state.copyWith(
        messages: [...state.messages, m],
        operatorTyping: fromPeer ? false : null,
        // Header fallback when chat:assigned was missed (e.g. app was closed).
        operatorName:
            fromPeer && (m.authorName?.isNotEmpty ?? false)
                ? m.authorName
                : null,
        // Tab badge (§7.8): only the peer's messages count, and only while the
        // chat screen itself is not open.
        unreadCount:
            fromPeer && !state.screenOpen ? state.unreadCount + 1 : null,
        sessionStatus: sessionStatus,
      ),
    );
  }

  void _onOperatorAssigned(_OperatorAssigned event, Emitter<ChatState> emit) {
    emit(state.copyWith(operatorName: event.name));
  }

  void _onOperatorTyping(_OperatorTyping event, Emitter<ChatState> emit) {
    emit(state.copyWith(operatorTyping: event.isTyping));
  }

  void _onOperatorPresence(
    _OperatorPresenceChanged event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(operatorInChat: event.joined));
  }

  void _onChatErrored(_ChatErrored event, Emitter<ChatState> emit) {
    if (chatAuthErrors.contains(event.message)) {
      // One-shot: the screen listener clears the token and leaves to login.
      emit(state.copyWith(authFailed: true, error: event.message));
      emit(state.copyWith(authFailed: false));
      return;
    }
    if (event.message == 'connect_error') {
      emit(state.copyWith(error: event.message));
      return;
    }
    // chat:error — the last in-flight message wasn't saved: mark it ❗.
    final idx = state.messages.lastIndexWhere((m) => m.isPending);
    if (idx != -1) {
      final updated = [...state.messages];
      updated[idx] = updated[idx].copyWith(sendStatus: ChatSendStatus.failed);
      emit(state.copyWith(messages: updated, error: event.message));
    } else {
      emit(state.copyWith(error: event.message));
    }
  }

  void _emitToSocket(ChatMessageModel m) {
    realtime.sendMessage(
      state.sessionKey,
      text: m.text,
      attachment:
          m.attachmentUrl != null
              ? {'url': m.attachmentUrl, 'type': m.attachmentType}
              : null,
      clientMsgId: m.localId,
    );
  }
}
