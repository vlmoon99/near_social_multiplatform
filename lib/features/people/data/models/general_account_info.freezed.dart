// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'general_account_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GeneralAccountInfo {

 String get accountId; String get name; String get description; Map<String, dynamic> get linktree; List<String> get tags; String get profileImageLink; String get backgroundImageLink;
/// Create a copy of GeneralAccountInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeneralAccountInfoCopyWith<GeneralAccountInfo> get copyWith => _$GeneralAccountInfoCopyWithImpl<GeneralAccountInfo>(this as GeneralAccountInfo, _$identity);

  /// Serializes this GeneralAccountInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeneralAccountInfo&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.linktree, linktree)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.profileImageLink, profileImageLink) || other.profileImageLink == profileImageLink)&&(identical(other.backgroundImageLink, backgroundImageLink) || other.backgroundImageLink == backgroundImageLink));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountId,name,description,const DeepCollectionEquality().hash(linktree),const DeepCollectionEquality().hash(tags),profileImageLink,backgroundImageLink);

@override
String toString() {
  return 'GeneralAccountInfo(accountId: $accountId, name: $name, description: $description, linktree: $linktree, tags: $tags, profileImageLink: $profileImageLink, backgroundImageLink: $backgroundImageLink)';
}


}

/// @nodoc
abstract mixin class $GeneralAccountInfoCopyWith<$Res>  {
  factory $GeneralAccountInfoCopyWith(GeneralAccountInfo value, $Res Function(GeneralAccountInfo) _then) = _$GeneralAccountInfoCopyWithImpl;
@useResult
$Res call({
 String accountId, String name, String description, Map<String, dynamic> linktree, List<String> tags, String profileImageLink, String backgroundImageLink
});




}
/// @nodoc
class _$GeneralAccountInfoCopyWithImpl<$Res>
    implements $GeneralAccountInfoCopyWith<$Res> {
  _$GeneralAccountInfoCopyWithImpl(this._self, this._then);

  final GeneralAccountInfo _self;
  final $Res Function(GeneralAccountInfo) _then;

/// Create a copy of GeneralAccountInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accountId = null,Object? name = null,Object? description = null,Object? linktree = null,Object? tags = null,Object? profileImageLink = null,Object? backgroundImageLink = null,}) {
  return _then(_self.copyWith(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,linktree: null == linktree ? _self.linktree : linktree // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,profileImageLink: null == profileImageLink ? _self.profileImageLink : profileImageLink // ignore: cast_nullable_to_non_nullable
as String,backgroundImageLink: null == backgroundImageLink ? _self.backgroundImageLink : backgroundImageLink // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GeneralAccountInfo].
extension GeneralAccountInfoPatterns on GeneralAccountInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeneralAccountInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeneralAccountInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeneralAccountInfo value)  $default,){
final _that = this;
switch (_that) {
case _GeneralAccountInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeneralAccountInfo value)?  $default,){
final _that = this;
switch (_that) {
case _GeneralAccountInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accountId,  String name,  String description,  Map<String, dynamic> linktree,  List<String> tags,  String profileImageLink,  String backgroundImageLink)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeneralAccountInfo() when $default != null:
return $default(_that.accountId,_that.name,_that.description,_that.linktree,_that.tags,_that.profileImageLink,_that.backgroundImageLink);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accountId,  String name,  String description,  Map<String, dynamic> linktree,  List<String> tags,  String profileImageLink,  String backgroundImageLink)  $default,) {final _that = this;
switch (_that) {
case _GeneralAccountInfo():
return $default(_that.accountId,_that.name,_that.description,_that.linktree,_that.tags,_that.profileImageLink,_that.backgroundImageLink);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accountId,  String name,  String description,  Map<String, dynamic> linktree,  List<String> tags,  String profileImageLink,  String backgroundImageLink)?  $default,) {final _that = this;
switch (_that) {
case _GeneralAccountInfo() when $default != null:
return $default(_that.accountId,_that.name,_that.description,_that.linktree,_that.tags,_that.profileImageLink,_that.backgroundImageLink);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GeneralAccountInfo implements GeneralAccountInfo {
  const _GeneralAccountInfo({required this.accountId, required this.name, required this.description, required final  Map<String, dynamic> linktree, required final  List<String> tags, required this.profileImageLink, required this.backgroundImageLink}): _linktree = linktree,_tags = tags;
  factory _GeneralAccountInfo.fromJson(Map<String, dynamic> json) => _$GeneralAccountInfoFromJson(json);

@override final  String accountId;
@override final  String name;
@override final  String description;
 final  Map<String, dynamic> _linktree;
@override Map<String, dynamic> get linktree {
  if (_linktree is EqualUnmodifiableMapView) return _linktree;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_linktree);
}

 final  List<String> _tags;
@override List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  String profileImageLink;
@override final  String backgroundImageLink;

/// Create a copy of GeneralAccountInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeneralAccountInfoCopyWith<_GeneralAccountInfo> get copyWith => __$GeneralAccountInfoCopyWithImpl<_GeneralAccountInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GeneralAccountInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeneralAccountInfo&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._linktree, _linktree)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.profileImageLink, profileImageLink) || other.profileImageLink == profileImageLink)&&(identical(other.backgroundImageLink, backgroundImageLink) || other.backgroundImageLink == backgroundImageLink));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountId,name,description,const DeepCollectionEquality().hash(_linktree),const DeepCollectionEquality().hash(_tags),profileImageLink,backgroundImageLink);

@override
String toString() {
  return 'GeneralAccountInfo(accountId: $accountId, name: $name, description: $description, linktree: $linktree, tags: $tags, profileImageLink: $profileImageLink, backgroundImageLink: $backgroundImageLink)';
}


}

/// @nodoc
abstract mixin class _$GeneralAccountInfoCopyWith<$Res> implements $GeneralAccountInfoCopyWith<$Res> {
  factory _$GeneralAccountInfoCopyWith(_GeneralAccountInfo value, $Res Function(_GeneralAccountInfo) _then) = __$GeneralAccountInfoCopyWithImpl;
@override @useResult
$Res call({
 String accountId, String name, String description, Map<String, dynamic> linktree, List<String> tags, String profileImageLink, String backgroundImageLink
});




}
/// @nodoc
class __$GeneralAccountInfoCopyWithImpl<$Res>
    implements _$GeneralAccountInfoCopyWith<$Res> {
  __$GeneralAccountInfoCopyWithImpl(this._self, this._then);

  final _GeneralAccountInfo _self;
  final $Res Function(_GeneralAccountInfo) _then;

/// Create a copy of GeneralAccountInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accountId = null,Object? name = null,Object? description = null,Object? linktree = null,Object? tags = null,Object? profileImageLink = null,Object? backgroundImageLink = null,}) {
  return _then(_GeneralAccountInfo(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,linktree: null == linktree ? _self._linktree : linktree // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,profileImageLink: null == profileImageLink ? _self.profileImageLink : profileImageLink // ignore: cast_nullable_to_non_nullable
as String,backgroundImageLink: null == backgroundImageLink ? _self.backgroundImageLink : backgroundImageLink // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
