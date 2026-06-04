import 'package:dio/dio.dart';
import 'package:ink_trail_client/core/network/api_exception.dart';
import 'package:ink_trail_client/features/library/data/models/library_remote_progress_model.dart';

abstract class LibraryRemoteDatasource {
  Future<List<LibraryRemoteProgressModel>> getRemoteReadingHistory({
    int limit = 100,
  });

  Future<void> saveRemoteReadingProgress({
    required String storyId,
    required int chapterIndex,
    required int? lastPosition,
  });
}

class LibraryRemoteDatasourceImpl implements LibraryRemoteDatasource {
  final Dio _dio;

  const LibraryRemoteDatasourceImpl(this._dio);

  @override
  Future<List<LibraryRemoteProgressModel>> getRemoteReadingHistory({
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        '/profile/me/reading-progress',
        queryParameters: <String, dynamic>{'limit': limit},
      );
      final rows = response.data as List<dynamic>? ?? const [];
      return rows
          .whereType<Map<String, dynamic>>()
          .map(LibraryRemoteProgressModel.fromJson)
          .where((item) => item.storyId.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> saveRemoteReadingProgress({
    required String storyId,
    required int chapterIndex,
    required int? lastPosition,
  }) async {
    try {
      await _dio.put(
        '/profile/me/reading-progress/$storyId',
        data: {
          'last_chapter_index': chapterIndex,
          'last_position': lastPosition?.clamp(0, 100).toInt(),
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
