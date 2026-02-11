// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_list_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UsersList _$UsersListFromJson(Map<String, dynamic> json) => _UsersList(
  loadingState:
      $enumDecodeNullable(_$UserListStateEnumMap, json['loadingState']) ??
      UserListState.initial,
  cachedUsers:
      (json['cachedUsers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, FullUserInfo.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  activeUsers:
      (json['activeUsers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, FullUserInfo.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
);

Map<String, dynamic> _$UsersListToJson(_UsersList instance) =>
    <String, dynamic>{
      'loadingState': _$UserListStateEnumMap[instance.loadingState]!,
      'cachedUsers': instance.cachedUsers,
      'activeUsers': instance.activeUsers,
    };

const _$UserListStateEnumMap = {
  UserListState.initial: 'initial',
  UserListState.loading: 'loading',
  UserListState.loaded: 'loaded',
};

_FullUserInfo _$FullUserInfoFromJson(Map<String, dynamic> json) =>
    _FullUserInfo(
      generalAccountInfo: GeneralAccountInfo.fromJson(
        json['generalAccountInfo'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$FullUserInfoToJson(_FullUserInfo instance) =>
    <String, dynamic>{'generalAccountInfo': instance.generalAccountInfo};
