import 'package:dartz/dartz.dart';

import '../../../../../core/error/error_model.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/network/dio_response_extension.dart';
import '../../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<Either<ErrorModel, List<NotificationModel>>> getNotifications();
  Future<Either<ErrorModel, int>> getUnreadCount();

  /// Marks notifications read. Passing null/empty marks all as read.
  Future<Either<ErrorModel, bool>> markRead({List<int>? ids});
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient dioClient;

  NotificationRemoteDataSourceImpl(this.dioClient);

  @override
  Future<Either<ErrorModel, List<NotificationModel>>> getNotifications() {
    return dioClient.dio.wrapResponse<List<NotificationModel>>(
      () => dioClient.dio.get('mobile/notifications'),
      (json) =>
          (json as List)
              .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  @override
  Future<Either<ErrorModel, int>> getUnreadCount() {
    return dioClient.dio.wrapResponse<int>(
      () => dioClient.dio.get('mobile/notifications/unread-count'),
      (json) {
        if (json is int) return json;
        if (json is Map) {
          return json['count'] as int? ?? json['unread'] as int? ?? 0;
        }
        return 0;
      },
    );
  }

  @override
  Future<Either<ErrorModel, bool>> markRead({List<int>? ids}) {
    final data = <String, dynamic>{};
    if (ids != null && ids.isNotEmpty) data['ids'] = ids;
    return dioClient.dio.wrapResponse<bool>(
      () => dioClient.dio.post('mobile/notifications/mark-read', data: data),
      (_) => true,
    );
  }
}
