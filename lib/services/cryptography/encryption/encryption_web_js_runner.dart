import 'dart:convert';
import 'dart:js_interop';
import 'package:near_social_mobile/services/cryptography/encryption/encryption_runner_interface.dart';
import 'dart:js' as js;

EncryptionRunner getEncryptionRunner() => WebEncryptionRunner();

class WebEncryptionRunner implements EncryptionRunner {
  @override
  Future<String> encryptMessage(String publicKeyPem, String message) {
    return Future.value(_encryptMessage(publicKeyPem.toJS, message.toJS));
  }

  @override
  Future<String> decryptMessage(
      String privateKeyPem, String encryptedMessageBase64) {
    return Future.value(
        _decryptMessage(privateKeyPem.toJS, encryptedMessageBase64.toJS));
  }

  @override
  Future<KeyPair> generateKeyPair() async {
    final jsKeyPair =
        jsonDecode(_generateKeyPair().toString()) as Map<String, dynamic>;

    final publicKey = jsKeyPair['public_key'].toString();
    final privateKey = jsKeyPair['private_key'].toString();
    final keys = KeyPair(publicKey: publicKey, privateKey: privateKey);

    return Future.value(keys);
  }
}

@JS('window.generate_keypair')
external String _generateKeyPair();

@JS('window.encrypt_message')
external String _encryptMessage(JSString publicKeyPem, JSString message);

@JS('window.decrypt_message')
external String _decryptMessage(
    JSString privateKeyPem, JSString encryptedMessageBase64);
