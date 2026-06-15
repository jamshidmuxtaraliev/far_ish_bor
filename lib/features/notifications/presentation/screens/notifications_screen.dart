import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/notification_model.dart';
import '../logic/notification_bloc.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const LoadNotificationsEvent());
  }

  void _markAllRead() {
    context.read<NotificationBloc>().add(const MarkNotificationsReadEvent());
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
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Bildirishnomalar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            BlocBuilder<NotificationBloc, NotificationState>(
              buildWhen: (p, c) => p.unreadCount != c.unreadCount,
              builder: (context, state) {
                if (state.unreadCount == 0) return const SizedBox.shrink();
                return TextButton(
                  onPressed: _markAllRead,
                  child: const Text(
                    "O'qildi",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state.status == FormzSubmissionStatus.inProgress &&
                state.notifications.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: PRIMARY_BLUE),
              );
            }
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.notifications_none,
                      size: 56,
                      color: Color(0xFFCBD5E1),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Bildirishnoma yo\'q',
                      style: TextStyle(color: GRAY_TEXT),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              color: PRIMARY_BLUE,
              onRefresh:
                  () async => context.read<NotificationBloc>().add(
                    const LoadNotificationsEvent(),
                  ),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: state.notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder:
                    (_, i) =>
                        _NotificationTile(notification: state.notifications[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    return GestureDetector(
      onTap:
          unread
              ? () => context.read<NotificationBloc>().add(
                MarkNotificationsReadEvent(ids: [notification.id]),
              )
              : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unread ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: unread ? const Color(0xFFBFDBFE) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: PRIMARY_BLUE.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: PRIMARY_BLUE,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title.isNotEmpty
                              ? notification.title
                              : 'Bildirishnoma',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                unread ? FontWeight.bold : FontWeight.w600,
                            color: DARK_NAVY,
                          ),
                        ),
                      ),
                      if (notification.timeDisplay.isNotEmpty)
                        Text(
                          notification.timeDisplay,
                          style: const TextStyle(
                            fontSize: 11,
                            color: GRAY_TEXT,
                          ),
                        ),
                    ],
                  ),
                  if (notification.body.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: const TextStyle(
                        fontSize: 13,
                        color: GRAY_TEXT,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (unread) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: PRIMARY_BLUE,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
