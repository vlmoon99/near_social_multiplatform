// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_storage_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserStorageInfo {

 int? get usedBytes; int? get availableBytes;
/// Create a copy of UserStorageInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserStorageInfoCopyWith<UserStorageInfo> get copyWith => _$UserStorageInfoCopyWithImpl<UserStorageInfo>(this as UserStorageInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserStorageInfo&&(identical(other.usedBytes, usedBytes) || other.usedBytes == usedBytes)&&(identical(other.availableBytes, availableBytes) || other.availableBytes == availableBytes));
}


@override
int get hashCode => Object.hash(runtimeType,usedBytes,availableBytes);

@override
String toString() {
  return 'UserStorageInfo(usedBytes: $usedBytes, availableBytes: $availableBytes)';
}


}

/// @nodoc
abstract mixin class $UserStorageInfoCopyWith<$Res>  {
  factory $UserStorageInfoCopyWith(UserStorageInfo value, $Res Function(UserStorageInfo) _then) = _$UserStorageInfoCopyWithImpl;
@useResult
$Res call({
 int? usedBytes, int? availableBytes
});




}
/// @nodoc
class _$UserStorageInfoCopyWithImpl<$Res>
    implements $UserStorageInfoCopyWith<$Res> {
  _$UserStorageInfoCopyWithImpl(this._self, this._then);

  final UserStorageInfo _self;
  final $Res Function(UserStorageInfo) _then;

/// Create a copy of UserStorageInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? usedBytes = freezed,Object? availableBytes = freezed,}) {
  return _then(_self.copyWith(
usedBytes: freezed == usedBytes ? _self.usedBytes : usedBytes // ignore: cast_nullable_to_non_nullable
as int?,availableBytes: freezed == availableBytes ? _self.availableBytes : availableBytes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserStorageInfo].
extension UserStorageInfoPatterns on UserStorageInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserStorageInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserStorageInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserStorageInfo value)  $default,){
final _that = this;
switch (_that) {
case _UserStorageInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserStorageInfo value)?  $default,){
final _that = this;
switch (_that) {
case _UserStorageInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? usedBytes,  int? availableBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserStorageInfo() when $default != null:
return $default(_that.usedBytes,_that.availableBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? usedBytes,  int? availableBytes)  $default,) {final _that = this;
switch (_that) {
case _UserStorageInfo():
return $default(_that.usedBytes,_that.availableBytes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? usedBytes,  int? availableBytes)?  $default,) {final _that = this;
switch (_that) {
case _UserStorageInfo() when $default != null:
return $default(_that.usedBytes,_that.availableBytes);case _:
  return null;

}
}

}

/// @nodoc


class _UserStorageInfo implements UserStorageInfo {
  const _UserStorageInfo({required this.usedBytes, required this.availableBytes});
  

@override final  int? usedBytes;
@override final  int? availableBytes;

/// Create a copy of UserStorageInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserStorageInfoCopyWith<_UserStorageInfo> get copyWith => __$UserStorageInfoCopyWithImpl<_UserStorageInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserStorageInfo&&(identical(other.usedBytes, usedBytes) || other.usedBytes == usedBytes)&&(identical(other.availableBytes, availableBytes) || other.availableBytes == availableBytes));
}


@override
int get hashCode => Object.hash(runtimeType,usedBytes,availableBytes);

@override
String toString() {
  return 'UserStorageInfo(usedBytes: $usedBytes, availableBytes: $availableBytes)';
}


}

/// @nodoc
abstract mixin class _$UserStorageInfoCopyWith<$Res> implements $UserStorageInfoCopyWith<$Res> {
  factory _$UserStorageInfoCopyWith(_UserStorageInfo value, $Res Function(_UserStorageInfo) _then) = __$UserStorageInfoCopyWithImpl;
@override @useResult
$Res call({
 int? usedBytes, int? availableBytes
});




}
/// @nodoc
class __$UserStorageInfoCopyWithImpl<$Res>
    implements _$UserStorageInfoCopyWith<$Res> {
  __$UserStorageInfoCopyWithImpl(this._self, this._then);

  final _UserStorageInfo _self;
  final $Res Function(_UserStorageInfo) _then;

/// Create a copy of UserStorageInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? usedBytes = freezed,Object? availableBytes = freezed,}) {
  return _then(_UserStorageInfo(
usedBytes: freezed == usedBytes ? _self.usedBytes : usedBytes // ignore: cast_nullable_to_non_nullable
as int?,availableBytes: freezed == availableBytes ? _self.availableBytes : availableBytes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
