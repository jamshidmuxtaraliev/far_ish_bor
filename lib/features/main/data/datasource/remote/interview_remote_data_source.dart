import 'package:dartz/dartz.dart';
import 'package:jobUp24/core/network/dio_response_extension.dart';

import '../../../../../core/error/error_model.dart';
import '../../../../../core/network/dio_client.dart';
import '../../models/interview_model.dart';

/// Suhbatlar REST qatlami (PROMPT_SUHBATLAR_MOBILE.md §4).
abstract class InterviewRemoteDataSource {
  /// Seeker: mening kelgusi suhbatlarim.
  Future<Either<ErrorModel, List<InterviewModel>>> getMyInterviews();

  /// Seeker: yo'l holatini boshqarish (on_way | arrived | stopped).
  Future<Either<ErrorModel, bool>> updateTravelStatus(
    int interviewId,
    String travelStatus,
  );

  /// Employer: rejalashtirilgan suhbatlar.
  Future<Either<ErrorModel, List<InterviewModel>>> getEmployerInterviews();

  /// Employer: hozir yo'lda (on_way) bo'lganlar + oxirgi koordinata (tiklash).
  Future<Either<ErrorModel, List<InterviewModel>>> getLiveInterviews();
}

class InterviewRemoteDataSourceImpl implements InterviewRemoteDataSource {
  final DioClient dioClient;

  InterviewRemoteDataSourceImpl(this.dioClient);

  @override
  Future<Either<ErrorModel, List<InterviewModel>>> getMyInterviews() {
    return dioClient.dio.wrapResponse<List<InterviewModel>>(
      () => dioClient.dio.get('mobile/interviews/me'),
      (json) => (json as List)
          .map((e) => InterviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<Either<ErrorModel, bool>> updateTravelStatus(
    int interviewId,
    String travelStatus,
  ) {
    return dioClient.dio.wrapResponse<bool>(
      () => dioClient.dio.patch(
        'mobile/interviews/$interviewId/travel',
        data: {'travel_status': travelStatus},
      ),
      (_) => true,
    );
  }

  @override
  Future<Either<ErrorModel, List<InterviewModel>>> getEmployerInterviews() {
    return dioClient.dio.wrapResponse<List<InterviewModel>>(
      () => dioClient.dio.get('mobile/employer/interviews'),
      (json) => (json as List)
          .map((e) => InterviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<Either<ErrorModel, List<InterviewModel>>> getLiveInterviews() {
    return dioClient.dio.wrapResponse<List<InterviewModel>>(
      () => dioClient.dio.get('mobile/employer/interviews/live'),
      (json) => (json as List)
          .map((e) => InterviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
