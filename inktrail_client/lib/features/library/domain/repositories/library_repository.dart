import 'package:ink_trail_client/features/library/domain/entities/library_remote_progress_entity.dart';

abstract class LibraryRepository {
  Future<List<LibraryRemoteProgressEntity>> getRemoteReadingHistory({
    int limit = 100,
  });

  Future<void> saveRemoteReadingProgress({
    required String storyId,
    required int chapterIndex,
    required int? lastPosition,
  });
}
