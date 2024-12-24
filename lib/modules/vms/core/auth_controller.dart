import 'dart:async';
import 'dart:convert';
import 'package:near_social_mobile/modules/home/apis/near_social.dart';
// import 'package:cloud_functions/cloud_functions.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutterchain/flutterchain_lib/services/chains/near_blockchain_service.dart';
import 'package:near_social_mobile/config/constants.dart';
import 'package:near_social_mobile/modules/home/apis/models/private_key_info.dart';
import 'package:near_social_mobile/services/crypto_storage_service.dart';
import 'package:near_social_mobile/services/cryptography/encryption/encryption_runner_interface.dart';
import 'package:near_social_mobile/services/cryptography/internal_cryptography_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/auth_info.dart';

class AuthController extends Disposable {
  final NearBlockChainService _nearBlockChainService;
  final FlutterSecureStorage _secureStorage;
  final NearSocialApi _nearSocialApi;

  late final CryptoStorageService _cryptoStorageService;

  final BehaviorSubject<AuthInfo> _streamController =
      BehaviorSubject.seeded(const AuthInfo());

  AuthController(
      this._nearBlockChainService, this._secureStorage, this._nearSocialApi)
      : _cryptoStorageService =
            CryptoStorageService(secureStorage: _secureStorage);

  Stream<AuthInfo> get stream => _streamController.stream.distinct();
  AuthInfo get state => _streamController.value;

  Future<void> login({
    required String accountId,
    required String secretKey,
  }) async {
    try {
      _streamController.add(state.copyWith(
        accountId: accountId,
        secretKey: secretKey,
      ));

      final privateKey = await _nearBlockChainService
          .getPrivateKeyFromSecretKeyFromNearApiJSFormat(
        secretKey.split(":").last,
      );
      final publicKey = await _nearBlockChainService
          .getPublicKeyFromSecretKeyFromNearApiJSFormat(
        secretKey.split(":").last,
      );

      final base58PubKey = await _nearBlockChainService
          .getBase58PubKeyFromHexValue(hexEncodedPubKey: publicKey);

      final additionalStoredKeys = {
        "Near Social QR Functional Key": PrivateKeyInfo(
          publicKey: accountId,
          privateKey: secretKey,
          base58PubKey: base58PubKey,
          privateKeyTypeInfo: const PrivateKeyTypeInfo(
            type: PrivateKeyType.FunctionCall,
            receiverId: "social.near",
            methodNames: [],
          ),
        ),
        ...await _getAdditionalAccessKeys()
      };

      String signedMessagedForVerification =
          await Modular.get<InternalCryptographyService>()
              .encryptionRunner
              .signMessageForVerification(secretKey);

      final uuid = Supabase.instance.client.auth.currentUser!.id;
      final secureStorage = Modular.get<FlutterSecureStorage>();
      var keyPair;
      final keys = await secureStorage.read(key: "session_keys");
      if (keys == null) {
        keyPair = await Modular.get<InternalCryptographyService>()
            .encryptionRunner
            .generateKeyPair();

        await secureStorage.write(
            key: "session_keys", value: jsonEncode(keyPair.toJson()));
      } else {
        keyPair = KeyPair.fromJson(
            jsonDecode(await Modular.get<FlutterSecureStorage>().read(
                  key: "session_keys",
                ) ??
                '{}'));
      }

      final res = await verifyTransaction(
        signature: signedMessagedForVerification,
        encryptionPublicKey: keyPair.publicKey,
        publicKeyStr: base58PubKey,
        uuid: uuid,
        accountId: accountId,
      );

      if (!res) {
        throw Exception("Server authenticated error");
      }

      _streamController.add(state.copyWith(
        accountId: accountId,
        publicKey: publicKey,
        secretKey: secretKey,
        privateKey: privateKey,
        additionalStoredKeys: additionalStoredKeys,
        status: AuthInfoStatus.authenticated,
      ));
    } catch (err) {
      rethrow;
    }
  }

  Future<AccountActivationStatus> getActivationStatus() async {
    try {
      if (state.accountActivationStatus != AccountActivationStatus.activated) {
        final activationStatus =
            await _nearSocialApi.getUserStorageInfo(state.accountId);
        final status = (activationStatus.usedBytes != null &&
                activationStatus.usedBytes != null)
            ? AccountActivationStatus.activated
            : AccountActivationStatus.notActivated;
        _streamController.add(state.copyWith(accountActivationStatus: status));
        return status;
      } else {
        return state.accountActivationStatus;
      }
    } catch (err) {
      return getActivationStatus();
    }
  }

  Future<bool> verifyTransaction({
    required String signature,
    required String publicKeyStr,
    required String encryptionPublicKey,
    required String uuid,
    required String accountId,
  }) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'verifyAccount',
        headers: {
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
        body: <String, dynamic>{
          'signature': signature,
          'publicKeyStr': publicKeyStr,
          'encryptionPublicKey': encryptionPublicKey,
          'uuid': uuid,
          'accountId': accountId,
        },
      );
      return response.data['success'] == true;
    } catch (e) {
      print('Unexpected error: $e');
      return false;
    }
  }

  // Future<UserCredential?> authenticateUser(
  //     String accountId, String secretKey) async {
  //   final FirebaseAuth auth = FirebaseAuth.instance;
  //   final userCredential = await auth.signInAnonymously();

  //   print("secretKey  :::  " + secretKey);
  //   final privateKey = await _nearBlockChainService
  //       .getPrivateKeyFromSecretKeyFromNearApiJSFormat(
  //     secretKey.split(":").last,
  //   );
  //   final publicKey = await _nearBlockChainService
  //       .getPublicKeyFromSecretKeyFromNearApiJSFormat(
  //     secretKey.split(":").last,
  //   );

  //   String base58EncodedPublicKey = (await _nearBlockChainService.jsVMService
  //       .callJS("window.fromSecretToNearAPIJSPublicKey('$secretKey')"));

  // String signedMessagedForVerification = (await _nearBlockChainService
  //         .jsVMService
  //         .callJS("window.signMessageForVerification('$secretKey')"))
  //     .toString();

  // print("signedMessagedForVerification  " + signedMessagedForVerification);

  //   verifyTransaction(
  //     signature: signedMessagedForVerification,
  //     publicKeyStr: base58EncodedPublicKey,
  //     uuid: FirebaseAuth.instance.currentUser!.uid,
  //     accountId: accountId,
  //   ).then((resVerefication) async {
  //     final DocumentSnapshot res = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(accountId)
  //         .get();

  //     if (res.exists) {
  //       print('User data: ${res.data()}');
  //     } else {
  //       print('No user found with ID: $accountId');
  //     }

  //     if (resVerefication && !res.exists) {
  //       final accountInfo = await NearSocialApi(
  //               _nearBlockChainService: NearBlockChainService.defaultInstance())
  //           .getGeneralAccountInfo(accountId: accountId);
  //       print("accountInfo  " + accountInfo.toString());

  //       FirebaseChatCore.instance.createUserInFirestore(
  //         types.User(
  //           firstName: accountInfo.name,
  //           id: accountInfo.accountId,
  //           imageUrl: accountInfo.profileImageLink,
  //           lastName: "No data exist",
  //           role: types.Role.user,
  //         ),
  //       );
  //       print("resVerefication  " + resVerefication.toString());
  //     }
  //   });

  //   try {
  //     return userCredential;
  //   } catch (e) {
  //     print('Authentication error: $e');
  //     return null;
  //   }
  // }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _secureStorage.delete(key: StorageKeys.authInfo);
      await _secureStorage.delete(key: StorageKeys.additionalCryptographicKeys);
      _streamController.add(const AuthInfo());
    } catch (err) {
      throw Exception("Failed to logout");
    }
  }

  Future<void> addAccessKey({
    required String accessKeyName,
    required PrivateKeyInfo privateKeyInfo,
  }) async {
    try {
      final newState = state.copyWith(
        additionalStoredKeys: Map.of(state.additionalStoredKeys)
          ..putIfAbsent(accessKeyName, () => privateKeyInfo),
      );
      await _cryptoStorageService.write(
        storageKey: StorageKeys.additionalCryptographicKeys,
        data: jsonEncode(newState.additionalStoredKeys),
      );
      _streamController.add(newState);
    } catch (err) {
      throw Exception("Failed to add key");
    }
  }

  Future<void> removeAccessKey({required String accessKeyName}) async {
    try {
      final newState = state.copyWith(
        additionalStoredKeys: Map.of(state.additionalStoredKeys)
          ..remove(accessKeyName),
      );
      await _cryptoStorageService.write(
        storageKey: StorageKeys.additionalCryptographicKeys,
        data: jsonEncode(newState.additionalStoredKeys),
      );
      _streamController.add(newState);
    } catch (err) {
      throw Exception("Failed to remove key");
    }
  }

  Future<Map<String, PrivateKeyInfo>> _getAdditionalAccessKeys() async {
    try {
      final encodedData = await _cryptoStorageService.read(
        storageKey: StorageKeys.additionalCryptographicKeys,
      );
      final decodedData = jsonDecode(encodedData) as Map<String, dynamic>?;
      if (decodedData == null) {
        return {};
      }
      final additionalKeys = decodedData.map((key, value) {
        return MapEntry(key, PrivateKeyInfo.fromJson(value));
      });
      return additionalKeys;
    } catch (err) {
      return {};
    }
  }

  @override
  void dispose() {
    _streamController.close();
  }
}
