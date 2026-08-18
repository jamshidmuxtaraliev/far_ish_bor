import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jobUp24/core/network/dio_response_extension.dart';

import '../../../../../core/error/error_model.dart';
import '../../../../../core/network/dio_client.dart';
import '../../models/anketa_models.dart';
import '../../models/auth_response_model.dart';
import '../../models/employer_model.dart';
import '../../models/resume_model.dart';
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
  Future<Either<ErrorModel, ResumeInfoModel>> getResumeInfo();
  Future<Either<ErrorModel, String>> downloadResume(
    String url,
    String savePath, {
    void Function(int received, int total)? onProgress,
  });

  /// Zaxira yo'l: bitta so'rovda token bilan xom PDF baytlarini oladi.
  Future<Either<ErrorModel, String>> downloadResumeDirect(
    String savePath, {
    void Function(int received, int total)? onProgress,
  });
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

  @override
  Future<Either<ErrorModel, ResumeInfoModel>> getResumeInfo() {
    return dioClient.dio.wrapResponse<ResumeInfoModel>(
      () => dioClient.dio.get('mobile/anketa/resume'),
      (json) => ResumeInfoModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<ErrorModel, String>> downloadResume(
    String url,
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) async {
    // Havola tokensiz ochiladi va javob — xom PDF baytlari. Shuning uchun
    // konvertni yechadigan interceptorlar aralashmasligi kerak: toza Dio.
    try {
      await Dio().download(
        url,
        savePath,
        onReceiveProgress: onProgress,
        options: Options(receiveTimeout: const Duration(seconds: 60)),
      );
      return Right(savePath);
    } on DioException catch (e) {
      return Left(ErrorModel(
        e.response?.statusCode == 404
            ? 'Rezyume fayli topilmadi, qaytadan urinib ko\'ring'
            : (e.message ?? 'Faylni yuklab bo\'lmadi'),
        errorCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ErrorModel('Faylni saqlashda xatolik: $e', errorCode: -1));
    }
  }

  @override
  Future<Either<ErrorModel, String>> downloadResumeDirect(
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      final response = await dioClient.dio.get<List<int>>(
        'mobile/anketa/resume.pdf',
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 60),
        ),
        onReceiveProgress: onProgress,
      );

      final bytes = response.data ?? const <int>[];
      final contentType = response.headers.value(Headers.contentTypeHeader) ?? '';

      // Xato bo'lsa PDF emas, odatdagi JSON konverti keladi.
      if (!contentType.contains('application/pdf')) {
        return Left(_parseErrorEnvelope(bytes));
      }

      await File(savePath).writeAsBytes(bytes);
      return Right(savePath);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is List<int>) return Left(_parseErrorEnvelope(data));
      return Left(ErrorModel(
        e.message ?? 'Rezyumeni olib bo\'lmadi',
        errorCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ErrorModel('Faylni saqlashda xatolik: $e', errorCode: -1));
    }
  }

  ErrorModel _parseErrorEnvelope(List<int> bytes) {
    try {
      final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      return ErrorModel(
        json['message'] as String? ?? 'Rezyumeni olib bo\'lmadi',
        errorCode: json['error_code'] as int?,
      );
    } catch (_) {
      return ErrorModel('Rezyumeni olib bo\'lmadi', errorCode: -1);
    }
  }
}
