import 'package:near_social_mobile/features/auth/data/models/private_key_info.dart';

sealed class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String accountId;
  final String secretKey;
  LoginEvent({required this.accountId, required this.secretKey});
}

class LogoutEvent extends AuthEvent {}

class GetActivationStatusEvent extends AuthEvent {}

class AddAccessKeyEvent extends AuthEvent {
  final String accessKeyName;
  final PrivateKeyInfo privateKeyInfo;
  AddAccessKeyEvent({required this.accessKeyName, required this.privateKeyInfo});
}

class RemoveAccessKeyEvent extends AuthEvent {
  final String accessKeyName;
  RemoveAccessKeyEvent({required this.accessKeyName});
}
