import '../../../../core/constants/colors.dart';
import 'package:flutter/material.dart';

/// Suhbat (Interview) — seeker va employer ro'yxatlari hamda `live` endpoint
/// uchun yagona model (PROMPT_SUHBATLAR_MOBILE.md §2.1, §4).
class InterviewModel {
  final int id;
  final DateTime? scheduledAt;
  final String status; // pending|confirmed|done|cancelled|no_show
  final String travelStatus; // idle|on_way|arrived|stopped
  final String type; // offline|online
  final String? onlineLink;

  final InterviewEmployer? employer;
  final InterviewAnketa? anketa;
  final String? vacancyJobType;
  final int? vacancyId;

  // `live` endpoint (employer) — oxirgi tiklangan koordinata.
  final double? seekerLat;
  final double? seekerLng;
  final double? seekerAccuracy;
  final double? seekerHeading;
  final DateTime? locationAt;

  const InterviewModel({
    required this.id,
    this.scheduledAt,
    this.status = 'confirmed',
    this.travelStatus = 'idle',
    this.type = 'offline',
    this.onlineLink,
    this.employer,
    this.anketa,
    this.vacancyJobType,
    this.vacancyId,
    this.seekerLat,
    this.seekerLng,
    this.seekerAccuracy,
    this.seekerHeading,
    this.locationAt,
  });

  factory InterviewModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v as String).toLocal();
      } catch (_) {
        return null;
      }
    }

    double? toD(dynamic v) => v == null ? null : (v as num).toDouble();

    final vac = json['vacancy'] as Map<String, dynamic>?;
    final vacJobType = vac?['job_type'] as Map<String, dynamic>?;

    return InterviewModel(
      id: json['id'] as int? ?? 0,
      scheduledAt: parseDate(json['scheduled_at']),
      status: json['status'] as String? ?? 'confirmed',
      travelStatus: json['travel_status'] as String? ?? 'idle',
      type: json['type'] as String? ?? 'offline',
      onlineLink: json['online_link'] as String?,
      employer: json['employer'] is Map<String, dynamic>
          ? InterviewEmployer.fromJson(json['employer'] as Map<String, dynamic>)
          : null,
      anketa: json['anketa'] is Map<String, dynamic>
          ? InterviewAnketa.fromJson(json['anketa'] as Map<String, dynamic>)
          : null,
      vacancyJobType: vacJobType?['name'] as String?,
      vacancyId: vac?['id'] as int?,
      seekerLat: toD(json['seeker_lat']),
      seekerLng: toD(json['seeker_lng']),
      seekerAccuracy: toD(json['seeker_accuracy']),
      seekerHeading: toD(json['seeker_heading']),
      locationAt: parseDate(json['location_at']),
    );
  }

  bool get isOnline => type == 'online';
  bool get isOnWay => travelStatus == 'on_way';
  bool get isArrived => travelStatus == 'arrived';

  /// Seeker hali boshqara oladigan (yakunlanmagan) suhbatmi.
  bool get isManageable =>
      status != 'done' && status != 'cancelled' && status != 'no_show';

  /// `scheduled_at` → `23.06.2026 09:00`.
  String get scheduledDisplay {
    final d = scheduledAt;
    if (d == null) return '—';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  String get statusLabel => switch (status) {
        'pending' => 'Kutilmoqda',
        'confirmed' => 'Tasdiqlandi',
        'done' => 'Yakunlandi',
        'cancelled' => 'Bekor qilindi',
        'no_show' => 'Kelmadi',
        _ => status,
      };

  Color get statusColor => switch (status) {
        'pending' => GRAY_TEXT,
        'confirmed' => PRIMARY_BLUE,
        'done' => GREEN_COLOR,
        'cancelled' => RED_COLOR,
        'no_show' => AMBER_COLOR,
        _ => GRAY_TEXT,
      };

  String get travelLabel => switch (travelStatus) {
        'idle' => 'Boshlanmagan',
        'on_way' => "Yo'lda",
        'arrived' => 'Yetib keldi',
        'stopped' => "To'xtatildi",
        _ => travelStatus,
      };

  Color get travelColor => switch (travelStatus) {
        'on_way' => AMBER_COLOR,
        'arrived' => GREEN_COLOR,
        _ => GRAY_TEXT,
      };
}

class InterviewEmployer {
  final int id;
  final String? name;
  final String? phone;
  final String? address;
  final double? latitude;
  final double? longitude;
  final bool isVerified;

  const InterviewEmployer({
    required this.id,
    this.name,
    this.phone,
    this.address,
    this.latitude,
    this.longitude,
    this.isVerified = false,
  });

  bool get hasCoords => latitude != null && longitude != null;

  factory InterviewEmployer.fromJson(Map<String, dynamic> json) {
    double? toD(dynamic v) => v == null ? null : (v as num).toDouble();
    return InterviewEmployer(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      latitude: toD(json['latitude']),
      longitude: toD(json['longitude']),
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }
}

class InterviewAnketa {
  final int id;
  final String? fullname;
  final String? phoneNumber;

  const InterviewAnketa({required this.id, this.fullname, this.phoneNumber});

  factory InterviewAnketa.fromJson(Map<String, dynamic> json) => InterviewAnketa(
        id: json['id'] as int? ?? 0,
        fullname: json['fullname'] as String?,
        phoneNumber: json['phone_number'] as String?,
      );
}

/// Socket `interview:location` orqali kelgan jonli nuqta.
class LiveLocation {
  final double lat;
  final double lng;
  final double? accuracy;
  final double? heading;
  final DateTime at;

  const LiveLocation({
    required this.lat,
    required this.lng,
    this.accuracy,
    this.heading,
    required this.at,
  });

  factory LiveLocation.fromJson(Map<String, dynamic> json) {
    double? toD(dynamic v) => v == null ? null : (v as num).toDouble();
    DateTime parseAt(dynamic v) {
      if (v is String) {
        return DateTime.tryParse(v)?.toLocal() ?? DateTime.now();
      }
      return DateTime.now();
    }

    return LiveLocation(
      lat: toD(json['lat']) ?? 0,
      lng: toD(json['lng']) ?? 0,
      accuracy: toD(json['accuracy']),
      heading: toD(json['heading']),
      at: parseAt(json['at']),
    );
  }
}
