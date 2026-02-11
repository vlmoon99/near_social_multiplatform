// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Nft {

 String get contractId; String get tokenId; String get title; String get description; String get imageUrl;
/// Create a copy of Nft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NftCopyWith<Nft> get copyWith => _$NftCopyWithImpl<Nft>(this as Nft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Nft&&(identical(other.contractId, contractId) || other.contractId == contractId)&&(identical(other.tokenId, tokenId) || other.tokenId == tokenId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}


@override
int get hashCode => Object.hash(runtimeType,contractId,tokenId,title,description,imageUrl);

@override
String toString() {
  return 'Nft(contractId: $contractId, tokenId: $tokenId, title: $title, description: $description, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $NftCopyWith<$Res>  {
  factory $NftCopyWith(Nft value, $Res Function(Nft) _then) = _$NftCopyWithImpl;
@useResult
$Res call({
 String contractId, String tokenId, String title, String description, String imageUrl
});




}
/// @nodoc
class _$NftCopyWithImpl<$Res>
    implements $NftCopyWith<$Res> {
  _$NftCopyWithImpl(this._self, this._then);

  final Nft _self;
  final $Res Function(Nft) _then;

/// Create a copy of Nft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contractId = null,Object? tokenId = null,Object? title = null,Object? description = null,Object? imageUrl = null,}) {
  return _then(_self.copyWith(
contractId: null == contractId ? _self.contractId : contractId // ignore: cast_nullable_to_non_nullable
as String,tokenId: null == tokenId ? _self.tokenId : tokenId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Nft].
extension NftPatterns on Nft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Nft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Nft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Nft value)  $default,){
final _that = this;
switch (_that) {
case _Nft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Nft value)?  $default,){
final _that = this;
switch (_that) {
case _Nft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String contractId,  String tokenId,  String title,  String description,  String imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Nft() when $default != null:
return $default(_that.contractId,_that.tokenId,_that.title,_that.description,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String contractId,  String tokenId,  String title,  String description,  String imageUrl)  $default,) {final _that = this;
switch (_that) {
case _Nft():
return $default(_that.contractId,_that.tokenId,_that.title,_that.description,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String contractId,  String tokenId,  String title,  String description,  String imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _Nft() when $default != null:
return $default(_that.contractId,_that.tokenId,_that.title,_that.description,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc


class _Nft implements Nft {
  const _Nft({required this.contractId, required this.tokenId, required this.title, required this.description, required this.imageUrl});
  

@override final  String contractId;
@override final  String tokenId;
@override final  String title;
@override final  String description;
@override final  String imageUrl;

/// Create a copy of Nft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NftCopyWith<_Nft> get copyWith => __$NftCopyWithImpl<_Nft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Nft&&(identical(other.contractId, contractId) || other.contractId == contractId)&&(identical(other.tokenId, tokenId) || other.tokenId == tokenId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}


@override
int get hashCode => Object.hash(runtimeType,contractId,tokenId,title,description,imageUrl);

@override
String toString() {
  return 'Nft(contractId: $contractId, tokenId: $tokenId, title: $title, description: $description, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$NftCopyWith<$Res> implements $NftCopyWith<$Res> {
  factory _$NftCopyWith(_Nft value, $Res Function(_Nft) _then) = __$NftCopyWithImpl;
@override @useResult
$Res call({
 String contractId, String tokenId, String title, String description, String imageUrl
});




}
/// @nodoc
class __$NftCopyWithImpl<$Res>
    implements _$NftCopyWith<$Res> {
  __$NftCopyWithImpl(this._self, this._then);

  final _Nft _self;
  final $Res Function(_Nft) _then;

/// Create a copy of Nft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contractId = null,Object? tokenId = null,Object? title = null,Object? description = null,Object? imageUrl = null,}) {
  return _then(_Nft(
contractId: null == contractId ? _self.contractId : contractId // ignore: cast_nullable_to_non_nullable
as String,tokenId: null == tokenId ? _self.tokenId : tokenId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
