import 'package:muto_driver_app/app/features/authentication/data/models/courier_model.dart';

class UserModel {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? emailVerifiedAt;
  final String? fcmToken;
  final String? deviceTokens;
  final String? preferredLanguage;
  final String? role;
  final DateTime? lastLoginAt;
  final DateTime? verificationCodeExpiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  CourierModel? courier;

  UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.emailVerifiedAt,
    this.fcmToken,
    this.deviceTokens,
    this.preferredLanguage,
    this.role,
    this.lastLoginAt,
    this.verificationCodeExpiresAt,
    this.createdAt,
    this.updatedAt,
    this.courier,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        email: json['email'],
        phone: json['phone'],
        emailVerifiedAt: json['email_verified_at'],
        fcmToken: json['fcm_token'],
        deviceTokens: json['device_tokens'],
        preferredLanguage: json['preferred_language'],
        role: json['role'],
        lastLoginAt: json['last_login_at'] == null
            ? null
            : DateTime.parse(json['last_login_at']),
        verificationCodeExpiresAt: json['verification_code_expires_at'] == null
            ? null
            : DateTime.parse(json['verification_code_expires_at']),
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at']),
        courier: json['courier'] != null
            ? CourierModel.fromJson(json['courier'])
            : null,
      );
}
