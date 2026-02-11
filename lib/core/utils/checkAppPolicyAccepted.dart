import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_social_mobile/core/config/constants.dart';

Future<bool> checkAppPolicyAccepted() async {
  final secureStorage = const FlutterSecureStorage(); // TODO: Replace with ref.read()
  String? value = await secureStorage.read(key: StorageKeys.appPolicyAccepted);
  if (value?.isNotEmpty ?? false) {
    return true;
  } else {
    return false;
  }
}
