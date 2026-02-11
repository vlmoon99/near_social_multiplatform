// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FilterController)
const filterControllerProvider = FilterControllerProvider._();

final class FilterControllerProvider
    extends $NotifierProvider<FilterController, Filters> {
  const FilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filterControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filterControllerHash();

  @$internal
  @override
  FilterController create() => FilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Filters value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Filters>(value),
    );
  }
}

String _$filterControllerHash() => r'92782b64aa0563d92542f5609150d353660dbfa1';

abstract class _$FilterController extends $Notifier<Filters> {
  Filters build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Filters, Filters>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Filters, Filters>,
              Filters,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
