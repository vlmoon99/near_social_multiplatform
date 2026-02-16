sealed class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String accountKey;
  LoginEvent({required this.accountKey});
}

class LogoutEvent extends AuthEvent {}

class WalletLoginEvent extends AuthEvent {
  final String accountId;
  final String? accountPublicKey;
  WalletLoginEvent({required this.accountId, this.accountPublicKey});
}

class GetActivationStatusEvent extends AuthEvent {}
