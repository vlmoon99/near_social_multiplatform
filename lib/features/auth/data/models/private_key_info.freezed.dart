// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'private_key_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrivateKeyInfo {

 String get publicKey; String get privateKey; String get base58PubKey; PrivateKeyTypeInfo get privateKeyTypeInfo;
/// Create a copy of PrivateKeyInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrivateKeyInfoCopyWith<PrivateKeyInfo> get copyWith => _$PrivateKeyInfoCopyWithImpl<PrivateKeyInfo>(this as PrivateKeyInfo, _$identity);

  /// Serializes this PrivateKeyInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrivateKeyInfo&&(identical(other.publicKey, publicKey) || other.publicKey == publicKey)&&(identical(other.privateKey, privateKey) || other.privateKey == privateKey)&&(identical(other.base58PubKey, base58PubKey) || other.base58PubKey == base58PubKey)&&(identical(other.privateKeyTypeInfo, privateKeyTypeInfo) || other.privateKeyTypeInfo == privateKeyTypeInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,publicKey,privateKey,base58PubKey,privateKeyTypeInfo);

@override
String toString() {
  return 'PrivateKeyInfo(publicKey: $publicKey, privateKey: $privateKey, base58PubKey: $base58PubKey, privateKeyTypeInfo: $privateKeyTypeInfo)';
}


}

/// @nodoc
abstract mixin class $PrivateKeyInfoCopyWith<$Res>  {
  factory $PrivateKeyInfoCopyWith(PrivateKeyInfo value, $Res Function(PrivateKeyInfo) _then) = _$PrivateKeyInfoCopyWithImpl;
@useResult
$Res call({
 String publicKey, String privateKey, String base58PubKey, PrivateKeyTypeInfo privateKeyTypeInfo
});


$PrivateKeyTypeInfoCopyWith<$Res> get privateKeyTypeInfo;

}
/// @nodoc
class _$PrivateKeyInfoCopyWithImpl<$Res>
    implements $PrivateKeyInfoCopyWith<$Res> {
  _$PrivateKeyInfoCopyWithImpl(this._self, this._then);

  final PrivateKeyInfo _self;
  final $Res Function(PrivateKeyInfo) _then;

/// Create a copy of PrivateKeyInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? publicKey = null,Object? privateKey = null,Object? base58PubKey = null,Object? privateKeyTypeInfo = null,}) {
  return _then(_self.copyWith(
publicKey: null == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as String,privateKey: null == privateKey ? _self.privateKey : privateKey // ignore: cast_nullable_to_non_nullable
as String,base58PubKey: null == base58PubKey ? _self.base58PubKey : base58PubKey // ignore: cast_nullable_to_non_nullable
as String,privateKeyTypeInfo: null == privateKeyTypeInfo ? _self.privateKeyTypeInfo : privateKeyTypeInfo // ignore: cast_nullable_to_non_nullable
as PrivateKeyTypeInfo,
  ));
}
/// Create a copy of PrivateKeyInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PrivateKeyTypeInfoCopyWith<$Res> get privateKeyTypeInfo {
  
  return $PrivateKeyTypeInfoCopyWith<$Res>(_self.privateKeyTypeInfo, (value) {
    return _then(_self.copyWith(privateKeyTypeInfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [PrivateKeyInfo].
extension PrivateKeyInfoPatterns on PrivateKeyInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrivateKeyInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrivateKeyInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrivateKeyInfo value)  $default,){
final _that = this;
switch (_that) {
case _PrivateKeyInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrivateKeyInfo value)?  $default,){
final _that = this;
switch (_that) {
case _PrivateKeyInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String publicKey,  String privateKey,  String base58PubKey,  PrivateKeyTypeInfo privateKeyTypeInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrivateKeyInfo() when $default != null:
return $default(_that.publicKey,_that.privateKey,_that.base58PubKey,_that.privateKeyTypeInfo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String publicKey,  String privateKey,  String base58PubKey,  PrivateKeyTypeInfo privateKeyTypeInfo)  $default,) {final _that = this;
switch (_that) {
case _PrivateKeyInfo():
return $default(_that.publicKey,_that.privateKey,_that.base58PubKey,_that.privateKeyTypeInfo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String publicKey,  String privateKey,  String base58PubKey,  PrivateKeyTypeInfo privateKeyTypeInfo)?  $default,) {final _that = this;
switch (_that) {
case _PrivateKeyInfo() when $default != null:
return $default(_that.publicKey,_that.privateKey,_that.base58PubKey,_that.privateKeyTypeInfo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrivateKeyInfo implements PrivateKeyInfo {
  const _PrivateKeyInfo({required this.publicKey, required this.privateKey, required this.base58PubKey, required this.privateKeyTypeInfo});
  factory _PrivateKeyInfo.fromJson(Map<String, dynamic> json) => _$PrivateKeyInfoFromJson(json);

@override final  String publicKey;
@override final  String privateKey;
@override final  String base58PubKey;
@override final  PrivateKeyTypeInfo privateKeyTypeInfo;

/// Create a copy of PrivateKeyInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrivateKeyInfoCopyWith<_PrivateKeyInfo> get copyWith => __$PrivateKeyInfoCopyWithImpl<_PrivateKeyInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrivateKeyInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrivateKeyInfo&&(identical(other.publicKey, publicKey) || other.publicKey == publicKey)&&(identical(other.privateKey, privateKey) || other.privateKey == privateKey)&&(identical(other.base58PubKey, base58PubKey) || other.base58PubKey == base58PubKey)&&(identical(other.privateKeyTypeInfo, privateKeyTypeInfo) || other.privateKeyTypeInfo == privateKeyTypeInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,publicKey,privateKey,base58PubKey,privateKeyTypeInfo);

@override
String toString() {
  return 'PrivateKeyInfo(publicKey: $publicKey, privateKey: $privateKey, base58PubKey: $base58PubKey, privateKeyTypeInfo: $privateKeyTypeInfo)';
}


}

/// @nodoc
abstract mixin class _$PrivateKeyInfoCopyWith<$Res> implements $PrivateKeyInfoCopyWith<$Res> {
  factory _$PrivateKeyInfoCopyWith(_PrivateKeyInfo value, $Res Function(_PrivateKeyInfo) _then) = __$PrivateKeyInfoCopyWithImpl;
@override @useResult
$Res call({
 String publicKey, String privateKey, String base58PubKey, PrivateKeyTypeInfo privateKeyTypeInfo
});


@override $PrivateKeyTypeInfoCopyWith<$Res> get privateKeyTypeInfo;

}
/// @nodoc
class __$PrivateKeyInfoCopyWithImpl<$Res>
    implements _$PrivateKeyInfoCopyWith<$Res> {
  __$PrivateKeyInfoCopyWithImpl(this._self, this._then);

  final _PrivateKeyInfo _self;
  final $Res Function(_PrivateKeyInfo) _then;

/// Create a copy of PrivateKeyInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? publicKey = null,Object? privateKey = null,Object? base58PubKey = null,Object? privateKeyTypeInfo = null,}) {
  return _then(_PrivateKeyInfo(
publicKey: null == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as String,privateKey: null == privateKey ? _self.privateKey : privateKey // ignore: cast_nullable_to_non_nullable
as String,base58PubKey: null == base58PubKey ? _self.base58PubKey : base58PubKey // ignore: cast_nullable_to_non_nullable
as String,privateKeyTypeInfo: null == privateKeyTypeInfo ? _self.privateKeyTypeInfo : privateKeyTypeInfo // ignore: cast_nullable_to_non_nullable
as PrivateKeyTypeInfo,
  ));
}

/// Create a copy of PrivateKeyInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PrivateKeyTypeInfoCopyWith<$Res> get privateKeyTypeInfo {
  
  return $PrivateKeyTypeInfoCopyWith<$Res>(_self.privateKeyTypeInfo, (value) {
    return _then(_self.copyWith(privateKeyTypeInfo: value));
  });
}
}


/// @nodoc
mixin _$PrivateKeyTypeInfo {

 PrivateKeyType get type; String? get receiverId; List<String>? get methodNames;
/// Create a copy of PrivateKeyTypeInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrivateKeyTypeInfoCopyWith<PrivateKeyTypeInfo> get copyWith => _$PrivateKeyTypeInfoCopyWithImpl<PrivateKeyTypeInfo>(this as PrivateKeyTypeInfo, _$identity);

  /// Serializes this PrivateKeyTypeInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrivateKeyTypeInfo&&(identical(other.type, type) || other.type == type)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&const DeepCollectionEquality().equals(other.methodNames, methodNames));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,receiverId,const DeepCollectionEquality().hash(methodNames));

@override
String toString() {
  return 'PrivateKeyTypeInfo(type: $type, receiverId: $receiverId, methodNames: $methodNames)';
}


}

/// @nodoc
abstract mixin class $PrivateKeyTypeInfoCopyWith<$Res>  {
  factory $PrivateKeyTypeInfoCopyWith(PrivateKeyTypeInfo value, $Res Function(PrivateKeyTypeInfo) _then) = _$PrivateKeyTypeInfoCopyWithImpl;
@useResult
$Res call({
 PrivateKeyType type, String? receiverId, List<String>? methodNames
});




}
/// @nodoc
class _$PrivateKeyTypeInfoCopyWithImpl<$Res>
    implements $PrivateKeyTypeInfoCopyWith<$Res> {
  _$PrivateKeyTypeInfoCopyWithImpl(this._self, this._then);

  final PrivateKeyTypeInfo _self;
  final $Res Function(PrivateKeyTypeInfo) _then;

/// Create a copy of PrivateKeyTypeInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? receiverId = freezed,Object? methodNames = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PrivateKeyType,receiverId: freezed == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String?,methodNames: freezed == methodNames ? _self.methodNames : methodNames // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [PrivateKeyTypeInfo].
extension PrivateKeyTypeInfoPatterns on PrivateKeyTypeInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrivateKeyTypeInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrivateKeyTypeInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrivateKeyTypeInfo value)  $default,){
final _that = this;
switch (_that) {
case _PrivateKeyTypeInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrivateKeyTypeInfo value)?  $default,){
final _that = this;
switch (_that) {
case _PrivateKeyTypeInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PrivateKeyType type,  String? receiverId,  List<String>? methodNames)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrivateKeyTypeInfo() when $default != null:
return $default(_that.type,_that.receiverId,_that.methodNames);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PrivateKeyType type,  String? receiverId,  List<String>? methodNames)  $default,) {final _that = this;
switch (_that) {
case _PrivateKeyTypeInfo():
return $default(_that.type,_that.receiverId,_that.methodNames);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PrivateKeyType type,  String? receiverId,  List<String>? methodNames)?  $default,) {final _that = this;
switch (_that) {
case _PrivateKeyTypeInfo() when $default != null:
return $default(_that.type,_that.receiverId,_that.methodNames);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrivateKeyTypeInfo implements PrivateKeyTypeInfo {
  const _PrivateKeyTypeInfo({required this.type, this.receiverId, final  List<String>? methodNames}): _methodNames = methodNames;
  factory _PrivateKeyTypeInfo.fromJson(Map<String, dynamic> json) => _$PrivateKeyTypeInfoFromJson(json);

@override final  PrivateKeyType type;
@override final  String? receiverId;
 final  List<String>? _methodNames;
@override List<String>? get methodNames {
  final value = _methodNames;
  if (value == null) return null;
  if (_methodNames is EqualUnmodifiableListView) return _methodNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of PrivateKeyTypeInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrivateKeyTypeInfoCopyWith<_PrivateKeyTypeInfo> get copyWith => __$PrivateKeyTypeInfoCopyWithImpl<_PrivateKeyTypeInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrivateKeyTypeInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrivateKeyTypeInfo&&(identical(other.type, type) || other.type == type)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&const DeepCollectionEquality().equals(other._methodNames, _methodNames));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,receiverId,const DeepCollectionEquality().hash(_methodNames));

@override
String toString() {
  return 'PrivateKeyTypeInfo(type: $type, receiverId: $receiverId, methodNames: $methodNames)';
}


}

/// @nodoc
abstract mixin class _$PrivateKeyTypeInfoCopyWith<$Res> implements $PrivateKeyTypeInfoCopyWith<$Res> {
  factory _$PrivateKeyTypeInfoCopyWith(_PrivateKeyTypeInfo value, $Res Function(_PrivateKeyTypeInfo) _then) = __$PrivateKeyTypeInfoCopyWithImpl;
@override @useResult
$Res call({
 PrivateKeyType type, String? receiverId, List<String>? methodNames
});




}
/// @nodoc
class __$PrivateKeyTypeInfoCopyWithImpl<$Res>
    implements _$PrivateKeyTypeInfoCopyWith<$Res> {
  __$PrivateKeyTypeInfoCopyWithImpl(this._self, this._then);

  final _PrivateKeyTypeInfo _self;
  final $Res Function(_PrivateKeyTypeInfo) _then;

/// Create a copy of PrivateKeyTypeInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? receiverId = freezed,Object? methodNames = freezed,}) {
  return _then(_PrivateKeyTypeInfo(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PrivateKeyType,receiverId: freezed == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String?,methodNames: freezed == methodNames ? _self._methodNames : methodNames // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
