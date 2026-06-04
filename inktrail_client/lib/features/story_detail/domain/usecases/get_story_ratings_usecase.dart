import 'package:ink_trail_client/features/story_detail/domain/entities/story_rating_review_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/repositories/story_detail_repository.dart';

class GetStoryRatingsUsecase {
  final StoryDetailRepository _repository;

  const GetStoryRatingsUsecase(this._repository);

  Future<StoryRatingsEntity> call({required String storyId}) {
    return _repository.getStoryRatings(storyId: storyId);
  }
}
