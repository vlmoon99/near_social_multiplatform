import 'package:freezed_annotation/freezed_annotation.dart';

part 'general_account_info.freezed.dart';
part 'general_account_info.g.dart';

@freezed
abstract class GeneralAccountInfo with _$GeneralAccountInfo {
  const factory GeneralAccountInfo({
    required String accountId,
    required String name,
    required String description,
    required Map<String, dynamic> linktree,
    required List<String> tags,
    required String profileImageLink,
    required String backgroundImageLink,
  }) = _GeneralAccountInfo;

  factory GeneralAccountInfo.fromJson(Map<String, dynamic> json) =>
      _$GeneralAccountInfoFromJson(json);
}
