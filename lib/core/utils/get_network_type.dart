import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_social_mobile/core/config/constants.dart';

enum NearNetworkType { testnet, mainnet }

Future<NearNetworkType> getNearNetworkType() async {
  final secureStorage = const FlutterSecureStorage(); // TODO: Replace with ref.read()
  final networkType = await secureStorage.read(key: StorageKeys.networkType);
  if (networkType == "mainnet") {
    return NearNetworkType.mainnet;
  } else {
    return NearNetworkType.testnet;
  }
}
