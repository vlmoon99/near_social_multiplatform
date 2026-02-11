// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserSession _$UserSessionFromJson(Map<String, dynamic> json) => _UserSession(
  accountId: json['account_id'] as String,
  encryptionPublicKey: json['encryption_public_key'] as String,
  encryptionPrivateKey: json['encryption_private_key'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  isActive: json['is_active'] as bool? ?? true,
);

Map<String, dynamic> _$UserSessionToJson(_UserSession instance) =>
    <String, dynamic>{
      'account_id': instance.accountId,
      'encryption_public_key': instance.encryptionPublicKey,
      'encryption_private_key': instance.encryptionPrivateKey,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'is_active': instance.isActive,
    };
