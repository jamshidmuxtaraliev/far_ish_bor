/// Response of `POST /mobile/chat/upload` (MOBILE_CHAT_PROMPT §4):
/// `{ "file": "file_....jpg", "url": "http://.../uploads/file_....jpg" }`.
class ChatUploadModel {
  final String file;
  final String url;

  const ChatUploadModel({required this.file, required this.url});

  factory ChatUploadModel.fromJson(Map<String, dynamic> json) {
    return ChatUploadModel(
      file: json['file'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}
