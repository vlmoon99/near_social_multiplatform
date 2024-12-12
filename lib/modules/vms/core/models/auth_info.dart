import 'package:equatable/equatable.dart';
import 'package:near_social_mobile/modules/home/apis/models/private_key_info.dart';

enum AuthInfoStatus { unauthenticated, authenticated }
enum AccountActivationStatus { undefined, notActivated, activated }

class AuthInfo extends Equatable {
  final String accountId;
  final String publicKey;
  final String secretKey;
  final String privateKey;
  final AuthInfoStatus status;
  final AccountActivationStatus accountActivationStatus;
  final Map<String, PrivateKeyInfo> additionalStoredKeys;

  const AuthInfo({
    this.accountId = "",
    this.publicKey = "",
    this.secretKey = "",
    this.privateKey = "",
    this.status = AuthInfoStatus.unauthenticated,
    this.additionalStoredKeys = const {},
    this.accountActivationStatus = AccountActivationStatus.undefined,
  });

  AuthInfo copyWith({
    String? accountId,
    String? publicKey,
    String? secretKey,
    String? privateKey,
    AuthInfoStatus? status,
    Map<String, PrivateKeyInfo>? additionalStoredKeys,
    AccountActivationStatus? accountActivationStatus,
  }) {
    return AuthInfo(
      accountId: accountId ?? this.accountId,
      publicKey: publicKey ?? this.publicKey,
      secretKey: secretKey ?? this.secretKey,
      privateKey: privateKey ?? this.privateKey,
      status: status ?? this.status,
      additionalStoredKeys: additionalStoredKeys ?? this.additionalStoredKeys,
      accountActivationStatus:
          accountActivationStatus ?? this.accountActivationStatus,
    );
  }

  @override
  List<Object?> get props => [
        accountId,
        publicKey,
        secretKey,
        privateKey,
        status,
        additionalStoredKeys,
        accountActivationStatus,
      ];

  @override
  bool? get stringify => true;
}
