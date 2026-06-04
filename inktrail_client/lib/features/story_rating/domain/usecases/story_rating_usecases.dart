import 'package:ink_trail_client/features/story_rating/domain/entities/story_rating_entity.dart';
import 'package:ink_trail_client/features/story_rating/domain/repositories/story_rating_repository.dart';

class GetStoryRatingsUsecase {
  final StoryRatingRepository _repository;

  const GetStoryRatingsUsecase(this._repository);

  Future<StoryRatingsEntity> call({required String storyId}) {
    return _repository.getStoryRatings(storyId: storyId);
  }
}

class SubmitStoryRatingUsecase {
  final StoryRatingRepository _repository;

  const SubmitStoryRatingUsecase(this._repository);

  Future<void> call({
    required String storyId,
    required int score,
    required String content,
  }) {
    return _repository.submitStoryRating(
      storyId: storyId,
      score: score,
      content: content,
    );
  }
}
