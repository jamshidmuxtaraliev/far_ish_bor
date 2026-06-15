class NotificationModel {
  final int id;
  final String title;
  final String body;
  final String? type;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    this.title = '',
    this.body = '',
    this.type,
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v as String).toLocal();
      } catch (_) {
        return null;
      }
    }

    return NotificationModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body:
          json['body'] as String? ??
          json['message'] as String? ??
          json['text'] as String? ??
          '',
      type: json['type'] as String?,
      isRead: json['is_read'] as bool? ?? json['read'] as bool? ?? false,
      createdAt: parseDate(json['created_at'] ?? json['at']),
    );
  }

  String get timeDisplay {
    final d = createdAt;
    if (d == null) return '';
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 1) return 'hozir';
    if (diff.inMinutes < 60) return '${diff.inMinutes} daq oldin';
    if (diff.inHours < 24) return '${diff.inHours} soat oldin';
    if (diff.inDays < 7) return '${diff.inDays} kun oldin';
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }
}
