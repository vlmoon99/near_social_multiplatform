import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_social_mobile/core/config/constants.dart';

Future<bool> checkAuthenticationOnDevice() async {
  final secureStorage = const FlutterSecureStorage(); // TODO: Replace with ref.read()
  String? value = await secureStorage.read(key: StorageKeys.authInfo);
  if (value?.isNotEmpty ?? false) {
    return true;
  } else {
    return false;
  }
}
