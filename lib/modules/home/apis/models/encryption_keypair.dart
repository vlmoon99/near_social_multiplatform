
import 'package:json_annotation/json_annotation.dart';
part 'encryption_keypair.g.dart';

@JsonSerializable()
class EncryptionKeypair {
  final String publicKey;
  final String privateKey;

  const EncryptionKeypair({
    required this.publicKey,
    required this.privateKey,
  });

  factory EncryptionKeypair.fromJson(Map<String, dynamic> json) =>
      _$EncryptionKeypairFromJson(json);

  Map<String, dynamic> toJson() => _$EncryptionKeypairToJson(this);

}