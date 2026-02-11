import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:near_social_mobile/features/people/data/models/general_account_info.dart';

part 'reposter_info.freezed.dart';

@freezed
abstract class ReposterInfo with _$ReposterInfo {
  const factory ReposterInfo({
    required GeneralAccountInfo accountInfo,
    required int blockHeight,
  }) = _ReposterInfo;
}
