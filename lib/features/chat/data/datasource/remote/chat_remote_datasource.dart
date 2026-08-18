import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../core/error/error_model.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/network/dio_response_extension.dart';
import '../../models/chat_session_model.dart';
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

  /// Suhbatlar ro'yxati (PROMPT_OTKLIK §7.1): operator suhbati + otklik bilan
  /// ochilgan har bir nomzod uchun bitta `direct:*` yozuv.
  Future<Either<ErrorModel, List<ChatSessionModel>>> getChats();
}

class ChatRemoteDatasourceImpl implements ChatRemoteDatasource {
  final DioClient dioClient;

  ChatRemoteDatasourceImpl(this.dioClient);

  /// Maksimal fayl hajmi (backend limiti) — 10 MB.
  static const _maxUploadBytes = 10 * 1024 * 1024;

  @override
  Future<Either<ErrorModel, ChatUploadModel>> uploadFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return Left(ErrorModel('Fayl topilmadi', errorCode: -1));
    }
    final size = await file.length();
    if (size > _maxUploadBytes) {
      return Left(ErrorModel(
        "Fayl hajmi 10 MB dan oshmasligi kerak "
        "(${(size / 1024 / 1024).toStringAsFixed(1)} MB)",
        errorCode: 413,
      ));
    }

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        path,
        filename: path.split('/').last,
        contentType: DioMediaType.parse(chatMimeType(path)),
      ),
    });

    // Bu endpoint javobi konvert bilan ham (`{success, data:{…}}`), konvertsiz
    // ham (`{file, url, type}`) kelishi mumkin — ikkalasini ham qabul qilamiz.
    try {
      final response = await dioClient.dio.post(
        'mobile/chat/upload',
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      final raw = response.data;
      if (raw is! Map) {
        return Left(ErrorModel('Yaroqsiz formatdagi javob', errorCode: -1));
      }
      final body = Map<String, dynamic>.from(raw);
      if (body['success'] == false) {
        return Left(ErrorModel(
          body['message'] as String? ?? 'Fayl yuklanmadi',
          errorCode: body['error_code'] as int?,
        ));
      }
      final payload = body['data'] is Map
          ? Map<String, dynamic>.from(body['data'] as Map)
          : body;
      final uploaded = ChatUploadModel.fromJson(payload);
      if (uploaded.url.isEmpty) {
        return Left(ErrorModel(
          body['message'] as String? ?? 'Server fayl havolasini qaytarmadi',
          errorCode: response.statusCode,
        ));
      }
      return Right(uploaded);
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map ? data['message'] as String? : null;
      final code = (data is Map ? data['error_code'] as int? : null) ??
          e.response?.statusCode;
      return Left(ErrorModel(
        message ??
            (e.type == DioExceptionType.sendTimeout ||
                    e.type == DioExceptionType.receiveTimeout
                ? "Fayl yuborilmadi — internet sekin, qayta urinib ko'ring"
                : (e.message ?? 'Tarmoq xatoligi')),
        errorCode: code,
      ));
    } catch (e) {
      return Left(ErrorModel('Fayl yuklanmadi: $e', errorCode: -1));
    }
  }

  @override
  Future<Either<ErrorModel, List<ChatSessionModel>>> getChats() {
    return dioClient.dio.wrapResponse<List<ChatSessionModel>>(
      () => dioClient.dio.get('mobile/chats'),
      (json) => (json as List)
          .whereType<Map>()
          .map((e) => ChatSessionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
