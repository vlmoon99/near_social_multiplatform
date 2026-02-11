// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pending_operation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PendingOperation {

 String get id; OperationType get type; OperationStatus get status; Map<String, dynamic> get payload; DateTime get createdAt; DateTime? get lastAttemptAt; int get attemptCount; String? get errorMessage; int get maxRetries;
/// Create a copy of PendingOperation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingOperationCopyWith<PendingOperation> get copyWith => _$PendingOperationCopyWithImpl<PendingOperation>(this as PendingOperation, _$identity);

  /// Serializes this PendingOperation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingOperation&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.payload, payload)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastAttemptAt, lastAttemptAt) || other.lastAttemptAt == lastAttemptAt)&&(identical(other.attemptCount, attemptCount) || other.attemptCount == attemptCount)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.maxRetries, maxRetries) || other.maxRetries == maxRetries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,status,const DeepCollectionEquality().hash(payload),createdAt,lastAttemptAt,attemptCount,errorMessage,maxRetries);

@override
String toString() {
  return 'PendingOperation(id: $id, type: $type, status: $status, payload: $payload, createdAt: $createdAt, lastAttemptAt: $lastAttemptAt, attemptCount: $attemptCount, errorMessage: $errorMessage, maxRetries: $maxRetries)';
}


}

/// @nodoc
abstract mixin class $PendingOperationCopyWith<$Res>  {
  factory $PendingOperationCopyWith(PendingOperation value, $Res Function(PendingOperation) _then) = _$PendingOperationCopyWithImpl;
@useResult
$Res call({
 String id, OperationType type, OperationStatus status, Map<String, dynamic> payload, DateTime createdAt, DateTime? lastAttemptAt, int attemptCount, String? errorMessage, int maxRetries
});




}
/// @nodoc
class _$PendingOperationCopyWithImpl<$Res>
    implements $PendingOperationCopyWith<$Res> {
  _$PendingOperationCopyWithImpl(this._self, this._then);

  final PendingOperation _self;
  final $Res Function(PendingOperation) _then;

/// Create a copy of PendingOperation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? status = null,Object? payload = null,Object? createdAt = null,Object? lastAttemptAt = freezed,Object? attemptCount = null,Object? errorMessage = freezed,Object? maxRetries = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OperationType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OperationStatus,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastAttemptAt: freezed == lastAttemptAt ? _self.lastAttemptAt : lastAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime?,attemptCount: null == attemptCount ? _self.attemptCount : attemptCount // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,maxRetries: null == maxRetries ? _self.maxRetries : maxRetries // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingOperation].
extension PendingOperationPatterns on PendingOperation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingOperation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingOperation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingOperation value)  $default,){
final _that = this;
switch (_that) {
case _PendingOperation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingOperation value)?  $default,){
final _that = this;
switch (_that) {
case _PendingOperation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  OperationType type,  OperationStatus status,  Map<String, dynamic> payload,  DateTime createdAt,  DateTime? lastAttemptAt,  int attemptCount,  String? errorMessage,  int maxRetries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingOperation() when $default != null:
return $default(_that.id,_that.type,_that.status,_that.payload,_that.createdAt,_that.lastAttemptAt,_that.attemptCount,_that.errorMessage,_that.maxRetries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  OperationType type,  OperationStatus status,  Map<String, dynamic> payload,  DateTime createdAt,  DateTime? lastAttemptAt,  int attemptCount,  String? errorMessage,  int maxRetries)  $default,) {final _that = this;
switch (_that) {
case _PendingOperation():
return $default(_that.id,_that.type,_that.status,_that.payload,_that.createdAt,_that.lastAttemptAt,_that.attemptCount,_that.errorMessage,_that.maxRetries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  OperationType type,  OperationStatus status,  Map<String, dynamic> payload,  DateTime createdAt,  DateTime? lastAttemptAt,  int attemptCount,  String? errorMessage,  int maxRetries)?  $default,) {final _that = this;
switch (_that) {
case _PendingOperation() when $default != null:
return $default(_that.id,_that.type,_that.status,_that.payload,_that.createdAt,_that.lastAttemptAt,_that.attemptCount,_that.errorMessage,_that.maxRetries);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingOperation extends PendingOperation {
  const _PendingOperation({required this.id, required this.type, this.status = OperationStatus.pending, required final  Map<String, dynamic> payload, required this.createdAt, this.lastAttemptAt, this.attemptCount = 0, this.errorMessage, this.maxRetries = 3}): _payload = payload,super._();
  factory _PendingOperation.fromJson(Map<String, dynamic> json) => _$PendingOperationFromJson(json);

@override final  String id;
@override final  OperationType type;
@override@JsonKey() final  OperationStatus status;
 final  Map<String, dynamic> _payload;
@override Map<String, dynamic> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}

@override final  DateTime createdAt;
@override final  DateTime? lastAttemptAt;
@override@JsonKey() final  int attemptCount;
@override final  String? errorMessage;
@override@JsonKey() final  int maxRetries;

/// Create a copy of PendingOperation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingOperationCopyWith<_PendingOperation> get copyWith => __$PendingOperationCopyWithImpl<_PendingOperation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingOperationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingOperation&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._payload, _payload)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastAttemptAt, lastAttemptAt) || other.lastAttemptAt == lastAttemptAt)&&(identical(other.attemptCount, attemptCount) || other.attemptCount == attemptCount)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.maxRetries, maxRetries) || other.maxRetries == maxRetries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,status,const DeepCollectionEquality().hash(_payload),createdAt,lastAttemptAt,attemptCount,errorMessage,maxRetries);

@override
String toString() {
  return 'PendingOperation(id: $id, type: $type, status: $status, payload: $payload, createdAt: $createdAt, lastAttemptAt: $lastAttemptAt, attemptCount: $attemptCount, errorMessage: $errorMessage, maxRetries: $maxRetries)';
}


}

/// @nodoc
abstract mixin class _$PendingOperationCopyWith<$Res> implements $PendingOperationCopyWith<$Res> {
  factory _$PendingOperationCopyWith(_PendingOperation value, $Res Function(_PendingOperation) _then) = __$PendingOperationCopyWithImpl;
@override @useResult
$Res call({
 String id, OperationType type, OperationStatus status, Map<String, dynamic> payload, DateTime createdAt, DateTime? lastAttemptAt, int attemptCount, String? errorMessage, int maxRetries
});




}
/// @nodoc
class __$PendingOperationCopyWithImpl<$Res>
    implements _$PendingOperationCopyWith<$Res> {
  __$PendingOperationCopyWithImpl(this._self, this._then);

  final _PendingOperation _self;
  final $Res Function(_PendingOperation) _then;

/// Create a copy of PendingOperation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? status = null,Object? payload = null,Object? createdAt = null,Object? lastAttemptAt = freezed,Object? attemptCount = null,Object? errorMessage = freezed,Object? maxRetries = null,}) {
  return _then(_PendingOperation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OperationType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OperationStatus,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastAttemptAt: freezed == lastAttemptAt ? _self.lastAttemptAt : lastAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime?,attemptCount: null == attemptCount ? _self.attemptCount : attemptCount // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,maxRetries: null == maxRetries ? _self.maxRetries : maxRetries // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
