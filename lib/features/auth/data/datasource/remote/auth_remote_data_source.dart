import 'package:far_ish_bor/core/network/dio_response_extension.dart';
import 'package:dartz/dartz.dart';

import '../../../../../core/error/error_model.dart';
import '../../../../../core/network/dio_client.dart';
import '../../models/signin_params.dart';
import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Either<ErrorModel, UserModel>> signIn(SignInParams params);

  Future<Either<ErrorModel, UserModel>> getUser(String fcmToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<Either<ErrorModel, UserModel>> signIn(SignInParams params) async {
    return dioClient.dio.wrapResponse<UserModel>(
      () => dioClient.dio.post("/auth/sign-in", data: {'email': params.username, 'password': params.password}),
      (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<ErrorModel, UserModel>> getUser(String fcmToken) async {
    return dioClient.dio.wrapResponse<UserModel>(
      () => dioClient.dio.get("/users/me", queryParameters: {"fcmToken": fcmToken}),
      (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
