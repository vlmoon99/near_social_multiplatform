// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation_queue_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OperationQueueController)
const operationQueueControllerProvider = OperationQueueControllerProvider._();

final class OperationQueueControllerProvider
    extends $NotifierProvider<OperationQueueController, OperationQueueState> {
  const OperationQueueControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'operationQueueControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$operationQueueControllerHash();

  @$internal
  @override
  OperationQueueController create() => OperationQueueController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OperationQueueState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OperationQueueState>(value),
    );
  }
}

String _$operationQueueControllerHash() =>
    r'c54d3f55b454836ef68e560777f4e2163e467951';

abstract class _$OperationQueueController
    extends $Notifier<OperationQueueState> {
  OperationQueueState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<OperationQueueState, OperationQueueState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OperationQueueState, OperationQueueState>,
              OperationQueueState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
