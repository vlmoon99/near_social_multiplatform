import 'package:near_social_mobile/core/services/crypto_service.dart';

class QRFormatter {
  /// Parses a QR code / pasted key string.
  ///
  /// Accepts both public keys (32 bytes) and private keys (64 bytes)
  /// in `ed25519:<base58>` format.
  static String parseKey(String qrData) {
    final trimmed = qrData.trim();

    if (!trimmed.startsWith('ed25519:')) {
      throw const FormatException(
        'Invalid key format: expected ed25519:<base58>',
      );
    }

    // Validate by decoding
    final raw = trimmed.substring(8);
    final decoded = Base58.decode(raw);
    if (decoded.length != 32 && decoded.length != 64) {
      throw FormatException(
        'Invalid key length: expected 32 or 64 bytes, got ${decoded.length}',
      );
    }

    return trimmed;
  }

  @Deprecated('Use parseKey instead')
  static String parsePublicKey(String qrData) => parseKey(qrData);
}
