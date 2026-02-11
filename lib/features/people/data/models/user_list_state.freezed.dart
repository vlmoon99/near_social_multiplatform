// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UsersList {

 UserListState get loadingState; Map<String, FullUserInfo> get cachedUsers; Map<String, FullUserInfo> get activeUsers;
/// Create a copy of UsersList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsersListCopyWith<UsersList> get copyWith => _$UsersListCopyWithImpl<UsersList>(this as UsersList, _$identity);

  /// Serializes this UsersList to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UsersList&&(identical(other.loadingState, loadingState) || other.loadingState == loadingState)&&const DeepCollectionEquality().equals(other.cachedUsers, cachedUsers)&&const DeepCollectionEquality().equals(other.activeUsers, activeUsers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,loadingState,const DeepCollectionEquality().hash(cachedUsers),const DeepCollectionEquality().hash(activeUsers));

@override
String toString() {
  return 'UsersList(loadingState: $loadingState, cachedUsers: $cachedUsers, activeUsers: $activeUsers)';
}


}

/// @nodoc
abstract mixin class $UsersListCopyWith<$Res>  {
  factory $UsersListCopyWith(UsersList value, $Res Function(UsersList) _then) = _$UsersListCopyWithImpl;
@useResult
$Res call({
 UserListState loadingState, Map<String, FullUserInfo> cachedUsers, Map<String, FullUserInfo> activeUsers
});




}
/// @nodoc
class _$UsersListCopyWithImpl<$Res>
    implements $UsersListCopyWith<$Res> {
  _$UsersListCopyWithImpl(this._self, this._then);

  final UsersList _self;
  final $Res Function(UsersList) _then;

/// Create a copy of UsersList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loadingState = null,Object? cachedUsers = null,Object? activeUsers = null,}) {
  return _then(_self.copyWith(
loadingState: null == loadingState ? _self.loadingState : loadingState // ignore: cast_nullable_to_non_nullable
as UserListState,cachedUsers: null == cachedUsers ? _self.cachedUsers : cachedUsers // ignore: cast_nullable_to_non_nullable
as Map<String, FullUserInfo>,activeUsers: null == activeUsers ? _self.activeUsers : activeUsers // ignore: cast_nullable_to_non_nullable
as Map<String, FullUserInfo>,
  ));
}

}


/// Adds pattern-matching-related methods to [UsersList].
extension UsersListPatterns on UsersList {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UsersList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UsersList() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UsersList value)  $default,){
final _that = this;
switch (_that) {
case _UsersList():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UsersList value)?  $default,){
final _that = this;
switch (_that) {
case _UsersList() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserListState loadingState,  Map<String, FullUserInfo> cachedUsers,  Map<String, FullUserInfo> activeUsers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UsersList() when $default != null:
return $default(_that.loadingState,_that.cachedUsers,_that.activeUsers);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserListState loadingState,  Map<String, FullUserInfo> cachedUsers,  Map<String, FullUserInfo> activeUsers)  $default,) {final _that = this;
switch (_that) {
case _UsersList():
return $default(_that.loadingState,_that.cachedUsers,_that.activeUsers);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserListState loadingState,  Map<String, FullUserInfo> cachedUsers,  Map<String, FullUserInfo> activeUsers)?  $default,) {final _that = this;
switch (_that) {
case _UsersList() when $default != null:
return $default(_that.loadingState,_that.cachedUsers,_that.activeUsers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UsersList extends UsersList {
  const _UsersList({this.loadingState = UserListState.initial, final  Map<String, FullUserInfo> cachedUsers = const {}, final  Map<String, FullUserInfo> activeUsers = const {}}): _cachedUsers = cachedUsers,_activeUsers = activeUsers,super._();
  factory _UsersList.fromJson(Map<String, dynamic> json) => _$UsersListFromJson(json);

@override@JsonKey() final  UserListState loadingState;
 final  Map<String, FullUserInfo> _cachedUsers;
@override@JsonKey() Map<String, FullUserInfo> get cachedUsers {
  if (_cachedUsers is EqualUnmodifiableMapView) return _cachedUsers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_cachedUsers);
}

 final  Map<String, FullUserInfo> _activeUsers;
@override@JsonKey() Map<String, FullUserInfo> get activeUsers {
  if (_activeUsers is EqualUnmodifiableMapView) return _activeUsers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_activeUsers);
}


/// Create a copy of UsersList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UsersListCopyWith<_UsersList> get copyWith => __$UsersListCopyWithImpl<_UsersList>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UsersListToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UsersList&&(identical(other.loadingState, loadingState) || other.loadingState == loadingState)&&const DeepCollectionEquality().equals(other._cachedUsers, _cachedUsers)&&const DeepCollectionEquality().equals(other._activeUsers, _activeUsers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,loadingState,const DeepCollectionEquality().hash(_cachedUsers),const DeepCollectionEquality().hash(_activeUsers));

@override
String toString() {
  return 'UsersList(loadingState: $loadingState, cachedUsers: $cachedUsers, activeUsers: $activeUsers)';
}


}

/// @nodoc
abstract mixin class _$UsersListCopyWith<$Res> implements $UsersListCopyWith<$Res> {
  factory _$UsersListCopyWith(_UsersList value, $Res Function(_UsersList) _then) = __$UsersListCopyWithImpl;
@override @useResult
$Res call({
 UserListState loadingState, Map<String, FullUserInfo> cachedUsers, Map<String, FullUserInfo> activeUsers
});




}
/// @nodoc
class __$UsersListCopyWithImpl<$Res>
    implements _$UsersListCopyWith<$Res> {
  __$UsersListCopyWithImpl(this._self, this._then);

  final _UsersList _self;
  final $Res Function(_UsersList) _then;

/// Create a copy of UsersList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loadingState = null,Object? cachedUsers = null,Object? activeUsers = null,}) {
  return _then(_UsersList(
loadingState: null == loadingState ? _self.loadingState : loadingState // ignore: cast_nullable_to_non_nullable
as UserListState,cachedUsers: null == cachedUsers ? _self._cachedUsers : cachedUsers // ignore: cast_nullable_to_non_nullable
as Map<String, FullUserInfo>,activeUsers: null == activeUsers ? _self._activeUsers : activeUsers // ignore: cast_nullable_to_non_nullable
as Map<String, FullUserInfo>,
  ));
}


}


/// @nodoc
mixin _$FullUserInfo {

 GeneralAccountInfo get generalAccountInfo;@JsonKey(includeFromJson: false, includeToJson: false) List<Nft>? get nfts;@JsonKey(includeFromJson: false, includeToJson: false) List<Follower>? get followers;@JsonKey(includeFromJson: false, includeToJson: false) List<Follower>? get followings;@JsonKey(includeFromJson: false, includeToJson: false) List<String>? get userTags;
/// Create a copy of FullUserInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FullUserInfoCopyWith<FullUserInfo> get copyWith => _$FullUserInfoCopyWithImpl<FullUserInfo>(this as FullUserInfo, _$identity);

  /// Serializes this FullUserInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FullUserInfo&&(identical(other.generalAccountInfo, generalAccountInfo) || other.generalAccountInfo == generalAccountInfo)&&const DeepCollectionEquality().equals(other.nfts, nfts)&&const DeepCollectionEquality().equals(other.followers, followers)&&const DeepCollectionEquality().equals(other.followings, followings)&&const DeepCollectionEquality().equals(other.userTags, userTags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,generalAccountInfo,const DeepCollectionEquality().hash(nfts),const DeepCollectionEquality().hash(followers),const DeepCollectionEquality().hash(followings),const DeepCollectionEquality().hash(userTags));

@override
String toString() {
  return 'FullUserInfo(generalAccountInfo: $generalAccountInfo, nfts: $nfts, followers: $followers, followings: $followings, userTags: $userTags)';
}


}

/// @nodoc
abstract mixin class $FullUserInfoCopyWith<$Res>  {
  factory $FullUserInfoCopyWith(FullUserInfo value, $Res Function(FullUserInfo) _then) = _$FullUserInfoCopyWithImpl;
@useResult
$Res call({
 GeneralAccountInfo generalAccountInfo,@JsonKey(includeFromJson: false, includeToJson: false) List<Nft>? nfts,@JsonKey(includeFromJson: false, includeToJson: false) List<Follower>? followers,@JsonKey(includeFromJson: false, includeToJson: false) List<Follower>? followings,@JsonKey(includeFromJson: false, includeToJson: false) List<String>? userTags
});


$GeneralAccountInfoCopyWith<$Res> get generalAccountInfo;

}
/// @nodoc
class _$FullUserInfoCopyWithImpl<$Res>
    implements $FullUserInfoCopyWith<$Res> {
  _$FullUserInfoCopyWithImpl(this._self, this._then);

  final FullUserInfo _self;
  final $Res Function(FullUserInfo) _then;

/// Create a copy of FullUserInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? generalAccountInfo = null,Object? nfts = freezed,Object? followers = freezed,Object? followings = freezed,Object? userTags = freezed,}) {
  return _then(_self.copyWith(
generalAccountInfo: null == generalAccountInfo ? _self.generalAccountInfo : generalAccountInfo // ignore: cast_nullable_to_non_nullable
as GeneralAccountInfo,nfts: freezed == nfts ? _self.nfts : nfts // ignore: cast_nullable_to_non_nullable
as List<Nft>?,followers: freezed == followers ? _self.followers : followers // ignore: cast_nullable_to_non_nullable
as List<Follower>?,followings: freezed == followings ? _self.followings : followings // ignore: cast_nullable_to_non_nullable
as List<Follower>?,userTags: freezed == userTags ? _self.userTags : userTags // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}
/// Create a copy of FullUserInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeneralAccountInfoCopyWith<$Res> get generalAccountInfo {
  
  return $GeneralAccountInfoCopyWith<$Res>(_self.generalAccountInfo, (value) {
    return _then(_self.copyWith(generalAccountInfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [FullUserInfo].
extension FullUserInfoPatterns on FullUserInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FullUserInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FullUserInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FullUserInfo value)  $default,){
final _that = this;
switch (_that) {
case _FullUserInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FullUserInfo value)?  $default,){
final _that = this;
switch (_that) {
case _FullUserInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GeneralAccountInfo generalAccountInfo, @JsonKey(includeFromJson: false, includeToJson: false)  List<Nft>? nfts, @JsonKey(includeFromJson: false, includeToJson: false)  List<Follower>? followers, @JsonKey(includeFromJson: false, includeToJson: false)  List<Follower>? followings, @JsonKey(includeFromJson: false, includeToJson: false)  List<String>? userTags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FullUserInfo() when $default != null:
return $default(_that.generalAccountInfo,_that.nfts,_that.followers,_that.followings,_that.userTags);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GeneralAccountInfo generalAccountInfo, @JsonKey(includeFromJson: false, includeToJson: false)  List<Nft>? nfts, @JsonKey(includeFromJson: false, includeToJson: false)  List<Follower>? followers, @JsonKey(includeFromJson: false, includeToJson: false)  List<Follower>? followings, @JsonKey(includeFromJson: false, includeToJson: false)  List<String>? userTags)  $default,) {final _that = this;
switch (_that) {
case _FullUserInfo():
return $default(_that.generalAccountInfo,_that.nfts,_that.followers,_that.followings,_that.userTags);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GeneralAccountInfo generalAccountInfo, @JsonKey(includeFromJson: false, includeToJson: false)  List<Nft>? nfts, @JsonKey(includeFromJson: false, includeToJson: false)  List<Follower>? followers, @JsonKey(includeFromJson: false, includeToJson: false)  List<Follower>? followings, @JsonKey(includeFromJson: false, includeToJson: false)  List<String>? userTags)?  $default,) {final _that = this;
switch (_that) {
case _FullUserInfo() when $default != null:
return $default(_that.generalAccountInfo,_that.nfts,_that.followers,_that.followings,_that.userTags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FullUserInfo extends FullUserInfo {
  const _FullUserInfo({required this.generalAccountInfo, @JsonKey(includeFromJson: false, includeToJson: false) final  List<Nft>? nfts, @JsonKey(includeFromJson: false, includeToJson: false) final  List<Follower>? followers, @JsonKey(includeFromJson: false, includeToJson: false) final  List<Follower>? followings, @JsonKey(includeFromJson: false, includeToJson: false) final  List<String>? userTags}): _nfts = nfts,_followers = followers,_followings = followings,_userTags = userTags,super._();
  factory _FullUserInfo.fromJson(Map<String, dynamic> json) => _$FullUserInfoFromJson(json);

@override final  GeneralAccountInfo generalAccountInfo;
 final  List<Nft>? _nfts;
@override@JsonKey(includeFromJson: false, includeToJson: false) List<Nft>? get nfts {
  final value = _nfts;
  if (value == null) return null;
  if (_nfts is EqualUnmodifiableListView) return _nfts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<Follower>? _followers;
@override@JsonKey(includeFromJson: false, includeToJson: false) List<Follower>? get followers {
  final value = _followers;
  if (value == null) return null;
  if (_followers is EqualUnmodifiableListView) return _followers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<Follower>? _followings;
@override@JsonKey(includeFromJson: false, includeToJson: false) List<Follower>? get followings {
  final value = _followings;
  if (value == null) return null;
  if (_followings is EqualUnmodifiableListView) return _followings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _userTags;
@override@JsonKey(includeFromJson: false, includeToJson: false) List<String>? get userTags {
  final value = _userTags;
  if (value == null) return null;
  if (_userTags is EqualUnmodifiableListView) return _userTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of FullUserInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FullUserInfoCopyWith<_FullUserInfo> get copyWith => __$FullUserInfoCopyWithImpl<_FullUserInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FullUserInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FullUserInfo&&(identical(other.generalAccountInfo, generalAccountInfo) || other.generalAccountInfo == generalAccountInfo)&&const DeepCollectionEquality().equals(other._nfts, _nfts)&&const DeepCollectionEquality().equals(other._followers, _followers)&&const DeepCollectionEquality().equals(other._followings, _followings)&&const DeepCollectionEquality().equals(other._userTags, _userTags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,generalAccountInfo,const DeepCollectionEquality().hash(_nfts),const DeepCollectionEquality().hash(_followers),const DeepCollectionEquality().hash(_followings),const DeepCollectionEquality().hash(_userTags));

@override
String toString() {
  return 'FullUserInfo(generalAccountInfo: $generalAccountInfo, nfts: $nfts, followers: $followers, followings: $followings, userTags: $userTags)';
}


}

/// @nodoc
abstract mixin class _$FullUserInfoCopyWith<$Res> implements $FullUserInfoCopyWith<$Res> {
  factory _$FullUserInfoCopyWith(_FullUserInfo value, $Res Function(_FullUserInfo) _then) = __$FullUserInfoCopyWithImpl;
@override @useResult
$Res call({
 GeneralAccountInfo generalAccountInfo,@JsonKey(includeFromJson: false, includeToJson: false) List<Nft>? nfts,@JsonKey(includeFromJson: false, includeToJson: false) List<Follower>? followers,@JsonKey(includeFromJson: false, includeToJson: false) List<Follower>? followings,@JsonKey(includeFromJson: false, includeToJson: false) List<String>? userTags
});


@override $GeneralAccountInfoCopyWith<$Res> get generalAccountInfo;

}
/// @nodoc
class __$FullUserInfoCopyWithImpl<$Res>
    implements _$FullUserInfoCopyWith<$Res> {
  __$FullUserInfoCopyWithImpl(this._self, this._then);

  final _FullUserInfo _self;
  final $Res Function(_FullUserInfo) _then;

/// Create a copy of FullUserInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? generalAccountInfo = null,Object? nfts = freezed,Object? followers = freezed,Object? followings = freezed,Object? userTags = freezed,}) {
  return _then(_FullUserInfo(
generalAccountInfo: null == generalAccountInfo ? _self.generalAccountInfo : generalAccountInfo // ignore: cast_nullable_to_non_nullable
as GeneralAccountInfo,nfts: freezed == nfts ? _self._nfts : nfts // ignore: cast_nullable_to_non_nullable
as List<Nft>?,followers: freezed == followers ? _self._followers : followers // ignore: cast_nullable_to_non_nullable
as List<Follower>?,followings: freezed == followings ? _self._followings : followings // ignore: cast_nullable_to_non_nullable
as List<Follower>?,userTags: freezed == userTags ? _self._userTags : userTags // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

/// Create a copy of FullUserInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeneralAccountInfoCopyWith<$Res> get generalAccountInfo {
  
  return $GeneralAccountInfoCopyWith<$Res>(_self.generalAccountInfo, (value) {
    return _then(_self.copyWith(generalAccountInfo: value));
  });
}
}

// dart format on
