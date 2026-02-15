import 'dart:convert';
import 'dart:typed_data';

import 'package:pinenacl/x25519.dart' as x25519;
import 'package:pinenacl/tweetnacl.dart';

/// End-to-end encryption service using NaCl Box (Curve25519 + XSalsa20-Poly1305).
///
/// Converts Ed25519 device keys → X25519 keys, then uses [x25519.Box] for
/// authenticated public-key encryption.
class ChatEncryptionService {
  /// Convert an Ed25519 private key (64 bytes) to an X25519 private key (32 bytes).
  Uint8List _ed25519SkToX25519(Uint8List ed25519Sk) {
    final x25519Sk = Uint8List(32);
    TweetNaClExt.crypto_sign_ed25519_sk_to_x25519_sk(x25519Sk, ed25519Sk);
    return x25519Sk;
  }

  /// Convert an Ed25519 public key (32 bytes) to an X25519 public key (32 bytes).
  Uint8List _ed25519PkToX25519(Uint8List ed25519Pk) {
    final x25519Pk = Uint8List(32);
    TweetNaClExt.crypto_sign_ed25519_pk_to_x25519_pk(x25519Pk, ed25519Pk);
    return x25519Pk;
  }

  /// Encrypt [plaintext] using my Ed25519 private key and the peer's Ed25519
  /// public key. Returns a base64-encoded ciphertext (nonce + encrypted data).
  ///
  /// Keys are expected as raw bytes (not base64/base58 encoded).
  String encrypt({
    required Uint8List myEd25519PrivateKey,
    required Uint8List theirEd25519PublicKey,
    required String plaintext,
  }) {
    final myX25519Sk = _ed25519SkToX25519(myEd25519PrivateKey);
    final theirX25519Pk = _ed25519PkToX25519(theirEd25519PublicKey);

    final box = x25519.Box(
      myPrivateKey: x25519.PrivateKey(myX25519Sk),
      theirPublicKey: x25519.PublicKey(theirX25519Pk),
    );

    final encrypted = box.encrypt(Uint8List.fromList(utf8.encode(plaintext)));
    return base64.encode(Uint8List.fromList(encrypted));
  }

  /// Decrypt a base64-encoded ciphertext using my Ed25519 private key and
  /// the peer's Ed25519 public key.
  String decrypt({
    required Uint8List myEd25519PrivateKey,
    required Uint8List theirEd25519PublicKey,
    required String base64Ciphertext,
  }) {
    final myX25519Sk = _ed25519SkToX25519(myEd25519PrivateKey);
    final theirX25519Pk = _ed25519PkToX25519(theirEd25519PublicKey);

    final box = x25519.Box(
      myPrivateKey: x25519.PrivateKey(myX25519Sk),
      theirPublicKey: x25519.PublicKey(theirX25519Pk),
    );

    final decoded = base64.decode(base64Ciphertext);
    final encryptedMessage = x25519.EncryptedMessage.fromList(decoded);
    final decrypted = box.decrypt(encryptedMessage);
    return utf8.decode(decrypted);
  }
}
