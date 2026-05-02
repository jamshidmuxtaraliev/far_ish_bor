// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num?)?.toInt(),
  first_name: json['first_name'] as String?,
  last_name: json['last_name'] as String?,
  email: json['email'] as String?,
  payment_day: (json['payment_day'] as num?)?.toInt(),
  gender: (json['gender'] as num?)?.toInt(),
  role_id: (json['role_id'] as num?)?.toInt(),
  class_id: (json['class_id'] as num?)?.toInt(),
  phone_number: json['phone_number'] as String?,
  cover_media_id: json['cover_media_id'] as String?,
  cover_media_path: json['cover_media_path'] as String?,
  profile_media_id: json['profile_media_id'] as String?,
  profile_media_path: json['profile_media_path'] as String?,
  father_name: json['father_name'] as String?,
  birth_date: json['birth_date'] as String?,
  balance: json['balance'] as String?,
  class_name: json['class_name'] as String?,
  extra_info: json['extra_info'] as String?,
  education_info: json['education_info'] as String?,
  subject_name: json['subject_name'] as String?,
  experience_years: (json['experience_years'] as num?)?.toDouble(),
  avg_score: json['avg_score'] as String?,
  token: json['token'] as String?,
  children_ids:
      (json['children_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.first_name,
  'last_name': instance.last_name,
  'email': instance.email,
  'payment_day': instance.payment_day,
  'gender': instance.gender,
  'role_id': instance.role_id,
  'class_id': instance.class_id,
  'phone_number': instance.phone_number,
  'cover_media_id': instance.cover_media_id,
  'cover_media_path': instance.cover_media_path,
  'profile_media_id': instance.profile_media_id,
  'profile_media_path': instance.profile_media_path,
  'father_name': instance.father_name,
  'birth_date': instance.birth_date,
  'balance': instance.balance,
  'class_name': instance.class_name,
  'extra_info': instance.extra_info,
  'education_info': instance.education_info,
  'subject_name': instance.subject_name,
  'experience_years': instance.experience_years,
  'avg_score': instance.avg_score,
  'token': instance.token,
  'children_ids': instance.children_ids,
};
