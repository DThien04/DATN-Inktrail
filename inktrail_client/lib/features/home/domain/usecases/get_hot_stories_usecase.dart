import 'package:ink_trail_client/features/home/domain/entities/home_story_page_entity.dart';
import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';
import 'package:ink_trail_client/features/home/domain/repositories/home_repository.dart';

class GetHotStoriesUsecase {
  final HomeRepository _repository;

  const GetHotStoriesUsecase(this._repository);

  Future<List<StoryEntity>> call({int limit = 6}) {
    return _repository.getHotStories(limit: limit);
  }

  Future<HomeStoryPageEntity> page({int page = 1, int limit = 6}) {
    return _repository.getHotStoriesPage(page: page, limit: limit);
  }
}
