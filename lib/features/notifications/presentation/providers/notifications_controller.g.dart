// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationsController)
const notificationsControllerProvider = NotificationsControllerProvider._();

final class NotificationsControllerProvider
    extends $NotifierProvider<NotificationsController, Notifications> {
  const NotificationsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsControllerHash();

  @$internal
  @override
  NotificationsController create() => NotificationsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Notifications value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Notifications>(value),
    );
  }
}

String _$notificationsControllerHash() =>
    r'e208933e0113aca50a11a6a7f3a5d7cd5f2e3661';

abstract class _$NotificationsController extends $Notifier<Notifications> {
  Notifications build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Notifications, Notifications>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Notifications, Notifications>,
              Notifications,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
