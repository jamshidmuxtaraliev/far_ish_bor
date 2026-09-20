import 'package:dartz/dartz.dart';

import '../../../../core/error/error_model.dart';
import '../../data/models/anketa_models.dart';
import '../../data/models/auth_flow_models.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/employer_model.dart';
import '../../data/models/public_stats_model.dart';
import '../../data/models/resume_model.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<Either<ErrorModel, CheckPhoneModel>> checkPhone(String phone);
  Future<Either<ErrorModel, SendCodeModel>> sendCode(String phone, {String? channel});
  Future<Either<ErrorModel, VerifyCodeModel>> verifyCode(String phone, String smsCode);
  Future<Either<ErrorModel, AuthResponseModel>> register(Map<String, dynamic> data);
  Future<Either<ErrorModel, AuthResponseModel>> login(String phone, {String? smsCode, String? regToken});
  Future<Either<ErrorModel, UserModel>> getMe();
  Future<Either<ErrorModel, PublicStatsModel>> getPublicStats();
  Future<Either<ErrorModel, bool>> registerPushToken(String token, String platform);
  Future<Either<ErrorModel, bool>> unregisterPushToken();
  Future<Either<ErrorModel, AnketaModel>> getAnketa();
  Future<Either<ErrorModel, bool>> updateAnketa(Map<String, dynamic> data);
  Future<Either<ErrorModel, List<RegionModel>>> getRegions();
  Future<Either<ErrorModel, List<JobTypeModel>>> getJobTypes({String? text});
  Future<Either<ErrorModel, List<LanguageModel>>> getLanguages();
  Future<Either<ErrorModel, EmployerModel>> getEmployer();
  Future<Either<ErrorModel, EmployerModel>> updateEmployer(Map<String, dynamic> data);
  Future<Either<ErrorModel, List<BranchModel>>> getBranches();
  Future<Either<ErrorModel, BranchModel>> createBranch(Map<String, dynamic> data);
  Future<Either<ErrorModel, BranchModel>> updateBranch(int id, Map<String, dynamic> data);
  Future<Either<ErrorModel, bool>> deleteBranch(int id);
  Future<Either<ErrorModel, String>> uploadLogo(String filePath);
  Future<Either<ErrorModel, String>> uploadPhoto(String filePath);
  Future<Either<ErrorModel, ResumeInfoModel>> getResumeInfo();
  Future<Either<ErrorModel, String>> downloadResume(
    String url,
    String savePath, {
    void Function(int received, int total)? onProgress,
  });
  Future<Either<ErrorModel, String>> downloadResumeDirect(
    String savePath, {
    void Function(int received, int total)? onProgress,
  });
}
