/// `GET /stats/public` javobi — platformaning ochiq raqamlari.
///
/// Bu yagona auth talab qilmaydigan statistika endpointi (qolgan `/stats/*`
/// ichki biznes ma'lumoti va token so'raydi). Ommaviy sayt landing'i ham
/// aynan shundan oziqlanadi, shuning uchun sayt bilan ilovadagi raqam
/// har doim bir xil bo'ladi.
class PublicStatsModel {
  /// Jami foydalanuvchilar (ish izlovchi + ish beruvchi).
  final int users;
  final int seekers;
  final int employers;

  /// Ishga joylashganlar (`anketa_assignments` dagi qabul qilingan statuslar).
  final int hired;

  /// FAOL vakansiyalar — bosh ekrandagi "Ish o'rinlari".
  final int vacancies;

  const PublicStatsModel({
    required this.users,
    required this.seekers,
    required this.employers,
    required this.hired,
    required this.vacancies,
  });

  factory PublicStatsModel.fromJson(Map<String, dynamic> json) {
    int n(String key) => (json[key] as num?)?.toInt() ?? 0;
    return PublicStatsModel(
      users: n('users'),
      seekers: n('seekers'),
      employers: n('employers'),
      hired: n('hired'),
      vacancies: n('vacancies'),
    );
  }

  /// Baza bo'm-bo'sh (yangi muhit) — nol ko'rsatgandan ko'ra blokni umuman
  /// chiqarmagan ma'qul.
  bool get isEmpty => seekers == 0 && employers == 0 && hired == 0;
}
