import 'package:ink_trail_client/features/home/domain/entities/home_story_page_entity.dart';
import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';
import 'package:ink_trail_client/features/home/domain/repositories/home_repository.dart';

class GetNewStoriesUsecase {
  final HomeRepository _repository;

  const GetNewStoriesUsecase(this._repository);

  Future<List<StoryEntity>> call({int limit = 6}) {
    return _repository.getNewStories(limit: limit);
  }

  Future<HomeStoryPageEntity> page({int page = 1, int limit = 6}) {
    return _repository.getNewStoriesPage(page: page, limit: limit);
  }
}
