import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';
import 'package:ink_trail_client/features/search/domain/repositories/search_repository.dart';

class SearchStoriesUsecase {
  final SearchRepository _repository;

  const SearchStoriesUsecase(this._repository);

  Future<List<StoryEntity>> call({
    required String query,
    required String? tagId,
    required String sort,
    int limit = 20,
  }) =>
      _repository.searchStories(
        query: query,
        tagId: tagId,
        sort: sort,
        limit: limit,
      );
}
