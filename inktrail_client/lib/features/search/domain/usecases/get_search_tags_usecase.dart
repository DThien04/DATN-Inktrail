import 'package:ink_trail_client/features/search/domain/entities/tag_filter_entity.dart';
import 'package:ink_trail_client/features/search/domain/repositories/search_repository.dart';

class GetSearchTagsUsecase {
  final SearchRepository _repository;

  const GetSearchTagsUsecase(this._repository);

  Future<List<TagFilterEntity>> call() => _repository.getTagFilters();
}
