import 'user_model.dart';

class AuthResponseModel {
  final String token;
  final String role;
  final UserModel? user;

  AuthResponseModel({required this.token, required this.role, this.user});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String? ?? '',
      role: json['role'] as String? ?? '',
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
