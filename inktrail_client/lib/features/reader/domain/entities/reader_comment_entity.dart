class ReaderCommentEntity {
  final String id;
  final String? storyId;
  final String? chapterId;
  final String? parentId;
  final String userId;
  final String author;
  final String content;
  final int likeCount;
  final bool isLiked;
  final DateTime? createdAt;
  final bool isHighlighted;
  final bool isMine;
  final String moderationStatus;
  final String? moderationReason;

  const ReaderCommentEntity({
    required this.id,
    required this.storyId,
    required this.chapterId,
    required this.parentId,
    required this.userId,
    required this.author,
    required this.content,
    required this.likeCount,
    required this.isLiked,
    required this.createdAt,
    required this.isHighlighted,
    required this.isMine,
    required this.moderationStatus,
    required this.moderationReason,
  });
}

class ReaderCommentsEntity {
  final List<ReaderCommentEntity> items;
  final int total;

  const ReaderCommentsEntity({
    required this.items,
    required this.total,
  });
}

class ReaderLikeResultEntity {
  final bool liked;
  final int likeCount;

  const ReaderLikeResultEntity({
    required this.liked,
    required this.likeCount,
  });
}
