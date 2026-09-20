import 'balance_model.dart' show parseAmount;

/// `GET /mobile/employer/subscription` javobi — otklik OBUNA tariflari.
///
/// ⚠ Bu tariflar CRM'dagi Premium A/B/V bilan ARALASHTIRILMAYDI: Premium'ni
/// faqat operator shartnoma orqali biriktiradi, ish beruvchi o'zi tanlaydigan
/// yagona narsa — otklik (docs/PROMPT_PREMIUM_YOQ_MOBILE.md).
class SubscriptionTariffsModel {
  final List<TariffPeriod> periods;
  final List<SubscriptionTariff> tariffs;
  final CurrentSubscription? current;

  const SubscriptionTariffsModel({
    this.periods = const [],
    this.tariffs = const [],
    this.current,
  });

  factory SubscriptionTariffsModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionTariffsModel(
      periods: (json['periods'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TariffPeriod.fromJson)
          .toList(),
      tariffs: (json['tariffs'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SubscriptionTariff.fromJson)
          .toList(),
      current: json['current'] is Map<String, dynamic>
          ? CurrentSubscription.fromJson(json['current'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// To'lov davri — 1 oy · 6 oy (−10%) · 12 oy (−20%). Chegirma va bonus kunlar
/// admin panelida sozlanadi (`tariff_periods`), shuning uchun qotirilmaydi.
class TariffPeriod {
  final int months;
  final String name;
  final int discountPct;
  final int bonusDays;

  const TariffPeriod({
    required this.months,
    this.name = '',
    this.discountPct = 0,
    this.bonusDays = 0,
  });

  factory TariffPeriod.fromJson(Map<String, dynamic> json) {
    final months = parseAmount(json['months']);
    return TariffPeriod(
      months: months,
      name: json['name'] as String? ?? '$months oy',
      discountPct: parseAmount(json['discount_pct']),
      bonusDays: parseAmount(json['bonus_days']),
    );
  }
}

/// Bitta tarifning bitta davr uchun narxi — **serverda** hisoblangan
/// (viloyat narxi + chegirma). Mijozda qayta hisoblanmaydi.
class TariffPeriodPrice {
  final int months;
  final String name;
  final int discountPct;
  final int bonusDays;
  final int price;
  final int priceWithoutDiscount;

  const TariffPeriodPrice({
    required this.months,
    this.name = '',
    this.discountPct = 0,
    this.bonusDays = 0,
    this.price = 0,
    this.priceWithoutDiscount = 0,
  });

  factory TariffPeriodPrice.fromJson(Map<String, dynamic> json) {
    final months = parseAmount(json['months']);
    return TariffPeriodPrice(
      months: months,
      name: json['name'] as String? ?? '$months oy',
      discountPct: parseAmount(json['discount_pct']),
      bonusDays: parseAmount(json['bonus_days']),
      price: parseAmount(json['price']),
      priceWithoutDiscount: parseAmount(json['price_without_discount']),
    );
  }
}

/// Obuna tarifi. ⚠ YAGONA limiti — `otklikQuota` (har `cycleDays` kunda).
/// "Xodimlar soni" va "vakansiya limiti" bazadan ham olib tashlangan.
class SubscriptionTariff {
  final int id;
  final String code;
  final String name;
  final String? description;
  final int currentPrice;
  final int otklikQuota;
  final int cycleDays;
  final bool isPopular;
  final List<String> features;
  final List<TariffPeriodPrice> prices;

  const SubscriptionTariff({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.currentPrice = 0,
    this.otklikQuota = 0,
    this.cycleDays = 30,
    this.isPopular = false,
    this.features = const [],
    this.prices = const [],
  });

  factory SubscriptionTariff.fromJson(Map<String, dynamic> json) {
    return SubscriptionTariff(
      id: parseAmount(json['id']),
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      currentPrice: parseAmount(json['current_price']),
      otklikQuota: parseAmount(json['otklik_quota']),
      cycleDays: parseAmount(json['cycle_days']) > 0
          ? parseAmount(json['cycle_days'])
          : 30,
      isPopular: json['is_popular'] == true,
      // `features` serverda JSON massiv — matnlarni admin tahrirlaydi,
      // shuning uchun ilovada O'ZGARTIRILMASDAN chiqariladi.
      features: (json['features'] as List? ?? const [])
          .map((e) => '$e')
          .where((e) => e.trim().isNotEmpty)
          .toList(),
      prices: (json['prices'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TariffPeriodPrice.fromJson)
          .toList(),
    );
  }

  /// Berilgan davr uchun narx; topilmasa oylik narxdan qaytadi.
  TariffPeriodPrice priceFor(int months) {
    for (final p in prices) {
      if (p.months == months) return p;
    }
    return TariffPeriodPrice(
      months: months,
      price: currentPrice * months,
      priceWithoutDiscount: currentPrice * months,
    );
  }
}

/// `current` — joriy obuna holati (`subscriptionService.limits`).
///
/// ⚠ Ikki xil muddat aralashtirilmaydi: `daysLeft` — butun obuna,
/// `cycleDaysLeft` — joriy 30 kunlik kvota oynasi (qoldiq keyingi oyga o'tmaydi).
class CurrentSubscription {
  final bool hasSubscription;
  final String? tariffCode;
  final String? tariffName;
  final int otklikQuota;
  final int otklikAvailable;
  final int otklikUsed;
  final String? expiresAt;
  final int? daysLeft;
  final String? cycleEndsAt;
  final int? cycleDaysLeft;

  const CurrentSubscription({
    this.hasSubscription = false,
    this.tariffCode,
    this.tariffName,
    this.otklikQuota = 0,
    this.otklikAvailable = 0,
    this.otklikUsed = 0,
    this.expiresAt,
    this.daysLeft,
    this.cycleEndsAt,
    this.cycleDaysLeft,
  });

  factory CurrentSubscription.fromJson(Map<String, dynamic> json) {
    return CurrentSubscription(
      hasSubscription: json['has_subscription'] == true,
      tariffCode: json['tariff_code'] as String?,
      tariffName: json['tariff_name'] as String?,
      otklikQuota: parseAmount(json['otklik_quota']),
      otklikAvailable: parseAmount(json['otklik_available']),
      otklikUsed: parseAmount(json['otklik_used']),
      expiresAt: json['expires_at'] as String?,
      daysLeft: json['days_left'] == null ? null : parseAmount(json['days_left']),
      cycleEndsAt: json['cycle_ends_at'] as String?,
      cycleDaysLeft:
          json['cycle_days_left'] == null ? null : parseAmount(json['cycle_days_left']),
    );
  }
}
