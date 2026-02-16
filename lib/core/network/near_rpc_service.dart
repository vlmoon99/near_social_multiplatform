import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:dio/dio.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/core/services/crypto_service.dart';

// =============================================================================
// Response types
// =============================================================================

/// Result returned by [NearRpcService.callSmartContractFunction].
class SmartContractCallResult {
  final String status;
  final Map<String, dynamic> data;

  const SmartContractCallResult({
    required this.status,
    required this.data,
  });
}

/// Result returned by [NearRpcService.callViewMethod].
class ViewMethodResult {
  final Map<String, dynamic> data;

  const ViewMethodResult({required this.data});
}

/// Transaction metadata needed to construct and sign a transaction.
class TransactionInfo {
  final int nonce;
  final String blockHash;

  const TransactionInfo({required this.nonce, required this.blockHash});
}

// =============================================================================
// Borsh Serializer
// =============================================================================

/// A minimal Borsh (Binary Object Representation Serializer for Hashing)
/// encoder used to serialize NEAR Protocol transactions.
///
/// Borsh spec: https://borsh.io
class BorshSerializer {
  final BytesBuilder _buffer = BytesBuilder(copy: false);

  /// Returns the serialized bytes accumulated so far.
  Uint8List toBytes() => _buffer.toBytes();

  // ---------------------------------------------------------------------------
  // Unsigned integers (little-endian)
  // ---------------------------------------------------------------------------

  /// Writes a single unsigned 8-bit integer.
  void writeU8(int value) {
    _buffer.addByte(value & 0xFF);
  }

  /// Writes an unsigned 32-bit integer in little-endian format.
  void writeU32(int value) {
    final bytes = Uint8List(4);
    final bd = ByteData.sublistView(bytes);
    bd.setUint32(0, value, Endian.little);
    _buffer.add(bytes);
  }

  /// Writes an unsigned 64-bit integer in little-endian format.
  ///
  /// Dart `int` is 64-bit on VM but only 53-bit safe on JS. For values within
  /// 53-bit range this is sufficient (NEAR nonces and gas fit comfortably).
  void writeU64(int value) {
    final bytes = Uint8List(8);
    final bd = ByteData.sublistView(bytes);
    bd.setUint64(0, value, Endian.little);
    _buffer.add(bytes);
  }

  /// Writes an unsigned 128-bit integer from a [BigInt] in little-endian.
  ///
  /// The output is always exactly 16 bytes.
  void writeU128(BigInt value) {
    final bytes = Uint8List(16);
    var remaining = value;
    for (var i = 0; i < 16; i++) {
      bytes[i] = (remaining & BigInt.from(0xFF)).toInt();
      remaining >>= 8;
    }
    _buffer.add(bytes);
  }

  // ---------------------------------------------------------------------------
  // Strings
  // ---------------------------------------------------------------------------

  /// Writes a UTF-8 string prefixed with its byte-length as a u32.
  void writeString(String value) {
    final encoded = utf8.encode(value);
    writeU32(encoded.length);
    _buffer.add(encoded);
  }

  // ---------------------------------------------------------------------------
  // Byte arrays
  // ---------------------------------------------------------------------------

  /// Writes a fixed-length byte array (no length prefix).
  void writeFixedArray(Uint8List bytes) {
    _buffer.add(bytes);
  }

  /// Writes a variable-length byte array prefixed with its length as a u32.
  void writeBytes(Uint8List bytes) {
    writeU32(bytes.length);
    _buffer.add(bytes);
  }
}

// =============================================================================
// NEAR Transaction Builder
// =============================================================================

/// Helper that builds, hashes, signs, and base64-encodes a NEAR transaction.
class _NearTransactionBuilder {
  _NearTransactionBuilder._();

  /// Default gas allowance: 30 TGas (30 * 10^12).
  static const int defaultGas = 30000000000000;

  /// Builds a signed transaction that calls a smart-contract function.
  ///
  /// Returns the base64-encoded `SignedTransaction` ready for
  /// `broadcast_tx_commit`.
  static String buildSignedFunctionCallTransaction({
    required String signerId,
    required Uint8List publicKey,
    required int nonce,
    required String receiverId,
    required Uint8List blockHash,
    required String methodName,
    required Uint8List args,
    required int gas,
    required BigInt deposit,
    required Uint8List privateKey,
  }) {
    final txSerializer = BorshSerializer();

    // --- Transaction fields ---
    txSerializer.writeString(signerId);

    // PublicKey: key_type (0 = ed25519) + 32-byte key data
    txSerializer.writeU8(0);
    txSerializer.writeFixedArray(publicKey);

    txSerializer.writeU64(nonce);
    txSerializer.writeString(receiverId);
    txSerializer.writeFixedArray(blockHash); // 32 bytes

    // Actions vector: length = 1
    txSerializer.writeU32(1);

    // Action::FunctionCall (enum tag = 2)
    txSerializer.writeU8(2);
    txSerializer.writeString(methodName);
    txSerializer.writeBytes(args);
    txSerializer.writeU64(gas);
    txSerializer.writeU128(deposit);

    final txBytes = txSerializer.toBytes();

    return _signAndEncode(txBytes, privateKey, publicKey);
  }

  /// Builds a signed transaction that performs a native NEAR transfer.
  ///
  /// Returns the base64-encoded `SignedTransaction`.
  static String buildSignedTransferTransaction({
    required String signerId,
    required Uint8List publicKey,
    required int nonce,
    required String receiverId,
    required Uint8List blockHash,
    required BigInt deposit,
    required Uint8List privateKey,
  }) {
    final txSerializer = BorshSerializer();

    // --- Transaction fields ---
    txSerializer.writeString(signerId);

    // PublicKey
    txSerializer.writeU8(0);
    txSerializer.writeFixedArray(publicKey);

    txSerializer.writeU64(nonce);
    txSerializer.writeString(receiverId);
    txSerializer.writeFixedArray(blockHash);

    // Actions vector: length = 1
    txSerializer.writeU32(1);

    // Action::Transfer (enum tag = 3)
    txSerializer.writeU8(3);
    txSerializer.writeU128(deposit);

    final txBytes = txSerializer.toBytes();

    return _signAndEncode(txBytes, privateKey, publicKey);
  }

  /// SHA-256 hashes [txBytes], signs the hash with Ed25519, then produces the
  /// Borsh-serialized `SignedTransaction` encoded as base64.
  static String _signAndEncode(
    Uint8List txBytes,
    Uint8List privateKey,
    Uint8List publicKey,
  ) {
    // SHA-256 hash of the serialized transaction.
    final hash = _sha256(txBytes);

    // Ed25519 signature over the hash.
    final signature = CryptoService.signMessage(privateKey, hash);

    // Build SignedTransaction = Transaction bytes || Signature
    final signedTxSerializer = BorshSerializer();

    // The raw transaction bytes (already Borsh-serialized) are written verbatim.
    signedTxSerializer.writeFixedArray(txBytes);

    // Signature: key_type (0 = ed25519) + 64-byte signature
    signedTxSerializer.writeU8(0);
    signedTxSerializer.writeFixedArray(signature);

    return base64.encode(signedTxSerializer.toBytes());
  }

  /// Computes SHA-256 using the `crypto` package (already in pubspec.yaml).
  static Uint8List _sha256(Uint8List data) {
    final digest = crypto.sha256.convert(data);
    return Uint8List.fromList(digest.bytes);
  }
}

// =============================================================================
// NearRpcService
// =============================================================================

/// A standalone NEAR blockchain RPC service that uses only [Dio] for HTTP
/// and [CryptoService]/[Base58] (from pointycastle) for cryptographic operations.
///
/// This replaces flutterchain's `NearBlockChainService` with zero flutterchain
/// imports.
class NearRpcService {
  final Dio _dio;
  final String _rpcUrl;

  /// Creates a [NearRpcService].
  ///
  /// [dio] - An existing Dio instance (allows sharing interceptors / config).
  /// [rpcUrl] - The NEAR JSON-RPC endpoint. Defaults to [NearUrls.blockchainRpc].
  NearRpcService({
    required Dio dio,
    String? rpcUrl,
  })  : _dio = dio,
        _rpcUrl = rpcUrl ?? NearUrls.blockchainRpc;

  // ---------------------------------------------------------------------------
  // View method (read-only, no signing required)
  // ---------------------------------------------------------------------------

  /// Calls a **view** (read-only) method on a NEAR smart contract.
  ///
  /// Uses the JSON-RPC `query` method with `request_type: call_function`.
  ///
  /// Returns a [ViewMethodResult] whose `data` map contains:
  /// - `"response"` - the decoded JSON response from the contract, or
  /// - `"error"` - the error string if the RPC returned an error.
  Future<ViewMethodResult> callViewMethod({
    required String contractId,
    required String method,
    required Map<String, dynamic> args,
  }) async {
    final argsBase64 = base64.encode(utf8.encode(json.encode(args)));

    final response = await _rpcCall('query', {
      'request_type': 'call_function',
      'finality': 'final',
      'account_id': contractId,
      'method_name': method,
      'args_base64': argsBase64,
    });

    final result = response.data as Map<String, dynamic>;

    if (result['error'] != null) {
      return ViewMethodResult(data: {'error': result['error']});
    }

    final resultBytes = List<int>.from(result['result']?['result'] ?? []);
    if (resultBytes.isEmpty) {
      return const ViewMethodResult(data: {'response': null});
    }

    final decoded = json.decode(utf8.decode(resultBytes));
    return ViewMethodResult(data: {'response': decoded});
  }

  // ---------------------------------------------------------------------------
  // Smart contract function call (state-changing, requires signing)
  // ---------------------------------------------------------------------------

  /// Signs and sends a transaction that calls a smart-contract function.
  ///
  /// Parameters mirror the old `NearBlockChainSmartContractArguments`:
  /// - [accountId] - the signer's NEAR account id.
  /// - [publicKey] - the signer's public key (hex string **without** `ed25519:` prefix).
  /// - [privateKey] - the signer's secret key (base58 with optional `ed25519:` prefix).
  /// - [toAddress] - the receiver (contract) account id.
  /// - [args] - the JSON arguments to pass to the contract method.
  /// - [method] - the contract method name.
  /// - [transferAmount] - attached deposit in **yoctoNEAR** as a string
  ///   ("0" for no deposit).
  ///
  /// Returns a [SmartContractCallResult] with `status` = `"success"` on
  /// success, or `"failure"` with error details in `data`.
  Future<SmartContractCallResult> callSmartContractFunction({
    required String accountId,
    required String publicKey,
    required String privateKey,
    required String toAddress,
    required Map<String, dynamic> args,
    required String method,
    required String transferAmount,
  }) async {
    try {
      // Derive key bytes.
      final privateKeyBytes = CryptoService.privateKeyFromBase58(privateKey);
      final base58PubKey = getBase58PubKey(publicKey);
      final publicKeyBytes = CryptoService.publicKeyFromBase58(base58PubKey);

      // Get current nonce and block hash.
      final txInfo = await getTransactionInfo(
        accountId: accountId,
        publicKey: base58PubKey,
      );

      // Decode block hash from base58.
      final blockHashBytes = Base58.decode(txInfo.blockHash);

      // Encode function call args.
      final argsBytes =
          Uint8List.fromList(utf8.encode(json.encode(args)));

      // Parse deposit.
      final deposit = BigInt.tryParse(transferAmount) ?? BigInt.zero;

      // Build, sign, and encode the transaction.
      final signedTx =
          _NearTransactionBuilder.buildSignedFunctionCallTransaction(
        signerId: accountId,
        publicKey: publicKeyBytes,
        nonce: txInfo.nonce + 1,
        receiverId: toAddress,
        blockHash: blockHashBytes,
        methodName: method,
        args: argsBytes,
        gas: _NearTransactionBuilder.defaultGas,
        deposit: deposit,
        privateKey: privateKeyBytes,
      );

      // Broadcast.
      final result = await sendSignedTransaction(signedTx);

      // Interpret result.
      final resultData = result.data as Map<String, dynamic>;

      if (resultData['error'] != null) {
        return SmartContractCallResult(
          status: 'failure',
          data: resultData,
        );
      }

      final txResult = resultData['result'] as Map<String, dynamic>?;
      final txStatus = txResult?['status'];

      if (txStatus is Map && txStatus.containsKey('SuccessValue')) {
        return SmartContractCallResult(
          status: 'success',
          data: {
            'txHash': txResult?['transaction']?['hash'] ?? '',
            ...resultData,
          },
        );
      } else if (txStatus is Map && txStatus.containsKey('Failure')) {
        return SmartContractCallResult(
          status: 'failure',
          data: {
            'error': txStatus['Failure'],
            ...resultData,
          },
        );
      }

      // Fallback: treat any non-error response as success.
      return SmartContractCallResult(
        status: 'success',
        data: {
          'txHash': txResult?['transaction']?['hash'] ?? '',
          ...resultData,
        },
      );
    } catch (e) {
      return SmartContractCallResult(
        status: 'failure',
        data: {'error': e.toString()},
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Wallet balance
  // ---------------------------------------------------------------------------

  /// Returns the account balance in **NEAR** (not yoctoNEAR) as a decimal string.
  ///
  /// Uses the JSON-RPC `query` method with `request_type: view_account`.
  Future<String> getWalletBalance(String accountId) async {
    final response = await _rpcCall('query', {
      'request_type': 'view_account',
      'finality': 'final',
      'account_id': accountId,
    });

    final result = response.data as Map<String, dynamic>;
    final amountYocto =
        result['result']?['amount'] as String? ?? '0';

    // Convert yoctoNEAR to NEAR.
    return _yoctoToNear(amountYocto);
  }

  // ---------------------------------------------------------------------------
  // Access key list
  // ---------------------------------------------------------------------------

  /// Queries the full list of access keys for [accountId].
  ///
  /// Returns the first full-access public key in `ed25519:<base58>` format,
  /// or `null` if none found.
  Future<String?> getFullAccessPublicKey(String accountId) async {
    final response = await _rpcCall('query', {
      'request_type': 'view_access_key_list',
      'finality': 'final',
      'account_id': accountId,
    });

    final result = response.data as Map<String, dynamic>;
    final keys = (result['result']?['keys'] as List<dynamic>?) ?? [];

    for (final key in keys) {
      final accessKey = key['access_key'] as Map<String, dynamic>?;
      if (accessKey != null && accessKey['permission'] == 'FullAccess') {
        return key['public_key'] as String?;
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Transaction info (nonce + block hash)
  // ---------------------------------------------------------------------------

  /// Retrieves the current nonce and recent block hash needed for transaction
  /// construction.
  ///
  /// [accountId] - the signer's account id.
  /// [publicKey] - the signer's public key in `ed25519:<base58>` format.
  Future<TransactionInfo> getTransactionInfo({
    required String accountId,
    required String publicKey,
  }) async {
    final response = await _rpcCall('query', {
      'request_type': 'view_access_key',
      'finality': 'final',
      'account_id': accountId,
      'public_key': publicKey,
    });

    final result =
        (response.data as Map<String, dynamic>)['result'] as Map<String, dynamic>;

    return TransactionInfo(
      nonce: result['nonce'] as int,
      blockHash: result['block_hash'] as String,
    );
  }

  // ---------------------------------------------------------------------------
  // Send signed transaction
  // ---------------------------------------------------------------------------

  /// Broadcasts a base64-encoded signed transaction via `broadcast_tx_commit`.
  ///
  /// Returns the raw Dio [Response] from the RPC node.
  Future<Response> sendSignedTransaction(String signedTxBase64) async {
    return _rpcCall('broadcast_tx_commit', [signedTxBase64]);
  }

  // ---------------------------------------------------------------------------
  // Key utilities
  // ---------------------------------------------------------------------------

  /// Derives the public key (as a hex string) from a NEAR secret key.
  ///
  /// The [secretKey] should be the base58-encoded key (with optional `ed25519:` prefix).
  ///
  /// This matches the old `getPublicKeyFromSecretKeyFromNearApiJSFormat`.
  String getPublicKeyFromSecretKey(String secretKey) {
    final privateKeyBytes = CryptoService.privateKeyFromBase58(secretKey);

    // The public key is the last 32 bytes of the 64-byte private key.
    final publicKeyBytes = Uint8List.sublistView(privateKeyBytes, 32, 64);

    // Return as hex string (matching the old API).
    return _bytesToHex(publicKeyBytes);
  }

  /// Converts a hex-encoded public key to the NEAR `ed25519:<base58>` format.
  ///
  /// This matches the old `getBase58PubKeyFromHexValue`.
  String getBase58PubKey(String hexPubKey) {
    // If already in ed25519: format, return as-is.
    if (hexPubKey.startsWith('ed25519:')) {
      return hexPubKey;
    }

    final pubKeyBytes = _hexToBytes(hexPubKey);
    return 'ed25519:${Base58.encode(pubKeyBytes)}';
  }

  // ---------------------------------------------------------------------------
  // Sign NEAR actions (for transfer transactions)
  // ---------------------------------------------------------------------------

  /// Signs a NEAR transaction with the given actions.
  ///
  /// This is used for building transfer transactions, returning the
  /// base64-encoded signed transaction string.
  ///
  /// [actions] is a list of maps like:
  /// ```
  /// [{"type": "transfer", "data": {"amount": "1000000..."}}]
  /// ```
  Future<String> signNearActions({
    required String fromAddress,
    required String toAddress,
    required String transferAmount,
    required String privateKey,
    required String gas,
    required int nonce,
    required String blockHash,
    required List<Map<String, dynamic>> actions,
  }) async {
    final privateKeyBytes = CryptoService.privateKeyFromBase58(privateKey);
    final publicKeyBytes =
        Uint8List.sublistView(privateKeyBytes, 32, 64);
    final blockHashBytes = Base58.decode(blockHash);

    // For now we only support Transfer actions.
    final action = actions.first;
    final type = action['type'] as String;

    if (type == 'transfer') {
      final amount =
          BigInt.tryParse(action['data']['amount'] as String) ?? BigInt.zero;

      return _NearTransactionBuilder.buildSignedTransferTransaction(
        signerId: fromAddress,
        publicKey: publicKeyBytes,
        nonce: nonce + 1,
        receiverId: toAddress,
        blockHash: blockHashBytes,
        deposit: amount,
        privateKey: privateKeyBytes,
      );
    }

    throw UnsupportedError('Unsupported action type: $type');
  }

  // ---------------------------------------------------------------------------
  // Raw JSON-RPC call
  // ---------------------------------------------------------------------------

  /// Sends a JSON-RPC 2.0 request to the NEAR RPC endpoint.
  Future<Response> _rpcCall(String method, dynamic params) async {
    return _dio.post(
      _rpcUrl,
      data: {
        'jsonrpc': '2.0',
        'id': 'dontcare',
        'method': method,
        'params': params,
      },
      options: Options(
        headers: {'Content-Type': 'application/json'},
        extra: {'withCredentials': false},
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Converts a yoctoNEAR string to a NEAR decimal string.
  ///
  /// 1 NEAR = 10^24 yoctoNEAR.
  static String _yoctoToNear(String yoctoNear) {
    const decimals = 24;
    final padded = yoctoNear.padLeft(decimals + 1, '0');
    final intPart = padded.substring(0, padded.length - decimals);
    final fracPart =
        padded.substring(padded.length - decimals).replaceFirst(RegExp(r'0+$'), '');

    if (fracPart.isEmpty) return intPart;
    return '$intPart.$fracPart';
  }

  /// Converts bytes to a lowercase hex string.
  static String _bytesToHex(Uint8List bytes) {
    final sb = StringBuffer();
    for (final b in bytes) {
      sb.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString();
  }

  /// Converts a hex string to bytes.
  static Uint8List _hexToBytes(String hex) {
    final length = hex.length;
    final bytes = Uint8List(length ~/ 2);
    for (var i = 0; i < length; i += 2) {
      bytes[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
    }
    return bytes;
  }
}
