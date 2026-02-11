import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/core/models/filters.dart';
import 'package:near_social_mobile/core/providers/service_providers.dart';
import 'package:near_social_mobile/features/settings/presentation/logic/settings_events.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'filter_controller.g.dart';

@Riverpod(keepAlive: true)
class FilterController extends _$FilterController {
  late FlutterSecureStorage _storage;

  @override
  Filters build() {
    _storage = ref.watch(secureStorageProvider);
    return const Filters();
  }

  Future<void> onEvent(SettingsEvent event) async {
    switch (event) {
      case LoadFiltersEvent():
        await loadFilters();
      case BlockUserEvent(:final accountId, :final blockedAccountId):
        await blockUser(accountId: accountId, blockedAccountId: blockedAccountId);
      case UnblockUserEvent(:final accountId, :final blockedAccountId):
        await unblockUser(accountId: accountId, blockedAccountId: blockedAccountId);
      case HidePostEvent(:final accountId, :final accountIdToHide, :final blockHeightToHide):
        await hidePost(accountId: accountId, accountIdToHide: accountIdToHide, blockHeightToHide: blockHeightToHide);
      case HidePostsOfUserEvent(:final accountId, :final accountIdToHide):
        await hidePostsOfUser(accountId: accountId, accountIdToHide: accountIdToHide);
      case RestorePostsOfUserEvent(:final accountId, :final accountIdToRestore):
        await restorePostsOfUser(accountId: accountId, accountIdToRestore: accountIdToRestore);
      case ClearFiltersEvent():
        await clear();
    }
  }

  Future<void> loadFilters() async {
    state = state.copyWith(status: FilterLoadStatus.loading);
    final Map<String, dynamic> filters =
        jsonDecode(await _storage.read(key: StorageKeys.filters) ?? "{}");
    if (filters.isEmpty) {
      state = state.copyWith(status: FilterLoadStatus.loaded);
      return;
    }
    final actualFilters = Filters.fromJson(filters);
    state = actualFilters.copyWith(status: FilterLoadStatus.loaded);
  }

  Future<void> blockUser(
      {required String accountId, required String blockedAccountId}) async {
    state = state.copyWith(
      blockedAccounts: [...state.blockedAccounts, blockedAccountId],
    );
    _updateFilters();
  }

  Future<void> unblockUser(
      {required String accountId, required String blockedAccountId}) async {
    state = state.copyWith(
      blockedAccounts: List.of(state.blockedAccounts)
        ..remove(blockedAccountId),
    );
    _updateFilters();
  }

  Future<void> hidePost(
      {required String accountId,
      required String accountIdToHide,
      required int blockHeightToHide}) async {
    state = state.copyWith(
      hidedPosts: [
        ...state.hidedPosts,
        "$accountIdToHide&$blockHeightToHide"
      ],
    );
    _updateFilters();
  }

  Future<void> hidePostsOfUser(
      {required String accountId, required String accountIdToHide}) async {
    state = state.copyWith(
      hidedAllPostsAccounts: [
        ...state.hidedAllPostsAccounts,
        accountIdToHide
      ],
      hidedPosts: List.of(state.hidedPosts)
        ..removeWhere(
          (element) => element.startsWith("$accountIdToHide&"),
        ),
    );
    _updateFilters();
  }

  Future<void> restorePostsOfUser(
      {required String accountId, required String accountIdToRestore}) async {
    state = state.copyWith(
      hidedAllPostsAccounts: List.of(state.hidedAllPostsAccounts)
        ..remove(accountIdToRestore),
      hidedPosts: List.of(state.hidedPosts)
        ..removeWhere(
          (element) => element.startsWith("$accountIdToRestore&"),
        ),
    );
    _updateFilters();
  }

  Future<void> _updateFilters() async {
    return _storage.write(
      key: StorageKeys.filters,
      value: jsonEncode(state.toJson()),
    );
  }

  Future<void> clear() async {
    state = const Filters();
    await _storage.delete(key: StorageKeys.filters);
  }
}

class FiltersUtil {
  final Filters filters;

  FiltersUtil({required this.filters});

  bool postIsHided(String accountId, int blockHeight) {
    return filters.blockedAccounts.contains(accountId) ||
        filters.hidedPosts.contains("$accountId&$blockHeight") ||
        filters.hidedAllPostsAccounts.contains(accountId);
  }

  bool commentIsHided(String accountId, int blockHeight) {
    return filters.blockedAccounts.contains(accountId);
  }

  bool userIsBlocked(String accountId) {
    return filters.blockedAccounts.contains(accountId);
  }
}
