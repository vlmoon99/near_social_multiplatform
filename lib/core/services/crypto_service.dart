import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pinenacl/ed25519.dart' as nacl;
import 'package:pointycastle/export.dart';

class CryptoService {
  CryptoService._();

  static Uint8List signMessage(Uint8List privateKey, Uint8List message) {
    final seed = Uint8List.sublistView(privateKey, 0, 32);
    final signingKey = nacl.SigningKey(seed: seed);
    final signed = signingKey.sign(message);
    return Uint8List.fromList(signed.signature.asTypedList);
  }

  static bool verifySignature(
    Uint8List publicKey,
    Uint8List message,
    Uint8List signature,
  ) {
    try {
      final verifyKey = nacl.VerifyKey(publicKey);
      final sig = nacl.Signature(signature);
      return verifyKey.verify(signature: sig, message: message);
    } catch (_) {
      return false;
    }
  }

  static ({Uint8List publicKey, Uint8List privateKey}) deriveKeyPairFromSeed(
    Uint8List seed,
  ) {
    if (seed.length != 32) {
      throw ArgumentError('Ed25519 seed must be exactly 32 bytes.');
    }

    final signingKey = nacl.SigningKey(seed: seed);
    final publicKeyBytes = Uint8List.fromList(signingKey.verifyKey.asTypedList);

    final privateKeyBytes = Uint8List(64);
    privateKeyBytes.setRange(0, 32, seed);
    privateKeyBytes.setRange(32, 64, publicKeyBytes);

    return (publicKey: publicKeyBytes, privateKey: privateKeyBytes);
  }

  static Uint8List privateKeyFromBase58(String base58Key) {
    final keyData = _stripPrefix(base58Key);
    final decoded = Base58.decode(keyData);

    if (decoded.length == 64) {
      return decoded;
    } else if (decoded.length == 32) {
      final pair = deriveKeyPairFromSeed(decoded);
      return pair.privateKey;
    } else {
      throw FormatException(
        'Invalid NEAR private key length: expected 32 or 64 bytes, '
        'got ${decoded.length}.',
      );
    }
  }

  static Uint8List publicKeyFromBase58(String base58Key) {
    final keyData = _stripPrefix(base58Key);
    final decoded = Base58.decode(keyData);

    if (decoded.length != 32) {
      throw FormatException(
        'Invalid NEAR public key length: expected 32 bytes, '
        'got ${decoded.length}.',
      );
    }

    return decoded;
  }

  static String publicKeyToBase58(Uint8List publicKey) {
    return 'ed25519:${Base58.encode(publicKey)}';
  }

  static String privateKeyToBase58(Uint8List privateKey) {
    return 'ed25519:${Base58.encode(privateKey)}';
  }

  static ({Uint8List publicKey, Uint8List privateKey}) generateEd25519KeyPair() {
    final seed = CryptoUtils.generateCryptographicKey();
    return deriveKeyPairFromSeed(seed);
  }

  static String publicKeyToImplicitAccountId(Uint8List publicKey) {
    if (publicKey.length != 32) {
      throw ArgumentError('Public key must be exactly 32 bytes.');
    }
    final buffer = StringBuffer();
    for (final byte in publicKey) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  static String _stripPrefix(String key) {
    const prefix = 'ed25519:';
    if (key.startsWith(prefix)) {
      return key.substring(prefix.length);
    }
    return key;
  }
}

class Base58 {
  Base58._();

  static const String _alphabet =
      '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

  static final Map<int, int> _baseMap = _buildBaseMap();

  static Map<int, int> _buildBaseMap() {
    final map = <int, int>{};
    for (var i = 0; i < _alphabet.length; i++) {
      map[_alphabet.codeUnitAt(i)] = i;
    }
    return map;
  }

  static String encode(Uint8List bytes) {
    if (bytes.isEmpty) return '';

    var leadingZeros = 0;
    for (final b in bytes) {
      if (b != 0) break;
      leadingZeros++;
    }

    final size = ((bytes.length - leadingZeros) * 138 ~/ 100) + 1;
    final b58 = Uint8List(size);

    var length = 0;
    for (var i = leadingZeros; i < bytes.length; i++) {
      var carry = bytes[i];
      var j = 0;
      for (var k = size - 1; k >= 0; k--, j++) {
        if (carry == 0 && j >= length) break;
        carry += 256 * b58[k];
        b58[k] = carry % 58;
        carry ~/= 58;
      }
      length = j;
    }

    var start = size - length;
    while (start < size && b58[start] == 0) {
      start++;
    }

    final buffer = StringBuffer();
    for (var i = 0; i < leadingZeros; i++) {
      buffer.write('1');
    }
    for (var i = start; i < size; i++) {
      buffer.write(_alphabet[b58[i]]);
    }

    return buffer.toString();
  }

  static Uint8List decode(String string) {
    if (string.isEmpty) return Uint8List(0);

    var leadingOnes = 0;
    for (final c in string.codeUnits) {
      if (c != 0x31) break;
      leadingOnes++;
    }

    final size = ((string.length - leadingOnes) * 733 ~/ 1000) + 1;
    final b256 = Uint8List(size);

    var length = 0;
    for (var i = leadingOnes; i < string.length; i++) {
      final charCode = string.codeUnitAt(i);
      final value = _baseMap[charCode];
      if (value == null) {
        throw FormatException(
          'Invalid Base58 character: "${string[i]}" at position $i.',
        );
      }

      var carry = value;
      var j = 0;
      for (var k = size - 1; k >= 0; k--, j++) {
        if (carry == 0 && j >= length) break;
        carry += 58 * b256[k];
        b256[k] = carry % 256;
        carry ~/= 256;
      }
      length = j;
    }

    var start = size - length;
    while (start < size && b256[start] == 0) {
      start++;
    }

    final result = Uint8List(leadingOnes + (size - start));
    result.setRange(leadingOnes, result.length, b256, start);

    return result;
  }
}

class CryptoUtils {
  CryptoUtils._();

  static final _random = FortunaRandom();
  static bool _seeded = false;

  static void _ensureSeeded() {
    if (!_seeded) {
      final seed = Uint8List(32);
      final dartRandom = Random.secure();
      for (var i = 0; i < 32; i++) {
        seed[i] = dartRandom.nextInt(256);
      }
      _random.seed(KeyParameter(seed));
      _seeded = true;
    }
  }

  static Uint8List generateCryptographicKey() {
    _ensureSeeded();
    return _random.nextBytes(32);
  }

  static String uint8ListKeyToBase64Key(Uint8List key) {
    return base64.encode(key);
  }

  static Uint8List keyBase64ToUint8ListKey(String base64Key) {
    return base64.decode(base64Key);
  }

  static String encrypt({
    required Uint8List cryptographicKey,
    required String data,
  }) {
    _ensureSeeded();
    final iv = _random.nextBytes(16);
    final cipher = CBCBlockCipher(AESEngine())
      ..init(true, ParametersWithIV(KeyParameter(cryptographicKey), iv));

    final input = _pad(Uint8List.fromList(utf8.encode(data)), 16);
    final output = Uint8List(input.length);

    for (var offset = 0; offset < input.length; offset += 16) {
      cipher.processBlock(input, offset, output, offset);
    }

    final combined = Uint8List(iv.length + output.length);
    combined.setRange(0, iv.length, iv);
    combined.setRange(iv.length, combined.length, output);
    return base64.encode(combined);
  }

  static String decrypt({
    required Uint8List cryptographicKey,
    required String data,
  }) {
    final combined = base64.decode(data);
    final iv = Uint8List.sublistView(combined, 0, 16);
    final ciphertext = Uint8List.sublistView(combined, 16);

    final cipher = CBCBlockCipher(AESEngine())
      ..init(false, ParametersWithIV(KeyParameter(cryptographicKey), iv));

    final output = Uint8List(ciphertext.length);
    for (var offset = 0; offset < ciphertext.length; offset += 16) {
      cipher.processBlock(ciphertext, offset, output, offset);
    }

    return utf8.decode(_unpad(output));
  }

  static Uint8List _pad(Uint8List data, int blockSize) {
    final padLength = blockSize - (data.length % blockSize);
    final padded = Uint8List(data.length + padLength);
    padded.setRange(0, data.length, data);
    for (var i = data.length; i < padded.length; i++) {
      padded[i] = padLength;
    }
    return padded;
  }

  static Uint8List _unpad(Uint8List data) {
    final padLength = data.last;
    if (padLength < 1 || padLength > 16) return data;
    return Uint8List.sublistView(data, 0, data.length - padLength);
  }
}
