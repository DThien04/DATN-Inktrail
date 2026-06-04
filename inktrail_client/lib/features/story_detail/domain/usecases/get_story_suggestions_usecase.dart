import 'package:ink_trail_client/features/story_detail/domain/entities/story_suggestion_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/repositories/story_detail_repository.dart';

class GetStorySuggestionsUsecase {
  final StoryDetailRepository _repository;

  const GetStorySuggestionsUsecase(this._repository);

  Future<List<StorySuggestionEntity>> similar({
    required String storyId,
    int limit = 10,
  }) =>
      _repository.getSimilarStories(storyId: storyId, limit: limit);

  Future<List<StorySuggestionEntity>> recommended({
    required String storyId,
    int limit = 12,
  }) =>
      _repository.getRecommendedStories(storyId: storyId, limit: limit);
}
