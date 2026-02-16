import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('nearConnectWallet')
external JSPromise<JSString> _nearConnectWallet();

@JS('nearConnectDisconnect')
external JSPromise<JSAny?> _nearConnectDisconnect();

class NearConnectService {
  /// Waits until the near-connect module script has loaded and set the
  /// global `nearConnectWallet` function on `window`.
  static Future<void> _waitForReady() async {
    for (var i = 0; i < 50; i++) {
      final fn = globalContext['nearConnectWallet'];
      if (fn != null && fn.isA<JSFunction>()) return;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    throw StateError('near-connect module did not load in time');
  }

  /// Connects to a NEAR wallet via near-connect.
  ///
  /// Returns a record with the accountId and an optional publicKey.
  static Future<({String accountId, String? publicKey})> connect() async {
    await _waitForReady();
    final jsResult = await _nearConnectWallet().toDart;
    final json = jsonDecode(jsResult.toDart) as Map<String, dynamic>;
    return (
      accountId: json['accountId'] as String,
      publicKey: json['publicKey'] as String?,
    );
  }

  /// Disconnects the current wallet session.
  static Future<void> disconnect() async {
    await _waitForReady();
    await _nearConnectDisconnect().toDart;
  }
}
