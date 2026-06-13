import 'package:ink_trail_client/features/reader/domain/entities/reader_comment_entity.dart';

ReaderCommentEntity? readerCommentEntityFromPayload(dynamic raw) {
  if (raw is! Map<String, dynamic>) return null;

  final user = raw['user'] as Map<String, dynamic>? ?? const {};
  final userId = (user['id'] ?? raw['user_id'] ?? raw['userId'] ?? '')
      .toString();
  final author = (user['display_name'] ??
          user['displayName'] ??
          user['email'] ??
          'Người dùng')
      .toString()
      .trim();

  return ReaderCommentEntity(
    id: (raw['id'] ?? '').toString(),
    storyId: (raw['story_id'] ?? raw['storyId'] ?? '').toString(),
    chapterId: (raw['chapter_id'] ?? raw['chapterId'] ?? '').toString(),
    parentId: (raw['parent_id'] ?? raw['parentId'])?.toString(),
    userId: userId,
    author: author.isEmpty ? 'Người dùng' : author,
    content: (raw['content'] ?? '').toString().trim(),
    likeCount: (raw['like_count'] as num?)?.toInt() ?? 0,
    isLiked: raw['is_liked'] as bool? ?? false,
    createdAt: DateTime.tryParse(
      (raw['created_at'] ?? raw['createdAt'] ?? '').toString(),
    ),
    isHighlighted:
        raw['is_highlighted'] as bool? ??
        raw['isHighlighted'] as bool? ??
        false,
    isMine: raw['is_mine'] as bool? ?? false,
    moderationStatus:
        (raw['moderation_status'] ?? raw['moderationStatus'] ?? 'approved')
            .toString(),
    moderationReason:
        (raw['moderation_reason'] ?? raw['moderationReason'])?.toString(),
  );
}
