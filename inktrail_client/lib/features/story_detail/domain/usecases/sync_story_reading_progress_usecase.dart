import 'package:ink_trail_client/features/story_detail/domain/entities/remote_reading_progress_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/repositories/story_detail_repository.dart';

class SyncStoryReadingProgressUsecase {
  final StoryDetailRepository _repository;

  const SyncStoryReadingProgressUsecase(this._repository);

  Future<RemoteReadingProgressEntity?> getRemote({required String storyId}) =>
      _repository.getRemoteReadingProgress(storyId: storyId);

  Future<void> saveRemote({
    required String storyId,
    required int chapterIndex,
    required int? lastPosition,
  }) =>
      _repository.saveRemoteReadingProgress(
        storyId: storyId,
        chapterIndex: chapterIndex,
        lastPosition: lastPosition,
      );
}
