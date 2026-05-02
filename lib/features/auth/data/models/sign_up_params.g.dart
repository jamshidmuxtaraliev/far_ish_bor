// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_up_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignUpParams _$SignUpParamsFromJson(Map<String, dynamic> json) => SignUpParams(
  (json['user_id'] as num).toInt(),
  json['login'] as String,
  json['password'] as String,
  json['isOwner'] as bool,
  json['isCompany'] as bool,
  json['companyName'] as String,
  json['inn'] as String,
  json['legal_name'] as String,
  json['phone'] as String,
  json['sms_code'] as String,
);

Map<String, dynamic> _$SignUpParamsToJson(SignUpParams instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'login': instance.login,
      'password': instance.password,
      'isOwner': instance.isOwner,
      'isCompany': instance.isCompany,
      'companyName': instance.companyName,
      'inn': instance.inn,
      'legal_name': instance.legal_name,
      'phone': instance.phone,
      'sms_code': instance.sms_code,
    };
