import 'package:ink_trail_client/features/library/data/resources/library_remote_datasource.dart';
import 'package:ink_trail_client/features/library/domain/entities/library_remote_progress_entity.dart';
import 'package:ink_trail_client/features/library/domain/repositories/library_repository.dart';

class LibraryRepoImpl implements LibraryRepository {
  final LibraryRemoteDatasource _datasource;

  const LibraryRepoImpl(this._datasource);

  @override
  Future<List<LibraryRemoteProgressEntity>> getRemoteReadingHistory({
    int limit = 100,
  }) {
    return _datasource.getRemoteReadingHistory(limit: limit);
  }

  @override
  Future<void> saveRemoteReadingProgress({
    required String storyId,
    required int chapterIndex,
    required int? lastPosition,
  }) {
    return _datasource.saveRemoteReadingProgress(
      storyId: storyId,
      chapterIndex: chapterIndex,
      lastPosition: lastPosition,
    );
  }
}
