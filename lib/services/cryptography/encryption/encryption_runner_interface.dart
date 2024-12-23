abstract class EncryptionRunner {
  Future<String> signMessageForVerification(String privateKey);
  Future<String> fromSecretToNearAPIJSPublicKey(String secretKey);
  Future<String> encryptMessage(String publicKeyPem, String message);
  Future<String> decryptMessage(
      String privateKeyPem, String encryptedMessageBase64);
  Future<KeyPair> generateKeyPair();
}

// class KeyPair {
//   final String publicKey;

//   final String privateKey;

//   KeyPair({required this.publicKey, required this.privateKey});

// @override
// String toString() {
//   return "KeyPair(publicKey : $publicKey , privateKey : $privateKey)";
// }
// }

class KeyPair {
  final String publicKey;
  final String privateKey;

  KeyPair({required this.publicKey, required this.privateKey});

  factory KeyPair.fromJson(Map<String, dynamic> json) {
    return KeyPair(
      publicKey: json['public_key'],
      privateKey: json['private_key'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'public_key': publicKey,
      'private_key': privateKey,
    };
  }

  @override
  String toString() {
    return "KeyPair(publicKey : $publicKey , privateKey : $privateKey)";
  }
}
