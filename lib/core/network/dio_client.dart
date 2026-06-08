import 'package:dio/dio.dart';
import 'package:flutter_alice/alice.dart';

import '../../features/auth/data/datasource/local/user_local_data_source.dart';
import '../constants/constants.dart';

class DioClient {
  final Dio _dio;
  final UserLocalDatasource userLocalDatasource;

  DioClient(this._dio, this.userLocalDatasource, Alice alice) {
    _dio.options.baseUrl = BASE_URL;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.headers.addAll({'Content-Type': 'application/json', 'Connection': "keep-alive"});
    _dio.interceptors.add(alice.getDioInterceptor());
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = userLocalDatasource.getToken();
          options.headers['Authorization'] = "Bearer $token";
          options.headers['token'] = token;
          options.headers['X-Client'] = 'mobile';
          options.headers['Accept-Language'] = userLocalDatasource.getLang();
          return handler.next(options);
        },
      ),
    );
  }

  Dio get dio {
    return _dio;
  }
}
