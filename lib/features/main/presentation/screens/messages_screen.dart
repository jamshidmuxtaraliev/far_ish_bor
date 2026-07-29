import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../chat/presentation/logic/chat_bloc.dart';
import '../../../chat/presentation/screens/support_chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

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
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // White header
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 18,
                left: 20,
                right: 20,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Xabarlar',
                    style: TextStyle(
                      color: JB_INK,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: JB_CHIP_BG,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const TextField(
                      style: TextStyle(color: DARK_NAVY, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Qidirish...',
                        hintStyle: TextStyle(color: GRAY_TEXT),
                        prefixIcon: Icon(Icons.search, color: GRAY_TEXT),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // List — bitta suhbat: qo'llab-quvvatlash (operator bilan chat).
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, chatState) {
                  final lastMsg = chatState.messages.isEmpty
                      ? null
                      : chatState.messages.last;
                  final c = {
                    'name': 'Qo\'llab-quvvatlash markazi',
                    'last': lastMsg?.text?.isNotEmpty == true
                        ? lastMsg!.text!
                        : (lastMsg?.attachmentUrl != null
                            ? 'Fayl'
                            : 'Savolingiz bo\'lsa, bemalol yozing'),
                    'time': lastMsg?.timeDisplay ?? '',
                  };
                  final unread = chatState.unreadCount;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: 1,
                    itemBuilder: (_, i) {
                      return InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SupportChatScreen()),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD1D5DB), Color(0xFF9CA3AF)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                (c['name'] as String)[0],
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        c['name'] as String,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: DARK_NAVY,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      c['time'] as String,
                                      style: const TextStyle(
                                          fontSize: 12, color: GRAY_TEXT),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        c['last'] as String,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: unread > 0
                                              ? DARK_NAVY
                                              : GRAY_TEXT,
                                          fontWeight: unread > 0
                                              ? FontWeight.w500
                                              : FontWeight.normal,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (unread > 0)
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: const BoxDecoration(
                                          color: PRIMARY_BLUE,
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
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
