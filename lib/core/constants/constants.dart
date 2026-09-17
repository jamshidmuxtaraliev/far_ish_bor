/// API manzili. Standart — PROD; boshqa serverga ulanish uchun kodni
/// tahrirlash SHART EMAS, buyruqqa `--dart-define` qo'shiladi:
///
///   fvm flutter run --dart-define=API_DOMAIN=http://192.168.x.x:5024
///
/// ⚠ Lokal backend `http://` bo'ladi — Android 9+ ochiq HTTP'ni bloklaydi.
/// Shuning uchun `android/app/src/debug/AndroidManifest.xml` da (FAQAT debug)
/// `usesCleartextTraffic=true` qo'yilgan; release build'ga ta'sir qilmaydi.
const String DOMAIN = String.fromEnvironment(
  'API_DOMAIN',
  defaultValue: 'https://api.jobup24.uz',
);
const String BASE_URL = "$DOMAIN/api/v1/";
const String BASE_IMAGE_URL = "$DOMAIN/api/v1/uploads/";

/// Serverdan kelgan media yo'lini to'liq URL'ga aylantiradi.
///
/// Yo'l goh `logo-1718.png`, goh `uploads/employer/logo-1718.png`
/// (mobile-employer-api.md §2.3), goh tayyor `http…` bo'lib keladi —
/// `uploads/` prefiksi ikkilanmasligi uchun bitta joyda normalizatsiya.
String? resolveMediaUrl(String? path) {
  final p = path;
  if (p == null || p.isEmpty) return null;
  if (p.startsWith('http')) return p;
  return '$BASE_IMAGE_URL${p.startsWith('uploads/') ? p.substring(8) : p}';
}

const String UZ_LANG_KEY = "uz";
const String RU_LANG_KEY = "ru";
const String DEFAULT_LANG_KEY = UZ_LANG_KEY;

const String PREF_USER = "prefUser";
const String PREF_TOKEN = "PREF_TOKEN";
const String PREF_ROLE = "PREF_ROLE";
const String FIRST_RUN = "FIRST_RUN";
const String PREF_LANG = "PREF_LANG";
const String PREF_THEME = "PREF_THEME";
const String PREF_RESUME_FILE = "PREF_RESUME_FILE";

const String SourceSerifPro = 'Montserrat';
const String SFPRODISPLAY = 'GothamPro';