import 'dart:convert';
import 'dart:js_interop';
import 'package:near_social_mobile/services/cryptography/encryption/encryption_runner_interface.dart';
import 'dart:js' as js;

EncryptionRunner getEncryptionRunner() => WebEncryptionRunner();

class WebEncryptionRunner implements EncryptionRunner {
  @override
  Future<String> encryptMessage(String dataFromDart) {
    return Future.value(_encryptMessage(dataFromDart.toJS));
  }

  @override
  Future<String> decryptMessage(String dataFromDart) async {
    final res = _decryptMessage(dataFromDart.toJS).toDart;
    return res;
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

  @override
  Future<String> fromSecretToNearAPIJSPublicKey(String secretKey) {
    return Future.value(_fromSecretToNearAPIJSPublicKey(secretKey.toJS).toDart);
  }

  @override
  Future<String> signMessageForVerification(String secretKey) {
    final secretKeyJs = secretKey.toJS;
    return Future.value(_signMessageForVerification(secretKeyJs).toString());
  }
}

@JS('window.fromSecretToNearAPIJSPublicKey')
external JSString _fromSecretToNearAPIJSPublicKey(JSString secretKey);

@JS('window.signMessageForVerification')
external JSString _signMessageForVerification(JSString privateKey);

@JS('window.generate_keypair')
external String _generateKeyPair();

@JS('window.encrypt_message')
external String _encryptMessage(JSString dataFromDart);

@JS('window.decrypt_message')
external JSString _decryptMessage(JSString dataFromDart);
