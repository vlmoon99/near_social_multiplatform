// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthInfo _$AuthInfoFromJson(Map<String, dynamic> json) => _AuthInfo(
  accountId: json['accountId'] as String? ?? "",
  accountPublicKey: json['accountPublicKey'] as String? ?? "",
  accountPrivateKey: json['accountPrivateKey'] as String? ?? "",
  devicePublicKey: json['devicePublicKey'] as String? ?? "",
  devicePrivateKey: json['devicePrivateKey'] as String? ?? "",
  status:
      $enumDecodeNullable(_$AuthInfoStatusEnumMap, json['status']) ??
      AuthInfoStatus.unauthenticated,
  accountActivationStatus:
      $enumDecodeNullable(
        _$AccountActivationStatusEnumMap,
        json['accountActivationStatus'],
      ) ??
      AccountActivationStatus.undefined,
);

Map<String, dynamic> _$AuthInfoToJson(_AuthInfo instance) => <String, dynamic>{
  'accountId': instance.accountId,
  'accountPublicKey': instance.accountPublicKey,
  'accountPrivateKey': instance.accountPrivateKey,
  'devicePublicKey': instance.devicePublicKey,
  'devicePrivateKey': instance.devicePrivateKey,
  'status': _$AuthInfoStatusEnumMap[instance.status]!,
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
