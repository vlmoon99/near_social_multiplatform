import 'package:near_social_mobile/exceptions/exceptions.dart';
import 'package:near_social_mobile/modules/home/apis/models/follower.dart';
import 'package:near_social_mobile/modules/home/apis/models/general_account_info.dart';
import 'package:near_social_mobile/modules/home/apis/near_social.dart';
import 'package:near_social_mobile/modules/home/vms/users/models/user_list_state.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:near_social_mobile/modules/vms/core/models/auth_info.dart';
import 'package:rxdart/rxdart.dart';

class UserListController {
  final NearSocialApi _nearSocialApi;
  final AuthController _authController;

  UserListController(this._nearSocialApi, this._authController);

  final BehaviorSubject<UsersList> _streamController =
      BehaviorSubject.seeded(UsersList());

  Stream<UsersList> get stream => _streamController.stream.distinct();
  UsersList get state => _streamController.value;

  Future<void> loadUsers() async {
    if (state.loadingState == UserListState.loading) {
      return;
    }
    _streamController.add(state.copyWith(loadingState: UserListState.loading));
    try {
      final generalAccountInfoOfUsers =
          await _nearSocialApi.getNearSocialAccountList();
      final Map<String, FullUserInfo> users = {};
      for (var generalAccountInfo in generalAccountInfoOfUsers) {
        users.putIfAbsent(generalAccountInfo.accountId, () {
          return FullUserInfo(generalAccountInfo: generalAccountInfo);
        });
      }

      _streamController.add(
        state.copyWith(
          loadingState: UserListState.loaded,
          cachedUsers: users,
        ),
      );
    } catch (err) {
      _streamController
          .add(state.copyWith(loadingState: UserListState.initial));
      rethrow;
    }
  }

  Future<void> addGeneralAccountInfoIfNotExists(
      {required GeneralAccountInfo generalAccountInfo}) async {
    if (state.activeUsers.containsKey(generalAccountInfo.accountId) ||
        state.cachedUsers.containsKey(generalAccountInfo.accountId)) {
      return;
    }
    _streamController.add(
      state.copyWith(
        activeUsers: Map.of(state.activeUsers)
          ..[generalAccountInfo.accountId] = FullUserInfo(
            generalAccountInfo: generalAccountInfo,
          ),
      ),
    );
  }

  Future<void> loadAndAddGeneralAccountInfoIfNotExists(
      {required String accountId}) async {
    if (state.activeUsers.containsKey(accountId)) {
      return;
    }

    if (state.cachedUsers.containsKey(accountId)) {
      _streamController.add(
        state.copyWith(
          activeUsers: Map.of(state.activeUsers)
            ..[accountId] = state.cachedUsers[accountId]!,
        ),
      );
      return;
    }

    _streamController.add(
      state.copyWith(
        activeUsers: Map.of(state.activeUsers)
          ..[accountId] = FullUserInfo(
            generalAccountInfo: await _nearSocialApi.getGeneralAccountInfo(
                accountId: accountId),
          ),
      ),
    );
  }

  Future<void> loadAdditionalMetadata({required String accountId}) async {
    try {
      final List<Follower> followings =
          await _nearSocialApi.getFollowingsOfAccount(accountId: accountId);
      final List<Follower> followers =
          await _nearSocialApi.getFollowersOfAccount(accountId: accountId);
      final List<String> userTags =
          await _nearSocialApi.getUserTagsOfAccount(accountId: accountId);

      _streamController.add(
        state.copyWith(
          activeUsers: Map.of(state.activeUsers)
            ..[accountId] = state.activeUsers[accountId]!.copyWith(
              followings: followings,
              followers: followers,
              userTags: userTags,
            ),
        ),
      );
    } catch (err) {
      rethrow;
    }
  }

  Future<void> followAccount({
    required String accountIdToFollow,
  }) async {
    final accountId = _authController.state.accountId;
    final publicKey = _authController.state.publicKey;
    final privateKey = _authController.state.privateKey;
    if ((await _authController.getActivationStatus()) !=
        AccountActivationStatus.activated) {
      throw AccountNotActivatedException();
    }
    try {
      _streamController.add(
        state.copyWith(
          activeUsers: Map.of(state.activeUsers)
            ..[accountIdToFollow] =
                state.activeUsers[accountIdToFollow]!.copyWith(
              followers:
                  List.of(state.activeUsers[accountIdToFollow]?.followers ?? [])
                    ..add(Follower(accountId: accountId)),
            ),
        ),
      );
      await _nearSocialApi.followAccount(
        accountIdToFollow: accountIdToFollow,
        accountId: accountId,
        publicKey: publicKey,
        privateKey: privateKey,
      );
    } catch (err) {
      _streamController.add(
        state.copyWith(
          activeUsers: Map.of(state.activeUsers)
            ..[accountIdToFollow] =
                state.activeUsers[accountIdToFollow]!.copyWith(
              followers: List.of(
                  state.activeUsers[accountIdToFollow]?.followers ?? [])
                ..removeWhere((follower) => follower.accountId == accountId),
            ),
        ),
      );
      if (err.toString().contains('Not enough storage balance')) {
        throw NotEnoughStorageBalanceException();
      } else {
        rethrow;
      }
    }
  }

  Future<void> unfollowAccount({
    required String accountIdToUnfollow,
  }) async {
    final accountId = _authController.state.accountId;
    final publicKey = _authController.state.publicKey;
    final privateKey = _authController.state.privateKey;
    if ((await _authController.getActivationStatus()) !=
        AccountActivationStatus.activated) {
      throw AccountNotActivatedException();
    }
    try {
      _streamController.add(
        state.copyWith(
          activeUsers: Map.of(state.activeUsers)
            ..[accountIdToUnfollow] =
                state.activeUsers[accountIdToUnfollow]!.copyWith(
              followers: List.of(
                  state.activeUsers[accountIdToUnfollow]?.followers ?? [])
                ..removeWhere((follower) => follower.accountId == accountId),
            ),
        ),
      );
      await _nearSocialApi.unfollowAccount(
        accountIdToUnfollow: accountIdToUnfollow,
        accountId: accountId,
        publicKey: publicKey,
        privateKey: privateKey,
      );
    } catch (err) {
      _streamController.add(
        state.copyWith(
          activeUsers: Map.of(state.activeUsers)
            ..[accountIdToUnfollow] =
                state.activeUsers[accountIdToUnfollow]!.copyWith(
              followers: List.of(
                  state.activeUsers[accountIdToUnfollow]?.followers ?? [])
                ..add(Follower(accountId: accountId)),
            ),
        ),
      );
      if (err.toString().contains('Not enough storage balance')) {
        throw NotEnoughStorageBalanceException();
      } else {
        rethrow;
      }
    }
  }

  Future<void> reloadUserInfo({required String accountId}) async {
    try {
      final generalAccountInfo =
          await _nearSocialApi.getGeneralAccountInfo(accountId: accountId);
      final List<Follower> followings =
          await _nearSocialApi.getFollowingsOfAccount(accountId: accountId);
      final List<Follower> followers =
          await _nearSocialApi.getFollowersOfAccount(accountId: accountId);
      final List<String> userTags =
          await _nearSocialApi.getUserTagsOfAccount(accountId: accountId);
      final user = state.activeUsers[accountId];

      _streamController.add(
        state.copyWith(
          activeUsers: Map<String, FullUserInfo>.from(state.activeUsers)
            ..[accountId] = user!.copyWith(
              generalAccountInfo: generalAccountInfo,
              followings: followings,
              followers: followers,
              userTags: userTags,
            ),
          cachedUsers: state.cachedUsers
            ..[accountId] = user.copyWith(
              generalAccountInfo: generalAccountInfo,
            ),
        ),
      );
      // }
    } catch (err) {
      rethrow;
    }
  }

  Future<void> loadNftsOfAccount({required String accountId}) async {
    try {
      final nfts =
          await _nearSocialApi.getNftsOfAccount(accountIdOfUser: accountId);
      _streamController.add(
        state.copyWith(
          activeUsers: Map.of(state.activeUsers)
            ..[accountId] = state.activeUsers[accountId]!.copyWith(
              nfts: nfts,
            ),
        ),
      );
    } catch (err) {
      rethrow;
    }
  }

  Future<void> loadWidgetsOfAccount({required String accountId}) async {
    try {
      final widgetList = await _nearSocialApi.getWidgetsList(
        accountId: accountId,
      );
      _streamController.add(
        state.copyWith(
          activeUsers: Map.of(state.activeUsers)
            ..[accountId] = state.activeUsers[accountId]!.copyWith(
              widgetList: widgetList,
            ),
        ),
      );
    } catch (err) {
      rethrow;
    }
  }
}
