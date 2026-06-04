import 'package:ink_trail_client/features/story_rating/domain/entities/story_rating_entity.dart';

abstract class StoryRatingRepository {
  Future<StoryRatingsEntity> getStoryRatings({required String storyId});

  Future<void> submitStoryRating({
    required String storyId,
    required int score,
    required String content,
  });
}
