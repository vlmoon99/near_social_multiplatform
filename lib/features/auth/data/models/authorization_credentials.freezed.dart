// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'authorization_credentials.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthorizationCredentials {

 String get accountId; String get secretKey;
/// Create a copy of AuthorizationCredentials
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthorizationCredentialsCopyWith<AuthorizationCredentials> get copyWith => _$AuthorizationCredentialsCopyWithImpl<AuthorizationCredentials>(this as AuthorizationCredentials, _$identity);

  /// Serializes this AuthorizationCredentials to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthorizationCredentials&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.secretKey, secretKey) || other.secretKey == secretKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountId,secretKey);

@override
String toString() {
  return 'AuthorizationCredentials(accountId: $accountId, secretKey: $secretKey)';
}


}

/// @nodoc
abstract mixin class $AuthorizationCredentialsCopyWith<$Res>  {
  factory $AuthorizationCredentialsCopyWith(AuthorizationCredentials value, $Res Function(AuthorizationCredentials) _then) = _$AuthorizationCredentialsCopyWithImpl;
@useResult
$Res call({
 String accountId, String secretKey
});




}
/// @nodoc
class _$AuthorizationCredentialsCopyWithImpl<$Res>
    implements $AuthorizationCredentialsCopyWith<$Res> {
  _$AuthorizationCredentialsCopyWithImpl(this._self, this._then);

  final AuthorizationCredentials _self;
  final $Res Function(AuthorizationCredentials) _then;

/// Create a copy of AuthorizationCredentials
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accountId = null,Object? secretKey = null,}) {
  return _then(_self.copyWith(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,secretKey: null == secretKey ? _self.secretKey : secretKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthorizationCredentials].
extension AuthorizationCredentialsPatterns on AuthorizationCredentials {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthorizationCredentials value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthorizationCredentials() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthorizationCredentials value)  $default,){
final _that = this;
switch (_that) {
case _AuthorizationCredentials():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthorizationCredentials value)?  $default,){
final _that = this;
switch (_that) {
case _AuthorizationCredentials() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accountId,  String secretKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthorizationCredentials() when $default != null:
return $default(_that.accountId,_that.secretKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accountId,  String secretKey)  $default,) {final _that = this;
switch (_that) {
case _AuthorizationCredentials():
return $default(_that.accountId,_that.secretKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accountId,  String secretKey)?  $default,) {final _that = this;
switch (_that) {
case _AuthorizationCredentials() when $default != null:
return $default(_that.accountId,_that.secretKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthorizationCredentials implements AuthorizationCredentials {
  const _AuthorizationCredentials({required this.accountId, required this.secretKey});
  factory _AuthorizationCredentials.fromJson(Map<String, dynamic> json) => _$AuthorizationCredentialsFromJson(json);

@override final  String accountId;
@override final  String secretKey;

/// Create a copy of AuthorizationCredentials
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthorizationCredentialsCopyWith<_AuthorizationCredentials> get copyWith => __$AuthorizationCredentialsCopyWithImpl<_AuthorizationCredentials>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthorizationCredentialsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthorizationCredentials&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.secretKey, secretKey) || other.secretKey == secretKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountId,secretKey);

@override
String toString() {
  return 'AuthorizationCredentials(accountId: $accountId, secretKey: $secretKey)';
}


}

/// @nodoc
abstract mixin class _$AuthorizationCredentialsCopyWith<$Res> implements $AuthorizationCredentialsCopyWith<$Res> {
  factory _$AuthorizationCredentialsCopyWith(_AuthorizationCredentials value, $Res Function(_AuthorizationCredentials) _then) = __$AuthorizationCredentialsCopyWithImpl;
@override @useResult
$Res call({
 String accountId, String secretKey
});




}
/// @nodoc
class __$AuthorizationCredentialsCopyWithImpl<$Res>
    implements _$AuthorizationCredentialsCopyWith<$Res> {
  __$AuthorizationCredentialsCopyWithImpl(this._self, this._then);

  final _AuthorizationCredentials _self;
  final $Res Function(_AuthorizationCredentials) _then;

/// Create a copy of AuthorizationCredentials
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accountId = null,Object? secretKey = null,}) {
  return _then(_AuthorizationCredentials(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,secretKey: null == secretKey ? _self.secretKey : secretKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
