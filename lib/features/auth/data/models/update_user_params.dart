import 'package:dio/dio.dart';

class UpdateUserParams {
  final int userId;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final String? login;
  final MultipartFile? image;

  UpdateUserParams(
    this.userId,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.login,
    this.image,
  );

  // FormData uchun map format
  Map<String, dynamic> toFormDataMap() {
    final map = <String, dynamic>{};

    if (firstName != null) map['first_name'] = firstName;
    if (lastName != null) map['last_name'] = lastName;
    if (phone != null) map['phone'] = phone;
    if (email != null) map['email'] = email;
    if (login != null) map['login'] = login;
    if (image != null) map['image'] = image; // Fayl MultipartFile holatida bo'lishi kerak

    return map;
  }
}
