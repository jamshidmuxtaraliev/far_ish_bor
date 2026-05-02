import 'package:far_ish_bor/core/locale/locale_cubit.dart';
import 'package:far_ish_bor/core/theme/theme_cubit.dart';
import 'package:far_ish_bor/features/auth/domain/auth_repository/auth_repository.dart';
import 'package:far_ish_bor/features/auth/domain/auth_repository/auth_repository_impl.dart';
import 'package:far_ish_bor/features/auth/presentation/logic/auth_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasource/local/user_local_data_source.dart';
import '../../features/auth/data/datasource/remote/auth_remote_data_source.dart';
import '../network/dio_client.dart';
import 'connection_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDI() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt
    ..registerLazySingleton(() => sharedPreferences)
    ..registerLazySingleton<ThemeCubit>(() => ThemeCubit(getIt()))
    ..registerLazySingleton<LocaleCubit>(() => LocaleCubit(getIt()))
    ..registerLazySingleton<UserLocalDatasource>(() => UserLocalDataSourceImpl(getIt()))
    ..registerLazySingleton(() => DioClient(Dio(), getIt()))
    ..registerLazySingleton<InternetCheckerService>(() => InternetCheckerService())
    ..registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(getIt()))
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt(), getIt()))
    ..registerLazySingleton<AuthBloc>(() => AuthBloc(getIt()));
}
