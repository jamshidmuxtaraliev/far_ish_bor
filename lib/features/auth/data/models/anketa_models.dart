class RegionModel {
  final int id;
  final String name;
  final List<DistrictModel> districts;

  const RegionModel({required this.id, required this.name, required this.districts});

  factory RegionModel.fromJson(Map<String, dynamic> json) => RegionModel(
        id: json['id'] as int,
        name: json['name_uz'] as String? ?? '',
        districts: (json['districts'] as List<dynamic>? ?? [])
            .map((e) => DistrictModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class DistrictModel {
  final int id;
  final String name;

  const DistrictModel({required this.id, required this.name});

  factory DistrictModel.fromJson(Map<String, dynamic> json) => DistrictModel(
        id: json['id'] as int,
        name: json['name_uz'] as String? ?? '',
      );
}

class JobTypeModel {
  final int id;
  final String name;

  const JobTypeModel({required this.id, required this.name});

  factory JobTypeModel.fromJson(Map<String, dynamic> json) => JobTypeModel(
        id: json['id'] as int,
        name: json['name_uz'] as String? ?? json['name_ru'] as String? ?? '',
      );
}

class LanguageModel {
  final String code;
  final String name;

  const LanguageModel({required this.code, required this.name});

  factory LanguageModel.fromJson(Map<String, dynamic> json) => LanguageModel(
        code: json['code'] as String? ?? '',
        name: json['name_uz'] as String? ?? json['name_ru'] as String? ?? '',
      );
}

class AnketaModel {
  final String? fullname;
  final String? gender;
  final String? birthday;
  final int? jobTypeId;
  final String? jobTypeName;
  final String? professionText;
  final int? regionId;
  final String? regionName;
  final int? districtId;
  final String? districtName;
  final int? experienceYear;
  final int? expectedSalary;
  final int? lastSalary;
  final String? workStatus;
  final String? workSchedule;
  final List<String> languages;
  final bool? hasLicense;
  final bool? hasCar;
  final bool? physicalWorkOk;
  final bool? computerLiteracy;
  final String? motivation;
  final String? previousJobReason;
  final String? additionalContact;
  final String? address;

  const AnketaModel({
    this.fullname,
    this.gender,
    this.birthday,
    this.jobTypeId,
    this.jobTypeName,
    this.professionText,
    this.regionId,
    this.regionName,
    this.districtId,
    this.districtName,
    this.experienceYear,
    this.expectedSalary,
    this.lastSalary,
    this.workStatus,
    this.workSchedule,
    this.languages = const [],
    this.hasLicense,
    this.hasCar,
    this.physicalWorkOk,
    this.computerLiteracy,
    this.motivation,
    this.previousJobReason,
    this.additionalContact,
    this.address,
  });

  factory AnketaModel.fromJson(Map<String, dynamic> json) => AnketaModel(
        fullname: json['fullname'] as String?,
        gender: json['gender'] as String?,
        birthday: json['birthday'] as String?,
        jobTypeId: json['job_type_id'] as int?,
        jobTypeName: json['job_type_name'] as String?,
        professionText: json['profession_text'] as String?,
        regionId: json['region_id'] as int?,
        regionName: json['region_name'] as String?,
        districtId: json['district_id'] as int?,
        districtName: json['district_name'] as String?,
        experienceYear: json['experience_year'] as int?,
        expectedSalary: json['expected_salary'] as int?,
        lastSalary: json['last_salary'] as int?,
        workStatus: json['work_status'] as String?,
        workSchedule: json['work_schedule'] as String?,
        languages: (json['languages'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        hasLicense: json['has_license'] as bool?,
        hasCar: json['has_car'] as bool?,
        physicalWorkOk: json['physical_work_ok'] as bool?,
        computerLiteracy: json['computer_literacy'] as bool?,
        motivation: json['motivation'] as String?,
        previousJobReason: json['previous_job_reason'] as String?,
        additionalContact: json['additional_contact'] as String?,
        address: json['address'] as String?,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (fullname != null) map['fullname'] = fullname;
    if (gender != null) map['gender'] = gender;
    if (birthday != null) map['birthday'] = birthday;
    if (jobTypeId != null) map['job_type_id'] = jobTypeId;
    if (professionText != null) map['profession_text'] = professionText;
    if (regionId != null) map['region_id'] = regionId;
    if (districtId != null) map['district_id'] = districtId;
    if (experienceYear != null) map['experience_year'] = experienceYear;
    if (expectedSalary != null) map['expected_salary'] = expectedSalary;
    if (lastSalary != null) map['last_salary'] = lastSalary;
    if (workStatus != null) map['work_status'] = workStatus;
    if (workSchedule != null) map['work_schedule'] = workSchedule;
    if (languages.isNotEmpty) map['languages'] = languages;
    if (hasLicense != null) map['has_license'] = hasLicense;
    if (hasCar != null) map['has_car'] = hasCar;
    if (physicalWorkOk != null) map['physical_work_ok'] = physicalWorkOk;
    if (computerLiteracy != null) map['computer_literacy'] = computerLiteracy;
    if (motivation != null) map['motivation'] = motivation;
    if (previousJobReason != null) map['previous_job_reason'] = previousJobReason;
    if (additionalContact != null) map['additional_contact'] = additionalContact;
    if (address != null) map['address'] = address;
    return map;
  }
}
