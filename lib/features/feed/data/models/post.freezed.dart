// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Post {

 GeneralAccountInfo get authorInfo; int get blockHeight; DateTime get date; PostBody get postBody; ReposterInfo? get reposterInfo; List<Like> get likeList; List<Reposter> get repostList; List<Comment>? get commentList; bool get fullyLoaded;
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCopyWith<Post> get copyWith => _$PostCopyWithImpl<Post>(this as Post, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Post&&(identical(other.authorInfo, authorInfo) || other.authorInfo == authorInfo)&&(identical(other.blockHeight, blockHeight) || other.blockHeight == blockHeight)&&(identical(other.date, date) || other.date == date)&&(identical(other.postBody, postBody) || other.postBody == postBody)&&(identical(other.reposterInfo, reposterInfo) || other.reposterInfo == reposterInfo)&&const DeepCollectionEquality().equals(other.likeList, likeList)&&const DeepCollectionEquality().equals(other.repostList, repostList)&&const DeepCollectionEquality().equals(other.commentList, commentList)&&(identical(other.fullyLoaded, fullyLoaded) || other.fullyLoaded == fullyLoaded));
}


@override
int get hashCode => Object.hash(runtimeType,authorInfo,blockHeight,date,postBody,reposterInfo,const DeepCollectionEquality().hash(likeList),const DeepCollectionEquality().hash(repostList),const DeepCollectionEquality().hash(commentList),fullyLoaded);

@override
String toString() {
  return 'Post(authorInfo: $authorInfo, blockHeight: $blockHeight, date: $date, postBody: $postBody, reposterInfo: $reposterInfo, likeList: $likeList, repostList: $repostList, commentList: $commentList, fullyLoaded: $fullyLoaded)';
}


}

/// @nodoc
abstract mixin class $PostCopyWith<$Res>  {
  factory $PostCopyWith(Post value, $Res Function(Post) _then) = _$PostCopyWithImpl;
@useResult
$Res call({
 GeneralAccountInfo authorInfo, int blockHeight, DateTime date, PostBody postBody, ReposterInfo? reposterInfo, List<Like> likeList, List<Reposter> repostList, List<Comment>? commentList, bool fullyLoaded
});


$GeneralAccountInfoCopyWith<$Res> get authorInfo;$PostBodyCopyWith<$Res> get postBody;$ReposterInfoCopyWith<$Res>? get reposterInfo;

}
/// @nodoc
class _$PostCopyWithImpl<$Res>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._self, this._then);

  final Post _self;
  final $Res Function(Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? authorInfo = null,Object? blockHeight = null,Object? date = null,Object? postBody = null,Object? reposterInfo = freezed,Object? likeList = null,Object? repostList = null,Object? commentList = freezed,Object? fullyLoaded = null,}) {
  return _then(_self.copyWith(
authorInfo: null == authorInfo ? _self.authorInfo : authorInfo // ignore: cast_nullable_to_non_nullable
as GeneralAccountInfo,blockHeight: null == blockHeight ? _self.blockHeight : blockHeight // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,postBody: null == postBody ? _self.postBody : postBody // ignore: cast_nullable_to_non_nullable
as PostBody,reposterInfo: freezed == reposterInfo ? _self.reposterInfo : reposterInfo // ignore: cast_nullable_to_non_nullable
as ReposterInfo?,likeList: null == likeList ? _self.likeList : likeList // ignore: cast_nullable_to_non_nullable
as List<Like>,repostList: null == repostList ? _self.repostList : repostList // ignore: cast_nullable_to_non_nullable
as List<Reposter>,commentList: freezed == commentList ? _self.commentList : commentList // ignore: cast_nullable_to_non_nullable
as List<Comment>?,fullyLoaded: null == fullyLoaded ? _self.fullyLoaded : fullyLoaded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeneralAccountInfoCopyWith<$Res> get authorInfo {
  
  return $GeneralAccountInfoCopyWith<$Res>(_self.authorInfo, (value) {
    return _then(_self.copyWith(authorInfo: value));
  });
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostBodyCopyWith<$Res> get postBody {
  
  return $PostBodyCopyWith<$Res>(_self.postBody, (value) {
    return _then(_self.copyWith(postBody: value));
  });
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReposterInfoCopyWith<$Res>? get reposterInfo {
    if (_self.reposterInfo == null) {
    return null;
  }

  return $ReposterInfoCopyWith<$Res>(_self.reposterInfo!, (value) {
    return _then(_self.copyWith(reposterInfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [Post].
extension PostPatterns on Post {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Post value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Post() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Post value)  $default,){
final _that = this;
switch (_that) {
case _Post():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Post value)?  $default,){
final _that = this;
switch (_that) {
case _Post() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GeneralAccountInfo authorInfo,  int blockHeight,  DateTime date,  PostBody postBody,  ReposterInfo? reposterInfo,  List<Like> likeList,  List<Reposter> repostList,  List<Comment>? commentList,  bool fullyLoaded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.authorInfo,_that.blockHeight,_that.date,_that.postBody,_that.reposterInfo,_that.likeList,_that.repostList,_that.commentList,_that.fullyLoaded);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GeneralAccountInfo authorInfo,  int blockHeight,  DateTime date,  PostBody postBody,  ReposterInfo? reposterInfo,  List<Like> likeList,  List<Reposter> repostList,  List<Comment>? commentList,  bool fullyLoaded)  $default,) {final _that = this;
switch (_that) {
case _Post():
return $default(_that.authorInfo,_that.blockHeight,_that.date,_that.postBody,_that.reposterInfo,_that.likeList,_that.repostList,_that.commentList,_that.fullyLoaded);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GeneralAccountInfo authorInfo,  int blockHeight,  DateTime date,  PostBody postBody,  ReposterInfo? reposterInfo,  List<Like> likeList,  List<Reposter> repostList,  List<Comment>? commentList,  bool fullyLoaded)?  $default,) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.authorInfo,_that.blockHeight,_that.date,_that.postBody,_that.reposterInfo,_that.likeList,_that.repostList,_that.commentList,_that.fullyLoaded);case _:
  return null;

}
}

}

/// @nodoc


class _Post implements Post {
  const _Post({required this.authorInfo, required this.blockHeight, required this.date, required this.postBody, this.reposterInfo, required final  List<Like> likeList, required final  List<Reposter> repostList, required final  List<Comment>? commentList, this.fullyLoaded = false}): _likeList = likeList,_repostList = repostList,_commentList = commentList;
  

@override final  GeneralAccountInfo authorInfo;
@override final  int blockHeight;
@override final  DateTime date;
@override final  PostBody postBody;
@override final  ReposterInfo? reposterInfo;
 final  List<Like> _likeList;
@override List<Like> get likeList {
  if (_likeList is EqualUnmodifiableListView) return _likeList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_likeList);
}

 final  List<Reposter> _repostList;
@override List<Reposter> get repostList {
  if (_repostList is EqualUnmodifiableListView) return _repostList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_repostList);
}

 final  List<Comment>? _commentList;
@override List<Comment>? get commentList {
  final value = _commentList;
  if (value == null) return null;
  if (_commentList is EqualUnmodifiableListView) return _commentList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  bool fullyLoaded;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostCopyWith<_Post> get copyWith => __$PostCopyWithImpl<_Post>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Post&&(identical(other.authorInfo, authorInfo) || other.authorInfo == authorInfo)&&(identical(other.blockHeight, blockHeight) || other.blockHeight == blockHeight)&&(identical(other.date, date) || other.date == date)&&(identical(other.postBody, postBody) || other.postBody == postBody)&&(identical(other.reposterInfo, reposterInfo) || other.reposterInfo == reposterInfo)&&const DeepCollectionEquality().equals(other._likeList, _likeList)&&const DeepCollectionEquality().equals(other._repostList, _repostList)&&const DeepCollectionEquality().equals(other._commentList, _commentList)&&(identical(other.fullyLoaded, fullyLoaded) || other.fullyLoaded == fullyLoaded));
}


@override
int get hashCode => Object.hash(runtimeType,authorInfo,blockHeight,date,postBody,reposterInfo,const DeepCollectionEquality().hash(_likeList),const DeepCollectionEquality().hash(_repostList),const DeepCollectionEquality().hash(_commentList),fullyLoaded);

@override
String toString() {
  return 'Post(authorInfo: $authorInfo, blockHeight: $blockHeight, date: $date, postBody: $postBody, reposterInfo: $reposterInfo, likeList: $likeList, repostList: $repostList, commentList: $commentList, fullyLoaded: $fullyLoaded)';
}


}

/// @nodoc
abstract mixin class _$PostCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$PostCopyWith(_Post value, $Res Function(_Post) _then) = __$PostCopyWithImpl;
@override @useResult
$Res call({
 GeneralAccountInfo authorInfo, int blockHeight, DateTime date, PostBody postBody, ReposterInfo? reposterInfo, List<Like> likeList, List<Reposter> repostList, List<Comment>? commentList, bool fullyLoaded
});


@override $GeneralAccountInfoCopyWith<$Res> get authorInfo;@override $PostBodyCopyWith<$Res> get postBody;@override $ReposterInfoCopyWith<$Res>? get reposterInfo;

}
/// @nodoc
class __$PostCopyWithImpl<$Res>
    implements _$PostCopyWith<$Res> {
  __$PostCopyWithImpl(this._self, this._then);

  final _Post _self;
  final $Res Function(_Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? authorInfo = null,Object? blockHeight = null,Object? date = null,Object? postBody = null,Object? reposterInfo = freezed,Object? likeList = null,Object? repostList = null,Object? commentList = freezed,Object? fullyLoaded = null,}) {
  return _then(_Post(
authorInfo: null == authorInfo ? _self.authorInfo : authorInfo // ignore: cast_nullable_to_non_nullable
as GeneralAccountInfo,blockHeight: null == blockHeight ? _self.blockHeight : blockHeight // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,postBody: null == postBody ? _self.postBody : postBody // ignore: cast_nullable_to_non_nullable
as PostBody,reposterInfo: freezed == reposterInfo ? _self.reposterInfo : reposterInfo // ignore: cast_nullable_to_non_nullable
as ReposterInfo?,likeList: null == likeList ? _self._likeList : likeList // ignore: cast_nullable_to_non_nullable
as List<Like>,repostList: null == repostList ? _self._repostList : repostList // ignore: cast_nullable_to_non_nullable
as List<Reposter>,commentList: freezed == commentList ? _self._commentList : commentList // ignore: cast_nullable_to_non_nullable
as List<Comment>?,fullyLoaded: null == fullyLoaded ? _self.fullyLoaded : fullyLoaded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeneralAccountInfoCopyWith<$Res> get authorInfo {
  
  return $GeneralAccountInfoCopyWith<$Res>(_self.authorInfo, (value) {
    return _then(_self.copyWith(authorInfo: value));
  });
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostBodyCopyWith<$Res> get postBody {
  
  return $PostBodyCopyWith<$Res>(_self.postBody, (value) {
    return _then(_self.copyWith(postBody: value));
  });
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReposterInfoCopyWith<$Res>? get reposterInfo {
    if (_self.reposterInfo == null) {
    return null;
  }

  return $ReposterInfoCopyWith<$Res>(_self.reposterInfo!, (value) {
    return _then(_self.copyWith(reposterInfo: value));
  });
}
}

/// @nodoc
mixin _$FullPostCreationInfo {

 PostCreationInfo get postCreationInfo; PostCreationInfo? get reposterPostCreationInfo;
/// Create a copy of FullPostCreationInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FullPostCreationInfoCopyWith<FullPostCreationInfo> get copyWith => _$FullPostCreationInfoCopyWithImpl<FullPostCreationInfo>(this as FullPostCreationInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FullPostCreationInfo&&(identical(other.postCreationInfo, postCreationInfo) || other.postCreationInfo == postCreationInfo)&&(identical(other.reposterPostCreationInfo, reposterPostCreationInfo) || other.reposterPostCreationInfo == reposterPostCreationInfo));
}


@override
int get hashCode => Object.hash(runtimeType,postCreationInfo,reposterPostCreationInfo);

@override
String toString() {
  return 'FullPostCreationInfo(postCreationInfo: $postCreationInfo, reposterPostCreationInfo: $reposterPostCreationInfo)';
}


}

/// @nodoc
abstract mixin class $FullPostCreationInfoCopyWith<$Res>  {
  factory $FullPostCreationInfoCopyWith(FullPostCreationInfo value, $Res Function(FullPostCreationInfo) _then) = _$FullPostCreationInfoCopyWithImpl;
@useResult
$Res call({
 PostCreationInfo postCreationInfo, PostCreationInfo? reposterPostCreationInfo
});


$PostCreationInfoCopyWith<$Res> get postCreationInfo;$PostCreationInfoCopyWith<$Res>? get reposterPostCreationInfo;

}
/// @nodoc
class _$FullPostCreationInfoCopyWithImpl<$Res>
    implements $FullPostCreationInfoCopyWith<$Res> {
  _$FullPostCreationInfoCopyWithImpl(this._self, this._then);

  final FullPostCreationInfo _self;
  final $Res Function(FullPostCreationInfo) _then;

/// Create a copy of FullPostCreationInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? postCreationInfo = null,Object? reposterPostCreationInfo = freezed,}) {
  return _then(_self.copyWith(
postCreationInfo: null == postCreationInfo ? _self.postCreationInfo : postCreationInfo // ignore: cast_nullable_to_non_nullable
as PostCreationInfo,reposterPostCreationInfo: freezed == reposterPostCreationInfo ? _self.reposterPostCreationInfo : reposterPostCreationInfo // ignore: cast_nullable_to_non_nullable
as PostCreationInfo?,
  ));
}
/// Create a copy of FullPostCreationInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCreationInfoCopyWith<$Res> get postCreationInfo {
  
  return $PostCreationInfoCopyWith<$Res>(_self.postCreationInfo, (value) {
    return _then(_self.copyWith(postCreationInfo: value));
  });
}/// Create a copy of FullPostCreationInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCreationInfoCopyWith<$Res>? get reposterPostCreationInfo {
    if (_self.reposterPostCreationInfo == null) {
    return null;
  }

  return $PostCreationInfoCopyWith<$Res>(_self.reposterPostCreationInfo!, (value) {
    return _then(_self.copyWith(reposterPostCreationInfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [FullPostCreationInfo].
extension FullPostCreationInfoPatterns on FullPostCreationInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FullPostCreationInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FullPostCreationInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FullPostCreationInfo value)  $default,){
final _that = this;
switch (_that) {
case _FullPostCreationInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FullPostCreationInfo value)?  $default,){
final _that = this;
switch (_that) {
case _FullPostCreationInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PostCreationInfo postCreationInfo,  PostCreationInfo? reposterPostCreationInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FullPostCreationInfo() when $default != null:
return $default(_that.postCreationInfo,_that.reposterPostCreationInfo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PostCreationInfo postCreationInfo,  PostCreationInfo? reposterPostCreationInfo)  $default,) {final _that = this;
switch (_that) {
case _FullPostCreationInfo():
return $default(_that.postCreationInfo,_that.reposterPostCreationInfo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PostCreationInfo postCreationInfo,  PostCreationInfo? reposterPostCreationInfo)?  $default,) {final _that = this;
switch (_that) {
case _FullPostCreationInfo() when $default != null:
return $default(_that.postCreationInfo,_that.reposterPostCreationInfo);case _:
  return null;

}
}

}

/// @nodoc


class _FullPostCreationInfo implements FullPostCreationInfo {
  const _FullPostCreationInfo({required this.postCreationInfo, this.reposterPostCreationInfo});
  

@override final  PostCreationInfo postCreationInfo;
@override final  PostCreationInfo? reposterPostCreationInfo;

/// Create a copy of FullPostCreationInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FullPostCreationInfoCopyWith<_FullPostCreationInfo> get copyWith => __$FullPostCreationInfoCopyWithImpl<_FullPostCreationInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FullPostCreationInfo&&(identical(other.postCreationInfo, postCreationInfo) || other.postCreationInfo == postCreationInfo)&&(identical(other.reposterPostCreationInfo, reposterPostCreationInfo) || other.reposterPostCreationInfo == reposterPostCreationInfo));
}


@override
int get hashCode => Object.hash(runtimeType,postCreationInfo,reposterPostCreationInfo);

@override
String toString() {
  return 'FullPostCreationInfo(postCreationInfo: $postCreationInfo, reposterPostCreationInfo: $reposterPostCreationInfo)';
}


}

/// @nodoc
abstract mixin class _$FullPostCreationInfoCopyWith<$Res> implements $FullPostCreationInfoCopyWith<$Res> {
  factory _$FullPostCreationInfoCopyWith(_FullPostCreationInfo value, $Res Function(_FullPostCreationInfo) _then) = __$FullPostCreationInfoCopyWithImpl;
@override @useResult
$Res call({
 PostCreationInfo postCreationInfo, PostCreationInfo? reposterPostCreationInfo
});


@override $PostCreationInfoCopyWith<$Res> get postCreationInfo;@override $PostCreationInfoCopyWith<$Res>? get reposterPostCreationInfo;

}
/// @nodoc
class __$FullPostCreationInfoCopyWithImpl<$Res>
    implements _$FullPostCreationInfoCopyWith<$Res> {
  __$FullPostCreationInfoCopyWithImpl(this._self, this._then);

  final _FullPostCreationInfo _self;
  final $Res Function(_FullPostCreationInfo) _then;

/// Create a copy of FullPostCreationInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? postCreationInfo = null,Object? reposterPostCreationInfo = freezed,}) {
  return _then(_FullPostCreationInfo(
postCreationInfo: null == postCreationInfo ? _self.postCreationInfo : postCreationInfo // ignore: cast_nullable_to_non_nullable
as PostCreationInfo,reposterPostCreationInfo: freezed == reposterPostCreationInfo ? _self.reposterPostCreationInfo : reposterPostCreationInfo // ignore: cast_nullable_to_non_nullable
as PostCreationInfo?,
  ));
}

/// Create a copy of FullPostCreationInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCreationInfoCopyWith<$Res> get postCreationInfo {
  
  return $PostCreationInfoCopyWith<$Res>(_self.postCreationInfo, (value) {
    return _then(_self.copyWith(postCreationInfo: value));
  });
}/// Create a copy of FullPostCreationInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCreationInfoCopyWith<$Res>? get reposterPostCreationInfo {
    if (_self.reposterPostCreationInfo == null) {
    return null;
  }

  return $PostCreationInfoCopyWith<$Res>(_self.reposterPostCreationInfo!, (value) {
    return _then(_self.copyWith(reposterPostCreationInfo: value));
  });
}
}

/// @nodoc
mixin _$PostCreationInfo {

 String get accountId; int get blockHeight;
/// Create a copy of PostCreationInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCreationInfoCopyWith<PostCreationInfo> get copyWith => _$PostCreationInfoCopyWithImpl<PostCreationInfo>(this as PostCreationInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostCreationInfo&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.blockHeight, blockHeight) || other.blockHeight == blockHeight));
}


@override
int get hashCode => Object.hash(runtimeType,accountId,blockHeight);

@override
String toString() {
  return 'PostCreationInfo(accountId: $accountId, blockHeight: $blockHeight)';
}


}

/// @nodoc
abstract mixin class $PostCreationInfoCopyWith<$Res>  {
  factory $PostCreationInfoCopyWith(PostCreationInfo value, $Res Function(PostCreationInfo) _then) = _$PostCreationInfoCopyWithImpl;
@useResult
$Res call({
 String accountId, int blockHeight
});




}
/// @nodoc
class _$PostCreationInfoCopyWithImpl<$Res>
    implements $PostCreationInfoCopyWith<$Res> {
  _$PostCreationInfoCopyWithImpl(this._self, this._then);

  final PostCreationInfo _self;
  final $Res Function(PostCreationInfo) _then;

/// Create a copy of PostCreationInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accountId = null,Object? blockHeight = null,}) {
  return _then(_self.copyWith(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,blockHeight: null == blockHeight ? _self.blockHeight : blockHeight // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PostCreationInfo].
extension PostCreationInfoPatterns on PostCreationInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostCreationInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostCreationInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostCreationInfo value)  $default,){
final _that = this;
switch (_that) {
case _PostCreationInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostCreationInfo value)?  $default,){
final _that = this;
switch (_that) {
case _PostCreationInfo() when $default != null:
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
case _PostCreationInfo() when $default != null:
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
case _PostCreationInfo():
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
case _PostCreationInfo() when $default != null:
return $default(_that.accountId,_that.blockHeight);case _:
  return null;

}
}

}

/// @nodoc


class _PostCreationInfo implements PostCreationInfo {
  const _PostCreationInfo({required this.accountId, required this.blockHeight});
  

@override final  String accountId;
@override final  int blockHeight;

/// Create a copy of PostCreationInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostCreationInfoCopyWith<_PostCreationInfo> get copyWith => __$PostCreationInfoCopyWithImpl<_PostCreationInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostCreationInfo&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.blockHeight, blockHeight) || other.blockHeight == blockHeight));
}


@override
int get hashCode => Object.hash(runtimeType,accountId,blockHeight);

@override
String toString() {
  return 'PostCreationInfo(accountId: $accountId, blockHeight: $blockHeight)';
}


}

/// @nodoc
abstract mixin class _$PostCreationInfoCopyWith<$Res> implements $PostCreationInfoCopyWith<$Res> {
  factory _$PostCreationInfoCopyWith(_PostCreationInfo value, $Res Function(_PostCreationInfo) _then) = __$PostCreationInfoCopyWithImpl;
@override @useResult
$Res call({
 String accountId, int blockHeight
});




}
/// @nodoc
class __$PostCreationInfoCopyWithImpl<$Res>
    implements _$PostCreationInfoCopyWith<$Res> {
  __$PostCreationInfoCopyWithImpl(this._self, this._then);

  final _PostCreationInfo _self;
  final $Res Function(_PostCreationInfo) _then;

/// Create a copy of PostCreationInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accountId = null,Object? blockHeight = null,}) {
  return _then(_PostCreationInfo(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,blockHeight: null == blockHeight ? _self.blockHeight : blockHeight // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$PostBody {

 String get text; String? get mediaLink;
/// Create a copy of PostBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostBodyCopyWith<PostBody> get copyWith => _$PostBodyCopyWithImpl<PostBody>(this as PostBody, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostBody&&(identical(other.text, text) || other.text == text)&&(identical(other.mediaLink, mediaLink) || other.mediaLink == mediaLink));
}


@override
int get hashCode => Object.hash(runtimeType,text,mediaLink);

@override
String toString() {
  return 'PostBody(text: $text, mediaLink: $mediaLink)';
}


}

/// @nodoc
abstract mixin class $PostBodyCopyWith<$Res>  {
  factory $PostBodyCopyWith(PostBody value, $Res Function(PostBody) _then) = _$PostBodyCopyWithImpl;
@useResult
$Res call({
 String text, String? mediaLink
});




}
/// @nodoc
class _$PostBodyCopyWithImpl<$Res>
    implements $PostBodyCopyWith<$Res> {
  _$PostBodyCopyWithImpl(this._self, this._then);

  final PostBody _self;
  final $Res Function(PostBody) _then;

/// Create a copy of PostBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? mediaLink = freezed,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,mediaLink: freezed == mediaLink ? _self.mediaLink : mediaLink // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PostBody].
extension PostBodyPatterns on PostBody {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostBody value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostBody() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostBody value)  $default,){
final _that = this;
switch (_that) {
case _PostBody():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostBody value)?  $default,){
final _that = this;
switch (_that) {
case _PostBody() when $default != null:
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
case _PostBody() when $default != null:
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
case _PostBody():
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
case _PostBody() when $default != null:
return $default(_that.text,_that.mediaLink);case _:
  return null;

}
}

}

/// @nodoc


class _PostBody implements PostBody {
  const _PostBody({required this.text, this.mediaLink});
  

@override final  String text;
@override final  String? mediaLink;

/// Create a copy of PostBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostBodyCopyWith<_PostBody> get copyWith => __$PostBodyCopyWithImpl<_PostBody>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostBody&&(identical(other.text, text) || other.text == text)&&(identical(other.mediaLink, mediaLink) || other.mediaLink == mediaLink));
}


@override
int get hashCode => Object.hash(runtimeType,text,mediaLink);

@override
String toString() {
  return 'PostBody(text: $text, mediaLink: $mediaLink)';
}


}

/// @nodoc
abstract mixin class _$PostBodyCopyWith<$Res> implements $PostBodyCopyWith<$Res> {
  factory _$PostBodyCopyWith(_PostBody value, $Res Function(_PostBody) _then) = __$PostBodyCopyWithImpl;
@override @useResult
$Res call({
 String text, String? mediaLink
});




}
/// @nodoc
class __$PostBodyCopyWithImpl<$Res>
    implements _$PostBodyCopyWith<$Res> {
  __$PostBodyCopyWithImpl(this._self, this._then);

  final _PostBody _self;
  final $Res Function(_PostBody) _then;

/// Create a copy of PostBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? mediaLink = freezed,}) {
  return _then(_PostBody(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,mediaLink: freezed == mediaLink ? _self.mediaLink : mediaLink // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
