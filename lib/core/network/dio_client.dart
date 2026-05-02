import 'package:dio/dio.dart';

import '../../features/auth/data/datasource/local/user_local_data_source.dart';
import '../constants/constants.dart';

class DioClient {
  final Dio _dio;
  final UserLocalDatasource userLocalDatasource;

  DioClient(this._dio, this.userLocalDatasource) {
    _dio.options.baseUrl = BASE_URL;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.headers.addAll({'Content-Type': 'application/json', 'Connection': "keep-alive"});
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = "Bearer ${userLocalDatasource.getToken()}";
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
