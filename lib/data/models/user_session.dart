import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Модель сессии пользователя, хранящая данные для E2E шифрования
/// и идентификации в системе.
class UserSession extends Equatable {
  /// NEAR account ID пользователя (e.g., "user.near")
  final String accountId;

  /// Публичный ключ для шифрования сообщений (X25519)
  final String encryptionPublicKey;

  /// Приватный ключ для расшифровки сообщений (X25519)
  final String encryptionPrivateKey;

  /// Дата создания сессии
  final DateTime createdAt;

  /// Дата последнего обновления
  final DateTime updatedAt;

  /// Активна ли сессия
  final bool isActive;

  const UserSession({
    required this.accountId,
    required this.encryptionPublicKey,
    required this.encryptionPrivateKey,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

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

  UserSession copyWith({
    String? accountId,
    String? encryptionPublicKey,
    String? encryptionPrivateKey,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserSession(
      accountId: accountId ?? this.accountId,
      encryptionPublicKey: encryptionPublicKey ?? this.encryptionPublicKey,
      encryptionPrivateKey: encryptionPrivateKey ?? this.encryptionPrivateKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
      'encryption_public_key': encryptionPublicKey,
      'encryption_private_key': encryptionPrivateKey,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      accountId: json['account_id'] as String,
      encryptionPublicKey: json['encryption_public_key'] as String,
      encryptionPrivateKey: json['encryption_private_key'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserSession.fromJsonString(String jsonString) {
    return UserSession.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  List<Object?> get props => [
        accountId,
        encryptionPublicKey,
        encryptionPrivateKey,
        createdAt,
        updatedAt,
        isActive,
      ];

  @override
  bool? get stringify => true;
}
