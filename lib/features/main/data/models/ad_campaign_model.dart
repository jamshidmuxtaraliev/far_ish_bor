import '../../../../core/constants/constants.dart';
import '../../../../core/utils/ad_text.dart';

/// `GET /ad-campaign/public` — bosh ekrandagi reklama slayderi.
///
/// Manba: `ad_campaigns` jadvali (`status='active'`, eng yangisi birinchi,
/// 12 tagacha). Ommaviy sayt ham xuddi shu endpointdan oziqlanadi.
class AdCampaignModel {
  final int id;
  final String advertiserName;
  final String? adType;
  final String? textContent;

  /// `uploads/` ichidagi fayl nomi yoki to'liq URL.
  final String? image;
  final String? video;
  final String? address;
  final String? phone;

  /// E'lon HALI faol vakansiyaga tegishli bo'lsa — uning id si, aks holda
  /// `null` (backend o'zi tekshirib yuboradi).
  final int? vacancyId;

  /// Rasmni BIZ yasaganmizmi (`vacancyBanner.js`, 1080×1080). Shunda kasb,
  /// maosh, manzil va telefon rasm ICHIDA yozilgan — pastda TAKRORLANMAYDI.
  final bool isVacancyBanner;

  const AdCampaignModel({
    required this.id,
    required this.advertiserName,
    this.adType,
    this.textContent,
    this.image,
    this.video,
    this.address,
    this.phone,
    this.vacancyId,
    this.isVacancyBanner = false,
  });

  factory AdCampaignModel.fromJson(Map<String, dynamic> json) {
    String? str(String key) {
      final v = json[key];
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    return AdCampaignModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      advertiserName: str('advertiser_name') ?? '',
      adType: str('ad_type'),
      textContent: str('text_content'),
      image: str('image'),
      video: str('video'),
      address: str('address'),
      phone: str('phone'),
      vacancyId: (json['vacancy_id'] as num?)?.toInt(),
      isVacancyBanner: json['is_vacancy_banner'] == true,
    );
  }

  /// Rasmning to'liq manzili. Backend ba'zan tayyor URL, ba'zan faqat fayl
  /// nomini qaytaradi — ikkalasi ham qo'llab-quvvatlanadi.
  String? get imageUrl {
    final v = image;
    if (v == null) return null;
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    return '$BASE_IMAGE_URL${v.startsWith('/') ? v.substring(1) : v}';
  }

  ParsedAd get parsed => parseAdText(textContent);

  /// Slayderda ko'rsatishga arziydimi — rasm ham, matn ham bo'lmasa yo'q.
  bool get isRenderable => imageUrl != null || (textContent?.trim().isNotEmpty ?? false);
}
