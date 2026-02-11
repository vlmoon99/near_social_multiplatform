// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Comment {

 GeneralAccountInfo get authorInfo; int get blockHeight; DateTime get date; CommentBody get commentBody; List<Like> get likeList;
/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentCopyWith<Comment> get copyWith => _$CommentCopyWithImpl<Comment>(this as Comment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Comment&&(identical(other.authorInfo, authorInfo) || other.authorInfo == authorInfo)&&(identical(other.blockHeight, blockHeight) || other.blockHeight == blockHeight)&&(identical(other.date, date) || other.date == date)&&(identical(other.commentBody, commentBody) || other.commentBody == commentBody)&&const DeepCollectionEquality().equals(other.likeList, likeList));
}


@override
int get hashCode => Object.hash(runtimeType,authorInfo,blockHeight,date,commentBody,const DeepCollectionEquality().hash(likeList));

@override
String toString() {
  return 'Comment(authorInfo: $authorInfo, blockHeight: $blockHeight, date: $date, commentBody: $commentBody, likeList: $likeList)';
}


}

/// @nodoc
abstract mixin class $CommentCopyWith<$Res>  {
  factory $CommentCopyWith(Comment value, $Res Function(Comment) _then) = _$CommentCopyWithImpl;
@useResult
$Res call({
 GeneralAccountInfo authorInfo, int blockHeight, DateTime date, CommentBody commentBody, List<Like> likeList
});


$GeneralAccountInfoCopyWith<$Res> get authorInfo;$CommentBodyCopyWith<$Res> get commentBody;

}
/// @nodoc
class _$CommentCopyWithImpl<$Res>
    implements $CommentCopyWith<$Res> {
  _$CommentCopyWithImpl(this._self, this._then);

  final Comment _self;
  final $Res Function(Comment) _then;

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? authorInfo = null,Object? blockHeight = null,Object? date = null,Object? commentBody = null,Object? likeList = null,}) {
  return _then(_self.copyWith(
authorInfo: null == authorInfo ? _self.authorInfo : authorInfo // ignore: cast_nullable_to_non_nullable
as GeneralAccountInfo,blockHeight: null == blockHeight ? _self.blockHeight : blockHeight // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,commentBody: null == commentBody ? _self.commentBody : commentBody // ignore: cast_nullable_to_non_nullable
as CommentBody,likeList: null == likeList ? _self.likeList : likeList // ignore: cast_nullable_to_non_nullable
as List<Like>,
  ));
}
/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeneralAccountInfoCopyWith<$Res> get authorInfo {
  
  return $GeneralAccountInfoCopyWith<$Res>(_self.authorInfo, (value) {
    return _then(_self.copyWith(authorInfo: value));
  });
}/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentBodyCopyWith<$Res> get commentBody {
  
  return $CommentBodyCopyWith<$Res>(_self.commentBody, (value) {
    return _then(_self.copyWith(commentBody: value));
  });
}
}


/// Adds pattern-matching-related methods to [Comment].
extension CommentPatterns on Comment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Comment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Comment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Comment value)  $default,){
final _that = this;
switch (_that) {
case _Comment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Comment value)?  $default,){
final _that = this;
switch (_that) {
case _Comment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GeneralAccountInfo authorInfo,  int blockHeight,  DateTime date,  CommentBody commentBody,  List<Like> likeList)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Comment() when $default != null:
return $default(_that.authorInfo,_that.blockHeight,_that.date,_that.commentBody,_that.likeList);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GeneralAccountInfo authorInfo,  int blockHeight,  DateTime date,  CommentBody commentBody,  List<Like> likeList)  $default,) {final _that = this;
switch (_that) {
case _Comment():
return $default(_that.authorInfo,_that.blockHeight,_that.date,_that.commentBody,_that.likeList);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GeneralAccountInfo authorInfo,  int blockHeight,  DateTime date,  CommentBody commentBody,  List<Like> likeList)?  $default,) {final _that = this;
switch (_that) {
case _Comment() when $default != null:
return $default(_that.authorInfo,_that.blockHeight,_that.date,_that.commentBody,_that.likeList);case _:
  return null;

}
}

}

/// @nodoc


class _Comment implements Comment {
  const _Comment({required this.authorInfo, required this.blockHeight, required this.date, required this.commentBody, required final  List<Like> likeList}): _likeList = likeList;
  

@override final  GeneralAccountInfo authorInfo;
@override final  int blockHeight;
@override final  DateTime date;
@override final  CommentBody commentBody;
 final  List<Like> _likeList;
@override List<Like> get likeList {
  if (_likeList is EqualUnmodifiableListView) return _likeList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_likeList);
}


/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentCopyWith<_Comment> get copyWith => __$CommentCopyWithImpl<_Comment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Comment&&(identical(other.authorInfo, authorInfo) || other.authorInfo == authorInfo)&&(identical(other.blockHeight, blockHeight) || other.blockHeight == blockHeight)&&(identical(other.date, date) || other.date == date)&&(identical(other.commentBody, commentBody) || other.commentBody == commentBody)&&const DeepCollectionEquality().equals(other._likeList, _likeList));
}


@override
int get hashCode => Object.hash(runtimeType,authorInfo,blockHeight,date,commentBody,const DeepCollectionEquality().hash(_likeList));

@override
String toString() {
  return 'Comment(authorInfo: $authorInfo, blockHeight: $blockHeight, date: $date, commentBody: $commentBody, likeList: $likeList)';
}


}

/// @nodoc
abstract mixin class _$CommentCopyWith<$Res> implements $CommentCopyWith<$Res> {
  factory _$CommentCopyWith(_Comment value, $Res Function(_Comment) _then) = __$CommentCopyWithImpl;
@override @useResult
$Res call({
 GeneralAccountInfo authorInfo, int blockHeight, DateTime date, CommentBody commentBody, List<Like> likeList
});


@override $GeneralAccountInfoCopyWith<$Res> get authorInfo;@override $CommentBodyCopyWith<$Res> get commentBody;

}
/// @nodoc
class __$CommentCopyWithImpl<$Res>
    implements _$CommentCopyWith<$Res> {
  __$CommentCopyWithImpl(this._self, this._then);

  final _Comment _self;
  final $Res Function(_Comment) _then;

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? authorInfo = null,Object? blockHeight = null,Object? date = null,Object? commentBody = null,Object? likeList = null,}) {
  return _then(_Comment(
authorInfo: null == authorInfo ? _self.authorInfo : authorInfo // ignore: cast_nullable_to_non_nullable
as GeneralAccountInfo,blockHeight: null == blockHeight ? _self.blockHeight : blockHeight // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,commentBody: null == commentBody ? _self.commentBody : commentBody // ignore: cast_nullable_to_non_nullable
as CommentBody,likeList: null == likeList ? _self._likeList : likeList // ignore: cast_nullable_to_non_nullable
as List<Like>,
  ));
}

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeneralAccountInfoCopyWith<$Res> get authorInfo {
  
  return $GeneralAccountInfoCopyWith<$Res>(_self.authorInfo, (value) {
    return _then(_self.copyWith(authorInfo: value));
  });
}/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentBodyCopyWith<$Res> get commentBody {
  
  return $CommentBodyCopyWith<$Res>(_self.commentBody, (value) {
    return _then(_self.copyWith(commentBody: value));
  });
}
}

/// @nodoc
mixin _$CommentCreationInfo {

 String get accountId; int get blockHeight;
/// Create a copy of CommentCreationInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentCreationInfoCopyWith<CommentCreationInfo> get copyWith => _$CommentCreationInfoCopyWithImpl<CommentCreationInfo>(this as CommentCreationInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentCreationInfo&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.blockHeight, blockHeight) || other.blockHeight == blockHeight));
}


@override
int get hashCode => Object.hash(runtimeType,accountId,blockHeight);

@override
String toString() {
  return 'CommentCreationInfo(accountId: $accountId, blockHeight: $blockHeight)';
}


}

/// @nodoc
abstract mixin class $CommentCreationInfoCopyWith<$Res>  {
  factory $CommentCreationInfoCopyWith(CommentCreationInfo value, $Res Function(CommentCreationInfo) _then) = _$CommentCreationInfoCopyWithImpl;
@useResult
$Res call({
 String accountId, int blockHeight
});




}
/// @nodoc
class _$CommentCreationInfoCopyWithImpl<$Res>
    implements $CommentCreationInfoCopyWith<$Res> {
  _$CommentCreationInfoCopyWithImpl(this._self, this._then);

  final CommentCreationInfo _self;
  final $Res Function(CommentCreationInfo) _then;

/// Create a copy of CommentCreationInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accountId = null,Object? blockHeight = null,}) {
  return _then(_self.copyWith(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,blockHeight: null == blockHeight ? _self.blockHeight : blockHeight // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CommentCreationInfo].
extension CommentCreationInfoPatterns on CommentCreationInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentCreationInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentCreationInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentCreationInfo value)  $default,){
final _that = this;
switch (_that) {
case _CommentCreationInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentCreationInfo value)?  $default,){
final _that = this;
switch (_that) {
case _CommentCreationInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accountId,  int blockHeight)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentCreationInfo() when $default != null:
return $default(_that.accountId,_that.blockHeight);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accountId,  int blockHeight)  $default,) {final _that = this;
switch (_that) {
case _CommentCreationInfo():
return $default(_that.accountId,_that.blockHeight);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accountId,  int blockHeight)?  $default,) {final _that = this;
switch (_that) {
case _CommentCreationInfo() when $default != null:
return $default(_that.accountId,_that.blockHeight);case _:
  return null;

}
}

}

/// @nodoc


class _CommentCreationInfo implements CommentCreationInfo {
  const _CommentCreationInfo({required this.accountId, required this.blockHeight});
  

@override final  String accountId;
@override final  int blockHeight;

/// Create a copy of CommentCreationInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentCreationInfoCopyWith<_CommentCreationInfo> get copyWith => __$CommentCreationInfoCopyWithImpl<_CommentCreationInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentCreationInfo&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.blockHeight, blockHeight) || other.blockHeight == blockHeight));
}


@override
int get hashCode => Object.hash(runtimeType,accountId,blockHeight);

@override
String toString() {
  return 'CommentCreationInfo(accountId: $accountId, blockHeight: $blockHeight)';
}


}

/// @nodoc
abstract mixin class _$CommentCreationInfoCopyWith<$Res> implements $CommentCreationInfoCopyWith<$Res> {
  factory _$CommentCreationInfoCopyWith(_CommentCreationInfo value, $Res Function(_CommentCreationInfo) _then) = __$CommentCreationInfoCopyWithImpl;
@override @useResult
$Res call({
 String accountId, int blockHeight
});




}
/// @nodoc
class __$CommentCreationInfoCopyWithImpl<$Res>
    implements _$CommentCreationInfoCopyWith<$Res> {
  __$CommentCreationInfoCopyWithImpl(this._self, this._then);

  final _CommentCreationInfo _self;
  final $Res Function(_CommentCreationInfo) _then;

/// Create a copy of CommentCreationInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accountId = null,Object? blockHeight = null,}) {
  return _then(_CommentCreationInfo(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,blockHeight: null == blockHeight ? _self.blockHeight : blockHeight // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$CommentBody {

 String get text; String? get mediaLink;
/// Create a copy of CommentBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentBodyCopyWith<CommentBody> get copyWith => _$CommentBodyCopyWithImpl<CommentBody>(this as CommentBody, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentBody&&(identical(other.text, text) || other.text == text)&&(identical(other.mediaLink, mediaLink) || other.mediaLink == mediaLink));
}


@override
int get hashCode => Object.hash(runtimeType,text,mediaLink);

@override
String toString() {
  return 'CommentBody(text: $text, mediaLink: $mediaLink)';
}


}

/// @nodoc
abstract mixin class $CommentBodyCopyWith<$Res>  {
  factory $CommentBodyCopyWith(CommentBody value, $Res Function(CommentBody) _then) = _$CommentBodyCopyWithImpl;
@useResult
$Res call({
 String text, String? mediaLink
});




}
/// @nodoc
class _$CommentBodyCopyWithImpl<$Res>
    implements $CommentBodyCopyWith<$Res> {
  _$CommentBodyCopyWithImpl(this._self, this._then);

  final CommentBody _self;
  final $Res Function(CommentBody) _then;

/// Create a copy of CommentBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? mediaLink = freezed,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,mediaLink: freezed == mediaLink ? _self.mediaLink : mediaLink // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CommentBody].
extension CommentBodyPatterns on CommentBody {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentBody value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentBody() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentBody value)  $default,){
final _that = this;
switch (_that) {
case _CommentBody():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentBody value)?  $default,){
final _that = this;
switch (_that) {
case _CommentBody() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  String? mediaLink)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentBody() when $default != null:
return $default(_that.text,_that.mediaLink);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  String? mediaLink)  $default,) {final _that = this;
switch (_that) {
case _CommentBody():
return $default(_that.text,_that.mediaLink);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  String? mediaLink)?  $default,) {final _that = this;
switch (_that) {
case _CommentBody() when $default != null:
return $default(_that.text,_that.mediaLink);case _:
  return null;

}
}

}

/// @nodoc


class _CommentBody implements CommentBody {
  const _CommentBody({required this.text, required this.mediaLink});
  

@override final  String text;
@override final  String? mediaLink;

/// Create a copy of CommentBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentBodyCopyWith<_CommentBody> get copyWith => __$CommentBodyCopyWithImpl<_CommentBody>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentBody&&(identical(other.text, text) || other.text == text)&&(identical(other.mediaLink, mediaLink) || other.mediaLink == mediaLink));
}


@override
int get hashCode => Object.hash(runtimeType,text,mediaLink);

@override
String toString() {
  return 'CommentBody(text: $text, mediaLink: $mediaLink)';
}


}

/// @nodoc
abstract mixin class _$CommentBodyCopyWith<$Res> implements $CommentBodyCopyWith<$Res> {
  factory _$CommentBodyCopyWith(_CommentBody value, $Res Function(_CommentBody) _then) = __$CommentBodyCopyWithImpl;
@override @useResult
$Res call({
 String text, String? mediaLink
});




}
/// @nodoc
class __$CommentBodyCopyWithImpl<$Res>
    implements _$CommentBodyCopyWith<$Res> {
  __$CommentBodyCopyWithImpl(this._self, this._then);

  final _CommentBody _self;
  final $Res Function(_CommentBody) _then;

/// Create a copy of CommentBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? mediaLink = freezed,}) {
  return _then(_CommentBody(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,mediaLink: freezed == mediaLink ? _self.mediaLink : mediaLink // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
