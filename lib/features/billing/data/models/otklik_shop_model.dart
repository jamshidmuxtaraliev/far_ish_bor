import 'balance_model.dart' show parseAmount;

/// `GET /mobile/employer/otklik` javobi — otklik kvotasi, sotib olish mumkin
/// bo'lgan paketlar va balans BITTA so'rovda keladi (PROMPT_OTKLIK_ONLY §4).
///
/// ⚠ Bu endpoint chaqirilganda server obunaning 30 kunlik siklini ham
/// tekshiradi — oy o'tgan bo'lsa yangi kvota shu yerda ochiladi. Ya'ni ekranni
/// ochishning o'zi sonlarni to'g'rilaydi, alohida "yangilash" so'rovi kerak emas.
class OtklikShopModel {
  final OtklikSummary summary;
  final List<OtklikPackage> packages;

  /// Kvota tugagach zaxira yo'l — bitta kontakt uchun balansdan yechiladigan summa.
  final int fallbackUnitFee;
  final int balance;
  final int totalUnlocked;

  const OtklikShopModel({
    this.summary = const OtklikSummary(),
    this.packages = const [],
    this.fallbackUnitFee = 0,
    this.balance = 0,
    this.totalUnlocked = 0,
  });

  factory OtklikShopModel.fromJson(Map<String, dynamic> json) {
    return OtklikShopModel(
      summary: OtklikSummary.fromJson(json['summary'] as Map<String, dynamic>?),
      packages: (json['packages'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(OtklikPackage.fromJson)
          .toList(),
      fallbackUnitFee: parseAmount(json['fallback_unit_fee']),
      balance: parseAmount(json['balance']),
      totalUnlocked: parseAmount(json['total_unlocked']),
    );
  }
}

/// Qoldiq kvota. `expiresAt` — eng tez tugaydigan hamyonning muddati:
/// qoldiq keyingi oyga O'TMAYDI, shuning uchun ekranda ko'rsatiladi.
class OtklikSummary {
  final int available;
  final int total;
  final int used;
  final bool hasQuota;
  final String? expiresAt;

  const OtklikSummary({
    this.available = 0,
    this.total = 0,
    this.used = 0,
    this.hasQuota = false,
    this.expiresAt,
  });

  factory OtklikSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OtklikSummary();
    return OtklikSummary(
      available: parseAmount(json['available']),
      total: parseAmount(json['total']),
      used: parseAmount(json['used']),
      hasQuota: json['has_quota'] == true,
      expiresAt: json['expires_at'] as String?,
    );
  }

  double get fraction => total <= 0 ? 0 : available / total;
}

/// Bir martalik paket — `qty` ta otklik, `totalDays` kun amal qiladi.
class OtklikPackage {
  final int id;
  final String name;
  final int qty;
  final int price;
  final int durationDays;
  final int bonusDays;
  final int totalDays;
  final int pricePerUnit;
  final String? description;

  const OtklikPackage({
    required this.id,
    required this.name,
    this.qty = 0,
    this.price = 0,
    this.durationDays = 30,
    this.bonusDays = 0,
    this.totalDays = 30,
    this.pricePerUnit = 0,
    this.description,
  });

  factory OtklikPackage.fromJson(Map<String, dynamic> json) {
    final duration = parseAmount(json['duration_days']);
    final bonus = parseAmount(json['bonus_days']);
    return OtklikPackage(
      id: parseAmount(json['id']),
      name: json['name'] as String? ?? 'Kalit paketi',
      qty: parseAmount(json['qty']),
      price: parseAmount(json['price']),
      durationDays: duration,
      bonusDays: bonus,
      // Server `total_days` ni o'zi qo'shib beradi; eski javobda bo'lmasa
      // muddat + bonusdan hisoblanadi.
      totalDays: parseAmount(json['total_days']) > 0
          ? parseAmount(json['total_days'])
          : duration + bonus,
      pricePerUnit: parseAmount(json['price_per_unit']),
      description: json['description'] as String?,
    );
  }
}

/// `POST /otklik/buy` va `POST /subscription/buy` javobining to'lovga tegishli
/// qismi (ikkalasi bir xil shaklda qaytaradi).
///
/// ⚠ ORALIQ SAHIFA YO'Q: `checkoutUrl` bo'lsa Payme/Click ILOVASI darhol
/// ochiladi, `url` (`/pay/<code>`) esa faqat ZAXIRA. Qarang:
/// docs/PROMPT_OTKLIK_ONLY_MOBILE.md §5.1.
class PurchaseResult {
  final String? checkoutUrl;
  final String? checkoutSystem;
  final String? payCode;
  final String? url;

  /// `pay_method: 'balance'` bilan sotib olinganda to'lov havolasi umuman
  /// bo'lmaydi — kvota darhol tushadi.
  final bool activated;

  final OtklikSummary? summary;

  const PurchaseResult({
    this.checkoutUrl,
    this.checkoutSystem,
    this.payCode,
    this.url,
    this.activated = false,
    this.summary,
  });

  factory PurchaseResult.fromJson(Map<String, dynamic> json) {
    final checkout = json['checkout_url'] as String?;
    final payUrl = json['url'] as String?;
    return PurchaseResult(
      checkoutUrl: (checkout?.isEmpty ?? true) ? null : checkout,
      checkoutSystem: json['checkout_system'] as String?,
      payCode: json['pay_code']?.toString(),
      url: (payUrl?.isEmpty ?? true) ? null : payUrl,
      activated: checkout == null && payUrl == null,
      summary: json['summary'] is Map<String, dynamic>
          ? OtklikSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Ochish uchun havola — avval `checkout_url`, keyin zaxira `/pay/<code>`.
  String? get launchUrl => checkoutUrl ?? url;

  String get systemLabel {
    switch (checkoutSystem) {
      case 'payme':
        return 'Payme';
      case 'click':
        return 'Click';
      case 'paynet':
        return 'Paynet';
      default:
        return "To'lov";
    }
  }
}
