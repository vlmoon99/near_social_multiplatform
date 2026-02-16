/// Stub implementation for non-web platforms.
class NearConnectService {
  static Future<({String accountId, String? publicKey})> connect() async {
    throw UnsupportedError('NearConnectService is only available on web');
  }

  static Future<void> disconnect() async {
    throw UnsupportedError('NearConnectService is only available on web');
  }

  static Future<
      ({
        String signature,
        String publicKey,
        String accountId,
        String nonce,
      })> signMessage(String message, String recipient) async {
    throw UnsupportedError('NearConnectService is only available on web');
  }
}
