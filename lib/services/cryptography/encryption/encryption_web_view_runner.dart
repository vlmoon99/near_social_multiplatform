import 'package:flutterchain/flutterchain_lib/services/core/js_engines/core/webview_js_engine.dart';
import 'package:near_social_mobile/services/cryptography/encryption/encryption_runner_interface.dart';

EncryptionRunner getEncryptionRunner() => EncryptionWebviewJSRunner();

class EncryptionWebviewJSRunner extends EncryptionRunner {
  final WebviewJsVMService jsVMService = WebviewJsVMService();

  @override
  Future<String> encryptMessage(
    String publicKeyPem,
    String message,
  ) async {
    final rawFunction = "window.encrypt_message('$publicKeyPem', '$message')";
    final res = await jsVMService.callJS(rawFunction);
    return res.toString();
  }

  @override
  Future<String> decryptMessage(
    String privateKeyPem,
    String encryptedMessageBase64,
  ) async {
    final rawFunction =
        "window.decrypt_message('$privateKeyPem', '$encryptedMessageBase64')";
    final res = await jsVMService.callJS(rawFunction);
    return res.toString();
  }

  @override
  Future<KeyPair> generateKeyPair() async {
    final rawFunction = "window.generate_keypair()";
    final res = await jsVMService.callJS(rawFunction);

    return KeyPair(
        privateKey: res['privateKey'].toString(),
        publicKey: res['publicKey'].toString());
  }
}
