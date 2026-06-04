import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';
import 'package:ink_trail_client/features/home/domain/repositories/home_repository.dart';

class GetMonthlyRankingStoriesUsecase {
  final HomeRepository _repository;

  const GetMonthlyRankingStoriesUsecase(this._repository);

  Future<List<StoryEntity>> call({int limit = 9}) {
    return _repository.getMonthlyRankingStories(limit: limit);
  }
}
