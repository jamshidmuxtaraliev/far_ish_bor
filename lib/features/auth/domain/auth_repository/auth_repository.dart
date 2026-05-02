import 'package:dartz/dartz.dart';

import '../../../../core/error/error_model.dart';
import '../../data/models/signin_params.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<Either<ErrorModel, UserModel>> signIn(SignInParams params);

  Future<Either<ErrorModel, UserModel>> getUser(String fcmToken);

}
