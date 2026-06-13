import 'package:dio/dio.dart';
import 'package:ink_trail_client/core/network/api_exception.dart';
import 'package:ink_trail_client/core/network/socket_base_url.dart';
import 'package:ink_trail_client/features/reader/data/models/reader_comment_model.dart';

abstract class ReaderRemoteDatasource {
  String? get socketBaseUrl;

  Future<void> trackReadEvent({
    required String storyId,
    required int chapterIndex,
    required int timeSpentSeconds,
    required int maxScrollPercent,
    required String deviceId,
  });

  Future<ReaderLikeResultModel> setChapterLike({
    required String chapterId,
    required bool liked,
    required int fallbackLikeCount,
  });

  Future<void> reportChapter({
    required String chapterId,
    required String reason,
    required String description,
  });

  Future<ReaderCommentModel?> getFeaturedChapterComment({
    required String chapterId,
  });

  Future<ReaderCommentsModel> getChapterComments({
    required String chapterId,
    int limit = 50,
  });

  Future<ReaderLikeResultModel> setChapterCommentLike({
    required String commentId,
    required bool liked,
    required int fallbackLikeCount,
  });

  Future<ReaderCommentModel?> createChapterComment({
    required String chapterId,
    required String content,
    String? parentId,
  });

  Future<ReaderCommentModel?> updateChapterComment({
    required String commentId,
    required String content,
  });

  Future<void> reportChapterComment({
    required String commentId,
    required String reason,
    required String description,
  });

  Future<void> deleteChapterComment({
    required String commentId,
  });
}

class ReaderRemoteDatasourceImpl implements ReaderRemoteDatasource {
  final Dio _dio;

  const ReaderRemoteDatasourceImpl(this._dio);

  @override
  String? get socketBaseUrl => socketBaseUrlFromApiBase(_dio.options.baseUrl);

  @override
  Future<void> trackReadEvent({
    required String storyId,
    required int chapterIndex,
    required int timeSpentSeconds,
    required int maxScrollPercent,
    required String deviceId,
  }) async {
    try {
      await _dio.post(
        '/stories/$storyId/read-event',
        data: {
          'chapter_index': chapterIndex,
          'time_spent_seconds': timeSpentSeconds,
          'max_scroll_percent': maxScrollPercent,
        },
        options: Options(headers: {'x-device-id': deviceId}),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<ReaderLikeResultModel> setChapterLike({
    required String chapterId,
    required bool liked,
    required int fallbackLikeCount,
  }) async {
    try {
      final response = liked
          ? await _dio.post('/chapters/$chapterId/like')
          : await _dio.delete('/chapters/$chapterId/like');
      final json = response.data as Map<String, dynamic>? ?? const {};
      return ReaderLikeResultModel.fromJson(
        json,
        fallbackLiked: liked,
        fallbackLikeCount: fallbackLikeCount,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> reportChapter({
    required String chapterId,
    required String reason,
    required String description,
  }) async {
    try {
      await _dio.post(
        '/reports/chapters/$chapterId',
        data: <String, dynamic>{
          'reason': reason,
          'description': description,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<ReaderCommentModel?> getFeaturedChapterComment({
    required String chapterId,
  }) async {
    try {
      final response = await _dio.get('/chapters/$chapterId/comments/featured');
      final data = response.data as Map<String, dynamic>? ?? const {};
      return ReaderCommentModel.tryFromJson(data['item']);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<ReaderCommentsModel> getChapterComments({
    required String chapterId,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/chapters/$chapterId/comments',
        queryParameters: <String, dynamic>{'limit': limit},
      );
      final data = response.data as Map<String, dynamic>? ?? const {};
      return ReaderCommentsModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<ReaderLikeResultModel> setChapterCommentLike({
    required String commentId,
    required bool liked,
    required int fallbackLikeCount,
  }) async {
    try {
      final response = liked
          ? await _dio.post('/chapters/comments/$commentId/like')
          : await _dio.delete('/chapters/comments/$commentId/like');
      final data = response.data as Map<String, dynamic>? ?? const {};
      return ReaderLikeResultModel.fromJson(
        data,
        fallbackLiked: liked,
        fallbackLikeCount: fallbackLikeCount,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<ReaderCommentModel?> createChapterComment({
    required String chapterId,
    required String content,
    String? parentId,
  }) async {
    try {
      final response = await _dio.post(
        '/chapters/$chapterId/comments',
        data: <String, dynamic>{
          'content': content,
          if (parentId != null && parentId.isNotEmpty) 'parent_id': parentId,
        },
      );
      final data = response.data as Map<String, dynamic>? ?? const {};
      return ReaderCommentModel.tryFromJson(data['comment']);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<ReaderCommentModel?> updateChapterComment({
    required String commentId,
    required String content,
  }) async {
    try {
      final response = await _dio.patch(
        '/chapters/comments/$commentId',
        data: <String, dynamic>{'content': content},
      );
      final data = response.data as Map<String, dynamic>? ?? const {};
      return ReaderCommentModel.tryFromJson(data['comment']);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> reportChapterComment({
    required String commentId,
    required String reason,
    required String description,
  }) async {
    try {
      await _dio.post(
        '/reports/chapter-comments/$commentId',
        data: <String, dynamic>{
          'reason': reason,
          if (description.isNotEmpty) 'description': description,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteChapterComment({required String commentId}) async {
    try {
      await _dio.delete('/chapters/comments/$commentId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
