import 'package:ink_trail_client/features/story_detail/domain/entities/highlighted_chapter_comment_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/repositories/story_detail_repository.dart';

class GetHighlightedCommentsUsecase {
  final StoryDetailRepository _repository;

  const GetHighlightedCommentsUsecase(this._repository);

  Future<List<HighlightedChapterCommentEntity>> call({
    required String storyId,
  }) =>
      _repository.getHighlightedComments(storyId: storyId);
}
