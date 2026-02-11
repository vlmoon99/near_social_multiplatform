// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Filters {

 FilterLoadStatus get status; List<String> get blockedAccounts; List<String> get hidedPosts; List<String> get hidedAllPostsAccounts;
/// Create a copy of Filters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FiltersCopyWith<Filters> get copyWith => _$FiltersCopyWithImpl<Filters>(this as Filters, _$identity);

  /// Serializes this Filters to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Filters&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.blockedAccounts, blockedAccounts)&&const DeepCollectionEquality().equals(other.hidedPosts, hidedPosts)&&const DeepCollectionEquality().equals(other.hidedAllPostsAccounts, hidedAllPostsAccounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(blockedAccounts),const DeepCollectionEquality().hash(hidedPosts),const DeepCollectionEquality().hash(hidedAllPostsAccounts));

@override
String toString() {
  return 'Filters(status: $status, blockedAccounts: $blockedAccounts, hidedPosts: $hidedPosts, hidedAllPostsAccounts: $hidedAllPostsAccounts)';
}


}

/// @nodoc
abstract mixin class $FiltersCopyWith<$Res>  {
  factory $FiltersCopyWith(Filters value, $Res Function(Filters) _then) = _$FiltersCopyWithImpl;
@useResult
$Res call({
 FilterLoadStatus status, List<String> blockedAccounts, List<String> hidedPosts, List<String> hidedAllPostsAccounts
});




}
/// @nodoc
class _$FiltersCopyWithImpl<$Res>
    implements $FiltersCopyWith<$Res> {
  _$FiltersCopyWithImpl(this._self, this._then);

  final Filters _self;
  final $Res Function(Filters) _then;

/// Create a copy of Filters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? blockedAccounts = null,Object? hidedPosts = null,Object? hidedAllPostsAccounts = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FilterLoadStatus,blockedAccounts: null == blockedAccounts ? _self.blockedAccounts : blockedAccounts // ignore: cast_nullable_to_non_nullable
as List<String>,hidedPosts: null == hidedPosts ? _self.hidedPosts : hidedPosts // ignore: cast_nullable_to_non_nullable
as List<String>,hidedAllPostsAccounts: null == hidedAllPostsAccounts ? _self.hidedAllPostsAccounts : hidedAllPostsAccounts // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Filters].
extension FiltersPatterns on Filters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Filters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Filters() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Filters value)  $default,){
final _that = this;
switch (_that) {
case _Filters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Filters value)?  $default,){
final _that = this;
switch (_that) {
case _Filters() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FilterLoadStatus status,  List<String> blockedAccounts,  List<String> hidedPosts,  List<String> hidedAllPostsAccounts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Filters() when $default != null:
return $default(_that.status,_that.blockedAccounts,_that.hidedPosts,_that.hidedAllPostsAccounts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FilterLoadStatus status,  List<String> blockedAccounts,  List<String> hidedPosts,  List<String> hidedAllPostsAccounts)  $default,) {final _that = this;
switch (_that) {
case _Filters():
return $default(_that.status,_that.blockedAccounts,_that.hidedPosts,_that.hidedAllPostsAccounts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FilterLoadStatus status,  List<String> blockedAccounts,  List<String> hidedPosts,  List<String> hidedAllPostsAccounts)?  $default,) {final _that = this;
switch (_that) {
case _Filters() when $default != null:
return $default(_that.status,_that.blockedAccounts,_that.hidedPosts,_that.hidedAllPostsAccounts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Filters extends Filters {
  const _Filters({this.status = FilterLoadStatus.initial, final  List<String> blockedAccounts = const [], final  List<String> hidedPosts = const [], final  List<String> hidedAllPostsAccounts = const []}): _blockedAccounts = blockedAccounts,_hidedPosts = hidedPosts,_hidedAllPostsAccounts = hidedAllPostsAccounts,super._();
  factory _Filters.fromJson(Map<String, dynamic> json) => _$FiltersFromJson(json);

@override@JsonKey() final  FilterLoadStatus status;
 final  List<String> _blockedAccounts;
@override@JsonKey() List<String> get blockedAccounts {
  if (_blockedAccounts is EqualUnmodifiableListView) return _blockedAccounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blockedAccounts);
}

 final  List<String> _hidedPosts;
@override@JsonKey() List<String> get hidedPosts {
  if (_hidedPosts is EqualUnmodifiableListView) return _hidedPosts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hidedPosts);
}

 final  List<String> _hidedAllPostsAccounts;
@override@JsonKey() List<String> get hidedAllPostsAccounts {
  if (_hidedAllPostsAccounts is EqualUnmodifiableListView) return _hidedAllPostsAccounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hidedAllPostsAccounts);
}


/// Create a copy of Filters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FiltersCopyWith<_Filters> get copyWith => __$FiltersCopyWithImpl<_Filters>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FiltersToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Filters&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._blockedAccounts, _blockedAccounts)&&const DeepCollectionEquality().equals(other._hidedPosts, _hidedPosts)&&const DeepCollectionEquality().equals(other._hidedAllPostsAccounts, _hidedAllPostsAccounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_blockedAccounts),const DeepCollectionEquality().hash(_hidedPosts),const DeepCollectionEquality().hash(_hidedAllPostsAccounts));

@override
String toString() {
  return 'Filters(status: $status, blockedAccounts: $blockedAccounts, hidedPosts: $hidedPosts, hidedAllPostsAccounts: $hidedAllPostsAccounts)';
}


}

/// @nodoc
abstract mixin class _$FiltersCopyWith<$Res> implements $FiltersCopyWith<$Res> {
  factory _$FiltersCopyWith(_Filters value, $Res Function(_Filters) _then) = __$FiltersCopyWithImpl;
@override @useResult
$Res call({
 FilterLoadStatus status, List<String> blockedAccounts, List<String> hidedPosts, List<String> hidedAllPostsAccounts
});




}
/// @nodoc
class __$FiltersCopyWithImpl<$Res>
    implements _$FiltersCopyWith<$Res> {
  __$FiltersCopyWithImpl(this._self, this._then);

  final _Filters _self;
  final $Res Function(_Filters) _then;

/// Create a copy of Filters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? blockedAccounts = null,Object? hidedPosts = null,Object? hidedAllPostsAccounts = null,}) {
  return _then(_Filters(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FilterLoadStatus,blockedAccounts: null == blockedAccounts ? _self._blockedAccounts : blockedAccounts // ignore: cast_nullable_to_non_nullable
as List<String>,hidedPosts: null == hidedPosts ? _self._hidedPosts : hidedPosts // ignore: cast_nullable_to_non_nullable
as List<String>,hidedAllPostsAccounts: null == hidedAllPostsAccounts ? _self._hidedAllPostsAccounts : hidedAllPostsAccounts // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
