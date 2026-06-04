import 'package:dio/dio.dart';
import 'package:ink_trail_client/core/network/api_exception.dart';
import 'package:ink_trail_client/features/home/data/models/home_banner_story_model.dart';
import 'package:ink_trail_client/features/home/data/models/home_story_page_model.dart';
import 'package:ink_trail_client/features/home/data/models/home_story_summary_model.dart';

abstract class HomeRemoteDatasource {
  Future<List<HomeBannerStoryModel>> getHomeBanners();
  Future<List<HomeStorySummaryModel>> getHotStories({int limit = 20});
  Future<HomeStoryPageModel> getHotStoriesPage({int page = 1, int limit = 20});
  Future<List<HomeStorySummaryModel>> getMonthlyRankingStories({int limit = 20});
  Future<List<HomeStorySummaryModel>> getNewStories({int limit = 20});
  Future<HomeStoryPageModel> getNewStoriesPage({int page = 1, int limit = 20});
  Future<List<String>> getTagNames();
}

class HomeRemoteDatasourceImpl implements HomeRemoteDatasource {
  final Dio _dio;

  const HomeRemoteDatasourceImpl(this._dio);

  @override
  Future<List<HomeBannerStoryModel>> getHomeBanners() async {
    try {
      final response = await _dio.get('/home/banners');
      final data = response.data as List<dynamic>? ?? const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(HomeBannerStoryModel.fromJson)
          .where((item) => item.id.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<HomeStorySummaryModel>> getHotStories({int limit = 20}) async {
    final page = await getHotStoriesPage(limit: limit);
    return page.items.cast<HomeStorySummaryModel>();
  }

  @override
  Future<HomeStoryPageModel> getHotStoriesPage({int page = 1, int limit = 20}) {
    return _getStoryPage('/home/stories/hot', page: page, limit: limit);
  }

  @override
  Future<List<HomeStorySummaryModel>> getMonthlyRankingStories({
    int limit = 20,
  }) async {
    return _getStoryList('/home/stories/monthly-ranking', limit: limit);
  }

  @override
  Future<List<HomeStorySummaryModel>> getNewStories({int limit = 20}) async {
    final page = await getNewStoriesPage(limit: limit);
    return page.items.cast<HomeStorySummaryModel>();
  }

  @override
  Future<HomeStoryPageModel> getNewStoriesPage({int page = 1, int limit = 20}) {
    return _getStoryPage('/home/stories/new', page: page, limit: limit);
  }

  @override
  Future<List<String>> getTagNames() async {
    try {
      final response = await _dio.get('/tags');
      final data = response.data as List<dynamic>? ?? const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => (json['name'] as String? ?? '').trim())
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<HomeStorySummaryModel>> _getStoryList(
    String path, {
    required int limit,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: {'limit': limit},
      );
      final data = response.data as List<dynamic>? ?? const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(HomeStorySummaryModel.fromJson)
          .where((item) => item.id.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<HomeStoryPageModel> _getStoryPage(
    String path, {
    required int page,
    required int limit,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: {'page': page, 'limit': limit},
      );
      final payload = response.data;
      if (payload is List<dynamic>) {
        final items = payload
            .whereType<Map<String, dynamic>>()
            .map(HomeStorySummaryModel.fromJson)
            .where((item) => item.id.isNotEmpty)
            .toList();
        return HomeStoryPageModel(
          items: items,
          page: page,
          limit: limit,
          hasMore: false,
          nextPage: null,
        );
      }
      final json = payload as Map<String, dynamic>? ?? const {};
      return HomeStoryPageModel.fromJson(json);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
