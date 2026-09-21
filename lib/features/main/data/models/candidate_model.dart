import '../../../../core/constants/constants.dart';
import '../../../../core/utils/json_num.dart';
import 'contact_unlock_model.dart';

class CandidateProfessionModel {
  final int jobTypeId;
  final String name;

  /// Tajriba yillari — bazada `decimal(4,1)`, ya'ni `0.5` (yarim yil) normal
  /// qiymat. ⚠ `int` QILMANG: JSON'dan `double` kelib `fromJson` yiqiladi.
  final double experienceYear;

  const CandidateProfessionModel({
    required this.jobTypeId,
    required this.name,
    required this.experienceYear,
  });

  factory CandidateProfessionModel.fromJson(Map<String, dynamic> json) =>
      CandidateProfessionModel(
        jobTypeId: asInt(json['job_type_id']) ?? 0,
        name: json['name'] as String? ?? '',
        experienceYear: asDouble(json['experience_year']) ?? 0,
      );

  /// Ekran uchun: `3.0` emas `3`, lekin `0.5` saqlanadi.
  String get experienceDisplay => formatNum(experienceYear);
}

class CandidateLocationModel {
  final int id;
  final String name;

  const CandidateLocationModel({required this.id, required this.name});

  factory CandidateLocationModel.fromJson(Map<String, dynamic> json) =>
      CandidateLocationModel(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
      );
}

class WorkHistoryModel {
  final String? companyName;
  final String? position;
  final int? startYear;
  final int? endYear;

  const WorkHistoryModel({
    this.companyName,
    this.position,
    this.startYear,
    this.endYear,
  });

  bool get isCurrent => endYear == null;

  factory WorkHistoryModel.fromJson(Map<String, dynamic> json) =>
      WorkHistoryModel(
        companyName: json['company_name'] as String?,
        position: json['position'] as String?,
        startYear: asInt(json['start_year']),
        endYear: asInt(json['end_year']),
      );
}

class CandidateAssignmentModel {
  final int id;
  final String status;
  final String? interviewDatetime;
  final String? comment;

  const CandidateAssignmentModel({
    required this.id,
    required this.status,
    this.interviewDatetime,
    this.comment,
  });

  factory CandidateAssignmentModel.fromJson(Map<String, dynamic> json) =>
      CandidateAssignmentModel(
        id: asInt(json['id']) ?? 0,
        status: json['status'] as String? ?? '',
        interviewDatetime: json['interview_datetime'] as String?,
        comment: json['comment'] as String?,
      );
}

class CandidateVacancyRefModel {
  final int id;
  final int? jobTypeId;
  final CandidateLocationModel? jobType;
  final int? salary;
  final int? anketaCount;

  const CandidateVacancyRefModel({
    required this.id,
    this.jobTypeId,
    this.jobType,
    this.salary,
    this.anketaCount,
  });

  factory CandidateVacancyRefModel.fromJson(Map<String, dynamic> json) {
    final jtJson = json['job_type'] as Map<String, dynamic>?;
    return CandidateVacancyRefModel(
      id: json['id'] as int? ?? 0,
      jobTypeId: json['job_type_id'] as int?,
      jobType: jtJson != null ? CandidateLocationModel.fromJson(jtJson) : null,
      salary: json['salary'] as int?,
      anketaCount: json['anketa_count'] as int?,
    );
  }
}

/// Bayroqlar backend'da goh `true`, goh `"ha"`/`1` bo'lib keladi. Qattiq
/// `as bool?` bitta maydon uchun butun rezyume parse'ini yiqitardi.
bool? _asBool(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final v = value.trim().toLowerCase();
    if (v.isEmpty) return null;
    return const {'true', '1', 'ha', 'yes', 'bor', 'da'}.contains(v);
  }
  return null;
}

/// `public_id` goh `5501`, goh `"A-5501"` bo'lib keladi — raqamli qismini
/// olamiz, aks holda butun parse yiqilardi.
int? _asId(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  final digits = value.toString().replaceAll(RegExp(r'\D'), '');
  return digits.isEmpty ? null : int.tryParse(digits);
}

class CandidateModel {
  final int id;
  final int? publicId;
  final String? fullname;
  final String? gender;
  final int? age;
  final String? birthday;
  final String? photo;
  final CandidateLocationModel? region;
  final CandidateLocationModel? district;
  // job_type at root level (tanlangan tilda)
  final CandidateLocationModel? jobType;
  final List<CandidateProfessionModel> professions;
  final String? professionText;
  final int? expectedSalary;
  final int? lastSalary;

  /// `anketas.experience_year` — `decimal(4,1)`, kasrli bo'lishi mumkin.
  final double? rawExperienceYear;
  final String? information;
  final List<String> languages;
  final bool? hasLicense;
  final bool? hasCar;
  final bool? computerLiteracy;
  final bool? physicalWorkOk;
  final String? motivation;
  final String? previousJobReason;
  final String? workStatus;
  final List<String> workSchedule;
  final String? candidateCategory;
  final bool isBlacklisted;
  final double? matchScore;
  final String? matchBucket;
  // Server sets is_unlocked=true → phone field comes with response
  final bool isUnlocked;
  final String? phoneRaw;
  final String? additionalContact;
  // Detail endpoint gating (B varianti): full resume hidden until unlocked.
  // locked=true → only teaser fields returned; `fee` = one-time unlock price.
  final bool locked;
  final int? fee;
  // PROMPT_OTKLIK §3.4 — yopiq kartada narx bilan birga keladigan balans holati.
  final int? balance;
  final bool? canPayFromBalance;
  // §6 — ochilgan nomzodda: telefon · chat kaliti · suhbat.
  final ContactCapabilitiesModel? capabilities;
  // Recommended endpoint extras
  final bool recommended;
  final CandidateAssignmentModel? assignment;
  final CandidateVacancyRefModel? vacancy;
  // Detail endpoint extra
  final List<WorkHistoryModel> workHistory;

  const CandidateModel({
    required this.id,
    this.publicId,
    this.fullname,
    this.gender,
    this.age,
    this.birthday,
    this.photo,
    this.region,
    this.district,
    this.jobType,
    this.professions = const [],
    this.professionText,
    this.expectedSalary,
    this.lastSalary,
    this.rawExperienceYear,
    this.information,
    this.languages = const [],
    this.hasLicense,
    this.hasCar,
    this.computerLiteracy,
    this.physicalWorkOk,
    this.motivation,
    this.previousJobReason,
    this.workStatus,
    this.workSchedule = const [],
    this.candidateCategory,
    this.isBlacklisted = false,
    this.matchScore,
    this.matchBucket,
    this.isUnlocked = false,
    this.phoneRaw,
    this.additionalContact,
    this.locked = false,
    this.fee,
    this.balance,
    this.canPayFromBalance,
    this.capabilities,
    this.recommended = false,
    this.assignment,
    this.vacancy,
    this.workHistory = const [],
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    final rawProfessions = json['professions'];
    final professions = rawProfessions is List
        ? rawProfessions
            .map((e) =>
                CandidateProfessionModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <CandidateProfessionModel>[];

    final rawLangs = json['languages'];
    final langs = rawLangs is List
        ? rawLangs.map((e) => e.toString()).toList()
        : <String>[];

    final rawSchedule = json['work_schedule'];
    final schedule = rawSchedule is List
        ? rawSchedule.map((e) => e.toString()).toList()
        : <String>[];

    final rawHistory = json['work_history'];
    final workHistory = rawHistory is List
        ? rawHistory
            .map((e) =>
                WorkHistoryModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <WorkHistoryModel>[];

    CandidateLocationModel? locFrom(String key) {
      final v = json[key] as Map<String, dynamic>?;
      return v != null ? CandidateLocationModel.fromJson(v) : null;
    }

    final assignJson = json['assignment'] as Map<String, dynamic>?;
    final vacJson = json['vacancy'] as Map<String, dynamic>?;

    return CandidateModel(
      id: json['id'] as int? ?? 0,
      publicId: _asId(json['public_id']),
      fullname: json['fullname'] as String?,
      gender: json['gender'] as String?,
      age: asInt(json['age']),
      birthday: json['birthday'] as String?,
      photo: json['photo'] as String?,
      region: locFrom('region'),
      district: locFrom('district'),
      jobType: locFrom('job_type'),
      professions: professions,
      professionText: json['profession_text'] as String?,
      expectedSalary: asInt(json['expected_salary']),
      lastSalary: asInt(json['last_salary']),
      rawExperienceYear: asDouble(json['experience_year']),
      information: json['information'] as String?,
      languages: langs,
      hasLicense: _asBool(json['has_license']),
      hasCar: _asBool(json['has_car']),
      computerLiteracy: _asBool(json['computer_literacy']),
      physicalWorkOk: _asBool(json['physical_work_ok']),
      motivation: json['motivation'] as String?,
      previousJobReason: json['previous_job_reason'] as String?,
      workStatus: json['work_status'] as String?,
      workSchedule: schedule,
      candidateCategory: json['candidate_category'] as String?,
      isBlacklisted: _asBool(json['is_blacklisted']) ?? false,
      matchScore: asDouble(json['match_score']),
      matchBucket: json['match_bucket'] as String?,
      isUnlocked: _asBool(json['is_unlocked']) ?? false,
      phoneRaw: json['phone'] as String? ?? json['phone_number'] as String?,
      additionalContact: json['additional_contact'] as String?,
      locked: _asBool(json['locked']) ?? false,
      fee: asInt(json['fee']),
      balance: asInt(json['balance']),
      canPayFromBalance: json['can_pay_from_balance'] as bool?,
      capabilities: json['capabilities'] is Map
          ? ContactCapabilitiesModel.fromJson(
              Map<String, dynamic>.from(json['capabilities'] as Map))
          : null,
      recommended: _asBool(json['recommended']) ?? false,
      assignment: assignJson != null
          ? CandidateAssignmentModel.fromJson(assignJson)
          : null,
      vacancy:
          vacJson != null ? CandidateVacancyRefModel.fromJson(vacJson) : null,
      workHistory: workHistory,
    );
  }

  // ── Computed getters ─────────────────────────────────────────────────────────

  int get matchPercent => (matchScore ?? 0).round();

  // job_type root field (tanlangan tilda) → professions → profession_text
  String? get jobTypeName =>
      jobType?.name ??
      (professions.isNotEmpty ? professions.first.name : professionText);

  int? get jobTypeId =>
      jobType?.id ??
      (professions.isNotEmpty ? professions.first.jobTypeId : null);

  // Total experience from professions (more accurate); falls back to root field
  double? get experienceYear {
    if (professions.isNotEmpty) {
      final total =
          professions.fold<double>(0, (s, p) => s + p.experienceYear);
      return total;
    }
    return rawExperienceYear;
  }

  /// Tajribani ekranga chiqarish uchun: `3` / `0.5` (bo'sh bo'lsa `''`).
  String get experienceDisplay => formatNum(experienceYear);

  /// Rasm to'liq URL'i (PROMPT §6) — normalizatsiya [resolveMediaUrl] da.
  String? get photoUrl => resolveMediaUrl(photo);

  String get initials {
    if (fullname == null || fullname!.isEmpty) return '?';
    final parts = fullname!.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  /// Maskalangan telefon (PROMPT §3.4): `phone` yo'q → `+998 XX XXX-XX-XX`;
  /// bor → faqat operator kodi + oxirgi 2 raqam: `+998 90 XXX-XX-67`.
  String get maskedPhone {
    final digits = (phoneRaw ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) return '+998 XX XXX-XX-XX';
    final op = digits.substring(digits.length - 9, digits.length - 7);
    final last2 = digits.substring(digits.length - 2);
    return '+998 $op XXX-XX-$last2';
  }

  String get salaryDisplay {
    if (expectedSalary == null) return '';
    final n = expectedSalary!;
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)} mln so'm";
    return "$n so'm";
  }

  // Enum → readable label
  String get genderLabel {
    return switch (gender) {
      'male' => 'Erkak',
      'female' => 'Ayol',
      _ => '',
    };
  }

  String get workStatusLabel {
    return switch (workStatus) {
      'izlayapti' => 'Ish izlayapti',
      'ishsiz' => 'Ishsiz',
      'almashitirish' => 'Ish almashtirmoqchi',
      'topdi' => 'Ish topdi',
      'takliflar' => 'Takliflarni ko\'rmoqda',
      _ => workStatus ?? '',
    };
  }

  /// Til kodlari o'rniga o'qiladigan nom: `uz` → `O'zbek`.
  List<String> get languageLabels {
    const map = {
      'uz': "O'zbek",
      'ru': 'Rus',
      'en': 'Ingliz',
      'kk': 'Qozoq',
      'tr': 'Turk',
      'tj': 'Tojik',
      'kaa': 'Qoraqalpoq',
    };
    return languages.map((c) => map[c.toLowerCase()] ?? c).toList();
  }

  /// `premium_a` → `Premium A`. Toifalar ro'yxati CRM'da o'sib boradi,
  /// shuning uchun qat'iy jadval emas — formatlash.
  String? get candidateCategoryLabel {
    final raw = candidateCategory;
    if (raw == null || raw.isEmpty) return null;
    return raw
        .split(RegExp(r'[_\s]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w.length <= 2
            ? w.toUpperCase()
            : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  List<String> get workScheduleLabels {
    final map = {
      'full': 'To\'liq kun',
      'part': 'Yarim kun',
      'remote': 'Masofaviy',
      'flex': 'Erkin grafik',
    };
    return workSchedule.map((s) => map[s] ?? s).toList();
  }
}
