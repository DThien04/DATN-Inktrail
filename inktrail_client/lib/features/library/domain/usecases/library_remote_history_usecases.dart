import 'package:ink_trail_client/features/library/domain/entities/library_remote_progress_entity.dart';
import 'package:ink_trail_client/features/library/domain/repositories/library_repository.dart';

class GetLibraryRemoteHistoryUsecase {
  final LibraryRepository _repository;

  const GetLibraryRemoteHistoryUsecase(this._repository);

  Future<List<LibraryRemoteProgressEntity>> call({int limit = 100}) {
    return _repository.getRemoteReadingHistory(limit: limit);
  }
}

class SaveLibraryRemoteProgressUsecase {
  final LibraryRepository _repository;

  const SaveLibraryRemoteProgressUsecase(this._repository);

  Future<void> call({
    required String storyId,
    required int chapterIndex,
    required int? lastPosition,
  }) {
    return _repository.saveRemoteReadingProgress(
      storyId: storyId,
      chapterIndex: chapterIndex,
      lastPosition: lastPosition,
    );
  }
}
