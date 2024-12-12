import 'package:near_social_mobile/modules/vms/core/models/authorization_credentials.dart';

class QRFormatter {
  static AuthorizationCredentials convertURLToAuthorizationCredentials(
      String url) {
    final accountIdStartIndex = url.indexOf('a=');
    final secretKeyStartIndex = url.indexOf('&k=');

    final accountIdEndIndex = url.indexOf('&', accountIdStartIndex + 2);
    final secretKeyEndIndex = url.length;

    if (accountIdStartIndex == -1 ||
        secretKeyStartIndex == -1 ||
        accountIdEndIndex == -1 ||
        secretKeyEndIndex == -1) {
      throw Exception("Invalid QR code format");
    }

    final accountId = url.substring(accountIdStartIndex + 2, accountIdEndIndex);
    final secretKey = url.substring(secretKeyStartIndex + 3, secretKeyEndIndex);

    return AuthorizationCredentials(accountId, secretKey);
  }
}
