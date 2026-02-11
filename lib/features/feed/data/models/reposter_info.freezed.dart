// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reposter_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReposterInfo {

 GeneralAccountInfo get accountInfo; int get blockHeight;
/// Create a copy of ReposterInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReposterInfoCopyWith<ReposterInfo> get copyWith => _$ReposterInfoCopyWithImpl<ReposterInfo>(this as ReposterInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReposterInfo&&(identical(other.accountInfo, accountInfo) || other.accountInfo == accountInfo)&&(identical(other.blockHeight, blockHeight) || other.blockHeight == blockHeight));
}


@override
int get hashCode => Object.hash(runtimeType,accountInfo,blockHeight);

@override
String toString() {
  return 'ReposterInfo(accountInfo: $accountInfo, blockHeight: $blockHeight)';
}


}

/// @nodoc
abstract mixin class $ReposterInfoCopyWith<$Res>  {
  factory $ReposterInfoCopyWith(ReposterInfo value, $Res Function(ReposterInfo) _then) = _$ReposterInfoCopyWithImpl;
@useResult
$Res call({
 GeneralAccountInfo accountInfo, int blockHeight
});


$GeneralAccountInfoCopyWith<$Res> get accountInfo;

}
/// @nodoc
class _$ReposterInfoCopyWithImpl<$Res>
    implements $ReposterInfoCopyWith<$Res> {
  _$ReposterInfoCopyWithImpl(this._self, this._then);

  final ReposterInfo _self;
  final $Res Function(ReposterInfo) _then;

/// Create a copy of ReposterInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accountInfo = null,Object? blockHeight = null,}) {
  return _then(_self.copyWith(
accountInfo: null == accountInfo ? _self.accountInfo : accountInfo // ignore: cast_nullable_to_non_nullable
as GeneralAccountInfo,blockHeight: null == blockHeight ? _self.blockHeight : blockHeight // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of ReposterInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeneralAccountInfoCopyWith<$Res> get accountInfo {
  
  return $GeneralAccountInfoCopyWith<$Res>(_self.accountInfo, (value) {
    return _then(_self.copyWith(accountInfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReposterInfo].
extension ReposterInfoPatterns on ReposterInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReposterInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReposterInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReposterInfo value)  $default,){
final _that = this;
switch (_that) {
case _ReposterInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReposterInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ReposterInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GeneralAccountInfo accountInfo,  int blockHeight)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReposterInfo() when $default != null:
return $default(_that.accountInfo,_that.blockHeight);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GeneralAccountInfo accountInfo,  int blockHeight)  $default,) {final _that = this;
switch (_that) {
case _ReposterInfo():
return $default(_that.accountInfo,_that.blockHeight);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GeneralAccountInfo accountInfo,  int blockHeight)?  $default,) {final _that = this;
switch (_that) {
case _ReposterInfo() when $default != null:
return $default(_that.accountInfo,_that.blockHeight);case _:
  return null;

}
}

}

/// @nodoc


class _ReposterInfo implements ReposterInfo {
  const _ReposterInfo({required this.accountInfo, required this.blockHeight});
  

@override final  GeneralAccountInfo accountInfo;
@override final  int blockHeight;

/// Create a copy of ReposterInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReposterInfoCopyWith<_ReposterInfo> get copyWith => __$ReposterInfoCopyWithImpl<_ReposterInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReposterInfo&&(identical(other.accountInfo, accountInfo) || other.accountInfo == accountInfo)&&(identical(other.blockHeight, blockHeight) || other.blockHeight == blockHeight));
}


@override
int get hashCode => Object.hash(runtimeType,accountInfo,blockHeight);

@override
String toString() {
  return 'ReposterInfo(accountInfo: $accountInfo, blockHeight: $blockHeight)';
}


}

/// @nodoc
abstract mixin class _$ReposterInfoCopyWith<$Res> implements $ReposterInfoCopyWith<$Res> {
  factory _$ReposterInfoCopyWith(_ReposterInfo value, $Res Function(_ReposterInfo) _then) = __$ReposterInfoCopyWithImpl;
@override @useResult
$Res call({
 GeneralAccountInfo accountInfo, int blockHeight
});


@override $GeneralAccountInfoCopyWith<$Res> get accountInfo;

}
/// @nodoc
class __$ReposterInfoCopyWithImpl<$Res>
    implements _$ReposterInfoCopyWith<$Res> {
  __$ReposterInfoCopyWithImpl(this._self, this._then);

  final _ReposterInfo _self;
  final $Res Function(_ReposterInfo) _then;

/// Create a copy of ReposterInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accountInfo = null,Object? blockHeight = null,}) {
  return _then(_ReposterInfo(
accountInfo: null == accountInfo ? _self.accountInfo : accountInfo // ignore: cast_nullable_to_non_nullable
as GeneralAccountInfo,blockHeight: null == blockHeight ? _self.blockHeight : blockHeight // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of ReposterInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeneralAccountInfoCopyWith<$Res> get accountInfo {
  
  return $GeneralAccountInfoCopyWith<$Res>(_self.accountInfo, (value) {
    return _then(_self.copyWith(accountInfo: value));
  });
}
}

// dart format on
