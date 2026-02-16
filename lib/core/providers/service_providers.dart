import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/core/network/interceptors/retry_on_connection_changed_interceptor.dart';
import 'package:near_social_mobile/core/network/near_rpc_service.dart';
import 'package:near_social_mobile/core/network/near_social_api.dart';
import 'package:near_social_mobile/core/services/secure_storage_service.dart';
import 'package:near_social_mobile/features/auth/data/repositories/local_user_data_repository.dart';
import 'package:near_social_mobile/features/auth/data/repositories/user_data_repository.dart';
import 'package:near_social_mobile/features/chat/data/services/chat_encryption_service.dart';
import 'package:near_social_mobile/features/chat/data/services/chat_storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'service_providers.g.dart';

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) {
  return const FlutterSecureStorage();
}

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio = Dio();
  dio.interceptors.addAll([
    RetryInterceptor(
      dio: dio,
      retries: 3,
      retryDelays: [
        const Duration(milliseconds: 500),
        const Duration(seconds: 1),
        const Duration(seconds: 2),
      ],
    ),
    RetryOnConnectionChangeInterceptor(
      dio: dio,
      connectivity: Connectivity(),
    ),
  ]);
  return dio;
}

@Riverpod(keepAlive: true)
NearRpcService nearRpcService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return NearRpcService(dio: dio, rpcUrl: NearUrls.blockchainRpc);
}

@Riverpod(keepAlive: true)
NearSocialApi nearSocialApi(Ref ref) {
  final nearRpcService = ref.watch(nearRpcServiceProvider);
  return NearSocialApi(nearRpcService: nearRpcService);
}

@Riverpod(keepAlive: true)
UserDataRepository userDataRepository(Ref ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return LocalUserDataRepository(secureStorage);
}

@Riverpod(keepAlive: true)
ChatEncryptionService chatEncryptionService(Ref ref) {
  return ChatEncryptionService();
}

@Riverpod(keepAlive: true)
CryptoStorageService cryptoStorageService(Ref ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return CryptoStorageService(secureStorage: secureStorage);
}

@Riverpod(keepAlive: true)
ChatStorageService chatStorageService(Ref ref) {
  final cryptoStorage = ref.watch(cryptoStorageServiceProvider);
  return ChatStorageService(cryptoStorage: cryptoStorage);
}
