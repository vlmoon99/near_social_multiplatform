import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:near_social_mobile/features/people/data/models/general_account_info.dart';
import 'package:near_social_mobile/features/feed/data/models/like.dart';

part 'comment.freezed.dart';

@freezed
abstract class Comment with _$Comment {
  const factory Comment({
    required GeneralAccountInfo authorInfo,
    required int blockHeight,
    required DateTime date,
    required CommentBody commentBody,
    required List<Like> likeList,
  }) = _Comment;
}

@freezed
abstract class CommentCreationInfo with _$CommentCreationInfo {
  const factory CommentCreationInfo({
    required String accountId,
    required int blockHeight,
  }) = _CommentCreationInfo;
}

@freezed
abstract class CommentBody with _$CommentBody {
  const factory CommentBody({
    required String text,
    required String? mediaLink,
  }) = _CommentBody;
}
