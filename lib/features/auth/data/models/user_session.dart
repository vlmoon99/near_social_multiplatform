// ignore_for_file: invalid_annotation_target
import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_session.freezed.dart';
part 'user_session.g.dart';

@freezed
abstract class UserSession with _$UserSession {
  const UserSession._();

  const factory UserSession({
    @JsonKey(name: 'account_id') required String accountId,
    @JsonKey(name: 'encryption_public_key') required String encryptionPublicKey,
    @JsonKey(name: 'encryption_private_key')
    required String encryptionPrivateKey,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _UserSession;

  factory UserSession.create({
    required String accountId,
    required String encryptionPublicKey,
    required String encryptionPrivateKey,
  }) {
    final now = DateTime.now();
    return UserSession(
      accountId: accountId,
      encryptionPublicKey: encryptionPublicKey,
      encryptionPrivateKey: encryptionPrivateKey,
      createdAt: now,
      updatedAt: now,
      isActive: true,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserSession.fromJson(Map<String, dynamic> json) =>
      _$UserSessionFromJson(json);

  factory UserSession.fromJsonString(String jsonString) {
    return UserSession.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>);
  }
}
