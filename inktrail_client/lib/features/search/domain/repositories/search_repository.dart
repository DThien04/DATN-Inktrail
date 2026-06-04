import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';
import 'package:ink_trail_client/features/search/domain/entities/tag_filter_entity.dart';

abstract class SearchRepository {
  Future<List<TagFilterEntity>> getTagFilters();

  Future<List<StoryEntity>> searchStories({
    required String query,
    required String? tagId,
    required String sort,
    int limit = 20,
  });
}
