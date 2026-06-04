import 'package:ink_trail_client/core/entities/tag_filter_entity.dart';
import 'package:ink_trail_client/features/tags/domain/repositories/tags_repository.dart';

class GetTagsUsecase {
  final TagsRepository _repository;

  const GetTagsUsecase(this._repository);

  Future<List<TagFilterEntity>> call() => _repository.getTagFilters();
}

