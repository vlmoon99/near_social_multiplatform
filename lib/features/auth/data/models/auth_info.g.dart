// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthInfo _$AuthInfoFromJson(Map<String, dynamic> json) => _AuthInfo(
  accountId: json['accountId'] as String? ?? "",
  publicKey: json['publicKey'] as String? ?? "",
  secretKey: json['secretKey'] as String? ?? "",
  privateKey: json['privateKey'] as String? ?? "",
  status:
      $enumDecodeNullable(_$AuthInfoStatusEnumMap, json['status']) ??
      AuthInfoStatus.unauthenticated,
  additionalStoredKeys:
      (json['additionalStoredKeys'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, PrivateKeyInfo.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  accountActivationStatus:
      $enumDecodeNullable(
        _$AccountActivationStatusEnumMap,
        json['accountActivationStatus'],
      ) ??
      AccountActivationStatus.undefined,
);

Map<String, dynamic> _$AuthInfoToJson(_AuthInfo instance) => <String, dynamic>{
  'accountId': instance.accountId,
  'publicKey': instance.publicKey,
  'secretKey': instance.secretKey,
  'privateKey': instance.privateKey,
  'status': _$AuthInfoStatusEnumMap[instance.status]!,
  'additionalStoredKeys': instance.additionalStoredKeys,
  'accountActivationStatus':
      _$AccountActivationStatusEnumMap[instance.accountActivationStatus]!,
};

const _$AuthInfoStatusEnumMap = {
  AuthInfoStatus.unauthenticated: 'unauthenticated',
  AuthInfoStatus.authenticated: 'authenticated',
};

const _$AccountActivationStatusEnumMap = {
  AccountActivationStatus.undefined: 'undefined',
  AccountActivationStatus.notActivated: 'notActivated',
  AccountActivationStatus.activated: 'activated',
};
