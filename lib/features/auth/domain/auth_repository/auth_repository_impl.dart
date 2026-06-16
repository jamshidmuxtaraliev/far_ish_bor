import 'package:dartz/dartz.dart';
import 'package:far_ish_bor/features/auth/domain/auth_repository/auth_repository.dart';

import '../../../../../core/error/error_model.dart';
import '../../data/datasource/remote/auth_remote_data_source.dart';
import '../../data/models/anketa_models.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/employer_model.dart';
import '../../data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<ErrorModel, bool>> sendCode(String phone) =>
      remoteDataSource.sendCode(phone);

  @override
  Future<Either<ErrorModel, AuthResponseModel>> register(Map<String, dynamic> data) =>
      remoteDataSource.register(data);

  @override
  Future<Either<ErrorModel, AuthResponseModel>> login(String phone, String smsCode) =>
      remoteDataSource.login(phone, smsCode);

  @override
  Future<Either<ErrorModel, UserModel>> getMe() =>
      remoteDataSource.getMe();

  @override
  Future<Either<ErrorModel, AnketaModel>> getAnketa() =>
      remoteDataSource.getAnketa();

  @override
  Future<Either<ErrorModel, bool>> updateAnketa(Map<String, dynamic> data) =>
      remoteDataSource.updateAnketa(data);

  @override
  Future<Either<ErrorModel, List<RegionModel>>> getRegions() =>
      remoteDataSource.getRegions();

  @override
  Future<Either<ErrorModel, List<JobTypeModel>>> getJobTypes({String? text}) =>
      remoteDataSource.getJobTypes(text: text);

  @override
  Future<Either<ErrorModel, List<LanguageModel>>> getLanguages() =>
      remoteDataSource.getLanguages();

  @override
  Future<Either<ErrorModel, EmployerModel>> getEmployer() =>
      remoteDataSource.getEmployer();

  @override
  Future<Either<ErrorModel, EmployerModel>> updateEmployer(Map<String, dynamic> data) =>
      remoteDataSource.updateEmployer(data);

  @override
  Future<Either<ErrorModel, String>> uploadLogo(String filePath) =>
      remoteDataSource.uploadLogo(filePath);
}
