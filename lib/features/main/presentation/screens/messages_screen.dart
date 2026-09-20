import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/utils/custom_cached_network_image.dart';
import '../../../chat/data/models/chat_session_model.dart';
import '../../../chat/presentation/logic/chat_bloc.dart';
import '../../../chat/presentation/screens/direct_chat_screen.dart';
import '../../../chat/presentation/screens/support_chat_screen.dart';
import '../../../../core/theme/jb_palette.dart';

/// "Xabarlar" — umumiy muloqot bo'limi (PROMPT_OTKLIK_MOBILE.md §7.1):
/// operator suhbati doim birinchi, so'ng otklik bilan ochilgan nomzodlar.
class MessagesScreen extends StatefulWidget {
  /// Ekran `push` bilan ochilganda `true` — sarlavhada orqaga tugmasi chiqadi.
  ///
  /// ⚠ Pastki menyuda tab sifatida tursa `false` bo'lishi SHART: tabda orqaga
  /// tugmasi ma'nosiz. Aksincha, push qilinganda u bo'lmasa foydalanuvchi
  /// faqat tizim "orqaga" tugmasi bilan chiqa oladi.
  final bool showBack;

  const MessagesScreen({super.key, this.showBack = false});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(const LoadChatsEvent());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ChatSessionModel> _filtered(List<ChatSessionModel> chats) {
    if (_query.isEmpty) return chats;
    final q = _query.toLowerCase();
    return chats.where((c) => c.title.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.jb.overlay,
      child: Scaffold(
        backgroundColor: context.jb.card,
        body: Column(
          children: [
            _header(),
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, chatState) {
                  final chats = _filtered(chatState.chats);
                  if (chats.isEmpty) {
                    // Ro'yxat hali kelmagan / bo'sh — operator suhbati doim bor.
                    if (chatState.chatsStatus ==
                            FormzSubmissionStatus.inProgress &&
                        chatState.chats.isEmpty) {
                      return Center(
                        child: CircularProgressIndicator(color: context.jb.blue),
                      );
                    }
                    if (_query.isNotEmpty) {
                      return const _EmptyNote(text: 'Suhbat topilmadi');
                    }
                    return RefreshIndicator(
                      color: context.jb.blue,
                      onRefresh: _reload,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [_supportFallbackTile(chatState)],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: context.jb.blue,
                    onRefresh: _reload,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: chats.length,
                      itemBuilder: (_, i) => _ChatTile(
                        chat: chats[i],
                        unread: chats[i].isSupport ? chatState.unreadCount : 0,
                        onTap: () => _open(chats[i]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reload() async {
    context.read<ChatBloc>().add(const LoadChatsEvent());
  }

  Future<void> _open(ChatSessionModel chat) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => chat.isSupport
            ? const SupportChatScreen()
            : DirectChatScreen(
                sessionKey: chat.sessionKey,
                peerName: chat.title,
                peerPhotoUrl: chat.peer?.photoUrl,
              ),
      ),
    );
    if (mounted) _reload();
  }

  /// `/mobile/chats` bo'sh yoki xato bo'lsa ham operator bilan yozish mumkin.
  Widget _supportFallbackTile(ChatState state) {
    final last = state.messages.isEmpty ? null : state.messages.last;
    return _Tile(
      title: "Qo'llab-quvvatlash markazi",
      subtitle: last?.text?.isNotEmpty == true
          ? last!.text!
          : (last?.attachmentUrl != null
              ? 'Fayl'
              : "Savolingiz bo'lsa, bemalol yozing"),
      time: last?.timeDisplay ?? '',
      unread: state.unreadCount,
      avatar: const _SupportAvatar(),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SupportChatScreen()),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      color: jb.card,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 18,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.showBack)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.arrow_back_rounded,
                          color: jb.ink, size: 22),
                    ),
                  ),
                ),
              Text(
                'Xabarlar',
                style: TextStyle(
                    color: jb.ink, fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: jb.chipBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v.trim()),
              style: TextStyle(color: jb.ink, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Qidirish...',
                hintStyle: TextStyle(color: jb.gray),
                prefixIcon: Icon(Icons.search, color: jb.gray),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatSessionModel chat;
  final int unread;
  final VoidCallback onTap;

  const _ChatTile({
    required this.chat,
    required this.unread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final preview = chat.lastMessage?.preview ?? '';
    return _Tile(
      title: chat.title,
      subtitle: preview.isNotEmpty
          ? preview
          : (chat.isSupport
              ? "Savolingiz bo'lsa, bemalol yozing"
              : 'Suhbatni boshlang'),
      time: chat.lastMessage?.timeDisplay ?? '',
      unread: unread,
      avatar: chat.isSupport
          ? const _SupportAvatar()
          : _PeerAvatar(name: chat.title, photoUrl: chat.peer?.photoUrl),
      onTap: onTap,
    );
  }
}

class _Tile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final int unread;
  final Widget avatar;
  final VoidCallback onTap;

  const _Tile({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.unread,
    required this.avatar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            avatar,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: context.jb.ink,
                          ),
                        ),
                      ),
                      Text(time,
                          style:
                              TextStyle(fontSize: 12, color: context.jb.gray)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: unread > 0 ? context.jb.ink : context.jb.gray,
                            fontWeight: unread > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (unread > 0)
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: context.jb.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$unread',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportAvatar extends StatelessWidget {
  const _SupportAvatar();

  @override
  Widget build(BuildContext context) => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: context.jb.blueTint,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.support_agent, color: context.jb.blue, size: 28),
      );
}

class _PeerAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  const _PeerAvatar({required this.name, this.photoUrl});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return (parts.first[0] + second).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    if (url != null && url.isNotEmpty) {
      return CustomCachedNetworkImage(
        url: url,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        forUserImages: true,
        borderRadius: BorderRadius.circular(28),
      );
    }
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: context.jb.chipBg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w800, color: context.jb.gray),
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  final String text;
  const _EmptyNote({required this.text});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: context.jb.gray)),
        ),
      );
}
