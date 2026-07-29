import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/enums/media_type_enum.dart';
import '../../../../core/services/file_picker_service.dart';
import '../../../../core/services/get_it.dart';
import '../../../auth/data/datasource/local/user_local_data_source.dart';
import '../../../auth/presentation/logic/auth_bloc.dart';
import '../../../auth/presentation/screens/language_screen.dart';
import '../../data/models/chat_message_model.dart';
import '../logic/chat_bloc.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _typingTimer;

  String _sessionKey = '';
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _tryStartSession();
    // Old installs may have token+role but no cached user (saveUser was only
    // added later) — refresh /mobile/me, the AuthBloc listener retries below.
    if (!_ready) context.read<AuthBloc>().add(GetMeEvent());
    _scrollCtrl.addListener(_onScroll);
  }

  void _tryStartSession() {
    final sessionKey = buildSupportSessionKey();
    if (sessionKey == null) return;
    _sessionKey = sessionKey;
    _ready = true;
    context.read<ChatBloc>()
      ..add(ConnectChatEvent(_sessionKey))
      ..add(const ChatScreenOpenedEvent());
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    // Socket stays connected (§7.10) so operator replies keep feeding the
    // unread badge; only the unread counting resumes.
    getIt<ChatBloc>().add(const ChatScreenClosedEvent());
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  /// Ro'yxat `reverse: true` — 0 = eng yangi xabar (past), maxScrollExtent =
  /// eng eski (tepa). Tepaga yaqinlashganda eski sahifani yuklaymiz.
  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent - 60) {
      final bloc = context.read<ChatBloc>();
      if (bloc.state.hasMore &&
          bloc.state.loadMoreStatus != FormzSubmissionStatus.inProgress) {
        bloc.add(const LoadMoreHistoryEvent());
      }
    }
  }

  void _onInputChanged(String value) {
    final bloc = context.read<ChatBloc>();
    if (value.trim().isNotEmpty) {
      bloc.add(const UserTypingEvent(true));
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        bloc.add(const UserTypingEvent(false));
      });
    }
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    context.read<ChatBloc>().add(SendChatMessageEvent(text));
    _inputCtrl.clear();
    _typingTimer?.cancel();
  }

  Future<void> _pickAttachment() async {
    final bloc = context.read<ChatBloc>();
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.image_outlined, color: PRIMARY_BLUE),
                  title: const Text('Rasm'),
                  onTap: () => Navigator.pop(ctx, 'image'),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.insert_drive_file_outlined,
                    color: PRIMARY_BLUE,
                  ),
                  title: const Text('Fayl'),
                  onTap: () => Navigator.pop(ctx, 'file'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
    if (choice == null) return;

    String? path;
    if (choice == 'image') {
      path = await pickMediaPath(MediaTypeEnum.photo);
    } else {
      final result = await FilePicker.pickFiles(allowMultiple: false);
      path = result?.files.single.path;
    }
    if (path == null || !mounted) return;

    // Yuborishdan oldin preview + ixtiyoriy izoh (null = bekor qilindi).
    final caption = await _askCaption(path, isImage: choice == 'image');
    if (caption == null) return;
    bloc.add(
      SendAttachmentEvent(
        path,
        caption: caption.trim().isEmpty ? null : caption.trim(),
      ),
    );
  }

  Future<String?> _askCaption(String path, {required bool isImage}) {
    final captionCtrl = TextEditingController();
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => Padding(
            // Klaviatura ochilganda sheet ko'tarilib turadi.
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yuborish',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: DARK_NAVY,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isImage)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(path),
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.insert_drive_file_outlined,
                              color: PRIMARY_BLUE,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                path.split('/').last,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: DARK_NAVY,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: captionCtrl,
                        autofocus: true,
                        minLines: 1,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(fontSize: 15, color: DARK_NAVY),
                        decoration: const InputDecoration(
                          hintText: 'Izoh (ixtiyoriy)...',
                          hintStyle: TextStyle(color: GRAY_TEXT),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(
                            'Bekor qilish',
                            style: TextStyle(color: GRAY_TEXT),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed:
                              () => Navigator.pop(ctx, captionCtrl.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PRIMARY_BLUE,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: const Text('Yuborish'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  /// Reversed list — pastki chekka (eng yangi xabar) = 0-offset.
  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _onAuthFailed() {
    context.read<ChatBloc>().add(const DisconnectChatEvent());
    getIt<UserLocalDatasource>().clearCache();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LanguageScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: MultiBlocListener(
        listeners: [
          // User keshda yo'q edi — GetMe qaytgach session'ni qayta boshlaymiz.
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (p, c) => !_ready && p.user?.id != c.user?.id,
            listener: (context, state) => setState(_tryStartSession),
          ),
          BlocListener<ChatBloc, ChatState>(
            listenWhen: (p, c) => !p.authFailed && c.authFailed,
            listener: (context, state) => _onAuthFailed(),
          ),
          BlocListener<ChatBloc, ChatState>(
            listenWhen:
                (p, c) =>
                    p.uploadStatus != c.uploadStatus &&
                    c.uploadStatus == FormzSubmissionStatus.failure,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error ?? 'Fayl yuklanmadi'),
                  backgroundColor: const Color(0xFFDC2626),
                ),
              );
            },
          ),
          // Yangi xabar kelganda pastga tushamiz — lekin foydalanuvchi eski
          // xabarlarni o'qiyotgan bo'lsa (tepada) uni tortib tushirmaymiz.
          BlocListener<ChatBloc, ChatState>(
            listenWhen: (p, c) {
              final pLast = p.messages.isEmpty ? null : p.messages.last;
              final cLast = c.messages.isEmpty ? null : c.messages.last;
              final lastChanged =
                  pLast?.id != cLast?.id || pLast?.localId != cLast?.localId;
              return lastChanged || p.operatorTyping != c.operatorTyping;
            },
            listener: (context, state) {
              if (!_scrollCtrl.hasClients || _scrollCtrl.position.pixels < 200) {
                _scrollToBottom();
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: JB_BG,
          appBar: _buildAppBar(),
          body:
              !_ready
                  ? BlocBuilder<AuthBloc, AuthState>(
                    builder:
                        (context, auth) =>
                            auth.getMeStatus == FormzSubmissionStatus.inProgress
                                ? const Center(
                                  child: CircularProgressIndicator(
                                    color: PRIMARY_BLUE,
                                  ),
                                )
                                : const _CenterNote(
                                  text:
                                      'Foydalanuvchi aniqlanmadi. Qaytadan kiring.',
                                ),
                  )
                  : Column(
                    children: [
                      _buildBanners(),
                      Expanded(child: _buildMessageList()),
                      _buildInputBar(),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildBanners() {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen:
          (p, c) =>
              p.connected != c.connected ||
              p.sessionStatus != c.sessionStatus,
      builder: (context, state) {
        return Column(
          children: [
            if (!state.connected)
              const _InfoBanner(
                text: 'Internet yo\'q — xabarlar ulanish tiklangach yuboriladi',
                color: Color(0xFFFEF3C7),
                fg: Color(0xFF92400E),
                icon: Icons.wifi_off_rounded,
              ),
            if (state.sessionClosed)
              const _InfoBanner(
                text: 'Suhbat yopildi — yangi xabar yozsangiz qayta ochiladi',
                color: Color(0xFFF1F5F9),
                fg: GRAY_TEXT,
                icon: Icons.lock_outline_rounded,
              ),
          ],
        );
      },
    );
  }

  Widget _buildMessageList() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state.historyStatus == FormzSubmissionStatus.inProgress &&
            state.messages.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: PRIMARY_BLUE),
          );
        }
        if (state.messages.isEmpty) {
          return const _CenterNote(
            text:
                'Salom! Savolingizni yozing — operator tez orada javob beradi.',
            icon: Icons.support_agent,
          );
        }

        // Flatten: date separators + messages (xronologik tartibda).
        final items = <Object>[];
        DateTime? prevDay;
        for (final m in state.messages) {
          final at = m.at;
          if (at != null) {
            final day = DateTime(at.year, at.month, at.day);
            if (prevDay == null || day != prevDay) {
              items.add(_dateLabel(day));
              prevDay = day;
            }
          }
          items.add(m);
        }
        // reverse: true — 0-index pastda turadi, shuning uchun ro'yxatni
        // teskari beramiz: ekran ochilishi bilan eng oxirgi xabar ko'rinadi,
        // eski xabarlar uchun tepaga scroll qilinadi.
        final display = items.reversed.toList();
        final showTopLoader =
            state.loadMoreStatus == FormzSubmissionStatus.inProgress;
        final typingOffset = state.operatorTyping ? 1 : 0;

        return ListView.builder(
          controller: _scrollCtrl,
          reverse: true,
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          itemCount:
              display.length + typingOffset + (showTopLoader ? 1 : 0),
          itemBuilder: (context, i) {
            // Eng past element — "operator yozmoqda..." pufakchasi.
            if (typingOffset == 1 && i == 0) return const _TypingBubble();
            final index = i - typingOffset;
            // Eng tepa element — eski sahifa yuklanayotgani.
            if (index >= display.length) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: PRIMARY_BLUE,
                    ),
                  ),
                ),
              );
            }
            final item = display[index];
            if (item is String) return _DateSeparator(label: item);
            final message = item as ChatMessageModel;
            if (message.isSystem) return _SystemNote(message: message);
            return _MessageBubble(
              message: message,
              onRetry:
                  message.sendStatus == ChatSendStatus.failed &&
                          message.localId != null
                      ? () => context.read<ChatBloc>().add(
                        RetryMessageEvent(message.localId!),
                      )
                      : null,
            );
          },
        );
      },
    );
  }

  String _dateLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (day == today) return 'Bugun';
    if (day == today.subtract(const Duration(days: 1))) return 'Kecha';
    return '${day.day.toString().padLeft(2, '0')}.'
        '${day.month.toString().padLeft(2, '0')}.${day.year}';
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      foregroundColor: JB_INK,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: JB_INDIGO_TINT,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent,
              color: JB_BLUE,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              buildWhen:
                  (p, c) =>
                      p.connected != c.connected ||
                      p.operatorTyping != c.operatorTyping ||
                      p.operatorInChat != c.operatorInChat ||
                      p.operatorName != c.operatorName,
              builder: (context, state) {
                // chat:assigned yangilaydi — operator almashishi normal (§6).
                final name = state.operatorName;
                final String status;
                if (state.operatorTyping) {
                  status = name.isNotEmpty ? '$name yozmoqda...' : 'yozmoqda...';
                } else if (!state.connected) {
                  status = 'ulanmoqda...';
                } else if (name.isNotEmpty) {
                  status = '$name — operator';
                } else if (state.operatorInChat) {
                  status = 'operator suhbatda';
                } else {
                  status = 'onlayn';
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Qo\'llab-quvvatlash',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            state.connected
                                ? JB_GREEN_FG
                                : JB_GRAY_LIGHT,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        8,
        8,
        12,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BlocBuilder<ChatBloc, ChatState>(
        buildWhen:
            (p, c) =>
                p.connected != c.connected || p.uploadStatus != c.uploadStatus,
        builder: (context, state) {
          final uploading =
              state.uploadStatus == FormzSubmissionStatus.inProgress;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 44,
                height: 46,
                child:
                    uploading
                        ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: PRIMARY_BLUE,
                            ),
                          ),
                        )
                        : IconButton(
                          onPressed: _pickAttachment,
                          icon: const Icon(
                            Icons.attach_file_rounded,
                            color: GRAY_TEXT,
                          ),
                        ),
              ),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: TextField(
                    controller: _inputCtrl,
                    onChanged: _onInputChanged,
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(fontSize: 15, color: DARK_NAVY),
                    decoration: const InputDecoration(
                      hintText: 'Xabar yozing...',
                      hintStyle: TextStyle(color: GRAY_TEXT),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: state.connected ? PRIMARY_BLUE : JB_GRAY_LIGHT,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final VoidCallback? onRetry;
  const _MessageBubble({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final mine = message.isMine;
    final bubbleColor = mine ? PRIMARY_BLUE : Colors.white;
    final textColor = mine ? Colors.white : DARK_NAVY;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(mine ? 18 : 4),
      bottomRight: Radius.circular(mine ? 4 : 18),
    );
    final hasText = message.text?.isNotEmpty ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment:
            mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!mine && (message.authorName?.isNotEmpty ?? false))
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 3),
              child: Text(
                message.authorName!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: PRIMARY_BLUE,
                ),
              ),
            ),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.76,
              ),
              padding:
                  message.attachmentUrl != null
                      ? const EdgeInsets.all(4)
                      : const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: radius,
                border:
                    mine ? null : Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.attachmentUrl != null)
                    _Attachment(message: message, textColor: textColor),
                  if (hasText)
                    Padding(
                      padding:
                          message.attachmentUrl != null
                              ? const EdgeInsets.fromLTRB(10, 6, 10, 6)
                              : EdgeInsets.zero,
                      child: Text(
                        message.text!,
                        style: TextStyle(
                          fontSize: 15,
                          color: textColor,
                          height: 1.3,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.timeDisplay.isNotEmpty)
                  Text(
                    message.timeDisplay,
                    style: const TextStyle(fontSize: 11, color: GRAY_TEXT),
                  ),
                if (mine) ...[
                  const SizedBox(width: 4),
                  switch (message.sendStatus) {
                    ChatSendStatus.sending => const Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: GRAY_TEXT,
                    ),
                    ChatSendStatus.sent => const Icon(
                      Icons.done_rounded,
                      size: 14,
                      color: PRIMARY_BLUE,
                    ),
                    ChatSendStatus.failed => const Icon(
                      Icons.error_outline_rounded,
                      size: 14,
                      color: Color(0xFFDC2626),
                    ),
                  },
                ],
              ],
            ),
          ),
          if (message.sendStatus == ChatSendStatus.failed)
            const Padding(
              padding: EdgeInsets.only(top: 2, right: 4),
              child: Text(
                'Yuborilmadi — qayta yuborish uchun bosing',
                style: TextStyle(fontSize: 10, color: Color(0xFFDC2626)),
              ),
            ),
        ],
      ),
    );
  }
}

class _Attachment extends StatelessWidget {
  final ChatMessageModel message;
  final Color textColor;
  const _Attachment({required this.message, required this.textColor});

  Future<void> _open() async {
    final url = message.attachmentUrl;
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (message.isImage) {
      return GestureDetector(
        onTap: _open,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: CachedNetworkImage(
            imageUrl: message.attachmentUrl!,
            width: MediaQuery.sizeOf(context).width * 0.6,
            fit: BoxFit.cover,
            placeholder:
                (_, __) => Container(
                  width: MediaQuery.sizeOf(context).width * 0.6,
                  height: 160,
                  color: const Color(0xFFF1F5F9),
                  child: const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: PRIMARY_BLUE,
                      ),
                    ),
                  ),
                ),
            errorWidget:
                (_, __, ___) => Container(
                  width: MediaQuery.sizeOf(context).width * 0.6,
                  height: 120,
                  color: const Color(0xFFF1F5F9),
                  child: const Icon(Icons.broken_image_outlined,
                      color: GRAY_TEXT),
                ),
          ),
        ),
      );
    }

    final name = Uri.tryParse(message.attachmentUrl!)?.pathSegments.lastOrNull ??
        'Fayl';
    return GestureDetector(
      onTap: _open,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file_outlined, size: 22, color: textColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                  decoration: TextDecoration.underline,
                  decorationColor: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemNote extends StatelessWidget {
  final ChatMessageModel message;
  const _SystemNote({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.text ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: GRAY_TEXT),
          ),
        ),
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final String label;
  const _DateSeparator({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 2),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: GRAY_TEXT,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;
  final Color color;
  final Color fg;
  final IconData icon;
  const _InfoBanner({
    required this.text,
    required this.color,
    required this.fg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12, color: fg)),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Text(
          'operator yozmoqda...',
          style: TextStyle(
            fontSize: 13,
            color: GRAY_TEXT,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

class _CenterNote extends StatelessWidget {
  final String text;
  final IconData? icon;
  const _CenterNote({required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 56, color: const Color(0xFFCBD5E1)),
              const SizedBox(height: 16),
            ],
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: GRAY_TEXT),
            ),
          ],
        ),
      ),
    );
  }
}
