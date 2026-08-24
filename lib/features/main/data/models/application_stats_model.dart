/// PROMPT_VAKANSIYA_OTKLIKLARI_MOBILE.md §3.1 — vakansiya bo'yicha otklik
/// (ariza) statistikasi. Eski backend `applications` obyektini yubormasligi
/// mumkin — u holda qisqa yorliqlardan (`applications_count`) yig'iladi.
class ApplicationStatsModel {
  final int total;

  /// `status = pending` — ish beruvchi hali ko'rmagan arizalar.
  final int newCount;
  final int inProgress;
  final int hired;
  final int closed;
  final Map<String, int> byStatus;

  const ApplicationStatsModel({
    this.total = 0,
    this.newCount = 0,
    this.inProgress = 0,
    this.hired = 0,
    this.closed = 0,
    this.byStatus = const {},
  });

  static const empty = ApplicationStatsModel();

  bool get isEmpty => total == 0;

  factory ApplicationStatsModel.fromJson(Map<String, dynamic> json) {
    final raw = json['by_status'];
    final byStatus = <String, int>{};
    if (raw is Map) {
      raw.forEach((k, v) {
        final n = (v as num?)?.toInt();
        if (n != null) byStatus['$k'] = n;
      });
    }
    return ApplicationStatsModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      newCount: (json['new'] as num?)?.toInt() ?? 0,
      inProgress: (json['in_progress'] as num?)?.toInt() ?? 0,
      hired: (json['hired'] as num?)?.toInt() ?? 0,
      closed: (json['closed'] as num?)?.toInt() ?? 0,
      byStatus: byStatus,
    );
  }

  /// Vakansiya obyektidan: `applications` bo'lsa o'shandan, aks holda
  /// `applications_count` / `new_applications_count` yorliqlaridan.
  factory ApplicationStatsModel.fromVacancyJson(Map<String, dynamic> json) {
    final nested = json['applications'];
    if (nested is Map<String, dynamic>) {
      return ApplicationStatsModel.fromJson(nested);
    }
    return ApplicationStatsModel(
      total: (json['applications_count'] as num?)?.toInt() ?? 0,
      newCount: (json['new_applications_count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// §4.2 `contact_policy` — telefon/chat bepulmi yoki har bir nomzod `fee`
/// evaziga ochiladimi.
class ContactPolicyModel {
  final bool freeContacts;
  final int fee;

  const ContactPolicyModel({this.freeContacts = false, this.fee = 0});

  factory ContactPolicyModel.fromJson(Map<String, dynamic> json) =>
      ContactPolicyModel(
        freeContacts: json['free_contacts'] as bool? ?? false,
        fee: (json['fee'] as num?)?.toInt() ?? 0,
      );
}
