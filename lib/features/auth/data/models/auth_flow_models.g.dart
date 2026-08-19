// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_flow_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckPhoneModel _$CheckPhoneModelFromJson(Map<String, dynamic> json) =>
    CheckPhoneModel(
      registered: json['registered'] as bool? ?? false,
      canLogin: json['can_login'] as bool? ?? false,
      role: json['role'] as String?,
    );

SendCodeModel _$SendCodeModelFromJson(Map<String, dynamic> json) =>
    SendCodeModel(
      sent: json['sent'] as bool? ?? false,
      via: json['via'] as String?,
      ttlSeconds: (json['ttl_seconds'] as num?)?.toInt() ?? 300,
      reason: json['reason'] as String?,
      botLink: json['bot_link'] as String?,
      debugCode: json['debug_code'] as String?,
    );

VerifyCodeModel _$VerifyCodeModelFromJson(Map<String, dynamic> json) =>
    VerifyCodeModel(
      verified: json['verified'] as bool? ?? false,
      regToken: json['reg_token'] as String?,
      ttlSeconds: (json['ttl_seconds'] as num?)?.toInt() ?? 1800,
      registered: json['registered'] as bool? ?? false,
      role: json['role'] as String?,
    );
