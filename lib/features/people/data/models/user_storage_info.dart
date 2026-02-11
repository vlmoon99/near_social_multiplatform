import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_storage_info.freezed.dart';

@freezed
abstract class UserStorageInfo with _$UserStorageInfo {
  const factory UserStorageInfo({
    required int? usedBytes,
    required int? availableBytes,
  }) = _UserStorageInfo;
}
