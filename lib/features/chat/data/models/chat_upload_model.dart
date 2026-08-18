/// Response of `POST /mobile/chat/upload` (MOBILE_CHAT_PROMPT §4,
/// PROMPT_OTKLIK_MOBILE §7.4):
/// `{ "file": "c_173….jpg", "url": "https://…/uploads/chat/c_….jpg",
///    "type": "image/jpeg" }`.
class ChatUploadModel {
  final String file;
  final String url;

  /// Server aniqlagan MIME turi — `chat:message.attachment.type` uchun.
  final String? type;

  const ChatUploadModel({required this.file, required this.url, this.type});

  factory ChatUploadModel.fromJson(Map<String, dynamic> json) {
    return ChatUploadModel(
      file: json['file'] as String? ?? '',
      url: json['url'] as String? ?? '',
      type: json['type'] as String?,
    );
  }
}
