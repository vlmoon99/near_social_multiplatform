import 'package:freezed_annotation/freezed_annotation.dart';

part 'encryption_keypair.freezed.dart';
part 'encryption_keypair.g.dart';

@freezed
abstract class EncryptionKeypair with _$EncryptionKeypair {
  const factory EncryptionKeypair({
    required String publicKey,
    required String privateKey,
  }) = _EncryptionKeypair;

  factory EncryptionKeypair.fromJson(Map<String, dynamic> json) =>
      _$EncryptionKeypairFromJson(json);
}
