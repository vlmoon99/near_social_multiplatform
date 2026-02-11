// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encryption_keypair.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EncryptionKeypair _$EncryptionKeypairFromJson(Map<String, dynamic> json) =>
    _EncryptionKeypair(
      publicKey: json['publicKey'] as String,
      privateKey: json['privateKey'] as String,
    );

Map<String, dynamic> _$EncryptionKeypairToJson(_EncryptionKeypair instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
      'privateKey': instance.privateKey,
    };
