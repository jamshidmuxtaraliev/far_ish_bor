import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/services/get_it.dart';
import '../../../auth/data/datasource/local/user_local_data_source.dart';
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
    final local = getIt<UserLocalDatasource>();
    final role = local.getRole(); // 'seeker' | 'employer'
    final userId = local.getCachedUser()?.id;
    if (role.isNotEmpty && userId != null) {
      _sessionKey = 'support:$role:$userId';
      _ready = true;
      context.read<ChatBloc>().add(ConnectChatEvent(_sessionKey));
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    context.read<ChatBloc>().add(const DisconnectChatEvent());
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
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

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
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
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(),
        body:
            !_ready
                ? const _CenterNote(
                  text: 'Foydalanuvchi aniqlanmadi. Qaytadan kiring.',
                )
                : Column(
                  children: [
                    Expanded(
                      child: BlocConsumer<ChatBloc, ChatState>(
                        listenWhen:
                            (p, c) =>
                                p.messages.length != c.messages.length ||
                                p.operatorTyping != c.operatorTyping,
                        listener: (context, state) => _scrollToBottom(),
                        builder: (context, state) {
                          if (state.historyStatus ==
                                  FormzSubmissionStatus.inProgress &&
                              state.messages.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: PRIMARY_BLUE,
                              ),
                            );
                          }
                          if (state.messages.isEmpty) {
                            return const _CenterNote(
                              text:
                                  'Savolingizni yozing — operator tez orada javob beradi.',
                              icon: Icons.support_agent,
                            );
                          }
                          return ListView.builder(
                            controller: _scrollCtrl,
                            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                            itemCount:
                                state.messages.length +
                                (state.operatorTyping ? 1 : 0),
                            itemBuilder: (context, i) {
                              if (i >= state.messages.length) {
                                return const _TypingBubble();
                              }
                              return _MessageBubble(message: state.messages[i]);
                            },
                          );
                        },
                      ),
                    ),
                    _buildInputBar(),
                  ],
                ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0F172A),
      foregroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              buildWhen:
                  (p, c) =>
                      p.connected != c.connected ||
                      p.operatorTyping != c.operatorTyping,
              builder: (context, state) {
                final status =
                    state.operatorTyping
                        ? 'yozmoqda...'
                        : (state.connected ? 'onlayn' : 'ulanmoqda...');
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
                                ? const Color(0xFF4ADE80)
                                : Colors.white60,
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
        12,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
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
              decoration: const BoxDecoration(
                color: PRIMARY_BLUE,
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
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  const _MessageBubble({required this.message});

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
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.76,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: radius,
              border: mine ? null : Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              message.text ?? '',
              style: TextStyle(fontSize: 15, color: textColor, height: 1.3),
            ),
          ),
          if (message.timeDisplay.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              child: Text(
                message.timeDisplay,
                style: const TextStyle(fontSize: 11, color: GRAY_TEXT),
              ),
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
