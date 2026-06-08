import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../error/base_model.dart';
import '../error/error_model.dart';

extension DioWrapper on Dio {
  Future<Either<ErrorModel, T>> wrapResponse<T>(
    Future<Response> Function() request,
    T Function(Object? json) fromJsonT,
  ) async {
    try {
      final response = await request();
      return _parseBaseModel<T>(response.data, fromJsonT);
    } on DioException catch (dioError) {
      final data = dioError.response?.data;
      if (data is Map<String, dynamic>) {
        try {
          final base = BaseData<T?>.fromJson(data, (_) => null);
          return Left(ErrorModel(
            base.message ?? 'Xatolik yuz berdi',
            errorCode: base.errorCode,
          ));
        } catch (_) {
          return Left(ErrorModel(
            'Javob parse qilinmadi',
            errorCode: dioError.response?.statusCode,
          ));
        }
      } else {
        return Left(ErrorModel(
          dioError.message ?? 'Tarmoq xatoligi',
          errorCode: dioError.response?.statusCode,
        ));
      }
    } catch (e) {
      return Left(ErrorModel('Kutilmagan xatolik: ${e.toString()}', errorCode: -1));
    }
  }

  Either<ErrorModel, T> _parseBaseModel<T>(
    dynamic data,
    T Function(Object? json) fromJsonT,
  ) {
    try {
      if (data is Map<String, dynamic>) {
        final baseModel = BaseData<T>.fromJson(data, fromJsonT);
        if (!baseModel.success) {
          return Left(ErrorModel(
            baseModel.message ?? 'Xatolik mavjud',
            errorCode: baseModel.errorCode,
          ));
        }
        if (baseModel.data == null) {
          // ignore: null_check_on_nullable_type_parameter
          return Right(true as T);
        }
        // ignore: null_check_on_nullable_type_parameter
        return Right(baseModel.data as T);
      } else {
        return Left(ErrorModel('Yaroqsiz formatdagi javob', errorCode: -1));
      }
    } catch (e) {
      return Left(ErrorModel('fromJson xatosi: ${e.toString()}', errorCode: -1));
    }
  }
}
