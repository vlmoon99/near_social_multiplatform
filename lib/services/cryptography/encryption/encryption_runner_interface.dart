abstract class EncryptionRunner {
  Future<String> encryptMessage(String publicKeyPem, String message);
  Future<String> decryptMessage(
      String privateKeyPem, String encryptedMessageBase64);
  Future<KeyPair> generateKeyPair();
}

class KeyPair {
  final String publicKey;

  final String privateKey;

  KeyPair({required this.publicKey, required this.privateKey});
}
