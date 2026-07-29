import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../core/error/error_model.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/network/dio_response_extension.dart';
import '../../models/chat_upload_model.dart';

/// MIME type for the socket `attachment.type` field, derived from extension.
String chatMimeType(String path) {
  final ext = path.split('.').last.toLowerCase();
  const map = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'heic': 'image/heic',
    'pdf': 'application/pdf',
    'doc': 'application/msword',
    'docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xls': 'application/vnd.ms-excel',
    'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'txt': 'text/plain',
    'zip': 'application/zip',
    'mp4': 'video/mp4',
    'mp3': 'audio/mpeg',
  };
  return map[ext] ?? 'application/octet-stream';
}

abstract class ChatRemoteDatasource {
  /// Uploads a chat attachment (`POST /mobile/chat/upload`, max 10 MB).
  Future<Either<ErrorModel, ChatUploadModel>> uploadFile(String path);
}

class ChatRemoteDatasourceImpl implements ChatRemoteDatasource {
  final DioClient dioClient;

  ChatRemoteDatasourceImpl(this.dioClient);

  @override
  Future<Either<ErrorModel, ChatUploadModel>> uploadFile(String path) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        path,
        filename: path.split('/').last,
      ),
    });
    return dioClient.dio.wrapResponse<ChatUploadModel>(
      () => dioClient.dio.post('mobile/chat/upload', data: formData),
      (json) => ChatUploadModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
