import 'package:dartz/dartz.dart';
import 'package:jobUp24/features/auth/domain/auth_repository/auth_repository.dart';

import '../../../../../core/error/error_model.dart';
import '../../data/datasource/remote/auth_remote_data_source.dart';
import '../../data/models/anketa_models.dart';
import '../../data/models/auth_flow_models.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/employer_model.dart';
import '../../data/models/resume_model.dart';
import '../../data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<ErrorModel, CheckPhoneModel>> checkPhone(String phone) =>
      remoteDataSource.checkPhone(phone);

  @override
  Future<Either<ErrorModel, SendCodeModel>> sendCode(String phone, {String? channel}) =>
      remoteDataSource.sendCode(phone, channel: channel);

  @override
  Future<Either<ErrorModel, VerifyCodeModel>> verifyCode(String phone, String smsCode) =>
      remoteDataSource.verifyCode(phone, smsCode);

  @override
  Future<Either<ErrorModel, AuthResponseModel>> register(Map<String, dynamic> data) =>
      remoteDataSource.register(data);

  @override
  Future<Either<ErrorModel, AuthResponseModel>> login(String phone, {String? smsCode, String? regToken}) =>
      remoteDataSource.login(phone, smsCode: smsCode, regToken: regToken);

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
  Future<Either<ErrorModel, List<BranchModel>>> getBranches() =>
      remoteDataSource.getBranches();

  @override
  Future<Either<ErrorModel, BranchModel>> createBranch(Map<String, dynamic> data) =>
      remoteDataSource.createBranch(data);

  @override
  Future<Either<ErrorModel, BranchModel>> updateBranch(int id, Map<String, dynamic> data) =>
      remoteDataSource.updateBranch(id, data);

  @override
  Future<Either<ErrorModel, bool>> deleteBranch(int id) =>
      remoteDataSource.deleteBranch(id);

  @override
  Future<Either<ErrorModel, String>> uploadLogo(String filePath) =>
      remoteDataSource.uploadLogo(filePath);

  @override
  Future<Either<ErrorModel, String>> uploadPhoto(String filePath) =>
      remoteDataSource.uploadPhoto(filePath);

  @override
  Future<Either<ErrorModel, ResumeInfoModel>> getResumeInfo() =>
      remoteDataSource.getResumeInfo();

  @override
  Future<Either<ErrorModel, String>> downloadResume(
    String url,
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) =>
      remoteDataSource.downloadResume(url, savePath, onProgress: onProgress);

  @override
  Future<Either<ErrorModel, String>> downloadResumeDirect(
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) =>
      remoteDataSource.downloadResumeDirect(savePath, onProgress: onProgress);
}
