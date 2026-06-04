import 'package:ink_trail_client/features/story_detail/domain/repositories/story_detail_repository.dart';

class ReportStoryUsecase {
  final StoryDetailRepository _repository;

  const ReportStoryUsecase(this._repository);

  Future<void> call({
    required String storyId,
    required String reason,
    required String description,
  }) =>
      _repository.reportStory(
        storyId: storyId,
        reason: reason,
        description: description,
      );
}
