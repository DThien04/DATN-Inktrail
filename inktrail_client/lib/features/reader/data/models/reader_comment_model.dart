import 'package:ink_trail_client/features/reader/domain/entities/reader_comment_entity.dart';

class ReaderCommentModel extends ReaderCommentEntity {
  const ReaderCommentModel({
    required super.id,
    required super.storyId,
    required super.chapterId,
    required super.parentId,
    required super.userId,
    required super.author,
    required super.content,
    required super.likeCount,
    required super.isLiked,
    required super.createdAt,
    required super.isHighlighted,
    required super.isMine,
    required super.moderationStatus,
    required super.moderationReason,
  });

  factory ReaderCommentModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    final userId = (user['id'] ?? json['user_id'] ?? json['userId'] ?? '')
        .toString();
    final author = (user['display_name'] ??
            user['displayName'] ??
            user['email'] ??
            'Người dùng')
        .toString()
        .trim();

    return ReaderCommentModel(
      id: (json['id'] ?? '').toString(),
      storyId: (json['story_id'] ?? json['storyId'] ?? '').toString(),
      chapterId: (json['chapter_id'] ?? json['chapterId'] ?? '').toString(),
      parentId: (json['parent_id'] ?? json['parentId'])?.toString(),
      userId: userId,
      author: author.isEmpty ? 'Người dùng' : author,
      content: (json['content'] ?? '').toString().trim(),
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      createdAt: DateTime.tryParse(
        (json['created_at'] ?? json['createdAt'] ?? '').toString(),
      ),
      isHighlighted:
          json['is_highlighted'] as bool? ??
          json['isHighlighted'] as bool? ??
          false,
      isMine: json['is_mine'] as bool? ?? false,
      moderationStatus:
          (json['moderation_status'] ?? json['moderationStatus'] ?? 'approved')
              .toString(),
      moderationReason:
          (json['moderation_reason'] ?? json['moderationReason'])?.toString(),
    );
  }

  static ReaderCommentModel? tryFromJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    return ReaderCommentModel.fromJson(raw);
  }
}

class ReaderCommentsModel extends ReaderCommentsEntity {
  const ReaderCommentsModel({
    required super.items,
    required super.total,
  });

  factory ReaderCommentsModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map(ReaderCommentModel.fromJson)
        .toList();

    return ReaderCommentsModel(
      items: items,
      total: (json['total'] as num?)?.toInt() ?? items.length,
    );
  }
}

class ReaderLikeResultModel extends ReaderLikeResultEntity {
  const ReaderLikeResultModel({
    required super.liked,
    required super.likeCount,
  });

  factory ReaderLikeResultModel.fromJson(
    Map<String, dynamic> json, {
    required bool fallbackLiked,
    required int fallbackLikeCount,
  }) {
    return ReaderLikeResultModel(
      liked: json['liked'] as bool? ?? fallbackLiked,
      likeCount: (json['like_count'] as num?)?.toInt() ?? fallbackLikeCount,
    );
  }
}
