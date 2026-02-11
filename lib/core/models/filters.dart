import 'package:freezed_annotation/freezed_annotation.dart';

part 'filters.freezed.dart';
part 'filters.g.dart';

enum FilterLoadStatus { initial, loading, loaded }

@freezed
abstract class Filters with _$Filters {
  const Filters._();

  const factory Filters({
    @Default(FilterLoadStatus.initial) FilterLoadStatus status,
    @Default([]) List<String> blockedAccounts,
    @Default([]) List<String> hidedPosts,
    @Default([]) List<String> hidedAllPostsAccounts,
  }) = _Filters;

  ({String accountId, int blockHeight}) convertIdToCredentials(String id) {
    final splittedID = id.split("&");
    return (
      accountId: splittedID.first,
      blockHeight: int.parse(splittedID.last)
    );
  }

  List<String> get allHiddenPostsUsers => List.of(hidedAllPostsAccounts)
    ..addAll(hidedPosts.map(
      (fullId) {
        return fullId.split("&")[0];
      },
    ).toSet());

  factory Filters.fromJson(Map<String, dynamic> json) =>
      _$FiltersFromJson(json);
}
