// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatState {

 bool get signalingConnected; PeerConnectionStatus get peerStatus; List<ChatMessage> get messages; String get remotePeerId; bool get isVideoEnabled; bool get isAudioEnabled; bool get isScreenSharing; String? get incomingCallFrom; String? get peerPublicKey;
/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatStateCopyWith<ChatState> get copyWith => _$ChatStateCopyWithImpl<ChatState>(this as ChatState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatState&&(identical(other.signalingConnected, signalingConnected) || other.signalingConnected == signalingConnected)&&(identical(other.peerStatus, peerStatus) || other.peerStatus == peerStatus)&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.remotePeerId, remotePeerId) || other.remotePeerId == remotePeerId)&&(identical(other.isVideoEnabled, isVideoEnabled) || other.isVideoEnabled == isVideoEnabled)&&(identical(other.isAudioEnabled, isAudioEnabled) || other.isAudioEnabled == isAudioEnabled)&&(identical(other.isScreenSharing, isScreenSharing) || other.isScreenSharing == isScreenSharing)&&(identical(other.incomingCallFrom, incomingCallFrom) || other.incomingCallFrom == incomingCallFrom)&&(identical(other.peerPublicKey, peerPublicKey) || other.peerPublicKey == peerPublicKey));
}


@override
int get hashCode => Object.hash(runtimeType,signalingConnected,peerStatus,const DeepCollectionEquality().hash(messages),remotePeerId,isVideoEnabled,isAudioEnabled,isScreenSharing,incomingCallFrom,peerPublicKey);

@override
String toString() {
  return 'ChatState(signalingConnected: $signalingConnected, peerStatus: $peerStatus, messages: $messages, remotePeerId: $remotePeerId, isVideoEnabled: $isVideoEnabled, isAudioEnabled: $isAudioEnabled, isScreenSharing: $isScreenSharing, incomingCallFrom: $incomingCallFrom, peerPublicKey: $peerPublicKey)';
}


}

/// @nodoc
abstract mixin class $ChatStateCopyWith<$Res>  {
  factory $ChatStateCopyWith(ChatState value, $Res Function(ChatState) _then) = _$ChatStateCopyWithImpl;
@useResult
$Res call({
 bool signalingConnected, PeerConnectionStatus peerStatus, List<ChatMessage> messages, String remotePeerId, bool isVideoEnabled, bool isAudioEnabled, bool isScreenSharing, String? incomingCallFrom, String? peerPublicKey
});




}
/// @nodoc
class _$ChatStateCopyWithImpl<$Res>
    implements $ChatStateCopyWith<$Res> {
  _$ChatStateCopyWithImpl(this._self, this._then);

  final ChatState _self;
  final $Res Function(ChatState) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? signalingConnected = null,Object? peerStatus = null,Object? messages = null,Object? remotePeerId = null,Object? isVideoEnabled = null,Object? isAudioEnabled = null,Object? isScreenSharing = null,Object? incomingCallFrom = freezed,Object? peerPublicKey = freezed,}) {
  return _then(_self.copyWith(
signalingConnected: null == signalingConnected ? _self.signalingConnected : signalingConnected // ignore: cast_nullable_to_non_nullable
as bool,peerStatus: null == peerStatus ? _self.peerStatus : peerStatus // ignore: cast_nullable_to_non_nullable
as PeerConnectionStatus,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,remotePeerId: null == remotePeerId ? _self.remotePeerId : remotePeerId // ignore: cast_nullable_to_non_nullable
as String,isVideoEnabled: null == isVideoEnabled ? _self.isVideoEnabled : isVideoEnabled // ignore: cast_nullable_to_non_nullable
as bool,isAudioEnabled: null == isAudioEnabled ? _self.isAudioEnabled : isAudioEnabled // ignore: cast_nullable_to_non_nullable
as bool,isScreenSharing: null == isScreenSharing ? _self.isScreenSharing : isScreenSharing // ignore: cast_nullable_to_non_nullable
as bool,incomingCallFrom: freezed == incomingCallFrom ? _self.incomingCallFrom : incomingCallFrom // ignore: cast_nullable_to_non_nullable
as String?,peerPublicKey: freezed == peerPublicKey ? _self.peerPublicKey : peerPublicKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatState].
extension ChatStatePatterns on ChatState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatState value)  $default,){
final _that = this;
switch (_that) {
case _ChatState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatState value)?  $default,){
final _that = this;
switch (_that) {
case _ChatState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool signalingConnected,  PeerConnectionStatus peerStatus,  List<ChatMessage> messages,  String remotePeerId,  bool isVideoEnabled,  bool isAudioEnabled,  bool isScreenSharing,  String? incomingCallFrom,  String? peerPublicKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatState() when $default != null:
return $default(_that.signalingConnected,_that.peerStatus,_that.messages,_that.remotePeerId,_that.isVideoEnabled,_that.isAudioEnabled,_that.isScreenSharing,_that.incomingCallFrom,_that.peerPublicKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool signalingConnected,  PeerConnectionStatus peerStatus,  List<ChatMessage> messages,  String remotePeerId,  bool isVideoEnabled,  bool isAudioEnabled,  bool isScreenSharing,  String? incomingCallFrom,  String? peerPublicKey)  $default,) {final _that = this;
switch (_that) {
case _ChatState():
return $default(_that.signalingConnected,_that.peerStatus,_that.messages,_that.remotePeerId,_that.isVideoEnabled,_that.isAudioEnabled,_that.isScreenSharing,_that.incomingCallFrom,_that.peerPublicKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool signalingConnected,  PeerConnectionStatus peerStatus,  List<ChatMessage> messages,  String remotePeerId,  bool isVideoEnabled,  bool isAudioEnabled,  bool isScreenSharing,  String? incomingCallFrom,  String? peerPublicKey)?  $default,) {final _that = this;
switch (_that) {
case _ChatState() when $default != null:
return $default(_that.signalingConnected,_that.peerStatus,_that.messages,_that.remotePeerId,_that.isVideoEnabled,_that.isAudioEnabled,_that.isScreenSharing,_that.incomingCallFrom,_that.peerPublicKey);case _:
  return null;

}
}

}

/// @nodoc


class _ChatState implements ChatState {
  const _ChatState({this.signalingConnected = false, this.peerStatus = PeerConnectionStatus.disconnected, final  List<ChatMessage> messages = const [], this.remotePeerId = '', this.isVideoEnabled = false, this.isAudioEnabled = false, this.isScreenSharing = false, this.incomingCallFrom = null, this.peerPublicKey = null}): _messages = messages;
  

@override@JsonKey() final  bool signalingConnected;
@override@JsonKey() final  PeerConnectionStatus peerStatus;
 final  List<ChatMessage> _messages;
@override@JsonKey() List<ChatMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@override@JsonKey() final  String remotePeerId;
@override@JsonKey() final  bool isVideoEnabled;
@override@JsonKey() final  bool isAudioEnabled;
@override@JsonKey() final  bool isScreenSharing;
@override@JsonKey() final  String? incomingCallFrom;
@override@JsonKey() final  String? peerPublicKey;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatStateCopyWith<_ChatState> get copyWith => __$ChatStateCopyWithImpl<_ChatState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatState&&(identical(other.signalingConnected, signalingConnected) || other.signalingConnected == signalingConnected)&&(identical(other.peerStatus, peerStatus) || other.peerStatus == peerStatus)&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.remotePeerId, remotePeerId) || other.remotePeerId == remotePeerId)&&(identical(other.isVideoEnabled, isVideoEnabled) || other.isVideoEnabled == isVideoEnabled)&&(identical(other.isAudioEnabled, isAudioEnabled) || other.isAudioEnabled == isAudioEnabled)&&(identical(other.isScreenSharing, isScreenSharing) || other.isScreenSharing == isScreenSharing)&&(identical(other.incomingCallFrom, incomingCallFrom) || other.incomingCallFrom == incomingCallFrom)&&(identical(other.peerPublicKey, peerPublicKey) || other.peerPublicKey == peerPublicKey));
}


@override
int get hashCode => Object.hash(runtimeType,signalingConnected,peerStatus,const DeepCollectionEquality().hash(_messages),remotePeerId,isVideoEnabled,isAudioEnabled,isScreenSharing,incomingCallFrom,peerPublicKey);

@override
String toString() {
  return 'ChatState(signalingConnected: $signalingConnected, peerStatus: $peerStatus, messages: $messages, remotePeerId: $remotePeerId, isVideoEnabled: $isVideoEnabled, isAudioEnabled: $isAudioEnabled, isScreenSharing: $isScreenSharing, incomingCallFrom: $incomingCallFrom, peerPublicKey: $peerPublicKey)';
}


}

/// @nodoc
abstract mixin class _$ChatStateCopyWith<$Res> implements $ChatStateCopyWith<$Res> {
  factory _$ChatStateCopyWith(_ChatState value, $Res Function(_ChatState) _then) = __$ChatStateCopyWithImpl;
@override @useResult
$Res call({
 bool signalingConnected, PeerConnectionStatus peerStatus, List<ChatMessage> messages, String remotePeerId, bool isVideoEnabled, bool isAudioEnabled, bool isScreenSharing, String? incomingCallFrom, String? peerPublicKey
});




}
/// @nodoc
class __$ChatStateCopyWithImpl<$Res>
    implements _$ChatStateCopyWith<$Res> {
  __$ChatStateCopyWithImpl(this._self, this._then);

  final _ChatState _self;
  final $Res Function(_ChatState) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? signalingConnected = null,Object? peerStatus = null,Object? messages = null,Object? remotePeerId = null,Object? isVideoEnabled = null,Object? isAudioEnabled = null,Object? isScreenSharing = null,Object? incomingCallFrom = freezed,Object? peerPublicKey = freezed,}) {
  return _then(_ChatState(
signalingConnected: null == signalingConnected ? _self.signalingConnected : signalingConnected // ignore: cast_nullable_to_non_nullable
as bool,peerStatus: null == peerStatus ? _self.peerStatus : peerStatus // ignore: cast_nullable_to_non_nullable
as PeerConnectionStatus,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,remotePeerId: null == remotePeerId ? _self.remotePeerId : remotePeerId // ignore: cast_nullable_to_non_nullable
as String,isVideoEnabled: null == isVideoEnabled ? _self.isVideoEnabled : isVideoEnabled // ignore: cast_nullable_to_non_nullable
as bool,isAudioEnabled: null == isAudioEnabled ? _self.isAudioEnabled : isAudioEnabled // ignore: cast_nullable_to_non_nullable
as bool,isScreenSharing: null == isScreenSharing ? _self.isScreenSharing : isScreenSharing // ignore: cast_nullable_to_non_nullable
as bool,incomingCallFrom: freezed == incomingCallFrom ? _self.incomingCallFrom : incomingCallFrom // ignore: cast_nullable_to_non_nullable
as String?,peerPublicKey: freezed == peerPublicKey ? _self.peerPublicKey : peerPublicKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
