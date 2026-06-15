/// A single support-chat message.
///
/// `author_audience`: `mobile` = the user themself (right side),
/// `staff` = operator (left side). Time field is `at` for both live & history.
class ChatMessageModel {
  final int? id;
  final String sessionKey;
  final String authorAudience; // 'mobile' | 'staff'
  final int? authorId;
  final String? authorName; // only on staff messages
  final String? text;
  final String? attachmentUrl;
  final String? attachmentType;
  final String? source; // mobile | web | telegram
  final DateTime? at;

  const ChatMessageModel({
    this.id,
    required this.sessionKey,
    required this.authorAudience,
    this.authorId,
    this.authorName,
    this.text,
    this.attachmentUrl,
    this.attachmentType,
    this.source,
    this.at,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v as String).toLocal();
      } catch (_) {
        return null;
      }
    }

    return ChatMessageModel(
      id: json['id'] as int?,
      sessionKey: json['session_key'] as String? ?? '',
      authorAudience: json['author_audience'] as String? ?? 'staff',
      authorId: json['author_id'] as int?,
      authorName: json['author_name'] as String?,
      text: json['text'] as String?,
      attachmentUrl: json['attachment_url'] as String?,
      attachmentType: json['attachment_type'] as String?,
      source: json['source'] as String?,
      at: parseDate(json['at']),
    );
  }

  bool get isMine => authorAudience == 'mobile';

  String get timeDisplay {
    final d = at;
    if (d == null) return '';
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
