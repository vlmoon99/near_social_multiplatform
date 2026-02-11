// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authorization_credentials.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthorizationCredentials _$AuthorizationCredentialsFromJson(
  Map<String, dynamic> json,
) => _AuthorizationCredentials(
  accountId: json['accountId'] as String,
  secretKey: json['secretKey'] as String,
);

Map<String, dynamic> _$AuthorizationCredentialsToJson(
  _AuthorizationCredentials instance,
) => <String, dynamic>{
  'accountId': instance.accountId,
  'secretKey': instance.secretKey,
};
