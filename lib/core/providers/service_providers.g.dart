// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(secureStorage)
const secureStorageProvider = SecureStorageProvider._();

final class SecureStorageProvider
    extends
        $FunctionalProvider<
          FlutterSecureStorage,
          FlutterSecureStorage,
          FlutterSecureStorage
        >
    with $Provider<FlutterSecureStorage> {
  const SecureStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureStorageHash();

  @$internal
  @override
  $ProviderElement<FlutterSecureStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FlutterSecureStorage create(Ref ref) {
    return secureStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlutterSecureStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlutterSecureStorage>(value),
    );
  }
}

String _$secureStorageHash() => r'a4f75721472cf77465bf47f759c90de5ca30856e';

@ProviderFor(dio)
const dioProvider = DioProvider._();

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  const DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'4a3f018dda6bf2a11cdc1fa7615fde6f5beff26d';

@ProviderFor(nearRpcService)
const nearRpcServiceProvider = NearRpcServiceProvider._();

final class NearRpcServiceProvider
    extends $FunctionalProvider<NearRpcService, NearRpcService, NearRpcService>
    with $Provider<NearRpcService> {
  const NearRpcServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nearRpcServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nearRpcServiceHash();

  @$internal
  @override
  $ProviderElement<NearRpcService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NearRpcService create(Ref ref) {
    return nearRpcService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NearRpcService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NearRpcService>(value),
    );
  }
}

String _$nearRpcServiceHash() => r'33e3c1c6b1dc0dd43c4dca4a563b4f39a77c5779';

@ProviderFor(nearSocialApi)
const nearSocialApiProvider = NearSocialApiProvider._();

final class NearSocialApiProvider
    extends $FunctionalProvider<NearSocialApi, NearSocialApi, NearSocialApi>
    with $Provider<NearSocialApi> {
  const NearSocialApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nearSocialApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nearSocialApiHash();

  @$internal
  @override
  $ProviderElement<NearSocialApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NearSocialApi create(Ref ref) {
    return nearSocialApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NearSocialApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NearSocialApi>(value),
    );
  }
}

String _$nearSocialApiHash() => r'b71afdcbba90b8d5a13739c2ff6a55aaca9ab227';

@ProviderFor(userDataRepository)
const userDataRepositoryProvider = UserDataRepositoryProvider._();

final class UserDataRepositoryProvider
    extends
        $FunctionalProvider<
          UserDataRepository,
          UserDataRepository,
          UserDataRepository
        >
    with $Provider<UserDataRepository> {
  const UserDataRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userDataRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userDataRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserDataRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserDataRepository create(Ref ref) {
    return userDataRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserDataRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserDataRepository>(value),
    );
  }
}

String _$userDataRepositoryHash() =>
    r'5639e3ea7d55449e2a58893a004a3b64b8d52ea6';

@ProviderFor(webWalletService)
const webWalletServiceProvider = WebWalletServiceProvider._();

final class WebWalletServiceProvider
    extends
        $FunctionalProvider<
          WebWalletService,
          WebWalletService,
          WebWalletService
        >
    with $Provider<WebWalletService> {
  const WebWalletServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'webWalletServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$webWalletServiceHash();

  @$internal
  @override
  $ProviderElement<WebWalletService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WebWalletService create(Ref ref) {
    return webWalletService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WebWalletService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WebWalletService>(value),
    );
  }
}

String _$webWalletServiceHash() => r'f44fa6fd6753d30ac23c5b398ccb4434ba6aebfb';
