import 'anketa_models.dart';

/// Kompaniyaning qo'shimcha manzili (filial).
///
/// Filialda faqat manzil bo'ladi: viloyat, tuman, manzil matni, xarita nuqtasi
/// va ixtiyoriy nom. Telefon, tarif, balans va vakansiya kompaniya darajasida
/// qoladi — filialga biriktirilmaydi.
class BranchModel {
  final int id;
  final String? name;
  final int? regionId;
  final int? districtId;
  final String? address;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final int sortOrder;
  final RegionModel? region;
  final DistrictModel? district;

  const BranchModel({
    required this.id,
    this.name,
    this.regionId,
    this.districtId,
    this.address,
    this.latitude,
    this.longitude,
    this.isActive = true,
    this.sortOrder = 0,
    this.region,
    this.district,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) => BranchModel(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String?,
        regionId: json['region_id'] as int?,
        districtId: json['district_id'] as int?,
        address: json['address'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        isActive: json['is_active'] as bool? ?? true,
        sortOrder: json['sort_order'] as int? ?? 0,
        region: _region(json['region']),
        district: _district(json['district']),
      );

  /// Ish izlovchi tomonidagi javoblarda hudud nomi `name` kalitida keladi,
  /// ish beruvchi tomonida esa `name_uz` — ikkalasi ham qabul qilinadi.
  static String _localName(Map<String, dynamic> json) =>
      (json['name_uz'] ?? json['name'] ?? json['name_ru'] ?? '') as String;

  static RegionModel? _region(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    return RegionModel(
      id: json['id'] as int? ?? 0,
      name: _localName(json),
      districts: const [],
    );
  }

  static DistrictModel? _district(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    return DistrictModel(
      id: json['id'] as int? ?? 0,
      name: _localName(json),
    );
  }

  bool get hasCoords => latitude != null && longitude != null;

  /// "Bunyodkor 12, Chilonzor tumani, Toshkent shahri"
  String get addressLine => [address, district?.name, region?.name]
      .where((s) => s != null && s.trim().isNotEmpty)
      .join(', ');

  /// Nom bo'lmasa ro'yxatdagi tartib raqami bo'yicha "Filial N".
  String title(int index) {
    final n = name?.trim();
    if (n != null && n.isNotEmpty) return n;
    return 'Filial ${index + 1}';
  }

  String get coordsLine => hasCoords
      ? '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}'
      : 'Xaritada belgilanmagan';
}
