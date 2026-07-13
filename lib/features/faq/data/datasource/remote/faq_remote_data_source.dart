import 'package:dartz/dartz.dart';

import '../../../../../core/error/error_model.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/network/dio_response_extension.dart';
import '../../models/faq_model.dart';

abstract class FaqRemoteDataSource {
  /// [audience] — `seeker` | `employer` | null (barchasi).
  Future<Either<ErrorModel, List<FaqModel>>> getFaqList({String? audience});
}

class FaqRemoteDataSourceImpl implements FaqRemoteDataSource {
  final DioClient dioClient;

  FaqRemoteDataSourceImpl(this.dioClient);

  @override
  Future<Either<ErrorModel, List<FaqModel>>> getFaqList({String? audience}) {
    return dioClient.dio.wrapResponse<List<FaqModel>>(
      () => dioClient.dio.get(
        'faq/public',
        queryParameters: audience != null ? {'audience': audience} : null,
      ),
      (json) =>
          (json as List)
              .map((e) => FaqModel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}
