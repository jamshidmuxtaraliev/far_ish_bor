import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../../auth/presentation/logic/auth_bloc.dart';
import '../logic/chat_bloc.dart';
import '../widgets/chat_view.dart';

/// Operator bilan suhbat (`support:{role}:{mobile_user_id}`).
class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  String? _sessionKey;

  @override
  void initState() {
    super.initState();
    _sessionKey = buildSupportSessionKey();
    // Old installs may have token+role but no cached user (saveUser was only
    // added later) — refresh /mobile/me, the AuthBloc listener retries below.
    if (_sessionKey == null) context.read<AuthBloc>().add(GetMeEvent());
  }

  @override
  Widget build(BuildContext context) {
    final key = _sessionKey;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: BlocListener<AuthBloc, AuthState>(
        // User keshda yo'q edi — GetMe qaytgach session'ni qayta boshlaymiz.
        listenWhen: (p, c) => _sessionKey == null && p.user?.id != c.user?.id,
        listener: (context, state) =>
            setState(() => _sessionKey = buildSupportSessionKey()),
        child: key == null ? _buildWaiting() : _buildChat(key),
      ),
    );
  }

  Widget _buildChat(String sessionKey) => ChatView(
        sessionKey: sessionKey,
        title: "Qo'llab-quvvatlash",
        peerLabel: 'operator',
        emptyText:
            'Salom! Savolingizni yozing — operator tez orada javob beradi.',
        emptyIcon: Icons.support_agent,
        avatar: Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: JB_INDIGO_TINT,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.support_agent, color: JB_BLUE, size: 22),
        ),
      );

  Widget _buildWaiting() {
    return Scaffold(
      backgroundColor: JB_BG,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: JB_INK,
        elevation: 0,
        title: const Text("Qo'llab-quvvatlash",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, auth) =>
            auth.getMeStatus == FormzSubmissionStatus.inProgress
                ? const Center(child: CircularProgressIndicator(color: PRIMARY_BLUE))
                : const ChatCenterNote(
                    text: 'Foydalanuvchi aniqlanmadi. Qaytadan kiring.',
                  ),
      ),
    );
  }
}
