import 'package:near_social_mobile/data/models/user_session.dart';

/// Результат верификации аккаунта
class VerificationResult {
  final bool success;
  final String? errorMessage;
  final UserSession? session;

  const VerificationResult({
    required this.success,
    this.errorMessage,
    this.session,
  });

  factory VerificationResult.success(UserSession session) {
    return VerificationResult(success: true, session: session);
  }

  factory VerificationResult.failure(String message) {
    return VerificationResult(success: false, errorMessage: message);
  }
}

/// Абстрактный интерфейс для работы с данными пользователя.
///
/// Позволяет легко переключаться между реализациями:
/// - [LocalUserDataRepository] - локальное хранение в SecureStorage
/// - RemoteUserDataRepository - серверное хранение (Supabase, custom backend)
/// - HybridUserDataRepository - комбинированный подход
///
/// Пример использования:
/// ```dart
/// // В CoreModule
/// i.addSingleton<UserDataRepository>(() => LocalUserDataRepository(secureStorage));
///
/// // Позже можно заменить на:
/// i.addSingleton<UserDataRepository>(() => RemoteUserDataRepository(apiClient));
/// ```
abstract class UserDataRepository {
  /// Верифицирует владение NEAR аккаунтом и создаёт/обновляет сессию.
  ///
  /// [accountId] - NEAR account ID (e.g., "user.near")
  /// [signature] - Подпись сообщения приватным ключом NEAR
  /// [publicKeyStr] - Публичный ключ NEAR в base58 формате
  /// [encryptionPublicKey] - Публичный ключ для E2E шифрования
  /// [encryptionPrivateKey] - Приватный ключ для E2E шифрования (хранится локально)
  Future<VerificationResult> verifyAndCreateSession({
    required String accountId,
    required String signature,
    required String publicKeyStr,
    required String encryptionPublicKey,
    required String encryptionPrivateKey,
  });

  /// Получает текущую сессию пользователя.
  /// Возвращает null если сессия не найдена или истекла.
  Future<UserSession?> getCurrentSession();

  /// Обновляет данные сессии.
  Future<bool> updateSession(UserSession session);

  /// Завершает текущую сессию (logout).
  Future<bool> endSession();

  /// Проверяет, есть ли активная сессия.
  Future<bool> hasActiveSession();

  /// Получает публичный ключ шифрования для указанного аккаунта.
  /// Используется для E2E шифрования сообщений.
  ///
  /// Для локальной реализации возвращает null для других пользователей.
  /// Для серверной реализации запрашивает ключ с сервера.
  Future<String?> getEncryptionPublicKey(String accountId);

  /// Сохраняет публичный ключ шифрования (для кэширования ключей собеседников).
  Future<bool> cacheEncryptionPublicKey(String accountId, String publicKey);

  /// Очищает все данные пользователя.
  Future<void> clearAllData();
}
