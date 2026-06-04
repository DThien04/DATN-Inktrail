import 'package:dio/dio.dart';
import 'package:ink_trail_client/core/network/api_exception.dart';
import 'package:ink_trail_client/features/story_detail/data/models/highlighted_chapter_comment_model.dart';
import 'package:ink_trail_client/features/story_detail/data/models/remote_reading_progress_model.dart';
import 'package:ink_trail_client/features/story_detail/data/models/story_detail_chapter_model.dart';
import 'package:ink_trail_client/features/story_detail/data/models/story_detail_info_model.dart';
import 'package:ink_trail_client/features/story_detail/data/models/story_rating_review_model.dart';
import 'package:ink_trail_client/features/story_detail/data/models/story_suggestion_model.dart';

abstract class StoryDetailRemoteDatasource {
  Future<StoryDetailInfoModel> getStoryDetail({required String slug});

  Future<List<StoryDetailChapterModel>> getChapters({
    required String storyId,
  });

  Future<RemoteReadingProgressModel?> getRemoteReadingProgress({
    required String storyId,
  });

  Future<void> saveRemoteReadingProgress({
    required String storyId,
    required int chapterIndex,
    required int? lastPosition,
  });

  Future<StoryRatingsModel> getStoryRatings({
    required String storyId,
  });

  Future<void> submitStoryRating({
    required String storyId,
    required int score,
    required String content,
  });

  Future<List<HighlightedChapterCommentModel>> getHighlightedComments({
    required String storyId,
  });

  Future<List<StorySuggestionModel>> getSimilarStories({
    required String storyId,
    int limit = 10,
  });

  Future<List<StorySuggestionModel>> getRecommendedStories({
    required String storyId,
    int limit = 12,
  });

  Future<void> reportStory({
    required String storyId,
    required String reason,
    required String description,
  });
}

class StoryDetailRemoteDatasourceImpl implements StoryDetailRemoteDatasource {
  final Dio _dio;

  const StoryDetailRemoteDatasourceImpl(this._dio);

  @override
  Future<StoryDetailInfoModel> getStoryDetail({required String slug}) async {
    try {
      final response = await _dio.get('/stories/$slug');
      final json = response.data as Map<String, dynamic>? ?? const {};
      return StoryDetailInfoModel.fromJson(json);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<StoryDetailChapterModel>> getChapters({
    required String storyId,
  }) async {
    try {
      final response = await _dio.get('/chapters/stories/$storyId/chapters');
      final rows = response.data as List<dynamic>? ?? const [];
      return rows
          .whereType<Map<String, dynamic>>()
          .map(StoryDetailChapterModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<RemoteReadingProgressModel?> getRemoteReadingProgress({
    required String storyId,
  }) async {
    try {
      final response = await _dio.get('/profile/me/reading-progress/$storyId');
      final json = response.data as Map<String, dynamic>?;
      if (json == null) return null;
      return RemoteReadingProgressModel.fromJson(json);
    } on FormatException {
      return null;
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
          'last_position': lastPosition?.clamp(0, 100),
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<StoryRatingsModel> getStoryRatings({
    required String storyId,
  }) async {
    try {
      final response = await _dio.get('/stories/$storyId/ratings');
      final json = response.data as Map<String, dynamic>? ?? const {};
      return StoryRatingsModel.fromJson(json);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> submitStoryRating({
    required String storyId,
    required int score,
    required String content,
  }) async {
    try {
      await _dio.put(
        '/stories/$storyId/rating',
        data: {'rating': score.clamp(1, 5), 'content': content},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<HighlightedChapterCommentModel>> getHighlightedComments({
    required String storyId,
  }) async {
    try {
      final response = await _dio.get('/stories/$storyId/comments/featured');
      final data = response.data as Map<String, dynamic>? ?? const {};
      final rawItems = data['items'] as List<dynamic>? ?? const [];
      return rawItems
          .whereType<Map<String, dynamic>>()
          .map(HighlightedChapterCommentModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<StorySuggestionModel>> getSimilarStories({
    required String storyId,
    int limit = 10,
  }) {
    return _getSuggestions('/stories/$storyId/similar', limit: limit);
  }

  @override
  Future<List<StorySuggestionModel>> getRecommendedStories({
    required String storyId,
    int limit = 12,
  }) {
    return _getSuggestions('/stories/$storyId/recommended', limit: limit);
  }

  @override
  Future<void> reportStory({
    required String storyId,
    required String reason,
    required String description,
  }) async {
    try {
      await _dio.post(
        '/reports/stories/$storyId',
        data: <String, dynamic>{
          'reason': reason,
          if (description.isNotEmpty) 'description': description,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<StorySuggestionModel>> _getSuggestions(
    String path, {
    required int limit,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: {'limit': limit},
      );
      final rows = response.data as List<dynamic>? ?? const [];
      return rows
          .whereType<Map<String, dynamic>>()
          .map(StorySuggestionModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
