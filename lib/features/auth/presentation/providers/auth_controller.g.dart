// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AuthController)
const authControllerProvider = AuthControllerProvider._();

final class AuthControllerProvider
    extends $NotifierProvider<AuthController, AuthInfo> {
  const AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthInfo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthInfo>(value),
    );
  }
}

String _$authControllerHash() => r'0c6212525f097faa0fe90a84258cf3d4ec52a0ab';

abstract class _$AuthController extends $Notifier<AuthInfo> {
  AuthInfo build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AuthInfo, AuthInfo>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthInfo, AuthInfo>,
              AuthInfo,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
