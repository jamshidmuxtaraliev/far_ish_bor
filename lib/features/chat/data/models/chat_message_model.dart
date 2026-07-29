/// Local delivery state of an outgoing message (optimistic UI):
/// `sending` (⏳ queued/awaiting echo) → `sent` (✓ server echo arrived) →
/// `failed` (❗ chat:error — tap to retry).
enum ChatSendStatus { sending, sent, failed }

/// A single support-chat message.
///
/// `author_audience`: `mobile` = the user themself (right side),
/// `staff` = operator (left side), `system` = centered notice.
/// Time field is `at` for both live & history.
class ChatMessageModel {
  final int? id;
  final String sessionKey;
  final String authorAudience; // 'mobile' | 'staff' | 'system'
  final int? authorId;
  final String? authorName; // only on staff messages
  final String? text;
  final String? attachmentUrl;
  final String? attachmentType;
  final String? source; // mobile | web | telegram | system
  final String? sessionStatus; // yangi | jarayonda | yopilgan (live only)
  final DateTime? at;

  /// Client-generated id for optimistic messages (TODO-3 `client_msg_id`).
  final String? localId;
  final ChatSendStatus sendStatus;

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
    this.sessionStatus,
    this.at,
    this.localId,
    this.sendStatus = ChatSendStatus.sent,
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

    // Live events may carry a nested `attachment: {url, type}` object in
    // addition to the flat `attachment_url`/`attachment_type` columns.
    final attachment = json['attachment'];
    final attachmentUrl =
        json['attachment_url'] as String? ??
        (attachment is Map ? attachment['url'] as String? : null);
    final attachmentType =
        json['attachment_type'] as String? ??
        (attachment is Map ? attachment['type'] as String? : null);

    return ChatMessageModel(
      id: json['id'] as int?,
      sessionKey: json['session_key'] as String? ?? '',
      authorAudience: json['author_audience'] as String? ?? 'staff',
      authorId: json['author_id'] as int?,
      authorName: json['author_name'] as String?,
      text: json['text'] as String?,
      attachmentUrl: attachmentUrl,
      attachmentType: attachmentType,
      source: json['source'] as String?,
      sessionStatus: json['status'] as String?,
      at: parseDate(json['at']),
      localId: json['client_msg_id'] as String?,
    );
  }

  ChatMessageModel copyWith({int? id, ChatSendStatus? sendStatus}) {
    return ChatMessageModel(
      id: id ?? this.id,
      sessionKey: sessionKey,
      authorAudience: authorAudience,
      authorId: authorId,
      authorName: authorName,
      text: text,
      attachmentUrl: attachmentUrl,
      attachmentType: attachmentType,
      source: source,
      sessionStatus: sessionStatus,
      at: at,
      localId: localId,
      sendStatus: sendStatus ?? this.sendStatus,
    );
  }

  bool get isMine => authorAudience == 'mobile';
  bool get isSystem => authorAudience == 'system';
  bool get isPending => sendStatus == ChatSendStatus.sending;
  bool get isImage => attachmentType?.startsWith('image/') ?? false;

  String get timeDisplay {
    final d = at;
    if (d == null) return '';
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
