import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:near_social_mobile/features/people/data/models/general_account_info.dart';
import 'package:near_social_mobile/features/feed/data/models/comment.dart';
import 'package:near_social_mobile/features/feed/data/models/like.dart';
import 'package:near_social_mobile/features/feed/data/models/reposter.dart';
import 'package:near_social_mobile/features/feed/data/models/reposter_info.dart';

part 'post.freezed.dart';

@freezed
abstract class Post with _$Post {
  const factory Post({
    required GeneralAccountInfo authorInfo,
    required int blockHeight,
    required DateTime date,
    required PostBody postBody,
    ReposterInfo? reposterInfo,
    required List<Like> likeList,
    required List<Reposter> repostList,
    required List<Comment>? commentList,
    @Default(false) bool fullyLoaded,
  }) = _Post;
}

@freezed
abstract class FullPostCreationInfo with _$FullPostCreationInfo {
  const factory FullPostCreationInfo({
    required PostCreationInfo postCreationInfo,
    PostCreationInfo? reposterPostCreationInfo,
  }) = _FullPostCreationInfo;
}

@freezed
abstract class PostCreationInfo with _$PostCreationInfo {
  const factory PostCreationInfo({
    required String accountId,
    required int blockHeight,
  }) = _PostCreationInfo;
}

@freezed
abstract class PostBody with _$PostBody {
  const factory PostBody({
    required String text,
    String? mediaLink,
  }) = _PostBody;
}
