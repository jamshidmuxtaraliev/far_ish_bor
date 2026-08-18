import '../../../../core/constants/constants.dart';

/// PROMPT_OTKLIK_MOBILE.md §7.1 — `GET /mobile/chats` bitta yozuvi.
///
/// Ikki tur: `support:*` (operator bilan, doim birinchi) va `direct:*`
/// (ish beruvchi ↔ otklik bilan ochilgan nomzod).
class ChatSessionModel {
  final String sessionKey;
  final String kind; // support | direct
  final int? sessionId;
  final ChatPeerModel? peer;
  final DateTime? lastMessageAt;
  final ChatLastMessageModel? lastMessage;

  const ChatSessionModel({
    required this.sessionKey,
    required this.kind,
    this.sessionId,
    this.peer,
    this.lastMessageAt,
    this.lastMessage,
  });

  bool get isSupport => kind == 'support' || sessionKey.startsWith('support:');
  bool get isDirect => !isSupport;

  /// `direct:e88:a4622` → `4622`; boshqa turlarda `null`.
  int? get anketaId {
    final peerId = peer?.anketaId;
    if (peerId != null) return peerId;
    final match = RegExp(r'^direct:e\d+:a(\d+)$').firstMatch(sessionKey);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  String get title =>
      peer?.name?.isNotEmpty == true ? peer!.name! : "Qo'llab-quvvatlash markazi";

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    DateTime? parse(dynamic v) {
      if (v is! String) return null;
      try {
        return DateTime.parse(v).toLocal();
      } catch (_) {
        return null;
      }
    }

    final peer = json['peer'];
    final last = json['last_message'];
    return ChatSessionModel(
      sessionKey: json['session_key'] as String? ?? '',
      kind: json['kind'] as String? ?? 'support',
      sessionId: (json['session_id'] as num?)?.toInt(),
      peer: peer is Map
          ? ChatPeerModel.fromJson(Map<String, dynamic>.from(peer))
          : null,
      lastMessageAt: parse(json['last_message_at']),
      lastMessage: last is Map
          ? ChatLastMessageModel.fromJson(Map<String, dynamic>.from(last))
          : null,
    );
  }
}

class ChatPeerModel {
  final String? type; // operator | seeker | employer
  final int? anketaId;
  final String? name;
  final String? photo;

  const ChatPeerModel({this.type, this.anketaId, this.name, this.photo});

  String? get photoUrl {
    final p = photo;
    if (p == null || p.isEmpty) return null;
    if (p.startsWith('http')) return p;
    // Backend `uploads/anketa/..` yoki `anketa/..` yuborishi mumkin; baza URL
    // allaqachon `.../uploads/` bilan tugaydi.
    return '$BASE_IMAGE_URL${p.startsWith('uploads/') ? p.substring(8) : p}';
  }

  factory ChatPeerModel.fromJson(Map<String, dynamic> json) => ChatPeerModel(
        type: json['type'] as String?,
        anketaId: (json['anketa_id'] as num?)?.toInt(),
        name: json['name'] as String?,
        photo: json['photo'] as String?,
      );
}

class ChatLastMessageModel {
  final String? text;
  final bool hasAttachment;
  final String? from; // mobile | staff
  final DateTime? at;

  const ChatLastMessageModel({
    this.text,
    this.hasAttachment = false,
    this.from,
    this.at,
  });

  String get preview {
    if (text != null && text!.isNotEmpty) return text!;
    return hasAttachment ? 'Fayl' : '';
  }

  String get timeDisplay {
    final d = at;
    if (d == null) return '';
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return '${d.hour.toString().padLeft(2, '0')}:'
          '${d.minute.toString().padLeft(2, '0')}';
    }
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}';
  }

  factory ChatLastMessageModel.fromJson(Map<String, dynamic> json) {
    DateTime? at;
    final raw = json['at'];
    if (raw is String) {
      try {
        at = DateTime.parse(raw).toLocal();
      } catch (_) {
        at = null;
      }
    }
    return ChatLastMessageModel(
      text: json['text'] as String?,
      hasAttachment: json['has_attachment'] as bool? ?? false,
      from: json['from'] as String?,
      at: at,
    );
  }
}
