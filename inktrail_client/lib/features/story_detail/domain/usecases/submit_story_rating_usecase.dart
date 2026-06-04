import 'package:ink_trail_client/features/story_detail/domain/repositories/story_detail_repository.dart';

class SubmitStoryRatingUsecase {
  final StoryDetailRepository _repository;

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
