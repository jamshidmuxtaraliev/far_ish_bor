import 'package:far_ish_bor/features/auth/domain/auth_repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../../core/error/error_model.dart';
import '../../data/datasource/local/user_local_data_source.dart';
import '../../data/datasource/remote/auth_remote_data_source.dart';
import '../../data/models/signin_params.dart';
import '../../data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final UserLocalDatasource localDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<ErrorModel, UserModel>> signIn(SignInParams params) async {
    return await remoteDataSource.signIn(params);
  }



  @override
  Future<Either<ErrorModel, UserModel>> getUser(String fcmToken) async {
    return await remoteDataSource.getUser(fcmToken);
  }
}
