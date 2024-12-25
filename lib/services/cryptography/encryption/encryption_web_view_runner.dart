import 'package:flutterchain/flutterchain_lib/services/core/js_engines/core/webview_js_engine.dart';
import 'package:near_social_mobile/services/cryptography/encryption/encryption_runner_interface.dart';

EncryptionRunner getEncryptionRunner() => EncryptionWebviewJSRunner();

class EncryptionWebviewJSRunner extends EncryptionRunner {
  final WebviewJsVMService jsVMService = WebviewJsVMService();

  @override
  Future<String> encryptMessage(
    String publicKey,
    String message,
  ) async {
    final rawFunction = "window.encrypt_message(`$publicKey`,`$message`)";
    final res = await jsVMService.callJS(rawFunction);
    return res.toString();
  }

  @override
  Future<String> decryptMessage(
    String privateKey,
    String encryptedMessage,
  ) async {
    final rawFunction =
        "window.decrypt_message(`$privateKey`,`$encryptedMessage`)";
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

  @override
  Future<String> fromSecretToNearAPIJSPublicKey(String secretKey) async {
    final rawFunction = "window.signMessageForVerification('$secretKey')";
    final res = await jsVMService.callJS(rawFunction);
    return res.toString();
  }

  @override
  Future<String> signMessageForVerification(String privateKey) async {
    final rawFunction = "window.fromSecretToNearAPIJSPublicKey('$privateKey')";
    final res = await jsVMService.callJS(rawFunction);
    return res.toString();
  }
}
