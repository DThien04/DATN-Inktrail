class StoryRatingMyRatingEntity {
  final int score;
  final String content;
  final int editCount;
  final bool canEdit;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StoryRatingMyRatingEntity({
    required this.score,
    required this.content,
    required this.editCount,
    required this.canEdit,
    required this.createdAt,
    required this.updatedAt,
  });
}

class StoryRatingReviewEntity {
  final String id;
  final String author;
  final int score;
  final String content;
  final DateTime? createdAt;

  const StoryRatingReviewEntity({
    required this.id,
    required this.author,
    required this.score,
    required this.content,
    required this.createdAt,
  });
}

class StoryRatingsEntity {
  final double averageRating;
  final int ratingCount;
  final StoryRatingMyRatingEntity? myRating;
  final List<StoryRatingReviewEntity> reviews;

  const StoryRatingsEntity({
    required this.averageRating,
    required this.ratingCount,
    required this.myRating,
    required this.reviews,
  });
}
