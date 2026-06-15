import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../../../core/error/error_model.dart';
import '../../data/datasource/remote/notification_remote_data_source.dart';
import '../../data/models/notification_model.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRemoteDataSource dataSource;

  NotificationBloc(this.dataSource) : super(const NotificationState()) {
    on<LoadNotificationsEvent>(_onLoad);
    on<LoadUnreadCountEvent>(_onLoadUnread);
    on<MarkNotificationsReadEvent>(_onMarkRead);
  }

  Future<void> _onLoad(
    LoadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    final result = await dataSource.getNotifications();
    result.fold(
      (failure) => emit(
        state.copyWith(status: FormzSubmissionStatus.failure, error: failure),
      ),
      (list) => emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          notifications: list,
          unreadCount: list.where((n) => !n.isRead).length,
        ),
      ),
    );
  }

  Future<void> _onLoadUnread(
    LoadUnreadCountEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await dataSource.getUnreadCount();
    result.fold((_) {}, (count) => emit(state.copyWith(unreadCount: count)));
  }

  Future<void> _onMarkRead(
    MarkNotificationsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await dataSource.markRead(ids: event.ids);
    result.fold((_) {}, (_) {
      final updated =
          state.notifications.map((n) {
            if (event.ids == null || event.ids!.contains(n.id)) {
              return NotificationModel(
                id: n.id,
                title: n.title,
                body: n.body,
                type: n.type,
                isRead: true,
                createdAt: n.createdAt,
              );
            }
            return n;
          }).toList();
      emit(
        state.copyWith(
          notifications: updated,
          unreadCount: updated.where((n) => !n.isRead).length,
        ),
      );
    });
  }
}
