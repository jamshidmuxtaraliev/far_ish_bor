import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jobUp24/core/network/dio_response_extension.dart';

import '../../../../../core/error/error_model.dart';
import '../../../../../core/network/dio_client.dart';
import '../../models/anketa_models.dart';
import '../../models/auth_response_model.dart';
import '../../models/employer_model.dart';
import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Either<ErrorModel, bool>> sendCode(String phone);
  Future<Either<ErrorModel, AuthResponseModel>> register(Map<String, dynamic> data);
  Future<Either<ErrorModel, AuthResponseModel>> login(String phone, String smsCode);
  Future<Either<ErrorModel, UserModel>> getMe();
  Future<Either<ErrorModel, AnketaModel>> getAnketa();
  Future<Either<ErrorModel, bool>> updateAnketa(Map<String, dynamic> data);
  Future<Either<ErrorModel, List<RegionModel>>> getRegions();
  Future<Either<ErrorModel, List<JobTypeModel>>> getJobTypes({String? text});
  Future<Either<ErrorModel, List<LanguageModel>>> getLanguages();
  Future<Either<ErrorModel, EmployerModel>> getEmployer();
  Future<Either<ErrorModel, EmployerModel>> updateEmployer(Map<String, dynamic> data);
  Future<Either<ErrorModel, String>> uploadLogo(String filePath);
  Future<Either<ErrorModel, String>> uploadPhoto(String filePath);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<Either<ErrorModel, bool>> sendCode(String phone) {
    return dioClient.dio.wrapResponse<bool>(
      () => dioClient.dio.post('mobile/send-code', data: {'phone': phone}),
      (_) => true,
    );
  }

  @override
  Future<Either<ErrorModel, AuthResponseModel>> register(Map<String, dynamic> data) {
    return dioClient.dio.wrapResponse<AuthResponseModel>(
      () => dioClient.dio.post('mobile/register', data: data),
      (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<ErrorModel, AuthResponseModel>> login(String phone, String smsCode) {
    return dioClient.dio.wrapResponse<AuthResponseModel>(
      () => dioClient.dio.post('mobile/login', data: {'phone': phone, 'sms_code': smsCode}),
      (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<ErrorModel, UserModel>> getMe() {
    return dioClient.dio.wrapResponse<UserModel>(
      () => dioClient.dio.get('mobile/me'),
      (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<ErrorModel, AnketaModel>> getAnketa() {
    return dioClient.dio.wrapResponse<AnketaModel>(
      () => dioClient.dio.get('mobile/anketa/me'),
      (json) => AnketaModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<ErrorModel, bool>> updateAnketa(Map<String, dynamic> data) {
    return dioClient.dio.wrapResponse<bool>(
      () => dioClient.dio.post('mobile/anketa', data: data),
      (_) => true,
    );
  }

  @override
  Future<Either<ErrorModel, List<RegionModel>>> getRegions() {
    return dioClient.dio.wrapResponse<List<RegionModel>>(
      () => dioClient.dio.get('mobile/regions'),
      (json) => (json as List).map((e) => RegionModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  @override
  Future<Either<ErrorModel, List<JobTypeModel>>> getJobTypes({String? text}) {
    return dioClient.dio.wrapResponse<List<JobTypeModel>>(
      () => dioClient.dio.get('mobile/job-types', queryParameters: text != null ? {'text': text} : null),
      (json) => (json as List).map((e) => JobTypeModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  @override
  Future<Either<ErrorModel, List<LanguageModel>>> getLanguages() {
    return dioClient.dio.wrapResponse<List<LanguageModel>>(
      () => dioClient.dio.get('mobile/languages'),
      (json) => (json as List).map((e) => LanguageModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  @override
  Future<Either<ErrorModel, EmployerModel>> getEmployer() {
    return dioClient.dio.wrapResponse<EmployerModel>(
      () => dioClient.dio.get('mobile/employer/me'),
      (json) => EmployerModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<ErrorModel, EmployerModel>> updateEmployer(Map<String, dynamic> data) {
    return dioClient.dio.wrapResponse<EmployerModel>(
      () => dioClient.dio.post('mobile/employer', data: data),
      (json) => EmployerModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<ErrorModel, String>> uploadLogo(String filePath) {
    return dioClient.dio.wrapResponse<String>(
      () async {
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
            filePath,
            filename: filePath.split('/').last,
          ),
        });
        return dioClient.dio.post(
          'mobile/employer/logo',
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );
      },
      (json) => (json as Map<String, dynamic>)['logo'] as String,
    );
  }

  @override
  Future<Either<ErrorModel, String>> uploadPhoto(String filePath) {
    return dioClient.dio.wrapResponse<String>(
      () async {
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
            filePath,
            filename: filePath.split('/').last,
          ),
        });
        return dioClient.dio.post(
          'mobile/anketa/photo',
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );
      },
      (json) => (json as Map<String, dynamic>)['photo'] as String,
    );
  }
}
