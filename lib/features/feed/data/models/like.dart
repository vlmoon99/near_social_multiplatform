import 'package:freezed_annotation/freezed_annotation.dart';

part 'like.freezed.dart';

@freezed
abstract class Like with _$Like {
  const factory Like({
    required String accountId,
  }) = _Like;
}
