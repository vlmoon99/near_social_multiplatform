import 'package:freezed_annotation/freezed_annotation.dart';

part 'private_key_info.freezed.dart';
part 'private_key_info.g.dart';

@freezed
abstract class PrivateKeyInfo with _$PrivateKeyInfo {
  const factory PrivateKeyInfo({
    required String publicKey,
    required String privateKey,
    required String base58PubKey,
    required PrivateKeyTypeInfo privateKeyTypeInfo,
  }) = _PrivateKeyInfo;

  factory PrivateKeyInfo.fromJson(Map<String, dynamic> json) =>
      _$PrivateKeyInfoFromJson(json);
}

enum PrivateKeyType { FullAccess, FunctionCall }

@freezed
abstract class PrivateKeyTypeInfo with _$PrivateKeyTypeInfo {
  const factory PrivateKeyTypeInfo({
    required PrivateKeyType type,
    String? receiverId,
    List<String>? methodNames,
  }) = _PrivateKeyTypeInfo;

  factory PrivateKeyTypeInfo.fromJson(Map<String, dynamic> json) =>
      _$PrivateKeyTypeInfoFromJson(json);
}
