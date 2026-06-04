import 'package:ink_trail_client/core/entities/tag_filter_entity.dart';

abstract class TagsRepository {
  Future<List<TagFilterEntity>> getTagFilters();
}

