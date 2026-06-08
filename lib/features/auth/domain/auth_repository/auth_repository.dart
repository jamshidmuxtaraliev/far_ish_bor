import 'package:dartz/dartz.dart';

import '../../../../core/error/error_model.dart';
import '../../data/models/anketa_models.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<Either<ErrorModel, bool>> sendCode(String phone);
  Future<Either<ErrorModel, AuthResponseModel>> register(Map<String, dynamic> data);
  Future<Either<ErrorModel, AuthResponseModel>> login(String phone, String smsCode);
  Future<Either<ErrorModel, UserModel>> getMe();
  Future<Either<ErrorModel, AnketaModel>> getAnketa();
  Future<Either<ErrorModel, bool>> updateAnketa(Map<String, dynamic> data);
  Future<Either<ErrorModel, List<RegionModel>>> getRegions();
  Future<Either<ErrorModel, List<JobTypeModel>>> getJobTypes({String? text});
  Future<Either<ErrorModel, List<LanguageModel>>> getLanguages();
}
