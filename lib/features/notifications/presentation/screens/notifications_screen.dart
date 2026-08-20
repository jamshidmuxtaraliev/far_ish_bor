import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/theme/jb_ui.dart';
import '../../data/models/notification_model.dart';
import '../logic/notification_bloc.dart';
import '../../../../core/theme/jb_palette.dart';

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
      value: context.jb.overlay,
      child: Scaffold(
        backgroundColor: context.jb.bg,
        appBar: AppBar(
          backgroundColor: context.jb.card,
          foregroundColor: context.jb.ink,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'Bildirishnomalar',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: context.jb.ink),
          ),
          actions: [
            BlocBuilder<NotificationBloc, NotificationState>(
              buildWhen: (p, c) => p.unreadCount != c.unreadCount,
              builder: (context, state) {
                if (state.unreadCount == 0) return const SizedBox.shrink();
                return TextButton(
                  onPressed: _markAllRead,
                  child: Text(
                    "O'qildi",
                    style: TextStyle(color: context.jb.blue, fontWeight: FontWeight.w600),
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
              return Center(
                child: CircularProgressIndicator(color: context.jb.blue),
              );
            }
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 56,
                      color: context.jb.borderStrong,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Bildirishnoma yo\'q',
                      style: TextStyle(color: context.jb.gray),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              color: context.jb.blue,
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
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: unread ? context.jb.blueTint : context.jb.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unread ? context.jb.blueTint : context.jb.border,
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const JBIconTile(icon: Icons.notifications_none_rounded, size: 40, radius: 12, iconSize: 18),
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
                                unread ? FontWeight.w700 : FontWeight.w600,
                            color: context.jb.ink,
                          ),
                        ),
                      ),
                      if (notification.timeDisplay.isNotEmpty)
                        Text(
                          notification.timeDisplay,
                          style: TextStyle(
                            fontSize: 11,
                            color: context.jb.gray,
                          ),
                        ),
                    ],
                  ),
                  if (notification.body.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.jb.gray,
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
                decoration: BoxDecoration(
                  color: context.jb.blue,
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
