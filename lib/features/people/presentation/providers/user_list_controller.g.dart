// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserListController)
const userListControllerProvider = UserListControllerProvider._();

final class UserListControllerProvider
    extends $NotifierProvider<UserListController, UsersList> {
  const UserListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userListControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userListControllerHash();

  @$internal
  @override
  UserListController create() => UserListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UsersList value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UsersList>(value),
    );
  }
}

String _$userListControllerHash() =>
    r'a29da1f6c1ba40d556ac31666d38a10a5f42886a';

abstract class _$UserListController extends $Notifier<UsersList> {
  UsersList build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<UsersList, UsersList>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UsersList, UsersList>,
              UsersList,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
