part of 'notification_bloc.dart';

class NotificationState extends Equatable {
  final List<NotificationModel> notifications;
  final FormzSubmissionStatus status;
  final int unreadCount;
  final ErrorModel? error;

  const NotificationState({
    this.notifications = const [],
    this.status = FormzSubmissionStatus.initial,
    this.unreadCount = 0,
    this.error,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    FormzSubmissionStatus? status,
    int? unreadCount,
    ErrorModel? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      status: status ?? this.status,
      unreadCount: unreadCount ?? this.unreadCount,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [notifications, status, unreadCount, error];
}
