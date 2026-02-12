sealed class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String accountPublicKey;
  LoginEvent({required this.accountPublicKey});
}

class LogoutEvent extends AuthEvent {}

class GetActivationStatusEvent extends AuthEvent {}
