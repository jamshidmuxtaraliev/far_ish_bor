/// Kontakt (korxona telefoni + chat) ochilishini boshqaruvchi qoida.
///
/// Ish izlovchi vakansiyaga ariza yuborgani bilan korxona telefonini yoki chatni
/// ko'ra olmaydi — bular faqat **ish beruvchi arizani qabul qilgandan** keyin
/// ochiladi. `pending`/`viewed` hali qabul emas, `rejected`/`missed` da esa
/// yopiq qoladi.
const Set<String> kAcceptedApplicationStatuses = {
  'invited',
  'scheduled',
  'confirmed',
  'on_way',
  'arrived',
  'accepted',
  'probation',
  'hired',
  'qabul_qilindi',
};

/// True — ariza qabul qilingan, ya'ni kontaktlar ochiq.
bool isApplicationAccepted(String? status) =>
    status != null && kAcceptedApplicationStatuses.contains(status);

/// Kontakt yopiq bo'lganda ko'rsatiladigan izoh.
const String kContactLockedHint =
    'Ish beruvchi arizangizni qabul qilgach ochiladi';
