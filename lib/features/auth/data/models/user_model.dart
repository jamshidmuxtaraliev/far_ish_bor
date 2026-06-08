class UserModel {
  final int? id;
  final String? phone;
  final String? role;
  final String? token;
  // Seeker fields (from nested anketa)
  final String? fullname;
  final String? jobTypeName;
  final int? experienceYear;
  final int? expectedSalary;
  final String? workStatus;
  // Employer fields (from nested employer)
  final String? companyName;
  final String? contactPerson;

  UserModel({
    this.id,
    this.phone,
    this.role,
    this.token,
    this.fullname,
    this.jobTypeName,
    this.experienceYear,
    this.expectedSalary,
    this.workStatus,
    this.companyName,
    this.contactPerson,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final anketa = json['anketa'] as Map<String, dynamic>? ?? {};
    final employer = json['employer'] as Map<String, dynamic>? ?? {};
    return UserModel(
      id: json['id'] as int?,
      phone: json['phone'] as String?,
      role: json['role'] as String?,
      token: json['token'] as String?,
      fullname: anketa['fullname'] as String?,
      jobTypeName: anketa['job_type_name'] as String?,
      experienceYear: anketa['experience_year'] as int?,
      expectedSalary: anketa['expected_salary'] as int?,
      workStatus: anketa['work_status'] as String?,
      companyName: employer['name'] as String?,
      contactPerson: employer['contact_person'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'role': role,
        'token': token,
        'anketa': {
          'fullname': fullname,
          'job_type_name': jobTypeName,
          'experience_year': experienceYear,
          'expected_salary': expectedSalary,
          'work_status': workStatus,
        },
        'employer': {
          'name': companyName,
          'contact_person': contactPerson,
        },
      };

  String get displayName {
    if (role == 'employer') return companyName ?? 'Kompaniya';
    return fullname ?? 'Foydalanuvchi';
  }

  String get initials {
    final name = displayName;
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
