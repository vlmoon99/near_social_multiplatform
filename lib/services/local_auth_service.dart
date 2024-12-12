import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate({required String requestAuthMessage}) async {
    try {
      final bool authenticated = await _auth.authenticate(
        localizedReason: requestAuthMessage,
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
      return authenticated;
    } on PlatformException {
      throw Exception('You have to enable password protection on your device');
    } catch (err) {
      throw Exception(err.toString());
    }
  }
}
