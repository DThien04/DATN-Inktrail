class StoryDetailInfoEntity {
  /// Story id from GET /stories/:slug (used when opening from push with slug only).
  final String? storyId;
  final int likeCount;
  final int readCount;
  final double rating;
  final int ratingCount;
  final StoryMyRatingEntity? myRating;
  final String description;
  final String category;
  final List<String> tags;
  final String authorId;
  final String authorBio;
  final int authorStoryCount;

  const StoryDetailInfoEntity({
    this.storyId,
    required this.likeCount,
    required this.readCount,
    required this.rating,
    required this.ratingCount,
    required this.myRating,
    required this.description,
    required this.category,
    required this.tags,
    required this.authorId,
    required this.authorBio,
    required this.authorStoryCount,
  });
}

class StoryMyRatingEntity {
  final int score;
  final String content;
  final int editCount;
  final bool canEdit;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StoryMyRatingEntity({
    required this.score,
    required this.content,
    required this.editCount,
    required this.canEdit,
    required this.createdAt,
    required this.updatedAt,
  });
}
