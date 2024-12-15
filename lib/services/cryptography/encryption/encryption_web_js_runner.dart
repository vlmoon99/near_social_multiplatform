import 'dart:convert';
import 'dart:js_interop';
import 'package:near_social_mobile/services/cryptography/encryption/encryption_runner_interface.dart';

class WebEncryptionRunner implements EncryptionRunner {
  @override
  Future<String> encryptMessage(String publicKeyPem, String message) {
    return Future.value(
        _encryptMessage(publicKeyPem.toJS, message.toJS).toDart);
  }

  @override
  Future<String> decryptMessage(
      String privateKeyPem, String encryptedMessageBase64) {
    return Future.value(
        _decryptMessage(privateKeyPem.toJS, encryptedMessageBase64.toJS)
            .toDart);
  }

  @override
  Future<KeyPair> generateKeyPair() {
    final jsKeyPair =
        jsonDecode(_generateKeyPair().toDart) as Map<String, dynamic>;
    final publicKey = jsKeyPair['publicKey'].toString();
    final privateKey = jsKeyPair['privateKey'].toString();
    return Future.value(KeyPair(publicKey: publicKey, privateKey: privateKey));
  }
}

@JS('generate_keypair')
external JSString _generateKeyPair();

@JS('encrypt_message')
external JSString _encryptMessage(JSString publicKeyPem, JSString message);

@JS('decrypt_message')
external JSString _decryptMessage(
    JSString privateKeyPem, JSString encryptedMessageBase64);
