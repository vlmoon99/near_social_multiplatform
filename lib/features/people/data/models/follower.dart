import 'package:freezed_annotation/freezed_annotation.dart';

part 'follower.freezed.dart';

@freezed
abstract class Follower with _$Follower {
  const factory Follower({
    required String accountId,
  }) = _Follower;
}
