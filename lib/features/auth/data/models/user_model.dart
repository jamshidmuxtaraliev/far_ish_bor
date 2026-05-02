import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int? id;
  final String? first_name;
  final String? last_name;
  final String? email;
  final int? payment_day;
  final int? gender;
  final int? role_id;
  final int? class_id;
  final String? phone_number;
  final String? cover_media_id;
  final String? cover_media_path;
  final String? profile_media_id;
  final String? profile_media_path;
  final String? father_name;
  final String? birth_date;
  final String? balance;
  final String? class_name;
  final String? extra_info;
  final String? education_info;
  final String? subject_name;
  final double? experience_years;
  final String? avg_score;
  final String? token;
  final List<int>? children_ids;

  UserModel({
    this.id,
    this.first_name,
    this.last_name,
    this.email,
    this.payment_day,
    this.gender,
    this.role_id,
    this.class_id,
    this.phone_number,
    this.cover_media_id,
    this.cover_media_path,
    this.profile_media_id,
    this.profile_media_path,
    this.father_name,
    this.birth_date,
    this.balance,
    this.class_name,
    this.extra_info,
    this.education_info,
    this.subject_name,
    this.experience_years,
    this.avg_score,
    this.token,
    this.children_ids,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    int? id,
    String? first_name,
    String? last_name,
    String? email,
    int? payment_day,
    int? gender,
    int? role_id,
    int? class_id,
    String? phone_number,
    String? cover_media_id,
    String? cover_media_path,
    String? profile_media_id,
    String? profile_media_path,
    String? father_name,
    String? birth_date,
    String? balance,
    String? class_name,
    String? extra_info,
    String? education_info,
    String? subject_name,
    double? experience_years,
    String? avg_score,
    String? token,
    List<int>? children_ids,
  }) {
    return UserModel(
      id: id ?? this.id,
      first_name: first_name ?? this.first_name,
      last_name: last_name ?? this.last_name,
      email: email ?? this.email,
      payment_day: payment_day ?? this.payment_day,
      gender: gender ?? this.gender,
      role_id: role_id ?? this.role_id,
      class_id: class_id ?? this.class_id,
      phone_number: phone_number ?? this.phone_number,
      cover_media_id: cover_media_id ?? this.cover_media_id,
      cover_media_path: cover_media_path ?? this.cover_media_path,
      profile_media_id: profile_media_id ?? this.profile_media_id,
      profile_media_path: profile_media_path ?? this.profile_media_path,
      father_name: father_name ?? this.father_name,
      birth_date: birth_date ?? this.birth_date,
      balance: balance ?? this.balance,
      class_name: class_name ?? this.class_name,
      extra_info: extra_info ?? this.extra_info,
      education_info: education_info ?? this.education_info,
      subject_name: subject_name ?? this.subject_name,
      experience_years: experience_years ?? this.experience_years,
      avg_score: avg_score ?? this.avg_score,
      token: token ?? this.token,
      children_ids: children_ids ?? this.children_ids,
    );
  }
}
