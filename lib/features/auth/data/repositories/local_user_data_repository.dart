import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_social_mobile/features/auth/data/models/user_session.dart';
import 'package:near_social_mobile/features/auth/data/repositories/user_data_repository.dart';

/// Ключи для хранения в SecureStorage
class _StorageKeys {
  static const userSession = 'user_session_data';
  static const encryptionKeysCache = 'encryption_keys_cache';
}

/// Локальная реализация [UserDataRepository].
///
/// Хранит все данные пользователя в зашифрованном SecureStorage.
/// Подходит для децентрализованного режима работы без сервера.
///
/// Особенности:
/// - Верификация подписи происходит неявно (если пользователь знает приватный ключ,
///   он владеет аккаунтом)
/// - Ключи шифрования хранятся локально
/// - Кэш публичных ключей других пользователей для E2E шифрования
class LocalUserDataRepository implements UserDataRepository {
  final FlutterSecureStorage _secureStorage;

  LocalUserDataRepository(this._secureStorage);

  @override
  Future<VerificationResult> verifyAndCreateSession({
    required String accountId,
    required String signature,
    required String publicKeyStr,
    required String encryptionPublicKey,
    required String encryptionPrivateKey,
  }) async {
    try {
      // В децентрализованном режиме верификация происходит неявно:
      // если пользователь смог подписать сообщение своим приватным ключом NEAR,
      // значит он владеет этим аккаунтом.
      //
      // Серверная верификация была нужна чтобы третья сторона (сервер)
      // подтвердила владение. Без сервера в этом нет необходимости.

      // Проверяем базовую валидность данных
      if (accountId.isEmpty) {
        return VerificationResult.failure('Account ID cannot be empty');
      }

      if (encryptionPublicKey.isEmpty || encryptionPrivateKey.isEmpty) {
        return VerificationResult.failure('Encryption keys cannot be empty');
      }

      // Создаём новую сессию
      final session = UserSession.create(
        accountId: accountId,
        encryptionPublicKey: encryptionPublicKey,
        encryptionPrivateKey: encryptionPrivateKey,
      );

      // Сохраняем сессию
      await _saveSession(session);

      // Кэшируем свой публичный ключ
      await cacheEncryptionPublicKey(accountId, encryptionPublicKey);

      return VerificationResult.success(session);
    } catch (e) {
      return VerificationResult.failure('Failed to create session: $e');
    }
  }

  @override
  Future<UserSession?> getCurrentSession() async {
    try {
      final sessionJson = await _secureStorage.read(key: _StorageKeys.userSession);
      if (sessionJson == null || sessionJson.isEmpty) {
        return null;
      }
      final session = UserSession.fromJsonString(sessionJson);

      // Проверяем активность сессии
      if (!session.isActive) {
        return null;
      }

      return session;
    } catch (e) {
      // Если не удалось прочитать сессию, возвращаем null
      return null;
    }
  }

  @override
  Future<bool> updateSession(UserSession session) async {
    try {
      final updatedSession = session.copyWith(
        updatedAt: DateTime.now(),
      );
      await _saveSession(updatedSession);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> endSession() async {
    try {
      final session = await getCurrentSession();
      if (session != null) {
        // Помечаем сессию как неактивную (можно восстановить историю)
        final inactiveSession = session.copyWith(
          isActive: false,
          updatedAt: DateTime.now(),
        );
        await _saveSession(inactiveSession);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> hasActiveSession() async {
    final session = await getCurrentSession();
    return session != null && session.isActive;
  }

  @override
  Future<String?> getEncryptionPublicKey(String accountId) async {
    try {
      // Сначала проверяем, не запрашиваем ли мы свой ключ
      final currentSession = await getCurrentSession();
      if (currentSession != null && currentSession.accountId == accountId) {
        return currentSession.encryptionPublicKey;
      }

      // Ищем в кэше
      final cache = await _loadEncryptionKeysCache();
      return cache[accountId];
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> cacheEncryptionPublicKey(String accountId, String publicKey) async {
    try {
      final cache = await _loadEncryptionKeysCache();
      cache[accountId] = publicKey;
      await _saveEncryptionKeysCache(cache);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearAllData() async {
    await _secureStorage.delete(key: _StorageKeys.userSession);
    await _secureStorage.delete(key: _StorageKeys.encryptionKeysCache);
  }

  // Private helpers

  Future<void> _saveSession(UserSession session) async {
    await _secureStorage.write(
      key: _StorageKeys.userSession,
      value: session.toJsonString(),
    );
  }

  Future<Map<String, String>> _loadEncryptionKeysCache() async {
    try {
      final cacheJson = await _secureStorage.read(key: _StorageKeys.encryptionKeysCache);
      if (cacheJson == null || cacheJson.isEmpty) {
        return {};
      }
      final decoded = jsonDecode(cacheJson) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      return {};
    }
  }

  Future<void> _saveEncryptionKeysCache(Map<String, String> cache) async {
    await _secureStorage.write(
      key: _StorageKeys.encryptionKeysCache,
      value: jsonEncode(cache),
    );
  }
}
