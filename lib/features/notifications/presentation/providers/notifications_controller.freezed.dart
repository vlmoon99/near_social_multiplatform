// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notifications_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Notifications {

 NotificationsLoadingState get status; List<Notification> get notifications;
/// Create a copy of Notifications
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationsCopyWith<Notifications> get copyWith => _$NotificationsCopyWithImpl<Notifications>(this as Notifications, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Notifications&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.notifications, notifications));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(notifications));

@override
String toString() {
  return 'Notifications(status: $status, notifications: $notifications)';
}


}

/// @nodoc
abstract mixin class $NotificationsCopyWith<$Res>  {
  factory $NotificationsCopyWith(Notifications value, $Res Function(Notifications) _then) = _$NotificationsCopyWithImpl;
@useResult
$Res call({
 NotificationsLoadingState status, List<Notification> notifications
});




}
/// @nodoc
class _$NotificationsCopyWithImpl<$Res>
    implements $NotificationsCopyWith<$Res> {
  _$NotificationsCopyWithImpl(this._self, this._then);

  final Notifications _self;
  final $Res Function(Notifications) _then;

/// Create a copy of Notifications
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? notifications = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NotificationsLoadingState,notifications: null == notifications ? _self.notifications : notifications // ignore: cast_nullable_to_non_nullable
as List<Notification>,
  ));
}

}


/// Adds pattern-matching-related methods to [Notifications].
extension NotificationsPatterns on Notifications {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Notifications value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Notifications() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Notifications value)  $default,){
final _that = this;
switch (_that) {
case _Notifications():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Notifications value)?  $default,){
final _that = this;
switch (_that) {
case _Notifications() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NotificationsLoadingState status,  List<Notification> notifications)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Notifications() when $default != null:
return $default(_that.status,_that.notifications);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NotificationsLoadingState status,  List<Notification> notifications)  $default,) {final _that = this;
switch (_that) {
case _Notifications():
return $default(_that.status,_that.notifications);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NotificationsLoadingState status,  List<Notification> notifications)?  $default,) {final _that = this;
switch (_that) {
case _Notifications() when $default != null:
return $default(_that.status,_that.notifications);case _:
  return null;

}
}

}

/// @nodoc


class _Notifications implements Notifications {
  const _Notifications({this.status = NotificationsLoadingState.initial, final  List<Notification> notifications = const []}): _notifications = notifications;
  

@override@JsonKey() final  NotificationsLoadingState status;
 final  List<Notification> _notifications;
@override@JsonKey() List<Notification> get notifications {
  if (_notifications is EqualUnmodifiableListView) return _notifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notifications);
}


/// Create a copy of Notifications
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationsCopyWith<_Notifications> get copyWith => __$NotificationsCopyWithImpl<_Notifications>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Notifications&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._notifications, _notifications));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_notifications));

@override
String toString() {
  return 'Notifications(status: $status, notifications: $notifications)';
}


}

/// @nodoc
abstract mixin class _$NotificationsCopyWith<$Res> implements $NotificationsCopyWith<$Res> {
  factory _$NotificationsCopyWith(_Notifications value, $Res Function(_Notifications) _then) = __$NotificationsCopyWithImpl;
@override @useResult
$Res call({
 NotificationsLoadingState status, List<Notification> notifications
});




}
/// @nodoc
class __$NotificationsCopyWithImpl<$Res>
    implements _$NotificationsCopyWith<$Res> {
  __$NotificationsCopyWithImpl(this._self, this._then);

  final _Notifications _self;
  final $Res Function(_Notifications) _then;

/// Create a copy of Notifications
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? notifications = null,}) {
  return _then(_Notifications(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NotificationsLoadingState,notifications: null == notifications ? _self._notifications : notifications // ignore: cast_nullable_to_non_nullable
as List<Notification>,
  ));
}


}

// dart format on
