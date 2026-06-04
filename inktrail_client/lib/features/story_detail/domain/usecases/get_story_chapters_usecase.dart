import 'package:ink_trail_client/features/story_detail/domain/entities/story_detail_chapter_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/repositories/story_detail_repository.dart';

class GetStoryChaptersUsecase {
  final StoryDetailRepository _repository;

  const GetStoryChaptersUsecase(this._repository);

  Future<List<StoryDetailChapterEntity>> call({required String storyId}) =>
      _repository.getChapters(storyId: storyId);
}
