import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../data/datasource/chat_realtime_datasource.dart';
import '../../data/models/chat_message_model.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRealtimeDatasource realtime;

  StreamSubscription<ChatMessageModel>? _messageSub;
  StreamSubscription<bool>? _connectionSub;
  StreamSubscription<Map<String, dynamic>>? _typingSub;
  StreamSubscription<String>? _errorSub;

  ChatBloc(this.realtime) : super(const ChatState()) {
    on<ConnectChatEvent>(_onConnect);
    on<DisconnectChatEvent>(_onDisconnect);
    on<LoadHistoryEvent>(_onLoadHistory);
    on<SendChatMessageEvent>(_onSendMessage);
    on<UserTypingEvent>(_onUserTyping);
    on<_MessageReceived>(_onMessageReceived);
    on<_ConnectionChanged>(_onConnectionChanged);
    on<_OperatorTyping>(_onOperatorTyping);
    on<_ChatErrored>(_onChatErrored);

    _messageSub = realtime.onMessage.listen((m) => add(_MessageReceived(m)));
    _connectionSub = realtime.onConnectionChanged.listen(
      (c) => add(_ConnectionChanged(c)),
    );
    _typingSub = realtime.onTyping.listen((d) {
      // Only show "operator is typing" for staff audience.
      final audience = d['audience'] as String?;
      if (audience == 'staff') {
        add(_OperatorTyping(d['is_typing'] as bool? ?? false));
      }
    });
    _errorSub = realtime.onError.listen((e) => add(_ChatErrored(e)));
  }

  @override
  Future<void> close() async {
    await _messageSub?.cancel();
    await _connectionSub?.cancel();
    await _typingSub?.cancel();
    await _errorSub?.cancel();
    return super.close();
  }

  void _onConnect(ConnectChatEvent event, Emitter<ChatState> emit) {
    emit(
      state.copyWith(
        sessionKey: event.sessionKey,
        messages: const [],
        historyStatus: FormzSubmissionStatus.inProgress,
      ),
    );
    realtime.connect();
    // If the socket is already live, the listener won't re-fire connect —
    // join + load history right away.
    if (realtime.isConnected) {
      realtime.joinSession(event.sessionKey);
      add(const LoadHistoryEvent());
    }
  }

  void _onDisconnect(DisconnectChatEvent event, Emitter<ChatState> emit) {
    if (state.sessionKey.isNotEmpty) realtime.leaveSession(state.sessionKey);
    realtime.disconnect();
  }

  Future<void> _onLoadHistory(
    LoadHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state.sessionKey.isEmpty) return;
    emit(state.copyWith(historyStatus: FormzSubmissionStatus.inProgress));
    final messages = await realtime.fetchHistory(
      state.sessionKey,
      beforeId: event.beforeId,
    );
    emit(
      state.copyWith(
        messages: messages,
        historyStatus: FormzSubmissionStatus.success,
      ),
    );
  }

  void _onSendMessage(SendChatMessageEvent event, Emitter<ChatState> emit) {
    final text = event.text.trim();
    if (text.isEmpty || state.sessionKey.isEmpty) return;
    realtime.sendMessage(state.sessionKey, text);
    realtime.sendTyping(state.sessionKey, false);
  }

  void _onUserTyping(UserTypingEvent event, Emitter<ChatState> emit) {
    if (state.sessionKey.isEmpty) return;
    realtime.sendTyping(state.sessionKey, event.isTyping);
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
    if (m.id != null && state.messages.any((e) => e.id == m.id)) return;
    emit(
      state.copyWith(messages: [...state.messages, m], operatorTyping: false),
    );
  }

  void _onOperatorTyping(_OperatorTyping event, Emitter<ChatState> emit) {
    emit(state.copyWith(operatorTyping: event.isTyping));
  }

  void _onChatErrored(_ChatErrored event, Emitter<ChatState> emit) {
    emit(state.copyWith(error: event.message));
  }
}
