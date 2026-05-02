import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../error/base_model.dart';
import '../error/error_model.dart';

extension DioWrapper on Dio {
  Future<Either<ErrorModel, T>> wrapResponse<T>(Future<Response> Function() request, T Function(Object? json) fromJsonT) async {
    try {
      final response = await request();
      return _parseBaseModel<T>(response.data, fromJsonT);
    } on DioException catch (dioError) {
      final data = dioError.response?.data;
      if (data is Map<String, dynamic>) {
        try {
          final base = BaseData<T?>.fromJson(data, (_) => null);
          return Left(ErrorModel(errorCode: base.error_code, base.message ?? 'Xatolik yuz berdi'));
        } catch (_) {
          return Left(ErrorModel(errorCode: dioError.response?.statusCode, 'BaseModel parse bo‘lmadi'));
        }
      } else {
        return Left(ErrorModel(errorCode: dioError.response?.statusCode, dioError.message ?? 'Tarmoq xatoligi'));
      }
    } catch (e) {
      return Left(ErrorModel(errorCode: -1, 'Kutilmagan xatolik: ${e.toString()}'));
    }
  }

  Either<ErrorModel, T> _parseBaseModel<T>(dynamic data, T Function(Object? json) fromJsonT) {
    try {
      if (data is Map<String, dynamic>) {
        final baseModel = BaseData<T>.fromJson(data, fromJsonT);
        if (baseModel.error) {
          return Left(ErrorModel(errorCode: baseModel.error_code, baseModel.message ?? 'Xatolik mavjud'));
        }
        if (baseModel.data == null && (200 <= (baseModel.error_code ?? 200) && (baseModel.error_code ?? 200) < 300)) {
          return Right(true as T);
        }
        return Right(baseModel.data!);
      } else {
        return Left(ErrorModel(errorCode: -1, 'Yaroqsiz formatdagi javob'));
      }
    } catch (e) {
      return Left(ErrorModel(errorCode: -1, 'fromJson parse xatosi: ${e.toString()}'));
    }
  }
}
