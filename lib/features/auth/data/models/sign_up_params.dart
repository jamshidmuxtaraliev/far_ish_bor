import 'package:json_annotation/json_annotation.dart';

part 'sign_up_params.g.dart';

@JsonSerializable()
class SignUpParams {
  int user_id;
  String login;
  String password;
  bool isOwner;
  bool isCompany;
  String companyName;
  String inn;
  String legal_name;
  String phone;
  String sms_code;

  SignUpParams(
    this.user_id,
    this.login,
    this.password,
    this.isOwner,
    this.isCompany,
    this.companyName,
    this.inn,
    this.legal_name,
    this.phone,
    this.sms_code,
  );

  factory SignUpParams.fromJson(Map<String, dynamic> json) {
    return _$SignUpParamsFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$SignUpParamsToJson(this);
  }
}
