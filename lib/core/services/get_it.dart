import 'package:dio/dio.dart';
import 'package:flutter_alice/alice.dart';
import 'package:jobUp24/core/locale/locale_cubit.dart';
import 'package:jobUp24/core/theme/theme_cubit.dart';
import 'package:jobUp24/features/auth/domain/auth_repository/auth_repository.dart';
import 'package:jobUp24/features/auth/domain/auth_repository/auth_repository_impl.dart';
import 'package:jobUp24/features/auth/presentation/logic/auth_bloc.dart';
import 'package:jobUp24/features/billing/data/datasource/remote/billing_remote_data_source.dart';
import 'package:jobUp24/features/billing/presentation/logic/billing_bloc.dart';
import 'package:jobUp24/features/chat/data/datasource/chat_realtime_datasource.dart';
import 'package:jobUp24/features/chat/presentation/logic/chat_bloc.dart';
import 'package:jobUp24/features/faq/data/datasource/remote/faq_remote_data_source.dart';
import 'package:jobUp24/features/faq/presentation/logic/faq_bloc.dart';
import 'package:jobUp24/features/notifications/data/datasource/remote/notification_remote_data_source.dart';
import 'package:jobUp24/features/notifications/presentation/logic/notification_bloc.dart';
import 'package:jobUp24/features/main/data/datasource/interview_realtime_datasource.dart';
import 'package:jobUp24/features/main/data/datasource/remote/interview_remote_data_source.dart';
import 'package:jobUp24/features/main/data/datasource/remote/vacancy_remote_data_source.dart';
import 'package:jobUp24/features/main/presentation/logic/interview_bloc.dart';
import 'package:jobUp24/features/main/presentation/logic/vacancy_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasource/local/user_local_data_source.dart';
import '../../features/auth/data/datasource/remote/auth_remote_data_source.dart';
import '../network/dio_client.dart';
import 'connection_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDI({required Alice alice}) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt
    ..registerLazySingleton(() => sharedPreferences)
    ..registerLazySingleton<ThemeCubit>(() => ThemeCubit(getIt()))
    ..registerLazySingleton<LocaleCubit>(() => LocaleCubit(getIt()))
    ..registerLazySingleton<UserLocalDatasource>(
      () => UserLocalDataSourceImpl(getIt()),
    )
    ..registerLazySingleton(() => DioClient(Dio(), getIt(), alice))
    ..registerLazySingleton<InternetCheckerService>(
      () => InternetCheckerService(),
    )
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()))
    ..registerLazySingleton<AuthBloc>(() => AuthBloc(getIt()))
    ..registerLazySingleton<VacancyRemoteDataSource>(
      () => VacancyRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<VacancyBloc>(() => VacancyBloc(getIt()))
    ..registerLazySingleton<InterviewRemoteDataSource>(
      () => InterviewRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<InterviewRealtimeDatasource>(
      () => InterviewRealtimeDatasource(),
    )
    ..registerLazySingleton<InterviewBloc>(
      () => InterviewBloc(getIt(), getIt()),
    )
    ..registerLazySingleton<BillingRemoteDataSource>(
      () => BillingRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<BillingBloc>(() => BillingBloc(getIt()))
    ..registerLazySingleton<ChatRealtimeDatasource>(
      () => ChatRealtimeDatasource(),
    )
    ..registerLazySingleton<ChatBloc>(() => ChatBloc(getIt()))
    ..registerLazySingleton<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<NotificationBloc>(() => NotificationBloc(getIt()))
    ..registerLazySingleton<FaqRemoteDataSource>(
      () => FaqRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<FaqBloc>(() => FaqBloc(getIt()));
}
