import 'package:near_social_mobile/features/auth/data/models/private_key_info.dart';

sealed class KeyManagerEvent {}

class AddKeyEvent extends KeyManagerEvent {
  final String accessKeyName;
  final PrivateKeyInfo privateKeyInfo;
  AddKeyEvent({required this.accessKeyName, required this.privateKeyInfo});
}

class RemoveKeyEvent extends KeyManagerEvent {
  final String accessKeyName;
  RemoveKeyEvent({required this.accessKeyName});
}
