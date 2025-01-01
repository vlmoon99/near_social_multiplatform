import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutterchain/flutterchain_lib/network/chains/near_rpc_client.dart';
import 'package:flutterchain/flutterchain_lib/services/chains/near_blockchain_service.dart';
import 'package:near_social_mobile/config/constants.dart';
import 'package:near_social_mobile/modules/home/apis/near_social.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:near_social_mobile/network/near_custom_client.dart';
import 'package:near_social_mobile/services/cryptography/internal_cryptography_service.dart';

class CoreModule extends Module {
  @override
  void exportedBinds(i) {
    i.addInstance<FlutterSecureStorage>(const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    ));
    i.addInstance<NearBlockChainService>(
      NearBlockChainService(
        nearRpcClient: NearRpcClient(
          networkClient: CustomNearNetworkClient(
            baseUrl: NearUrls.blockchainRpc,
            dio: Dio(),
          ),
        ),
      ),
    );

    i.add(NearSocialApi.new);
    i.addSingleton(InternalCryptographyService.new);
    i.addLazySingleton(AuthController.new);
  }
}
