part of 'notification_bloc.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationsEvent extends NotificationEvent {
  const LoadNotificationsEvent();
}

class LoadUnreadCountEvent extends NotificationEvent {
  const LoadUnreadCountEvent();
}

/// Marks the given notifications read; null = all.
class MarkNotificationsReadEvent extends NotificationEvent {
  final List<int>? ids;
  const MarkNotificationsReadEvent({this.ids});

  @override
  List<Object?> get props => [ids];
}
