import 'package:dio/dio.dart';
import 'package:ink_trail_client/core/network/api_exception.dart';
import 'package:ink_trail_client/features/chapter_management/data/models/my_story_chapter_model.dart';

abstract class ChapterManagementRemoteDatasource {
  Future<List<MyStoryChapterModel>> getMyStoryChapters({required String storyId});

  Future<MyStoryChapterModel> createMyStoryChapter({
    required String storyId,
    required int chapterNumber,
    required String title,
    required String content,
  });

  Future<MyStoryChapterModel> updateMyStoryChapter({
    required String chapterId,
    required int chapterNumber,
    required String title,
    required String content,
  });

  Future<MyStoryChapterModel> publishMyStoryChapter({required String chapterId});

  Future<MyStoryChapterModel> unpublishMyStoryChapter({
    required String chapterId,
  });

  Future<void> deleteMyStoryChapter({required String chapterId});
}

class ChapterManagementRemoteDatasourceImpl
    implements ChapterManagementRemoteDatasource {
  final Dio _dio;

  const ChapterManagementRemoteDatasourceImpl(this._dio);

  @override
  Future<List<MyStoryChapterModel>> getMyStoryChapters({
    required String storyId,
  }) async {
    try {
      final response = await _dio.get('/chapters/stories/$storyId/chapters');
      final rows = response.data as List<dynamic>? ?? const [];
      return rows
          .whereType<Map<String, dynamic>>()
          .map(MyStoryChapterModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<MyStoryChapterModel> createMyStoryChapter({
    required String storyId,
    required int chapterNumber,
    required String title,
    required String content,
  }) async {
    try {
      final response = await _dio.post(
        '/chapters/stories/$storyId/chapters',
        data: {
          'chapter_number': chapterNumber,
          'title': title,
          'content': content,
        },
      );
      final chapterJson = response.data['chapter'] as Map<String, dynamic>;
      return MyStoryChapterModel.fromJson(chapterJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<MyStoryChapterModel> updateMyStoryChapter({
    required String chapterId,
    required int chapterNumber,
    required String title,
    required String content,
  }) async {
    try {
      final response = await _dio.patch(
        '/chapters/$chapterId',
        data: {
          'chapter_number': chapterNumber,
          'title': title,
          'content': content,
        },
      );
      final chapterJson = response.data['chapter'] as Map<String, dynamic>;
      return MyStoryChapterModel.fromJson(chapterJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<MyStoryChapterModel> publishMyStoryChapter({
    required String chapterId,
  }) async {
    try {
      final response = await _dio.post('/chapters/$chapterId/publish');
      final chapterJson = response.data['chapter'] as Map<String, dynamic>;
      return MyStoryChapterModel.fromJson(chapterJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<MyStoryChapterModel> unpublishMyStoryChapter({
    required String chapterId,
  }) async {
    try {
      final response = await _dio.post('/chapters/$chapterId/unpublish');
      final chapterJson = response.data['chapter'] as Map<String, dynamic>;
      return MyStoryChapterModel.fromJson(chapterJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteMyStoryChapter({required String chapterId}) async {
    try {
      await _dio.delete('/chapters/$chapterId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
