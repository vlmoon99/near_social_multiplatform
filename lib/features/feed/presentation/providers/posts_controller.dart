import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:near_social_mobile/core/exceptions/exceptions.dart';
import 'package:near_social_mobile/features/feed/data/models/comment.dart';
import 'package:near_social_mobile/features/people/data/models/general_account_info.dart';
import 'package:near_social_mobile/features/feed/data/models/like.dart';
import 'package:near_social_mobile/features/feed/data/models/post.dart';
import 'package:near_social_mobile/features/feed/data/models/reposter.dart';
import 'package:near_social_mobile/features/feed/data/models/reposter_info.dart';
import 'package:near_social_mobile/core/network/near_social_api.dart';
import 'package:near_social_mobile/core/models/pending_operation.dart';
import 'package:near_social_mobile/core/providers/operation_queue_controller.dart';
import 'package:near_social_mobile/core/providers/service_providers.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/features/auth/data/models/auth_info.dart';
import 'package:near_social_mobile/core/models/filters.dart';
import 'package:near_social_mobile/core/providers/filter_controller.dart';
import 'package:near_social_mobile/features/feed/presentation/logic/feed_events.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'posts_controller.g.dart';

@Riverpod(keepAlive: true)
class PostsController extends _$PostsController {
  late NearSocialApi _nearSocialApi;

  final Map<String, GeneralAccountInfo> _profileCache = {};

  int _activeLoads = 0;
  static const int _maxConcurrentLoads = 5;
  final List<Future<void> Function()> _loadQueue = [];

  Timer? _batchUpdateTimer;

  @override
  Posts build() {
    _nearSocialApi = ref.watch(nearSocialApiProvider);
    ref.onDispose(() {
      _batchUpdateTimer?.cancel();
    });
    return const Posts();
  }

  Future<void> onEvent(FeedEvent event) async {
    switch (event) {
      case LoadPostsEvent(:final postsViewMode, :final postsOfAccountId, :final filters):
        await loadPosts(postsViewMode: postsViewMode, postsOfAccountId: postsOfAccountId, filters: filters);
      case LoadMorePostsEvent(:final postsViewMode, :final postsOfAccountId, :final filters):
        await loadMorePosts(postsViewMode: postsViewMode, postsOfAccountId: postsOfAccountId, filters: filters);
      case LoadCommentsEvent(:final accountId, :final blockHeight, :final postsViewMode, :final postsOfAccountId):
        await loadCommentsOfPost(accountId: accountId, blockHeight: blockHeight, postsViewMode: postsViewMode, postsOfAccountId: postsOfAccountId);
      case UpdateCommentsEvent(:final accountId, :final blockHeight, :final postsViewMode, :final postsOfAccountId):
        await updateCommentsOfPost(accountId: accountId, blockHeight: blockHeight, postsViewMode: postsViewMode, postsOfAccountId: postsOfAccountId);
      case LikePostEvent(:final post, :final postsViewMode, :final postsOfAccountId):
        await likePost(post: post, postsViewMode: postsViewMode, postsOfAccountId: postsOfAccountId);
      case LikeCommentEvent(:final post, :final comment, :final postsViewMode, :final postsOfAccountId):
        await likeComment(post: post, comment: comment, postsViewMode: postsViewMode, postsOfAccountId: postsOfAccountId);
      case RepostEvent(:final post, :final postsViewMode, :final postsOfAccountId):
        await repostPost(post: post, postsViewMode: postsViewMode, postsOfAccountId: postsOfAccountId);
      case LoadSinglePostEvent(:final accountInfo, :final blockHeight):
        await loadAndAddSinglePostIfNotExistToTempList(accountInfo: accountInfo, blockHeight: blockHeight);
      case UpdatePostsOfAccountEvent(:final postsOfAccountId, :final filters):
        await updatePostsOfAccount(postsOfAccountId: postsOfAccountId, filters: filters);
      case ClearFeedEvent():
        clear();
    }
  }

  void _flushState() {
    _batchUpdateTimer?.cancel();
    _batchUpdateTimer = null;
  }

  void _emitStateThrottled() {
    _batchUpdateTimer ??= Timer(const Duration(milliseconds: 80), () {
      state = state.copyWith();
      _batchUpdateTimer = null;
    });
  }

  Future<GeneralAccountInfo> _getCachedProfile(String accountId) async {
    if (_profileCache.containsKey(accountId)) {
      return _profileCache[accountId]!;
    }
    final info =
        await _nearSocialApi.getGeneralAccountInfo(accountId: accountId);
    _profileCache[accountId] = info;
    return info;
  }

  void _enqueueLoad(Future<void> Function() task) {
    if (_activeLoads < _maxConcurrentLoads) {
      _activeLoads++;
      task().whenComplete(() {
        _activeLoads--;
        _processLoadQueue();
      });
    } else {
      _loadQueue.add(task);
    }
  }

  void _processLoadQueue() {
    while (_activeLoads < _maxConcurrentLoads && _loadQueue.isNotEmpty) {
      final task = _loadQueue.removeAt(0);
      _activeLoads++;
      task().whenComplete(() {
        _activeLoads--;
        _processLoadQueue();
      });
    }
  }

  Future<void> loadPosts(
      {String? postsOfAccountId,
      required PostsViewMode postsViewMode,
      Filters? filters}) async {
    try {
      if (postsViewMode == PostsViewMode.main) {
        state = state.copyWith(status: PostLoadingStatus.loading);
      }

      final List<Post> posts = await _nearSocialApi.getPosts(
        targetAccounts: postsOfAccountId == null ? null : [postsOfAccountId],
        limit: postsViewMode == PostsViewMode.account ? 20 : 10,
      );
      switch (postsViewMode) {
        case PostsViewMode.main:
          state = state.copyWith(posts: posts);
          break;
        case PostsViewMode.account:
          state = state.copyWith(
            postsOfAccounts: Map.of(state.postsOfAccounts)
              ..[postsOfAccountId!] = posts,
          );
          break;
        case PostsViewMode.temporary:
          break;
      }

      checkPostsForFullLoadAndLoadIfNecessary(
        postsViewMode: postsViewMode,
        filters: filters,
        postsOfAccountId: postsOfAccountId,
      );

      state = state.copyWith(status: PostLoadingStatus.loaded);
    } catch (err) {
      rethrow;
    }
  }

  Future<void> checkPostsForFullLoadAndLoadIfNecessary(
      {required PostsViewMode postsViewMode,
      Filters? filters,
      String? postsOfAccountId}) async {
    final summaryPosts = getPostsDueToPostsViewMode(
      postsViewMode,
      postsOfAccountId,
    );

    if (filters != null) {
      final FiltersUtil filtersUtil = FiltersUtil(filters: filters);
      for (var i = 0; i < summaryPosts.length; i++) {
        final post = summaryPosts[i];
        if (!post.fullyLoaded &&
            !filtersUtil.postIsHided(
                post.authorInfo.accountId, post.blockHeight)) {
          final index = i;
          _enqueueLoad(
              () => _loadPostsDataAsync(index, postsViewMode, postsOfAccountId));
        }
      }
    } else {
      for (var i = 0; i < summaryPosts.length; i++) {
        final post = summaryPosts[i];
        if (!post.fullyLoaded) {
          final index = i;
          _enqueueLoad(
              () => _loadPostsDataAsync(index, postsViewMode, postsOfAccountId));
        }
      }
    }
  }

  Future<void> loadAndAddSinglePostIfNotExistToTempList({
    required GeneralAccountInfo accountInfo,
    required int blockHeight,
  }) async {
    if (state.temporaryPosts.isNotEmpty &&
        state.temporaryPosts.any((element) =>
            element.blockHeight == blockHeight &&
            element.authorInfo.accountId == accountInfo.accountId)) {
      return;
    }

    final results = await Future.wait([
      _nearSocialApi.getPostContent(
        accountId: accountInfo.accountId,
        blockHeight: blockHeight,
      ),
      _nearSocialApi.getDateOfBlockHeight(blockHeight: blockHeight),
      _nearSocialApi.getLikesOfPost(
          accountId: accountInfo.accountId, blockHeight: blockHeight),
      _nearSocialApi.getRepostsOfPost(
          accountId: accountInfo.accountId, blockHeight: blockHeight),
    ]);

    final postBody = results[0] as PostBody;
    final data = results[1] as DateTime;
    final likeList = results[2] as List<Like>;
    final repostList = results[3] as List<Reposter>;

    state = state.copyWith(
      temporaryPosts: [
        Post(
          authorInfo: accountInfo,
          postBody: postBody,
          likeList: likeList,
          repostList: repostList,
          blockHeight: blockHeight,
          date: data,
          commentList: null,
          fullyLoaded: true,
        ),
        ...state.temporaryPosts
      ],
    );
  }

  List<Post> getPostsDueToPostsViewMode(PostsViewMode postsViewMode,
      [String? postsOfAccountId]) {
    switch (postsViewMode) {
      case PostsViewMode.main:
        return List.of(state.posts);
      case PostsViewMode.account:
        return List.of(state.postsOfAccounts[postsOfAccountId]!);
      case PostsViewMode.temporary:
        return List.of(state.temporaryPosts);
    }
  }

  Future<List<Post>> loadMorePosts(
      {String? postsOfAccountId,
      required PostsViewMode postsViewMode,
      Filters? filters}) async {
    try {
      state = state.copyWith(status: PostLoadingStatus.loadingMorePosts);

      final List<Post> chosenPosts = getPostsDueToPostsViewMode(
        postsViewMode,
        postsOfAccountId,
      );

      final lastBlockHeightIndexOfPosts =
          chosenPosts.lastIndexWhere((element) => element.reposterInfo == null);
      final lastBlockHeightIndexOfReposts =
          chosenPosts.lastIndexWhere((element) => element.reposterInfo != null);
      final posts = await _nearSocialApi.getPosts(
        lastBlockHeightIndexOfPosts: lastBlockHeightIndexOfPosts == -1
            ? null
            : chosenPosts.elementAt(lastBlockHeightIndexOfPosts).blockHeight,
        lastBlockHeightIndexOfReposts: lastBlockHeightIndexOfReposts == -1
            ? null
            : chosenPosts.elementAt(lastBlockHeightIndexOfReposts).blockHeight,
        targetAccounts: postsOfAccountId == null ? null : [postsOfAccountId],
        limit: 20,
      );

      if (lastBlockHeightIndexOfPosts != -1) {
        posts.removeWhere((post) =>
            post.blockHeight ==
            chosenPosts.elementAt(lastBlockHeightIndexOfPosts).blockHeight);
      }

      if (lastBlockHeightIndexOfReposts != -1) {
        posts.removeWhere(
          (post) =>
              post.blockHeight ==
              chosenPosts.elementAt(lastBlockHeightIndexOfReposts).blockHeight,
        );
      }

      final newPosts = [...chosenPosts, ...posts];

      switch (postsViewMode) {
        case PostsViewMode.main:
          state = state.copyWith(posts: newPosts);
          break;
        case PostsViewMode.account:
          state = state.copyWith(
              postsOfAccounts: Map.of(state.postsOfAccounts)
                ..[postsOfAccountId!] = newPosts);
          break;
        case PostsViewMode.temporary:
          state = state.copyWith(temporaryPosts: newPosts);
          break;
      }

      checkPostsForFullLoadAndLoadIfNecessary(
        postsViewMode: postsViewMode,
        filters: filters,
        postsOfAccountId: postsOfAccountId,
      );

      state = state.copyWith(status: PostLoadingStatus.loaded);
      return posts;
    } catch (err) {
      state = state.copyWith(status: PostLoadingStatus.loaded);
      rethrow;
    }
  }

  Future<void> loadCommentsOfPost({
    required String accountId,
    required int blockHeight,
    String? postsOfAccountId,
    required PostsViewMode postsViewMode,
  }) async {
    try {
      late final Post post;

      switch (postsViewMode) {
        case PostsViewMode.main:
          post = state.posts.firstWhere(
            (element) =>
                element.blockHeight == blockHeight &&
                element.authorInfo.accountId == accountId,
          );
          break;
        case PostsViewMode.account:
          post = state.postsOfAccounts[postsOfAccountId]!.firstWhere(
            (element) =>
                element.blockHeight == blockHeight &&
                element.authorInfo.accountId == accountId,
          );
          break;
        case PostsViewMode.temporary:
          post = state.temporaryPosts.firstWhere(
            (element) =>
                element.blockHeight == blockHeight &&
                element.authorInfo.accountId == accountId,
          );
          break;
      }

      final commentsOfPost = await _nearSocialApi.getCommentsOfPost(
        accountId: accountId,
        blockHeight: blockHeight,
      );

      _updateDataDueToPostsViewMode(
        post: post,
        commentList: commentsOfPost,
        postsViewMode: postsViewMode,
        postsOfAccountId: postsOfAccountId,
      );

      for (var indexOfComment = 0;
          indexOfComment < commentsOfPost.length;
          indexOfComment++) {
        _loadCommentsDataAsync(
            post, indexOfComment, postsViewMode, postsOfAccountId);
      }
    } catch (err) {
      rethrow;
    }
  }

  Future<void> updateCommentsOfPost({
    required String accountId,
    required int blockHeight,
    required PostsViewMode postsViewMode,
    String? postsOfAccountId,
  }) async {
    late final Post post;

    switch (postsViewMode) {
      case PostsViewMode.main:
        post = state.posts.firstWhere(
          (element) =>
              element.blockHeight == blockHeight &&
              element.authorInfo.accountId == accountId,
        );
        break;
      case PostsViewMode.account:
        post = state.postsOfAccounts[postsOfAccountId]!.firstWhere(
          (element) =>
              element.blockHeight == blockHeight &&
              element.authorInfo.accountId == accountId,
        );
        break;
      case PostsViewMode.temporary:
        post = state.temporaryPosts.firstWhere(
          (element) =>
              element.blockHeight == blockHeight &&
              element.authorInfo.accountId == accountId,
        );
        break;
    }
    final int indexOfPost =
        _getIndexOfPost(post, postsViewMode, postsOfAccountId);

    final newCommentsOfPost = await _nearSocialApi.getCommentsOfPost(
      accountId: accountId,
      blockHeight: blockHeight,
    );

    late final List<Comment> commentsOfPost;
    switch (postsViewMode) {
      case PostsViewMode.main:
        commentsOfPost = List.of(state.posts[indexOfPost].commentList!);
        break;
      case PostsViewMode.account:
        commentsOfPost = List.of(state
            .postsOfAccounts[postsOfAccountId]![indexOfPost].commentList!);
        break;
      case PostsViewMode.temporary:
        commentsOfPost =
            List.of(state.temporaryPosts[indexOfPost].commentList!);
        break;
    }

    newCommentsOfPost.removeWhere(
      (comment) => commentsOfPost.any(
        (element) =>
            element.blockHeight == comment.blockHeight &&
            element.authorInfo.accountId == comment.authorInfo.accountId,
      ),
    );

    final finalCommentsOfPost = [...newCommentsOfPost, ...commentsOfPost];

    _updateDataDueToPostsViewMode(
      postsViewMode: postsViewMode,
      post: post,
      commentList: finalCommentsOfPost,
      postsOfAccountId: postsOfAccountId,
    );

    for (var i = 0; i < finalCommentsOfPost.length; i++) {
      _loadCommentsDataAsync(post, i, postsViewMode, postsOfAccountId);
    }
  }

  Future<void> _loadCommentsDataAsync(
      Post post, int indexOfComment, PostsViewMode postsViewMode,
      [String? postsOfAccountId]) async {
    final int indexOfPost =
        _getIndexOfPost(post, postsViewMode, postsOfAccountId);
    late final Comment comment;

    switch (postsViewMode) {
      case PostsViewMode.main:
        comment = state.posts[indexOfPost].commentList![indexOfComment];
        break;
      case PostsViewMode.account:
        comment = state.postsOfAccounts[postsOfAccountId]![indexOfPost]
            .commentList![indexOfComment];
        break;
      case PostsViewMode.temporary:
        comment =
            state.temporaryPosts[indexOfPost].commentList![indexOfComment];
        break;
    }

    final results = await Future.wait([
      _nearSocialApi.getCommentContent(
        accountId: comment.authorInfo.accountId,
        blockHeight: comment.blockHeight,
      ),
      _nearSocialApi.getDateOfBlockHeight(
        blockHeight: comment.blockHeight,
      ),
      _nearSocialApi.getLikesOfComment(
        accountId: comment.authorInfo.accountId,
        blockHeight: comment.blockHeight,
      ),
    ]);

    final CommentBody commentBody = results[0] as CommentBody;
    final DateTime date = results[1] as DateTime;
    final List<Like> likes = results[2] as List<Like>;

    late final List<Comment> commentsOfPost;
    switch (postsViewMode) {
      case PostsViewMode.main:
        commentsOfPost =
            List<Comment>.of(state.posts[indexOfPost].commentList!);
        break;
      case PostsViewMode.account:
        commentsOfPost = List<Comment>.of(state
            .postsOfAccounts[postsOfAccountId]![indexOfPost].commentList!);
        break;
      case PostsViewMode.temporary:
        commentsOfPost =
            List<Comment>.of(state.temporaryPosts[indexOfPost].commentList!);
        break;
    }
    _updateDataDueToPostsViewMode(
      postsViewMode: postsViewMode,
      post: post,
      commentList: commentsOfPost
        ..[indexOfComment] = commentsOfPost[indexOfComment].copyWith(
          commentBody: commentBody,
          likeList: likes,
          date: date,
        ),
      postsOfAccountId: postsOfAccountId,
    );
  }

  Future<void> updatePostsOfAccount(
      {required String postsOfAccountId, Filters? filters}) async {
    try {
      final FiltersUtil filtersUtil =
          FiltersUtil(filters: filters ?? const Filters());
      final newPosts = await _nearSocialApi.getPosts(
        targetAccounts: [postsOfAccountId],
        limit: 10,
      );

      newPosts.removeWhere(
        (post) => state.postsOfAccounts[postsOfAccountId]!.any(
          (element) =>
              (element.blockHeight == post.blockHeight &&
                  element.authorInfo.accountId == post.authorInfo.accountId &&
                  element.reposterInfo == post.reposterInfo) ||
              filtersUtil.postIsHided(
                  post.authorInfo.accountId, post.blockHeight),
        ),
      );

      state = state.copyWith(
        postsOfAccounts: Map.of(state.postsOfAccounts)
          ..[postsOfAccountId] = [
            ...newPosts,
            ...state.postsOfAccounts[postsOfAccountId]!
          ],
        status: PostLoadingStatus.loaded,
      );

      checkPostsForFullLoadAndLoadIfNecessary(
        postsViewMode: PostsViewMode.account,
        postsOfAccountId: postsOfAccountId,
        filters: filters,
      );
    } catch (err) {
      rethrow;
    }
  }

  Future<void> _loadPostsDataAsync(int indexOfPost, PostsViewMode postsViewMode,
      [String? postsOfAccountId]) async {
    late final Post post;

    switch (postsViewMode) {
      case PostsViewMode.main:
        post = state.posts[indexOfPost];
        break;
      case PostsViewMode.account:
        post = state.postsOfAccounts[postsOfAccountId]![indexOfPost];
        break;
      case PostsViewMode.temporary:
        post = state.temporaryPosts[indexOfPost];
        break;
    }

    final loadedPosts = getPostsDueToPostsViewMode(
      postsViewMode,
      postsOfAccountId,
    ).where((element) => element.fullyLoaded == true).toList();
    final alreadyLoaded = loadedPosts.any((element) =>
        element.blockHeight == post.blockHeight &&
        element.authorInfo.accountId == post.authorInfo.accountId);

    final hasReposter = post.reposterInfo != null;
    final dateBlockHeight =
        hasReposter ? post.reposterInfo!.blockHeight : post.blockHeight;

    if (alreadyLoaded) {
      final futures = <Future>[
        _nearSocialApi.getDateOfBlockHeight(blockHeight: dateBlockHeight),
        if (hasReposter)
          _getCachedProfile(post.reposterInfo!.accountInfo.accountId),
      ];
      final results = await Future.wait(futures);
      final actualDateOfPost = results[0] as DateTime;
      ReposterInfo? actualReposterInfo;
      if (hasReposter) {
        actualReposterInfo = post.reposterInfo!.copyWith(
          accountInfo: results[1] as GeneralAccountInfo,
        );
      }
      final postToCopyInfo = loadedPosts.firstWhere((element) =>
          element.blockHeight == post.blockHeight &&
          element.authorInfo.accountId == post.authorInfo.accountId);

      _updateDataDueToPostsViewMode(
        post: post,
        postsViewMode: postsViewMode,
        postsOfAccountId: postsOfAccountId,
        repostList: postToCopyInfo.repostList,
        likeList: postToCopyInfo.likeList,
        date: actualDateOfPost,
        authorInfo: postToCopyInfo.authorInfo,
        reposterInfo: actualReposterInfo,
        postBody: postToCopyInfo.postBody,
        fullyLoaded: true,
        throttle: true,
      );
      return;
    }

    final futures = <Future>[
      _nearSocialApi.getPostContent(
        accountId: post.authorInfo.accountId,
        blockHeight: post.blockHeight,
      ),
      _getCachedProfile(post.authorInfo.accountId),
      _nearSocialApi.getLikesOfPost(
          accountId: post.authorInfo.accountId, blockHeight: post.blockHeight),
      _nearSocialApi.getRepostsOfPost(
          accountId: post.authorInfo.accountId, blockHeight: post.blockHeight),
      _nearSocialApi.getDateOfBlockHeight(blockHeight: dateBlockHeight),
      if (hasReposter)
        _getCachedProfile(post.reposterInfo!.accountInfo.accountId),
    ];
    final results = await Future.wait(futures);

    final actualPostBody = results[0] as PostBody;
    final actualAuthorInfo = results[1] as GeneralAccountInfo;
    final actualLikeList = results[2] as List<Like>;
    final actualRepostsOfPostList = results[3] as List<Reposter>;
    final actualDateOfPost = results[4] as DateTime;
    ReposterInfo? actualReposterInfo;
    if (hasReposter) {
      actualReposterInfo = post.reposterInfo!.copyWith(
        accountInfo: results[5] as GeneralAccountInfo,
      );
    }

    _updateDataDueToPostsViewMode(
      post: post,
      postsViewMode: postsViewMode,
      postsOfAccountId: postsOfAccountId,
      repostList: actualRepostsOfPostList,
      likeList: actualLikeList,
      date: actualDateOfPost,
      authorInfo: actualAuthorInfo,
      reposterInfo: actualReposterInfo,
      postBody: actualPostBody,
      fullyLoaded: true,
      throttle: true,
    );
  }

  Future<void> likePost({
    required Post post,
    required PostsViewMode postsViewMode,
    String? postsOfAccountId,
  }) async {
    final authState = ref.read(authControllerProvider);
    final authNotifier = ref.read(authControllerProvider.notifier);
    final accountId = authState.accountId;
    if ((await authNotifier.getActivationStatus()) !=
        AccountActivationStatus.activated) {
      throw AccountNotActivatedException();
    }
    final isLiked =
        post.likeList.any((element) => element.accountId == accountId);

    if (isLiked) {
      _updateDataDueToPostsViewMode(
        postsViewMode: postsViewMode,
        post: post,
        likeList: List.of(post.likeList)
          ..removeWhere((element) => element.accountId == accountId),
        postsOfAccountId: postsOfAccountId,
      );
      await ref.read(operationQueueControllerProvider.notifier).enqueue(
        type: OperationType.unlikePost,
        payload: {
          'accountIdOfPost': post.authorInfo.accountId,
          'blockHeight': post.blockHeight,
        },
      );
    } else {
      _updateDataDueToPostsViewMode(
        postsViewMode: postsViewMode,
        post: post,
        likeList: List.of(post.likeList)..add(Like(accountId: accountId)),
        postsOfAccountId: postsOfAccountId,
      );
      await ref.read(operationQueueControllerProvider.notifier).enqueue(
        type: OperationType.likePost,
        payload: {
          'accountIdOfPost': post.authorInfo.accountId,
          'blockHeight': post.blockHeight,
        },
      );
    }
  }

  Future<void> likeComment({
    required Post post,
    required Comment comment,
    required PostsViewMode postsViewMode,
    String? postsOfAccountId,
  }) async {
    final authState = ref.read(authControllerProvider);
    final authNotifier = ref.read(authControllerProvider.notifier);
    final accountId = authState.accountId;
    if ((await authNotifier.getActivationStatus()) !=
        AccountActivationStatus.activated) {
      throw AccountNotActivatedException();
    }
    final indexOfPost = _getIndexOfPost(post, postsViewMode, postsOfAccountId);
    final indexOfComment = post.commentList!.indexWhere(
      (element) =>
          element.blockHeight == comment.blockHeight &&
          element.authorInfo.accountId == comment.authorInfo.accountId,
    );
    final isLiked = post.commentList![indexOfComment].likeList
        .any((element) => element.accountId == accountId);

    List<Comment> commentsOfPost() {
      switch (postsViewMode) {
        case PostsViewMode.main:
          return List.of(state.posts[indexOfPost].commentList!);
        case PostsViewMode.account:
          return List.of(state
              .postsOfAccounts[postsOfAccountId]![indexOfPost].commentList!);
        case PostsViewMode.temporary:
          return List.of(state.temporaryPosts[indexOfPost].commentList!);
      }
    }

    if (isLiked) {
      _updateDataDueToPostsViewMode(
        postsViewMode: postsViewMode,
        post: post,
        commentList: commentsOfPost()
          ..[indexOfComment] = commentsOfPost()[indexOfComment].copyWith(
            likeList: List.of(comment.likeList)
              ..removeWhere((element) => element.accountId == accountId),
          ),
        postsOfAccountId: postsOfAccountId,
      );
      await ref.read(operationQueueControllerProvider.notifier).enqueue(
        type: OperationType.unlikeComment,
        payload: {
          'accountIdOfPost': comment.authorInfo.accountId,
          'blockHeight': comment.blockHeight,
        },
      );
    } else {
      _updateDataDueToPostsViewMode(
        postsViewMode: postsViewMode,
        post: post,
        commentList: commentsOfPost()
          ..[indexOfComment] = commentsOfPost()[indexOfComment].copyWith(
            likeList: List.of(comment.likeList)
              ..add(Like(accountId: accountId)),
          ),
        postsOfAccountId: postsOfAccountId,
      );
      await ref.read(operationQueueControllerProvider.notifier).enqueue(
        type: OperationType.likeComment,
        payload: {
          'accountIdOfPost': comment.authorInfo.accountId,
          'blockHeight': comment.blockHeight,
        },
      );
    }
  }

  Future<void> repostPost({
    required Post post,
    required PostsViewMode postsViewMode,
    String? postsOfAccountId,
  }) async {
    final authState = ref.read(authControllerProvider);
    final authNotifier = ref.read(authControllerProvider.notifier);
    final accountId = authState.accountId;
    if ((await authNotifier.getActivationStatus()) !=
        AccountActivationStatus.activated) {
      throw AccountNotActivatedException();
    }

    _updateDataDueToPostsViewMode(
      postsViewMode: postsViewMode,
      post: post,
      repostList: List.of(post.repostList)
        ..add(Reposter(accountId: accountId)),
      postsOfAccountId: postsOfAccountId,
    );

    await ref.read(operationQueueControllerProvider.notifier).enqueue(
      type: OperationType.repostPost,
      payload: {
        'accountIdOfPost': post.authorInfo.accountId,
        'blockHeight': post.blockHeight,
      },
    );
  }

  void _updateDataDueToPostsViewMode({
    required PostsViewMode postsViewMode,
    required Post post,
    String? postsOfAccountId,
    List<Like>? likeList,
    List<Comment>? commentList,
    List<Reposter>? repostList,
    PostBody? postBody,
    GeneralAccountInfo? authorInfo,
    ReposterInfo? reposterInfo,
    DateTime? date,
    bool? fullyLoaded,
    bool throttle = false,
  }) {
    final indexOfPost = _getIndexOfPost(post, postsViewMode, postsOfAccountId);
    if (indexOfPost == -1) return;

    switch (postsViewMode) {
      case PostsViewMode.main:
        state = state.copyWith(
          posts: List<Post>.of(state.posts)
            ..[indexOfPost] = state.posts[indexOfPost].copyWith(
              likeList: likeList ?? state.posts[indexOfPost].likeList,
              commentList:
                  commentList ?? state.posts[indexOfPost].commentList,
              repostList: repostList ?? state.posts[indexOfPost].repostList,
              postBody: postBody ?? state.posts[indexOfPost].postBody,
              authorInfo: authorInfo ?? state.posts[indexOfPost].authorInfo,
              reposterInfo:
                  reposterInfo ?? state.posts[indexOfPost].reposterInfo,
              date: date ?? state.posts[indexOfPost].date,
              fullyLoaded:
                  fullyLoaded ?? state.posts[indexOfPost].fullyLoaded,
            ),
        );
        break;
      case PostsViewMode.account:
        final newListOfPostsForUser = List<Post>.of(
            state.postsOfAccounts[postsOfAccountId]!)
          ..[indexOfPost] =
              state.postsOfAccounts[postsOfAccountId]![indexOfPost].copyWith(
            likeList: likeList ??
                state
                    .postsOfAccounts[postsOfAccountId]![indexOfPost].likeList,
            commentList: commentList ??
                state.postsOfAccounts[postsOfAccountId]![indexOfPost]
                    .commentList,
            repostList: repostList ??
                state.postsOfAccounts[postsOfAccountId]![indexOfPost]
                    .repostList,
            postBody: postBody ??
                state
                    .postsOfAccounts[postsOfAccountId]![indexOfPost].postBody,
            authorInfo: authorInfo ??
                state.postsOfAccounts[postsOfAccountId]![indexOfPost]
                    .authorInfo,
            reposterInfo: reposterInfo ??
                state.postsOfAccounts[postsOfAccountId]![indexOfPost]
                    .reposterInfo,
            date: date ??
                state.postsOfAccounts[postsOfAccountId]![indexOfPost].date,
            fullyLoaded: fullyLoaded ??
                state.postsOfAccounts[postsOfAccountId]![indexOfPost]
                    .fullyLoaded,
          );
        state = state.copyWith(
          postsOfAccounts: Map<String, List<Post>>.of(state.postsOfAccounts)
            ..[postsOfAccountId!] = newListOfPostsForUser,
        );
        break;
      case PostsViewMode.temporary:
        state = state.copyWith(
          temporaryPosts: List.of(state.temporaryPosts)
            ..[indexOfPost] = state.temporaryPosts[indexOfPost].copyWith(
              likeList:
                  likeList ?? state.temporaryPosts[indexOfPost].likeList,
              commentList: commentList ??
                  state.temporaryPosts[indexOfPost].commentList,
              repostList: repostList ??
                  state.temporaryPosts[indexOfPost].repostList,
              postBody:
                  postBody ?? state.temporaryPosts[indexOfPost].postBody,
              authorInfo: authorInfo ??
                  state.temporaryPosts[indexOfPost].authorInfo,
              reposterInfo: reposterInfo ??
                  state.temporaryPosts[indexOfPost].reposterInfo,
              date: date ?? state.temporaryPosts[indexOfPost].date,
              fullyLoaded: fullyLoaded ??
                  state.temporaryPosts[indexOfPost].fullyLoaded,
            ),
        );
        break;
    }

    if (throttle) {
      _emitStateThrottled();
    }
  }

  int _getIndexOfPost(
      Post post, PostsViewMode postsViewMode, String? postsOfAccountId) {
    switch (postsViewMode) {
      case PostsViewMode.main:
        return state.posts.indexWhere(
          (element) =>
              element.blockHeight == post.blockHeight &&
              element.authorInfo.accountId == post.authorInfo.accountId &&
              element.reposterInfo == post.reposterInfo,
        );
      case PostsViewMode.account:
        return state.postsOfAccounts[postsOfAccountId]!.indexWhere(
          (element) =>
              element.blockHeight == post.blockHeight &&
              element.authorInfo.accountId == post.authorInfo.accountId &&
              element.reposterInfo == post.reposterInfo,
        );
      case PostsViewMode.temporary:
        return state.temporaryPosts.indexWhere(
          (element) =>
              element.blockHeight == post.blockHeight &&
              element.authorInfo.accountId == post.authorInfo.accountId &&
              element.reposterInfo == post.reposterInfo,
        );
    }
  }

  Future<void> clear() async {
    _flushState();
    _profileCache.clear();
    _loadQueue.clear();
    _activeLoads = 0;
    state = const Posts();
  }
}

enum PostLoadingStatus {
  initial,
  loading,
  loadingMorePosts,
  loaded,
}

enum PostsViewMode { main, account, temporary }

class Posts extends Equatable {
  final List<Post> posts;
  final List<Post> temporaryPosts;
  final Map<String, List<Post>> postsOfAccounts;
  final PostLoadingStatus status;

  const Posts({
    this.posts = const [],
    this.temporaryPosts = const [],
    this.postsOfAccounts = const {},
    this.status = PostLoadingStatus.initial,
  });

  Posts copyWith({
    List<Post>? posts,
    List<Post>? temporaryPosts,
    Map<String, List<Post>>? postsOfAccounts,
    PostLoadingStatus? status,
  }) {
    return Posts(
      posts: posts ?? this.posts,
      postsOfAccounts: postsOfAccounts ?? this.postsOfAccounts,
      temporaryPosts: temporaryPosts ?? this.temporaryPosts,
      status: status ?? this.status,
    );
  }

  Post getPost({
    required String authorId,
    required int blockHeight,
    ReposterInfo? reposterInfo,
    required PostsViewMode postsViewMode,
    String? postsOfAccountId,
  }) {
    switch (postsViewMode) {
      case PostsViewMode.main:
        return posts.firstWhere(
          (element) =>
              element.blockHeight == blockHeight &&
              element.authorInfo.accountId == authorId &&
              element.reposterInfo == reposterInfo,
        );
      case PostsViewMode.account:
        return postsOfAccounts[postsOfAccountId]!.firstWhere(
          (element) =>
              element.blockHeight == blockHeight &&
              element.authorInfo.accountId == authorId &&
              element.reposterInfo == reposterInfo,
        );
      case PostsViewMode.temporary:
        return temporaryPosts.firstWhere(
          (element) =>
              element.blockHeight == blockHeight &&
              element.authorInfo.accountId == authorId &&
              element.reposterInfo == reposterInfo,
        );
    }
  }

  @override
  List<Object?> get props => [
        posts,
        temporaryPosts,
        postsOfAccounts,
        status,
      ];

  @override
  bool? get stringify => true;
}
