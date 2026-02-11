import 'package:freezed_annotation/freezed_annotation.dart';

part 'authorization_credentials.freezed.dart';
part 'authorization_credentials.g.dart';

@freezed
abstract class AuthorizationCredentials with _$AuthorizationCredentials {
  const factory AuthorizationCredentials({
    required String accountId,
    required String secretKey,
  }) = _AuthorizationCredentials;

  factory AuthorizationCredentials.fromJson(Map<String, dynamic> json) =>
      _$AuthorizationCredentialsFromJson(json);
}
