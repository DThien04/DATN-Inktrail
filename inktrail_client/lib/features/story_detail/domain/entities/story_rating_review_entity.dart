import 'package:ink_trail_client/features/story_detail/domain/entities/story_detail_info_entity.dart';

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
  final StoryMyRatingEntity? myRating;
  final List<StoryRatingReviewEntity> reviews;

  const StoryRatingsEntity({
    required this.averageRating,
    required this.ratingCount,
    required this.myRating,
    required this.reviews,
  });
}
