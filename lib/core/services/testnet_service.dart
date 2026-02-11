import 'dart:developer' as developer;
import 'dart:math';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:near_social_mobile/core/network/interceptors/retry_on_connection_changed_interceptor.dart';
import 'package:near_social_mobile/core/services/crypto_service.dart';

class TestNetService {
  Future<({String publicKey, String secretKey})> createAccount() async {
    try {
      final random = Random.secure();
      final seed = Uint8List(32);
      for (var i = 0; i < 32; i++) {
        seed[i] = random.nextInt(256);
      }
      final keyPair = CryptoService.deriveKeyPairFromSeed(seed);

      final publicKeyBase58 = CryptoService.publicKeyToBase58(keyPair.publicKey);
      final secretKey = CryptoService.privateKeyToBase58(Uint8List.fromList(seed));

      developer.log("TestNet account public key: $publicKeyBase58");
      developer.log("TestNet account secret key: $secretKey");

      final Dio dio = Dio();
      dio.interceptors.addAll([
        RetryInterceptor(
          dio: dio,
          logPrint: developer.log,
          retries: 5,
          retryDelays: [
            ...List.generate(5, (index) => const Duration(seconds: 1))
          ],
        ),
        RetryOnConnectionChangeInterceptor(
          dio: dio,
          connectivity: Connectivity(),
        ),
      ]);

      final response = await dio.post(
        "https://server-for-account-creation.onrender.com/create-account",
        data: {
          "accountId": publicKeyBase58,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      if (!(response.data["message"] as String)
          .contains("Account created and funded")) {
        throw Exception(response.data.toString());
      }
      return (
        publicKey: publicKeyBase58,
        secretKey: secretKey,
      );
    } catch (err) {
      throw Exception("Failed to create account");
    }
  }
}
