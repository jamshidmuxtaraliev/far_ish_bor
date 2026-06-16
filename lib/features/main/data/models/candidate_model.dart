class CandidateProfessionModel {
  final int jobTypeId;
  final String name;
  final int experienceYear;

  const CandidateProfessionModel({
    required this.jobTypeId,
    required this.name,
    required this.experienceYear,
  });

  factory CandidateProfessionModel.fromJson(Map<String, dynamic> json) =>
      CandidateProfessionModel(
        jobTypeId: json['job_type_id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        experienceYear: json['experience_year'] as int? ?? 0,
      );
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
        startYear: json['start_year'] as int?,
        endYear: json['end_year'] as int?,
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
        id: json['id'] as int? ?? 0,
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
  final int? rawExperienceYear;
  final String? information;
  final List<String> languages;
  final bool? hasLicense;
  final bool? hasCar;
  final String? computerLiteracy;
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
      publicId: json['public_id'] as int?,
      fullname: json['fullname'] as String?,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      birthday: json['birthday'] as String?,
      photo: json['photo'] as String?,
      region: locFrom('region'),
      district: locFrom('district'),
      jobType: locFrom('job_type'),
      professions: professions,
      professionText: json['profession_text'] as String?,
      expectedSalary: json['expected_salary'] as int?,
      lastSalary: json['last_salary'] as int?,
      rawExperienceYear: json['experience_year'] as int?,
      information: json['information'] as String?,
      languages: langs,
      hasLicense: json['has_license'] as bool?,
      hasCar: json['has_car'] as bool?,
      computerLiteracy: json['computer_literacy'] as String?,
      physicalWorkOk: json['physical_work_ok'] as bool?,
      motivation: json['motivation'] as String?,
      previousJobReason: json['previous_job_reason'] as String?,
      workStatus: json['work_status'] as String?,
      workSchedule: schedule,
      candidateCategory: json['candidate_category'] as String?,
      isBlacklisted: json['is_blacklisted'] as bool? ?? false,
      matchScore: (json['match_score'] as num?)?.toDouble(),
      matchBucket: json['match_bucket'] as String?,
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      phoneRaw: json['phone'] as String? ?? json['phone_number'] as String?,
      additionalContact: json['additional_contact'] as String?,
      recommended: json['recommended'] as bool? ?? false,
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
  int? get experienceYear {
    if (professions.isNotEmpty) {
      final total = professions.fold<int>(0, (s, p) => s + p.experienceYear);
      return total;
    }
    return rawExperienceYear;
  }

  String get initials {
    if (fullname == null || fullname!.isEmpty) return '?';
    final parts = fullname!.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  String? get maskedPhone {
    final p = phoneRaw;
    if (p == null || p.length < 6) return p;
    return '${p.substring(0, p.length - 4)}****';
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
