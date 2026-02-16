import 'package:near_social_mobile/core/exceptions/exceptions.dart';
import 'package:near_social_mobile/features/people/data/models/follower.dart';
import 'package:near_social_mobile/features/people/data/models/general_account_info.dart';
import 'package:near_social_mobile/core/network/near_social_api.dart';
import 'package:near_social_mobile/core/models/pending_operation.dart';
import 'package:near_social_mobile/core/providers/operation_queue_controller.dart';
import 'package:near_social_mobile/core/providers/service_providers.dart';
import 'package:near_social_mobile/features/people/data/models/user_list_state.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/features/auth/data/models/auth_info.dart';
import 'package:near_social_mobile/features/people/presentation/logic/people_events.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_list_controller.g.dart';

@Riverpod(keepAlive: true)
class UserListController extends _$UserListController {
  late NearSocialApi _nearSocialApi;

  @override
  UsersList build() {
    _nearSocialApi = ref.watch(nearSocialApiProvider);
    return UsersList();
  }

  Future<void> onEvent(PeopleEvent event) async {
    switch (event) {
      case LoadUsersEvent():
        await loadUsers();
      case AddUserEvent(:final generalAccountInfo):
        addGeneralAccountInfoIfNotExists(generalAccountInfo: generalAccountInfo);
      case LoadAndAddUserEvent(:final accountId):
        await loadAndAddGeneralAccountInfoIfNotExists(accountId: accountId);
      case LoadAdditionalMetadataEvent(:final accountId):
        await loadAdditionalMetadata(accountId: accountId);
      case FollowAccountEvent(:final accountIdToFollow):
        await followAccount(accountIdToFollow: accountIdToFollow);
      case UnfollowAccountEvent(:final accountIdToUnfollow):
        await unfollowAccount(accountIdToUnfollow: accountIdToUnfollow);
      case ReloadUserInfoEvent(:final accountId):
        await reloadUserInfo(accountId: accountId);
      case LoadNftsEvent(:final accountId):
        await loadNftsOfAccount(accountId: accountId);
    }
  }

  Future<void> loadUsers() async {
    if (state.loadingState == UserListState.loading) {
      return;
    }
    state = state.copyWith(loadingState: UserListState.loading);
    try {
      final generalAccountInfoOfUsers =
          await _nearSocialApi.getNearSocialAccountList();
      final Map<String, FullUserInfo> users = {};
      for (var generalAccountInfo in generalAccountInfoOfUsers) {
        users.putIfAbsent(generalAccountInfo.accountId, () {
          return FullUserInfo(generalAccountInfo: generalAccountInfo);
        });
      }

      state = state.copyWith(
        loadingState: UserListState.loaded,
        cachedUsers: users,
      );
    } catch (err) {
      state = state.copyWith(loadingState: UserListState.initial);
      rethrow;
    }
  }

  Future<void> addGeneralAccountInfoIfNotExists(
      {required GeneralAccountInfo generalAccountInfo}) async {
    if (state.activeUsers.containsKey(generalAccountInfo.accountId) ||
        state.cachedUsers.containsKey(generalAccountInfo.accountId)) {
      return;
    }
    state = state.copyWith(
      activeUsers: Map.of(state.activeUsers)
        ..[generalAccountInfo.accountId] = FullUserInfo(
          generalAccountInfo: generalAccountInfo,
        ),
    );
  }

  Future<void> loadAndAddGeneralAccountInfoIfNotExists(
      {required String accountId}) async {
    if (state.activeUsers.containsKey(accountId)) {
      return;
    }

    if (state.cachedUsers.containsKey(accountId)) {
      state = state.copyWith(
        activeUsers: Map.of(state.activeUsers)
          ..[accountId] = state.cachedUsers[accountId]!,
      );
      return;
    }

    state = state.copyWith(
      activeUsers: Map.of(state.activeUsers)
        ..[accountId] = FullUserInfo(
          generalAccountInfo: await _nearSocialApi.getGeneralAccountInfo(
              accountId: accountId),
        ),
    );
  }

  Future<void> loadAdditionalMetadata({required String accountId}) async {
    try {
      final results = await Future.wait([
        _nearSocialApi.getFollowingsOfAccount(accountId: accountId),
        _nearSocialApi.getFollowersOfAccount(accountId: accountId),
        _nearSocialApi.getUserTagsOfAccount(accountId: accountId),
      ]);

      final user = state.activeUsers[accountId];
      if (user == null) return;

      state = state.copyWith(
        activeUsers: Map.of(state.activeUsers)
          ..[accountId] = user.copyWith(
            followings: results[0] as List<Follower>,
            followers: results[1] as List<Follower>,
            userTags: results[2] as List<String>,
          ),
      );
    } catch (err) {
      rethrow;
    }
  }

  Future<void> followAccount({
    required String accountIdToFollow,
  }) async {
    final authState = ref.read(authControllerProvider);
    final authNotifier = ref.read(authControllerProvider.notifier);
    final accountId = authState.accountId;
    if ((await authNotifier.getActivationStatus()) !=
        AccountActivationStatus.activated) {
      throw AccountNotActivatedException();
    }

    state = state.copyWith(
      activeUsers: Map.of(state.activeUsers)
        ..[accountIdToFollow] =
            state.activeUsers[accountIdToFollow]!.copyWith(
          followers:
              List.of(state.activeUsers[accountIdToFollow]?.followers ?? [])
                ..add(Follower(accountId: accountId)),
        ),
    );

    await ref.read(operationQueueControllerProvider.notifier).enqueue(
      type: OperationType.followAccount,
      payload: {
        'accountIdToFollow': accountIdToFollow,
      },
    );
  }

  Future<void> unfollowAccount({
    required String accountIdToUnfollow,
  }) async {
    final authState = ref.read(authControllerProvider);
    final authNotifier = ref.read(authControllerProvider.notifier);
    final accountId = authState.accountId;
    if ((await authNotifier.getActivationStatus()) !=
        AccountActivationStatus.activated) {
      throw AccountNotActivatedException();
    }

    state = state.copyWith(
      activeUsers: Map.of(state.activeUsers)
        ..[accountIdToUnfollow] =
            state.activeUsers[accountIdToUnfollow]!.copyWith(
          followers: List.of(
              state.activeUsers[accountIdToUnfollow]?.followers ?? [])
            ..removeWhere((follower) => follower.accountId == accountId),
        ),
    );

    await ref.read(operationQueueControllerProvider.notifier).enqueue(
      type: OperationType.unfollowAccount,
      payload: {
        'accountIdToUnfollow': accountIdToUnfollow,
      },
    );
  }

  Future<void> reloadUserInfo({required String accountId}) async {
    try {
      final results = await Future.wait([
        _nearSocialApi.getGeneralAccountInfo(accountId: accountId),
        _nearSocialApi.getFollowingsOfAccount(accountId: accountId),
        _nearSocialApi.getFollowersOfAccount(accountId: accountId),
        _nearSocialApi.getUserTagsOfAccount(accountId: accountId),
      ]);
      final user = state.activeUsers[accountId];
      if (user == null) return;

      final generalAccountInfo = results[0] as GeneralAccountInfo;
      state = state.copyWith(
        activeUsers: Map<String, FullUserInfo>.from(state.activeUsers)
          ..[accountId] = user.copyWith(
            generalAccountInfo: generalAccountInfo,
            followings: results[1] as List<Follower>,
            followers: results[2] as List<Follower>,
            userTags: results[3] as List<String>,
          ),
        cachedUsers: state.cachedUsers
          ..[accountId] = user.copyWith(
            generalAccountInfo: generalAccountInfo,
          ),
      );
    } catch (err) {
      rethrow;
    }
  }

  Future<void> loadNftsOfAccount({required String accountId}) async {
    try {
      final nfts =
          await _nearSocialApi.getNftsOfAccount(accountIdOfUser: accountId);
      final user = state.activeUsers[accountId];
      if (user == null) return;
      state = state.copyWith(
        activeUsers: Map.of(state.activeUsers)
          ..[accountId] = user.copyWith(
            nfts: nfts,
          ),
      );
    } catch (err) {
      rethrow;
    }
  }

}
