/// `GET /mobile/anketa/resume` javobi.
///
/// Bu endpoint hech qachon xato qaytarmaydi — u har doim `success: true` bilan
/// keladi va PDF hozir olinadimi-yo'qmi `ready` + `reason` orqali bildiriladi.
class ResumeInfoModel {
  final bool ready;

  /// `null` | `not_approved` | `photo_required`
  final String? reason;

  /// Serverdan kelgan izoh — `ready == false` bo'lganda ko'rsatiladi.
  final String? message;
  final String? submissionStatus;
  final bool hasPhoto;

  /// Qurilmada saqlanadigan nom (`Ism_Familiya.pdf`) — o'zimiz yasamaymiz.
  final String? filename;

  /// Bayt hisobida; `total` noma'lum bo'lganda progress uchun ishlatiladi.
  final int? size;

  /// Tokensiz ochiladigan havola. Har chaqiruvda yangilanadi — KESHLAMANG.
  final String? url;

  const ResumeInfoModel({
    required this.ready,
    this.reason,
    this.message,
    this.submissionStatus,
    this.hasPhoto = false,
    this.filename,
    this.size,
    this.url,
  });

  factory ResumeInfoModel.fromJson(Map<String, dynamic> json) => ResumeInfoModel(
        ready: json['ready'] as bool? ?? false,
        reason: json['reason'] as String?,
        message: json['message'] as String?,
        submissionStatus: json['submission_status'] as String?,
        hasPhoto: json['has_photo'] as bool? ?? false,
        filename: json['filename'] as String?,
        size: json['size'] as int?,
        url: json['url'] as String?,
      );

  bool get isNotApproved => reason == 'not_approved';

  bool get isPhotoRequired => reason == 'photo_required';
}
