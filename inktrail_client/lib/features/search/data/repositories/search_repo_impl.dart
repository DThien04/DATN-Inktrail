import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';
import 'package:ink_trail_client/features/search/data/resources/search_remote_datasource.dart';
import 'package:ink_trail_client/features/search/domain/entities/tag_filter_entity.dart';
import 'package:ink_trail_client/features/search/domain/repositories/search_repository.dart';

class SearchRepoImpl implements SearchRepository {
  final SearchRemoteDatasource _datasource;

  const SearchRepoImpl(this._datasource);

  @override
  Future<List<TagFilterEntity>> getTagFilters() => _datasource.getTagFilters();

  @override
  Future<List<StoryEntity>> searchStories({
    required String query,
    required String? tagId,
    required String sort,
    int limit = 20,
  }) =>
      _datasource.searchStories(
        query: query,
        tagId: tagId,
        sort: sort,
        limit: limit,
      );
}
