import '../../../../core/constants/constants.dart';

/// `GET /story/public` — bosh ekran tepasidagi story lentasi.
///
/// Kontentni faqat operator/admin qo'shadi (CRM `/stories`). Backend
/// muddati o'tgan va faolsiz yozuvlarni O'ZI filtrlaydi — ilovada
/// `expires_at` faqat "yaqinda tugaydi" belgisini ko'rsatish uchun keladi.
class StoryModel {
  final int id;
  final String title;
  final String? text;

  /// Story rasmi — `uploads/` dagi fayl nomi yoki to'liq URL.
  final String image;

  /// Lentadagi doira uchun kichik rasm (bo'sh bo'lsa [image] olinadi).
  final String? cover;

  /// `none` · `vacancy` · `url`
  final String linkType;
  final int? vacancyId;
  final String? linkUrl;
  final String? linkLabel;

  final int position;
  final DateTime? expiresAt;

  const StoryModel({
    required this.id,
    required this.title,
    required this.image,
    this.text,
    this.cover,
    this.linkType = 'none',
    this.vacancyId,
    this.linkUrl,
    this.linkLabel,
    this.position = 0,
    this.expiresAt,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    String? str(String key) {
      final v = json[key];
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    return StoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: str('title') ?? '',
      text: str('text'),
      image: str('image') ?? '',
      cover: str('cover'),
      linkType: str('link_type') ?? 'none',
      vacancyId: (json['vacancy_id'] as num?)?.toInt(),
      linkUrl: str('link_url'),
      linkLabel: str('link_label'),
      position: (json['position'] as num?)?.toInt() ?? 0,
      expiresAt: DateTime.tryParse(str('expires_at') ?? ''),
    );
  }

  static String? _full(String? v) {
    if (v == null || v.isEmpty) return null;
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    return '$BASE_IMAGE_URL${v.startsWith('/') ? v.substring(1) : v}';
  }

  String? get imageUrl => _full(image);

  /// Lentadagi doira rasmi — alohida ikonka bo'lmasa story rasmining o'zi.
  String? get coverUrl => _full(cover) ?? imageUrl;

  bool get hasAction =>
      (linkType == 'vacancy' && vacancyId != null) ||
      (linkType == 'url' && (linkUrl?.isNotEmpty ?? false));

  String get actionLabel => linkLabel?.isNotEmpty == true ? linkLabel! : 'Batafsil';

  /// Rasmsiz story ko'rsatilmaydi — u bo'sh qora ekran bo'lib qolardi.
  bool get isRenderable => imageUrl != null;
}
