import 'package:ink_trail_client/core/entities/tag_filter_entity.dart';
import 'package:ink_trail_client/features/search/domain/repositories/search_repository.dart';
import 'package:ink_trail_client/features/tags/domain/repositories/tags_repository.dart';

class TagsRepoImpl implements TagsRepository {
  final SearchRepository _searchRepository;

  const TagsRepoImpl(this._searchRepository);

  @override
  Future<List<TagFilterEntity>> getTagFilters() => _searchRepository.getTagFilters();
}

