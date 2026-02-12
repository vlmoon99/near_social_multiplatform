import 'package:near_social_mobile/core/services/crypto_service.dart';

class QRFormatter {
  static String parsePublicKey(String qrData) {
    final trimmed = qrData.trim();

    if (!trimmed.startsWith('ed25519:')) {
      throw const FormatException(
        'Invalid QR code format: expected ed25519:<base58>',
      );
    }

    // Validate by decoding — throws FormatException if invalid
    CryptoService.publicKeyFromBase58(trimmed);

    return trimmed;
  }
}
