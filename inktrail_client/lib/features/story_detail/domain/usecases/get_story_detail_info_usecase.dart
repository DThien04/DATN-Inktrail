import 'package:ink_trail_client/features/story_detail/domain/entities/story_detail_info_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/repositories/story_detail_repository.dart';

class GetStoryDetailInfoUsecase {
  final StoryDetailRepository _repository;

  const GetStoryDetailInfoUsecase(this._repository);

  Future<StoryDetailInfoEntity> call({required String slug}) =>
      _repository.getStoryDetail(slug: slug);
}
