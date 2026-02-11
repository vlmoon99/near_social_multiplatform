import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:near_social_mobile/features/auth/data/models/private_key_info.dart';

part 'auth_info.freezed.dart';
part 'auth_info.g.dart';

enum AuthInfoStatus { unauthenticated, authenticated }

enum AccountActivationStatus { undefined, notActivated, activated }

@freezed
abstract class AuthInfo with _$AuthInfo {
  const factory AuthInfo({
    @Default("") String accountId,
    @Default("") String publicKey,
    @Default("") String secretKey,
    @Default("") String privateKey,
    @Default(AuthInfoStatus.unauthenticated) AuthInfoStatus status,
    @Default({}) Map<String, PrivateKeyInfo> additionalStoredKeys,
    @Default(AccountActivationStatus.undefined)
    AccountActivationStatus accountActivationStatus,
  }) = _AuthInfo;

  factory AuthInfo.fromJson(Map<String, dynamic> json) =>
      _$AuthInfoFromJson(json);
}
