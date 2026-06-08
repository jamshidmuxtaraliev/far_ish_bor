class CreateVacancyRequest {
  final int? id;
  final int? jobTypeId;
  final int? anketaCount;
  final int? salary;
  final String? deadline;
  final int? minAge;
  final int? maxAge;
  final String? status;
  final String? comment;

  const CreateVacancyRequest({
    this.id,
    this.jobTypeId,
    this.anketaCount,
    this.salary,
    this.deadline,
    this.minAge,
    this.maxAge,
    this.status,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (id != null) map['id'] = id;
    if (jobTypeId != null) map['job_type_id'] = jobTypeId;
    if (anketaCount != null) map['anketa_count'] = anketaCount;
    if (salary != null) map['salary'] = salary;
    if (deadline != null) map['deadline'] = deadline;
    if (minAge != null) map['min_age'] = minAge;
    if (maxAge != null) map['max_age'] = maxAge;
    if (status != null) map['status'] = status;
    if (comment != null && comment!.isNotEmpty) map['comment'] = comment;
    return map;
  }
}
