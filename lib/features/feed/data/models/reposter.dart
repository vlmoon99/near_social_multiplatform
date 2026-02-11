import 'package:freezed_annotation/freezed_annotation.dart';

part 'reposter.freezed.dart';

@freezed
abstract class Reposter with _$Reposter {
  const factory Reposter({
    required String accountId,
  }) = _Reposter;
}
