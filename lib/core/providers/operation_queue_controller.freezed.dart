// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'operation_queue_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OperationQueueState {

 List<PendingOperation> get operations; bool get isProcessing; PendingOperation? get currentOperation;
/// Create a copy of OperationQueueState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OperationQueueStateCopyWith<OperationQueueState> get copyWith => _$OperationQueueStateCopyWithImpl<OperationQueueState>(this as OperationQueueState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OperationQueueState&&const DeepCollectionEquality().equals(other.operations, operations)&&(identical(other.isProcessing, isProcessing) || other.isProcessing == isProcessing)&&(identical(other.currentOperation, currentOperation) || other.currentOperation == currentOperation));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(operations),isProcessing,currentOperation);

@override
String toString() {
  return 'OperationQueueState(operations: $operations, isProcessing: $isProcessing, currentOperation: $currentOperation)';
}


}

/// @nodoc
abstract mixin class $OperationQueueStateCopyWith<$Res>  {
  factory $OperationQueueStateCopyWith(OperationQueueState value, $Res Function(OperationQueueState) _then) = _$OperationQueueStateCopyWithImpl;
@useResult
$Res call({
 List<PendingOperation> operations, bool isProcessing, PendingOperation? currentOperation
});


$PendingOperationCopyWith<$Res>? get currentOperation;

}
/// @nodoc
class _$OperationQueueStateCopyWithImpl<$Res>
    implements $OperationQueueStateCopyWith<$Res> {
  _$OperationQueueStateCopyWithImpl(this._self, this._then);

  final OperationQueueState _self;
  final $Res Function(OperationQueueState) _then;

/// Create a copy of OperationQueueState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? operations = null,Object? isProcessing = null,Object? currentOperation = freezed,}) {
  return _then(_self.copyWith(
operations: null == operations ? _self.operations : operations // ignore: cast_nullable_to_non_nullable
as List<PendingOperation>,isProcessing: null == isProcessing ? _self.isProcessing : isProcessing // ignore: cast_nullable_to_non_nullable
as bool,currentOperation: freezed == currentOperation ? _self.currentOperation : currentOperation // ignore: cast_nullable_to_non_nullable
as PendingOperation?,
  ));
}
/// Create a copy of OperationQueueState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PendingOperationCopyWith<$Res>? get currentOperation {
    if (_self.currentOperation == null) {
    return null;
  }

  return $PendingOperationCopyWith<$Res>(_self.currentOperation!, (value) {
    return _then(_self.copyWith(currentOperation: value));
  });
}
}


/// Adds pattern-matching-related methods to [OperationQueueState].
extension OperationQueueStatePatterns on OperationQueueState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OperationQueueState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OperationQueueState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OperationQueueState value)  $default,){
final _that = this;
switch (_that) {
case _OperationQueueState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OperationQueueState value)?  $default,){
final _that = this;
switch (_that) {
case _OperationQueueState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PendingOperation> operations,  bool isProcessing,  PendingOperation? currentOperation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OperationQueueState() when $default != null:
return $default(_that.operations,_that.isProcessing,_that.currentOperation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PendingOperation> operations,  bool isProcessing,  PendingOperation? currentOperation)  $default,) {final _that = this;
switch (_that) {
case _OperationQueueState():
return $default(_that.operations,_that.isProcessing,_that.currentOperation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PendingOperation> operations,  bool isProcessing,  PendingOperation? currentOperation)?  $default,) {final _that = this;
switch (_that) {
case _OperationQueueState() when $default != null:
return $default(_that.operations,_that.isProcessing,_that.currentOperation);case _:
  return null;

}
}

}

/// @nodoc


class _OperationQueueState extends OperationQueueState {
  const _OperationQueueState({final  List<PendingOperation> operations = const [], this.isProcessing = false, this.currentOperation}): _operations = operations,super._();
  

 final  List<PendingOperation> _operations;
@override@JsonKey() List<PendingOperation> get operations {
  if (_operations is EqualUnmodifiableListView) return _operations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_operations);
}

@override@JsonKey() final  bool isProcessing;
@override final  PendingOperation? currentOperation;

/// Create a copy of OperationQueueState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OperationQueueStateCopyWith<_OperationQueueState> get copyWith => __$OperationQueueStateCopyWithImpl<_OperationQueueState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OperationQueueState&&const DeepCollectionEquality().equals(other._operations, _operations)&&(identical(other.isProcessing, isProcessing) || other.isProcessing == isProcessing)&&(identical(other.currentOperation, currentOperation) || other.currentOperation == currentOperation));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_operations),isProcessing,currentOperation);

@override
String toString() {
  return 'OperationQueueState(operations: $operations, isProcessing: $isProcessing, currentOperation: $currentOperation)';
}


}

/// @nodoc
abstract mixin class _$OperationQueueStateCopyWith<$Res> implements $OperationQueueStateCopyWith<$Res> {
  factory _$OperationQueueStateCopyWith(_OperationQueueState value, $Res Function(_OperationQueueState) _then) = __$OperationQueueStateCopyWithImpl;
@override @useResult
$Res call({
 List<PendingOperation> operations, bool isProcessing, PendingOperation? currentOperation
});


@override $PendingOperationCopyWith<$Res>? get currentOperation;

}
/// @nodoc
class __$OperationQueueStateCopyWithImpl<$Res>
    implements _$OperationQueueStateCopyWith<$Res> {
  __$OperationQueueStateCopyWithImpl(this._self, this._then);

  final _OperationQueueState _self;
  final $Res Function(_OperationQueueState) _then;

/// Create a copy of OperationQueueState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? operations = null,Object? isProcessing = null,Object? currentOperation = freezed,}) {
  return _then(_OperationQueueState(
operations: null == operations ? _self._operations : operations // ignore: cast_nullable_to_non_nullable
as List<PendingOperation>,isProcessing: null == isProcessing ? _self.isProcessing : isProcessing // ignore: cast_nullable_to_non_nullable
as bool,currentOperation: freezed == currentOperation ? _self.currentOperation : currentOperation // ignore: cast_nullable_to_non_nullable
as PendingOperation?,
  ));
}

/// Create a copy of OperationQueueState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PendingOperationCopyWith<$Res>? get currentOperation {
    if (_self.currentOperation == null) {
    return null;
  }

  return $PendingOperationCopyWith<$Res>(_self.currentOperation!, (value) {
    return _then(_self.copyWith(currentOperation: value));
  });
}
}

// dart format on
