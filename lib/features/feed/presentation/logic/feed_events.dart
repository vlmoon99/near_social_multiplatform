import 'package:near_social_mobile/core/models/filters.dart';
import 'package:near_social_mobile/features/feed/data/models/comment.dart';
import 'package:near_social_mobile/features/feed/data/models/post.dart';
import 'package:near_social_mobile/features/feed/presentation/providers/posts_controller.dart';
import 'package:near_social_mobile/features/people/data/models/general_account_info.dart';

sealed class FeedEvent {}

class LoadPostsEvent extends FeedEvent {
  final PostsViewMode postsViewMode;
  final String? postsOfAccountId;
  final Filters? filters;
  LoadPostsEvent({required this.postsViewMode, this.postsOfAccountId, this.filters});
}

class LoadMorePostsEvent extends FeedEvent {
  final PostsViewMode postsViewMode;
  final String? postsOfAccountId;
  final Filters? filters;
  LoadMorePostsEvent({required this.postsViewMode, this.postsOfAccountId, this.filters});
}

class LoadCommentsEvent extends FeedEvent {
  final String accountId;
  final int blockHeight;
  final PostsViewMode postsViewMode;
  final String? postsOfAccountId;
  LoadCommentsEvent({
    required this.accountId,
    required this.blockHeight,
    required this.postsViewMode,
    this.postsOfAccountId,
  });
}

class UpdateCommentsEvent extends FeedEvent {
  final String accountId;
  final int blockHeight;
  final PostsViewMode postsViewMode;
  final String? postsOfAccountId;
  UpdateCommentsEvent({
    required this.accountId,
    required this.blockHeight,
    required this.postsViewMode,
    this.postsOfAccountId,
  });
}

class LikePostEvent extends FeedEvent {
  final Post post;
  final PostsViewMode postsViewMode;
  final String? postsOfAccountId;
  LikePostEvent({required this.post, required this.postsViewMode, this.postsOfAccountId});
}

class LikeCommentEvent extends FeedEvent {
  final Post post;
  final Comment comment;
  final PostsViewMode postsViewMode;
  final String? postsOfAccountId;
  LikeCommentEvent({
    required this.post,
    required this.comment,
    required this.postsViewMode,
    this.postsOfAccountId,
  });
}

class RepostEvent extends FeedEvent {
  final Post post;
  final PostsViewMode postsViewMode;
  final String? postsOfAccountId;
  RepostEvent({required this.post, required this.postsViewMode, this.postsOfAccountId});
}

class LoadSinglePostEvent extends FeedEvent {
  final GeneralAccountInfo accountInfo;
  final int blockHeight;
  LoadSinglePostEvent({required this.accountInfo, required this.blockHeight});
}

class UpdatePostsOfAccountEvent extends FeedEvent {
  final String postsOfAccountId;
  final Filters? filters;
  UpdatePostsOfAccountEvent({required this.postsOfAccountId, this.filters});
}

class ClearFeedEvent extends FeedEvent {}
