import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_info.freezed.dart';
part 'auth_info.g.dart';

enum AuthInfoStatus { unauthenticated, authenticated }

enum AccountActivationStatus { undefined, notActivated, activated }

@freezed
abstract class AuthInfo with _$AuthInfo {
  const factory AuthInfo({
    @Default("") String accountId,
    @Default("") String accountPublicKey,
    @Default("") String accountPrivateKey,
    @Default("") String devicePublicKey,
    @Default("") String devicePrivateKey,
    @Default(AuthInfoStatus.unauthenticated) AuthInfoStatus status,
    @Default(AccountActivationStatus.undefined)
    AccountActivationStatus accountActivationStatus,
  }) = _AuthInfo;

  factory AuthInfo.fromJson(Map<String, dynamic> json) =>
      _$AuthInfoFromJson(json);
}
