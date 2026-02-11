// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:near_social_mobile/features/people/data/models/follower.dart';
import 'package:near_social_mobile/features/people/data/models/general_account_info.dart';
import 'package:near_social_mobile/features/people/data/models/nft.dart';

part 'user_list_state.freezed.dart';
part 'user_list_state.g.dart';

enum UserListState { initial, loading, loaded }

@freezed
abstract class UsersList with _$UsersList {
  const UsersList._();

  const factory UsersList({
    @Default(UserListState.initial) UserListState loadingState,
    @Default({}) Map<String, FullUserInfo> cachedUsers,
    @Default({}) Map<String, FullUserInfo> activeUsers,
  }) = _UsersList;

  FullUserInfo getUserByAccountId({required String accountId}) {
    return activeUsers[accountId] ?? cachedUsers[accountId]!;
  }

  factory UsersList.fromJson(Map<String, dynamic> json) =>
      _$UsersListFromJson(json);
}

@freezed
abstract class FullUserInfo with _$FullUserInfo {
  const FullUserInfo._();

  const factory FullUserInfo({
    required GeneralAccountInfo generalAccountInfo,
    @JsonKey(includeFromJson: false, includeToJson: false) List<Nft>? nfts,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<Follower>? followers,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<Follower>? followings,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<String>? userTags,
  }) = _FullUserInfo;

  bool get allMetadataLoaded {
    return followers != null && followings != null && userTags != null;
  }

  factory FullUserInfo.fromJson(Map<String, dynamic> json) =>
      _$FullUserInfoFromJson(json);
}
