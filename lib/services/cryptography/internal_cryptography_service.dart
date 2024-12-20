import 'package:near_social_mobile/services/cryptography/encryption/encryption_runner_interface.dart';
import 'package:near_social_mobile/services/cryptography/encryption/encryption_runner_stub.dart'
    if (dart.library.io) 'package:near_social_mobile/services/cryptography/encryption/encryption_web_view_runner.dart'
    if (dart.library.js) 'package:near_social_mobile/services/cryptography/encryption/encryption_web_js_runner.dart';

class InternalCryptographyService {
  EncryptionRunner encryptionRunner = getEncryptionRunner();
}
