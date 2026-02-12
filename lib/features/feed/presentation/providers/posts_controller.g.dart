// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posts_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PostsController)
const postsControllerProvider = PostsControllerProvider._();

final class PostsControllerProvider
    extends $NotifierProvider<PostsController, Posts> {
  const PostsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postsControllerHash();

  @$internal
  @override
  PostsController create() => PostsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Posts value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Posts>(value),
    );
  }
}

String _$postsControllerHash() => r'dc8ac9f61fd767d6629b2e91fca82f9650620ff1';

abstract class _$PostsController extends $Notifier<Posts> {
  Posts build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Posts, Posts>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Posts, Posts>,
              Posts,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
