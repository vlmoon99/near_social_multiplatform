// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follower.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Follower {

 String get accountId;
/// Create a copy of Follower
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowerCopyWith<Follower> get copyWith => _$FollowerCopyWithImpl<Follower>(this as Follower, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Follower&&(identical(other.accountId, accountId) || other.accountId == accountId));
}


@override
int get hashCode => Object.hash(runtimeType,accountId);

@override
String toString() {
  return 'Follower(accountId: $accountId)';
}


}

/// @nodoc
abstract mixin class $FollowerCopyWith<$Res>  {
  factory $FollowerCopyWith(Follower value, $Res Function(Follower) _then) = _$FollowerCopyWithImpl;
@useResult
$Res call({
 String accountId
});




}
/// @nodoc
class _$FollowerCopyWithImpl<$Res>
    implements $FollowerCopyWith<$Res> {
  _$FollowerCopyWithImpl(this._self, this._then);

  final Follower _self;
  final $Res Function(Follower) _then;

/// Create a copy of Follower
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accountId = null,}) {
  return _then(_self.copyWith(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Follower].
extension FollowerPatterns on Follower {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Follower value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Follower() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Follower value)  $default,){
final _that = this;
switch (_that) {
case _Follower():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Follower value)?  $default,){
final _that = this;
switch (_that) {
case _Follower() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accountId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Follower() when $default != null:
return $default(_that.accountId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accountId)  $default,) {final _that = this;
switch (_that) {
case _Follower():
return $default(_that.accountId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accountId)?  $default,) {final _that = this;
switch (_that) {
case _Follower() when $default != null:
return $default(_that.accountId);case _:
  return null;

}
}

}

/// @nodoc


class _Follower implements Follower {
  const _Follower({required this.accountId});
  

@override final  String accountId;

/// Create a copy of Follower
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowerCopyWith<_Follower> get copyWith => __$FollowerCopyWithImpl<_Follower>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Follower&&(identical(other.accountId, accountId) || other.accountId == accountId));
}


@override
int get hashCode => Object.hash(runtimeType,accountId);

@override
String toString() {
  return 'Follower(accountId: $accountId)';
}


}

/// @nodoc
abstract mixin class _$FollowerCopyWith<$Res> implements $FollowerCopyWith<$Res> {
  factory _$FollowerCopyWith(_Follower value, $Res Function(_Follower) _then) = __$FollowerCopyWithImpl;
@override @useResult
$Res call({
 String accountId
});




}
/// @nodoc
class __$FollowerCopyWithImpl<$Res>
    implements _$FollowerCopyWith<$Res> {
  __$FollowerCopyWithImpl(this._self, this._then);

  final _Follower _self;
  final $Res Function(_Follower) _then;

/// Create a copy of Follower
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accountId = null,}) {
  return _then(_Follower(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
