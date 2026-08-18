import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/services/get_it.dart';
import '../../../../core/utils/custom_cached_network_image.dart';
import '../logic/chat_bloc.dart';
import '../logic/direct_chat_bloc.dart';
import '../widgets/chat_view.dart';

/// PROMPT_OTKLIK_MOBILE.md §6–7 — ish beruvchi ↔ ochilgan nomzod suhbati.
///
/// `sessionKey` — `contact-unlock`/`candidates/:id` javobidagi
/// `capabilities.chat.session_key` (`direct:e<employer_id>:a<anketa_id>`).
/// Chat tugmasi faqat nomzod **ochilgan** bo'lsa faollashadi (§7.5).
class DirectChatScreen extends StatelessWidget {
  final String sessionKey;
  final String peerName;
  final String? peerPhotoUrl;

  const DirectChatScreen({
    super.key,
    required this.sessionKey,
    required this.peerName,
    this.peerPhotoUrl,
  });

  String get _initials {
    final parts = peerName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return (parts.first[0] + second).toUpperCase();
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
      // Operator suhbati bilan bir vaqtda ochiq turishi uchun alohida bloc.
      child: BlocProvider<ChatBloc>.value(
        value: getIt<DirectChatBloc>(),
        child: ChatView(
          sessionKey: sessionKey,
          title: peerName,
          peerLabel: 'nomzod',
          emptyText: 'Nomzod bilan suhbatni boshlang — birinchi xabarni yozing.',
          emptyIcon: Icons.forum_outlined,
          avatar: _avatar(),
        ),
      ),
    );
  }

  Widget _avatar() {
    final url = peerPhotoUrl;
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: CustomCachedNetworkImage(
          url: url,
          width: 38,
          height: 38,
          fit: BoxFit.cover,
          forUserImages: true,
          borderRadius: BorderRadius.circular(19),
        ),
      );
    }
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: JB_INDIGO_TINT,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: JB_BLUE,
        ),
      ),
    );
  }
}
