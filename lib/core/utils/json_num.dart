/// JSON'dagi raqamlarni **chidamli** o'qish.
///
/// ⚠ Nega kerak: backend bazadan kelgan `DECIMAL` ustunlarni JSON'ga kasr son
/// bo'lib chiqaradi (`"experience_year": 0.5`), ba'zi ustunlar esa Sequelize
/// orqali MATN bo'lib keladi (`"8000000.00"`). Dart'da `json['x'] as int?`
/// bunday qiymatda `type 'double' is not a subtype of type 'int?'` bilan
/// YIQILADI va bitta yozuv butun ro'yxatning `fromJson` ini o'ldiradi —
/// foydalanuvchi bo'sh ekran ko'radi.
///
/// Shuning uchun yangi DTO maydonlari raqamni SHU yordamchilar bilan o'qisin,
/// `as int?` / `as double?` bilan EMAS.
library;

/// Har qanday raqamli qiymatni `num` ga keltiradi (`null` — o'qib bo'lmasa).
num? asNum(Object? value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is bool) return value ? 1 : 0;
  final s = value.toString().trim();
  if (s.isEmpty) return null;
  return num.tryParse(s);
}

/// Butun songa keltiradi — kasrli kelsa YAXLITLANADI (`2.6` → `3`).
int? asInt(Object? value) => asNum(value)?.round();

/// Kasr songa keltiradi (`0.5` yo'qolmaydi).
double? asDouble(Object? value) => asNum(value)?.toDouble();

/// Raqamni ekranga chiqarish uchun matn: butun bo'lsa kasr qismi
/// KO'RSATILMAYDI (`3.0` → `3`), kasrli bo'lsa saqlanadi (`0.5` → `0.5`).
///
/// Tajriba yillari aynan shunday ko'rsatiladi: bazada `decimal(4,1)`, ya'ni
/// "yarim yil" (`0.5`) normal qiymat, lekin "3.0 yil" deb yozish xunuk.
String formatNum(num? value, {String ifNull = ''}) {
  if (value == null) return ifNull;
  if (value == value.roundToDouble()) return value.round().toString();
  return value.toString();
}
