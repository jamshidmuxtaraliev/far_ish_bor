import 'dart:math' as math;

/// Ikki koordinata orasidagi to'g'ri chiziqli masofa (km) — haversine.
/// PROMPT_SUHBATLAR_MOBILE.md §7: ETA/masofa to'g'ri chiziq bilan hisoblanadi.
double haversineKm(double lat1, double lng1, double lat2, double lng2) {
  const earthR = 6371.0; // km
  final dLat = _rad(lat2 - lat1);
  final dLng = _rad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_rad(lat1)) *
          math.cos(_rad(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthR * c;
}

double _rad(double deg) => deg * math.pi / 180.0;

/// Masofani odam o'qiy oladigan ko'rinishda: `850 m` yoki `3.4 km`.
String distanceDisplay(double km) {
  if (km < 1) return '${(km * 1000).round()} m';
  return '${km.toStringAsFixed(1)} km';
}

/// Taxminiy yetib borish vaqti (ETA). Standart shahar tezligi ~30 km/soat.
String etaDisplay(double km, {double speedKmh = 30}) {
  if (speedKmh <= 0) return '—';
  final minutes = (km / speedKmh * 60).round();
  if (minutes < 1) return '< 1 daqiqa';
  if (minutes < 60) return '$minutes daqiqa';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '$h soat' : '$h soat $m daqiqa';
}
