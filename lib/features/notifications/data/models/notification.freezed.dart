// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Notification {

 GeneralAccountInfo get authorInfo; int get blockHeight; DateTime get date; NotificationType get notificationType;
/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationCopyWith<Notification> get copyWith => _$NotificationCopyWithImpl<Notification>(this as Notification, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Notification&&(identical(other.authorInfo, authorInfo) || other.authorInfo == authorInfo)&&(identical(other.blockHeight, blockHeight) || other.blockHeight == blockHeight)&&(identical(other.date, date) || other.date == date)&&(identical(other.notificationType, notificationType) || other.notificationType == notificationType));
}


@override
int get hashCode => Object.hash(runtimeType,authorInfo,blockHeight,date,notificationType);

@override
String toString() {
  return 'Notification(authorInfo: $authorInfo, blockHeight: $blockHeight, date: $date, notificationType: $notificationType)';
}


}

/// @nodoc
abstract mixin class $NotificationCopyWith<$Res>  {
  factory $NotificationCopyWith(Notification value, $Res Function(Notification) _then) = _$NotificationCopyWithImpl;
@useResult
$Res call({
 GeneralAccountInfo authorInfo, int blockHeight, DateTime date, NotificationType notificationType
});


$GeneralAccountInfoCopyWith<$Res> get authorInfo;$NotificationTypeCopyWith<$Res> get notificationType;

}
/// @nodoc
class _$NotificationCopyWithImpl<$Res>
    implements $NotificationCopyWith<$Res> {
  _$NotificationCopyWithImpl(this._self, this._then);

  final Notification _self;
  final $Res Function(Notification) _then;

/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? authorInfo = null,Object? blockHeight = null,Object? date = null,Object? notificationType = null,}) {
  return _then(_self.copyWith(
authorInfo: null == authorInfo ? _self.authorInfo : authorInfo // ignore: cast_nullable_to_non_nullable
as GeneralAccountInfo,blockHeight: null == blockHeight ? _self.blockHeight : blockHeight // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,notificationType: null == notificationType ? _self.notificationType : notificationType // ignore: cast_nullable_to_non_nullable
as NotificationType,
  ));
}
/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeneralAccountInfoCopyWith<$Res> get authorInfo {
  
  return $GeneralAccountInfoCopyWith<$Res>(_self.authorInfo, (value) {
    return _then(_self.copyWith(authorInfo: value));
  });
}/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationTypeCopyWith<$Res> get notificationType {
  
  return $NotificationTypeCopyWith<$Res>(_self.notificationType, (value) {
    return _then(_self.copyWith(notificationType: value));
  });
}
}


/// Adds pattern-matching-related methods to [Notification].
extension NotificationPatterns on Notification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Notification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Notification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Notification value)  $default,){
final _that = this;
switch (_that) {
case _Notification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Notification value)?  $default,){
final _that = this;
switch (_that) {
case _Notification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GeneralAccountInfo authorInfo,  int blockHeight,  DateTime date,  NotificationType notificationType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Notification() when $default != null:
return $default(_that.authorInfo,_that.blockHeight,_that.date,_that.notificationType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GeneralAccountInfo authorInfo,  int blockHeight,  DateTime date,  NotificationType notificationType)  $default,) {final _that = this;
switch (_that) {
case _Notification():
return $default(_that.authorInfo,_that.blockHeight,_that.date,_that.notificationType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GeneralAccountInfo authorInfo,  int blockHeight,  DateTime date,  NotificationType notificationType)?  $default,) {final _that = this;
switch (_that) {
case _Notification() when $default != null:
return $default(_that.authorInfo,_that.blockHeight,_that.date,_that.notificationType);case _:
  return null;

}
}

}

/// @nodoc


class _Notification implements Notification {
  const _Notification({required this.authorInfo, required this.blockHeight, required this.date, required this.notificationType});
  

@override final  GeneralAccountInfo authorInfo;
@override final  int blockHeight;
@override final  DateTime date;
@override final  NotificationType notificationType;

/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationCopyWith<_Notification> get copyWith => __$NotificationCopyWithImpl<_Notification>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Notification&&(identical(other.authorInfo, authorInfo) || other.authorInfo == authorInfo)&&(identical(other.blockHeight, blockHeight) || other.blockHeight == blockHeight)&&(identical(other.date, date) || other.date == date)&&(identical(other.notificationType, notificationType) || other.notificationType == notificationType));
}


@override
int get hashCode => Object.hash(runtimeType,authorInfo,blockHeight,date,notificationType);

@override
String toString() {
  return 'Notification(authorInfo: $authorInfo, blockHeight: $blockHeight, date: $date, notificationType: $notificationType)';
}


}

/// @nodoc
abstract mixin class _$NotificationCopyWith<$Res> implements $NotificationCopyWith<$Res> {
  factory _$NotificationCopyWith(_Notification value, $Res Function(_Notification) _then) = __$NotificationCopyWithImpl;
@override @useResult
$Res call({
 GeneralAccountInfo authorInfo, int blockHeight, DateTime date, NotificationType notificationType
});


@override $GeneralAccountInfoCopyWith<$Res> get authorInfo;@override $NotificationTypeCopyWith<$Res> get notificationType;

}
/// @nodoc
class __$NotificationCopyWithImpl<$Res>
    implements _$NotificationCopyWith<$Res> {
  __$NotificationCopyWithImpl(this._self, this._then);

  final _Notification _self;
  final $Res Function(_Notification) _then;

/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? authorInfo = null,Object? blockHeight = null,Object? date = null,Object? notificationType = null,}) {
  return _then(_Notification(
authorInfo: null == authorInfo ? _self.authorInfo : authorInfo // ignore: cast_nullable_to_non_nullable
as GeneralAccountInfo,blockHeight: null == blockHeight ? _self.blockHeight : blockHeight // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,notificationType: null == notificationType ? _self.notificationType : notificationType // ignore: cast_nullable_to_non_nullable
as NotificationType,
  ));
}

/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeneralAccountInfoCopyWith<$Res> get authorInfo {
  
  return $GeneralAccountInfoCopyWith<$Res>(_self.authorInfo, (value) {
    return _then(_self.copyWith(authorInfo: value));
  });
}/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationTypeCopyWith<$Res> get notificationType {
  
  return $NotificationTypeCopyWith<$Res>(_self.notificationType, (value) {
    return _then(_self.copyWith(notificationType: value));
  });
}
}

/// @nodoc
mixin _$NotificationType {

 NotificationTypes get type; Map<String, dynamic> get data;
/// Create a copy of NotificationType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationTypeCopyWith<NotificationType> get copyWith => _$NotificationTypeCopyWithImpl<NotificationType>(this as NotificationType, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationType&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'NotificationType(type: $type, data: $data)';
}


}

/// @nodoc
abstract mixin class $NotificationTypeCopyWith<$Res>  {
  factory $NotificationTypeCopyWith(NotificationType value, $Res Function(NotificationType) _then) = _$NotificationTypeCopyWithImpl;
@useResult
$Res call({
 NotificationTypes type, Map<String, dynamic> data
});




}
/// @nodoc
class _$NotificationTypeCopyWithImpl<$Res>
    implements $NotificationTypeCopyWith<$Res> {
  _$NotificationTypeCopyWithImpl(this._self, this._then);

  final NotificationType _self;
  final $Res Function(NotificationType) _then;

/// Create a copy of NotificationType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? data = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationTypes,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationType].
extension NotificationTypePatterns on NotificationType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationType value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationType() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationType value)  $default,){
final _that = this;
switch (_that) {
case _NotificationType():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationType value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationType() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NotificationTypes type,  Map<String, dynamic> data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationType() when $default != null:
return $default(_that.type,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NotificationTypes type,  Map<String, dynamic> data)  $default,) {final _that = this;
switch (_that) {
case _NotificationType():
return $default(_that.type,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NotificationTypes type,  Map<String, dynamic> data)?  $default,) {final _that = this;
switch (_that) {
case _NotificationType() when $default != null:
return $default(_that.type,_that.data);case _:
  return null;

}
}

}

/// @nodoc


class _NotificationType implements NotificationType {
  const _NotificationType({required this.type, required final  Map<String, dynamic> data}): _data = data;
  

@override final  NotificationTypes type;
 final  Map<String, dynamic> _data;
@override Map<String, dynamic> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}


/// Create a copy of NotificationType
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationTypeCopyWith<_NotificationType> get copyWith => __$NotificationTypeCopyWithImpl<_NotificationType>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationType&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._data, _data));
}


@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'NotificationType(type: $type, data: $data)';
}


}

/// @nodoc
abstract mixin class _$NotificationTypeCopyWith<$Res> implements $NotificationTypeCopyWith<$Res> {
  factory _$NotificationTypeCopyWith(_NotificationType value, $Res Function(_NotificationType) _then) = __$NotificationTypeCopyWithImpl;
@override @useResult
$Res call({
 NotificationTypes type, Map<String, dynamic> data
});




}
/// @nodoc
class __$NotificationTypeCopyWithImpl<$Res>
    implements _$NotificationTypeCopyWith<$Res> {
  __$NotificationTypeCopyWithImpl(this._self, this._then);

  final _NotificationType _self;
  final $Res Function(_NotificationType) _then;

/// Create a copy of NotificationType
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? data = null,}) {
  return _then(_NotificationType(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationTypes,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
