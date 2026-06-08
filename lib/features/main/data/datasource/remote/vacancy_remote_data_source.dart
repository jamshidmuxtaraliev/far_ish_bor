import 'package:dartz/dartz.dart';
import 'package:far_ish_bor/core/network/dio_response_extension.dart';

import '../../../../../core/error/error_model.dart';
import '../../../../../core/network/dio_client.dart';
import '../../models/application_model.dart';
import '../../models/candidate_model.dart';
import '../../models/create_vacancy_request.dart';
import '../../models/employer_application_model.dart';
import '../../models/employer_vacancy_model.dart';
import '../../models/saved_vacancy_model.dart';
import '../../models/vacancy_model.dart';

abstract class VacancyRemoteDataSource {
  // Seeker
  Future<Either<ErrorModel, List<VacancyModel>>> getSeekerVacancies({int? jobTypeId, int? regionId});
  Future<Either<ErrorModel, bool>> applyVacancy(int vacancyId, {String? coverMessage});
  Future<Either<ErrorModel, List<ApplicationModel>>> getMyApplications();
  Future<Either<ErrorModel, bool>> updateApplicationStatus(int applicationId, String status);
  // Saved vacancies
  Future<Either<ErrorModel, List<SavedVacancyModel>>> getSavedVacancies(int mobileUserId);
  Future<Either<ErrorModel, bool>> saveVacancy(int mobileUserId, int vacancyId);
  Future<Either<ErrorModel, bool>> unsaveVacancy(int mobileUserId, int vacancyId);
  // Employer
  Future<Either<ErrorModel, List<EmployerVacancyModel>>> getEmployerVacancies();
  Future<Either<ErrorModel, bool>> createOrUpdateVacancy(CreateVacancyRequest request);
  Future<Either<ErrorModel, bool>> deleteVacancy(int id);
  Future<Either<ErrorModel, List<CandidateModel>>> getCandidates();
  Future<Either<ErrorModel, List<EmployerApplicationModel>>> getEmployerApplications();
  Future<Either<ErrorModel, bool>> updateEmployerApplicationStatus(
    int applicationId,
    String status, {
    String? interviewDatetime,
    String? type,
  });
}

class VacancyRemoteDataSourceImpl implements VacancyRemoteDataSource {
  final DioClient dioClient;

  VacancyRemoteDataSourceImpl(this.dioClient);

  @override
  Future<Either<ErrorModel, List<VacancyModel>>> getSeekerVacancies({int? jobTypeId, int? regionId}) {
    final params = <String, dynamic>{};
    if (jobTypeId != null) params['job_type_id'] = jobTypeId;
    if (regionId != null) params['region_id'] = regionId;
    return dioClient.dio.wrapResponse<List<VacancyModel>>(
      () => dioClient.dio.get('mobile/vacancies', queryParameters: params.isNotEmpty ? params : null),
      (json) => (json as List).map((e) => VacancyModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  @override
  Future<Either<ErrorModel, bool>> applyVacancy(int vacancyId, {String? coverMessage}) {
    final data = <String, dynamic>{'vacancy_id': vacancyId};
    if (coverMessage != null && coverMessage.isNotEmpty) data['cover_message'] = coverMessage;
    return dioClient.dio.wrapResponse<bool>(
      () => dioClient.dio.post('mobile/applications', data: data),
      (_) => true,
    );
  }

  @override
  Future<Either<ErrorModel, List<EmployerVacancyModel>>> getEmployerVacancies() {
    return dioClient.dio.wrapResponse<List<EmployerVacancyModel>>(
      () => dioClient.dio.get('mobile/employer/vacancies'),
      (json) => (json as List).map((e) => EmployerVacancyModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  @override
  Future<Either<ErrorModel, bool>> createOrUpdateVacancy(CreateVacancyRequest request) {
    return dioClient.dio.wrapResponse<bool>(
      () => dioClient.dio.post('mobile/employer/vacancies', data: request.toJson()),
      (_) => true,
    );
  }

  @override
  Future<Either<ErrorModel, bool>> deleteVacancy(int id) {
    return dioClient.dio.wrapResponse<bool>(
      () => dioClient.dio.delete('mobile/employer/vacancies/$id'),
      (_) => true,
    );
  }

  @override
  Future<Either<ErrorModel, List<CandidateModel>>> getCandidates() {
    return dioClient.dio.wrapResponse<List<CandidateModel>>(
      () => dioClient.dio.get('mobile/employer/candidates'),
      (json) => (json as List).map((e) => CandidateModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  @override
  Future<Either<ErrorModel, List<ApplicationModel>>> getMyApplications() {
    return dioClient.dio.wrapResponse<List<ApplicationModel>>(
      () => dioClient.dio.get('mobile/applications/me'),
      (json) => (json as List).map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  @override
  Future<Either<ErrorModel, bool>> updateApplicationStatus(int applicationId, String status) {
    return dioClient.dio.wrapResponse<bool>(
      () => dioClient.dio.patch('mobile/applications/$applicationId/status', data: {'status': status}),
      (_) => true,
    );
  }

  @override
  Future<Either<ErrorModel, List<SavedVacancyModel>>> getSavedVacancies(int mobileUserId) {
    return dioClient.dio.wrapResponse<List<SavedVacancyModel>>(
      () => dioClient.dio.get('saved-vacancy/by-user/$mobileUserId'),
      (json) => (json as List).map((e) => SavedVacancyModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  @override
  Future<Either<ErrorModel, bool>> saveVacancy(int mobileUserId, int vacancyId) {
    return dioClient.dio.wrapResponse<bool>(
      () => dioClient.dio.post('saved-vacancy/save', data: {'mobile_user_id': mobileUserId, 'vacancy_id': vacancyId}),
      (_) => true,
    );
  }

  @override
  Future<Either<ErrorModel, bool>> unsaveVacancy(int mobileUserId, int vacancyId) {
    return dioClient.dio.wrapResponse<bool>(
      () => dioClient.dio.delete('saved-vacancy/unsave', data: {'mobile_user_id': mobileUserId, 'vacancy_id': vacancyId}),
      (_) => true,
    );
  }

  @override
  Future<Either<ErrorModel, List<EmployerApplicationModel>>> getEmployerApplications() {
    return dioClient.dio.wrapResponse<List<EmployerApplicationModel>>(
      () => dioClient.dio.get('mobile/employer/applications'),
      (json) => (json as List).map((e) => EmployerApplicationModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  @override
  Future<Either<ErrorModel, bool>> updateEmployerApplicationStatus(
    int applicationId,
    String status, {
    String? interviewDatetime,
    String? type,
  }) {
    final data = <String, dynamic>{'status': status};
    if (interviewDatetime != null) data['interview_datetime'] = interviewDatetime;
    if (type != null) data['type'] = type;
    return dioClient.dio.wrapResponse<bool>(
      () => dioClient.dio.patch('mobile/employer/applications/$applicationId', data: data),
      (_) => true,
    );
  }
}
