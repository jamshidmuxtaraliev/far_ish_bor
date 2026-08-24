import '../../../../core/constants/constants.dart';
import 'anketa_models.dart';
import 'branch_model.dart';

class CoverageRegionModel {
  final int? id;
  final int regionId;
  final int? districtId;
  final RegionModel? region;
  final DistrictModel? district;

  const CoverageRegionModel({
    this.id,
    required this.regionId,
    this.districtId,
    this.region,
    this.district,
  });

  factory CoverageRegionModel.fromJson(Map<String, dynamic> json) =>
      CoverageRegionModel(
        id: json['id'] as int?,
        regionId: json['region_id'] as int,
        districtId: json['district_id'] as int?,
        region: json['region'] != null
            ? RegionModel.fromJson(json['region'] as Map<String, dynamic>)
            : null,
        district: json['district'] != null
            ? DistrictModel.fromJson(json['district'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'region_id': regionId};
    if (districtId != null) map['district_id'] = districtId;
    return map;
  }

  String get displayName {
    final regionName = region?.name ?? '';
    final districtName = district?.name;
    if (districtName != null && districtName.isNotEmpty) {
      return '$regionName — $districtName';
    }
    return regionName;
  }
}

class EmployerModel {
  final int id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? phone2;
  final String? tin;
  final String? address;
  final String? logo;
  final double? latitude;
  final double? longitude;
  final int? regionId;
  final int? districtId;
  final bool isAllRegions;
  final String tier;
  final String submissionStatus;
  final String lifecycleStatus;
  final RegionModel? region;
  final DistrictModel? district;
  final List<CoverageRegionModel> coverageRegions;

  /// Qo'shimcha manzillar — `/mobile/employer/me` javobida birga keladi.
  final List<BranchModel> branches;

  const EmployerModel({
    required this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    this.phone2,
    this.tin,
    this.address,
    this.logo,
    this.latitude,
    this.longitude,
    this.regionId,
    this.districtId,
    this.isAllRegions = false,
    this.tier = 'free',
    this.submissionStatus = 'yangi',
    this.lifecycleStatus = 'yangi',
    this.region,
    this.district,
    this.coverageRegions = const [],
    this.branches = const [],
  });

  factory EmployerModel.fromJson(Map<String, dynamic> json) => EmployerModel(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        contactPerson: json['contact_person'] as String?,
        phone: json['phone'] as String?,
        phone2: json['phone2'] as String?,
        tin: json['tin'] as String?,
        address: json['address'] as String?,
        logo: json['logo'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        regionId: json['region_id'] as int?,
        districtId: json['district_id'] as int?,
        isAllRegions: json['is_all_regions'] as bool? ?? false,
        tier: json['tier'] as String? ?? 'free',
        submissionStatus: json['submission_status'] as String? ?? 'yangi',
        lifecycleStatus: json['lifecycle_status'] as String? ?? 'yangi',
        region: json['region'] != null
            ? RegionModel.fromJson(json['region'] as Map<String, dynamic>)
            : null,
        district: json['district'] != null
            ? DistrictModel.fromJson(json['district'] as Map<String, dynamic>)
            : null,
        coverageRegions: (json['coverage_regions'] as List<dynamic>? ?? [])
            .map((e) => CoverageRegionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        branches: (json['branches'] as List<dynamic>? ?? [])
            .map((e) => BranchModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Tarif faqat call-markaz operatori tomonidan berilgani uchun mobil ilovada
  /// bu qiymat faqat ko'rsatiladi — o'zgartirilmaydi.
  bool get isPremiumTier => tier.isNotEmpty && tier.toLowerCase() != 'free';

  /// `premium_a` → `Premium A`, `free` → `Bepul`. Tariflar ro'yxati CRM'da
  /// o'sib borgani uchun qat'iy jadval emas — formatlash.
  String get tierLabel {
    final raw = tier.trim();
    if (raw.isEmpty || raw.toLowerCase() == 'free') return 'Bepul';
    return raw
        .split(RegExp(r'[_\s]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w.length <= 2
            ? w.toUpperCase()
            : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  String? get logoUrl => resolveMediaUrl(logo);
}
