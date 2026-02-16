sealed class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String accountPublicKey;
  LoginEvent({required this.accountPublicKey});
}

class LogoutEvent extends AuthEvent {}

class WalletLoginEvent extends AuthEvent {
  final String accountId;
  final String? accountPublicKey;
  WalletLoginEvent({required this.accountId, this.accountPublicKey});
}

class GetActivationStatusEvent extends AuthEvent {}
