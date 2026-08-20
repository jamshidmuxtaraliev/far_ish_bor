import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/enums/media_type_enum.dart';
import '../../../../core/services/file_picker_service.dart';
import '../../../../core/services/get_it.dart';
import '../../../auth/data/datasource/local/user_local_data_source.dart';
import '../../../auth/presentation/screens/language_screen.dart';
import '../../data/models/chat_message_model.dart';
import '../logic/chat_bloc.dart';
import '../../../../core/theme/jb_palette.dart';

/// Suhbat ekranining umumiy tanasi — operator chati (`support:*`) va
/// ish beruvchi ↔ nomzod chati (`direct:*`) bir xil mexanizmdan foydalanadi
/// (PROMPT_OTKLIK_MOBILE.md §7).
///
/// `ChatBloc`ni **context'dan** oladi: `direct` suhbat uni o'zining
/// [DirectChatBloc] nusxasi bilan almashtiradi.
class ChatView extends StatefulWidget {
  final String sessionKey;

  /// AppBar sarlavhasi: operator uchun "Qo'llab-quvvatlash", direct uchun nomzod ismi.
  final String title;

  /// Sarlavha yonidagi avatar.
  final Widget avatar;

  /// Suhbat bo'sh bo'lganda ko'rsatiladigan matn.
  final String emptyText;
  final IconData emptyIcon;

  /// Suhbatdosh rolini bildiruvchi qo'shimcha ("operator" / "nomzod").
  final String peerLabel;

  const ChatView({
    super.key,
    required this.sessionKey,
    required this.title,
    required this.avatar,
    required this.emptyText,
    this.emptyIcon = Icons.chat_bubble_outline_rounded,
    this.peerLabel = 'operator',
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _typingTimer;
  late final ChatBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<ChatBloc>();
    _bloc
      ..add(ConnectChatEvent(widget.sessionKey))
      ..add(const ChatScreenOpenedEvent());
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    // Socket ochiq qoladi (§7.10) — suhbatdosh javobi o'qilmagan hisoblagichga
    // tushishi uchun; faqat hisoblash qayta yoqiladi.
    _bloc.add(const ChatScreenClosedEvent());
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
      if (_bloc.state.hasMore &&
          _bloc.state.loadMoreStatus != FormzSubmissionStatus.inProgress) {
        _bloc.add(const LoadMoreHistoryEvent());
      }
    }
  }

  void _onInputChanged(String value) {
    if (value.trim().isNotEmpty) {
      _bloc.add(const UserTypingEvent(true));
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        _bloc.add(const UserTypingEvent(false));
      });
    }
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _bloc.add(SendChatMessageEvent(text));
    _inputCtrl.clear();
    _typingTimer?.cancel();
  }

  Future<void> _pickAttachment() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: jb.card,
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
                  leading: Icon(Icons.image_outlined, color: jb.blue),
                  title: const Text('Rasm'),
                  onTap: () => Navigator.pop(ctx, 'image'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.insert_drive_file_outlined,
                    color: jb.blue,
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
    _bloc.add(
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
      backgroundColor: jb.card,
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
                    Text(
                      'Yuborish',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: jb.ink,
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
                          color: jb.cardAlt,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.insert_drive_file_outlined,
                              color: jb.blue,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                path.split('/').last,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: jb.ink,
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
                        color: jb.cardAlt,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: captionCtrl,
                        autofocus: true,
                        minLines: 1,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(fontSize: 15, color: jb.ink),
                        decoration: InputDecoration(
                          hintText: 'Izoh (ixtiyoriy)...',
                          hintStyle: TextStyle(color: jb.gray),
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
                          child: Text(
                            'Bekor qilish',
                            style: TextStyle(color: jb.gray),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(ctx, captionCtrl.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: jb.blue,
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
    _bloc.add(const DisconnectChatEvent());
    getIt<UserLocalDatasource>().clearCache();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LanguageScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
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
                backgroundColor: context.jb.red,
              ),
            );
          },
        ),
        // Server rad etgan xabar (§7.5 — ochilmagan nomzodga yozish) va boshqa
        // `chat:error` holatlari.
        BlocListener<ChatBloc, ChatState>(
          listenWhen: (p, c) =>
              p.error != c.error &&
              c.error != null &&
              c.error != 'connect_error' &&
              !c.authFailed &&
              // Fayl yuklash xatosi yuqoridagi listener bilan ko'rsatiladi —
              // ikki marta toast chiqmasin.
              c.uploadStatus != FormzSubmissionStatus.failure,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: context.jb.red,
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
        backgroundColor: context.jb.bg,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildBanners(),
            Expanded(child: _buildMessageList()),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBanners() {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen:
          (p, c) => p.connected != c.connected || p.sessionStatus != c.sessionStatus,
      builder: (context, state) {
        return Column(
          children: [
            if (!state.connected)
              _InfoBanner(
                text: 'Internet yo\'q — xabarlar ulanish tiklangach yuboriladi',
                color: jb.amberBg,
                fg: jb.amber,
                icon: Icons.wifi_off_rounded,
              ),
            if (state.sessionClosed)
              _InfoBanner(
                text: 'Suhbat yopildi — yangi xabar yozsangiz qayta ochiladi',
                color: jb.cardAlt,
                fg: jb.gray,
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
          return Center(
            child: CircularProgressIndicator(color: jb.blue),
          );
        }
        if (state.messages.isEmpty) {
          return ChatCenterNote(text: widget.emptyText, icon: widget.emptyIcon);
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
          itemCount: display.length + typingOffset + (showTopLoader ? 1 : 0),
          itemBuilder: (context, i) {
            // Eng past element — "yozmoqda..." pufakchasi.
            if (typingOffset == 1 && i == 0) {
              return _TypingBubble(label: widget.peerLabel);
            }
            final index = i - typingOffset;
            // Eng tepa element — eski sahifa yuklanayotgani.
            if (index >= display.length) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: jb.blue,
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
              mine: _bloc.isMineMessage(message),
              onRetry:
                  message.sendStatus == ChatSendStatus.failed &&
                          message.localId != null
                      ? () => _bloc.add(RetryMessageEvent(message.localId!))
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
      backgroundColor: jb.card,
      surfaceTintColor: jb.card,
      foregroundColor: jb.ink,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      titleSpacing: 0,
      title: Row(
        children: [
          widget.avatar,
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
                final name = state.isDirect ? '' : state.operatorName;
                final String status;
                if (state.operatorTyping) {
                  status = name.isNotEmpty ? '$name yozmoqda...' : 'yozmoqda...';
                } else if (!state.connected) {
                  status = 'ulanmoqda...';
                } else if (name.isNotEmpty) {
                  status = '$name — ${widget.peerLabel}';
                } else if (state.operatorInChat) {
                  status = '${widget.peerLabel} suhbatda';
                } else {
                  status = 'onlayn';
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        color: state.connected ? jb.green : jb.grayLight,
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
        color: jb.card,
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
                        ? Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: jb.blue,
                            ),
                          ),
                        )
                        : IconButton(
                          onPressed: _pickAttachment,
                          icon: Icon(
                            Icons.attach_file_rounded,
                            color: jb.gray,
                          ),
                        ),
              ),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: jb.cardAlt,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: TextField(
                    controller: _inputCtrl,
                    onChanged: _onInputChanged,
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(fontSize: 15, color: jb.ink),
                    decoration: InputDecoration(
                      hintText: 'Xabar yozing...',
                      hintStyle: TextStyle(color: jb.gray),
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
                    color: state.connected ? jb.blue : jb.grayLight,
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
  final bool mine;
  final VoidCallback? onRetry;
  const _MessageBubble({
    required this.message,
    required this.mine,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = mine ? context.jb.blue : context.jb.card;
    final textColor = mine ? Colors.white : context.jb.ink;
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
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: context.jb.blue,
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
                border: mine ? null : Border.all(color: context.jb.border),
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
                    style: TextStyle(fontSize: 11, color: context.jb.gray),
                  ),
                if (mine) ...[
                  const SizedBox(width: 4),
                  switch (message.sendStatus) {
                    ChatSendStatus.sending => Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: context.jb.gray,
                    ),
                    ChatSendStatus.sent => Icon(
                      Icons.done_rounded,
                      size: 14,
                      color: context.jb.blue,
                    ),
                    ChatSendStatus.failed => Icon(
                      Icons.error_outline_rounded,
                      size: 14,
                      color: context.jb.red,
                    ),
                  },
                ],
              ],
            ),
          ),
          if (message.sendStatus == ChatSendStatus.failed)
            Padding(
              padding: EdgeInsets.only(top: 2, right: 4),
              child: Text(
                'Yuborilmadi — qayta yuborish uchun bosing',
                style: TextStyle(fontSize: 10, color: context.jb.red),
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
                  color: context.jb.cardAlt,
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.jb.blue,
                      ),
                    ),
                  ),
                ),
            errorWidget:
                (_, __, ___) => Container(
                  width: MediaQuery.sizeOf(context).width * 0.6,
                  height: 120,
                  color: context.jb.cardAlt,
                  child: Icon(Icons.broken_image_outlined,
                      color: context.jb.gray),
                ),
          ),
        ),
      );
    }

    final name =
        Uri.tryParse(message.attachmentUrl!)?.pathSegments.lastOrNull ?? 'Fayl';
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
            color: context.jb.cardAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.text ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: context.jb.gray),
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
            color: context.jb.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.jb.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: context.jb.gray,
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
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: fg))),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  final String label;
  const _TypingBubble({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.jb.card,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: context.jb.border),
        ),
        child: Text(
          '$label yozmoqda...',
          style: TextStyle(
            fontSize: 13,
            color: context.jb.gray,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

/// Bo'sh holat / ogohlantirish matni — suhbat ekranlarida umumiy.
class ChatCenterNote extends StatelessWidget {
  final String text;
  final IconData? icon;
  const ChatCenterNote({super.key, required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 56, color: context.jb.borderStrong),
              const SizedBox(height: 16),
            ],
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: context.jb.gray),
            ),
          ],
        ),
      ),
    );
  }
}
