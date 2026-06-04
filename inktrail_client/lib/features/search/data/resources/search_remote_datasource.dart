import 'package:dio/dio.dart';
import 'package:ink_trail_client/core/network/api_exception.dart';
import 'package:ink_trail_client/features/search/data/models/search_story_model.dart';
import 'package:ink_trail_client/features/search/data/models/tag_filter_model.dart';

abstract class SearchRemoteDatasource {
  Future<List<TagFilterModel>> getTagFilters();

  Future<List<SearchStoryModel>> searchStories({
    required String query,
    required String? tagId,
    required String sort,
    int limit = 20,
  });
}

class SearchRemoteDatasourceImpl implements SearchRemoteDatasource {
  final Dio _dio;

  const SearchRemoteDatasourceImpl(this._dio);

  @override
  Future<List<TagFilterModel>> getTagFilters() async {
    try {
      final response = await _dio.get('/tags');
      final rows = response.data as List<dynamic>? ?? const [];
      return rows
          .whereType<Map<String, dynamic>>()
          .map(TagFilterModel.fromJson)
          .where((item) => item.id.isNotEmpty && item.name.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<SearchStoryModel>> searchStories({
    required String query,
    required String? tagId,
    required String sort,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/stories/search',
        queryParameters: {
          'query': query.isEmpty ? null : query,
          'tag_id': tagId,
          'sort': sort,
          'limit': limit,
        },
      );
      final rows = response.data as List<dynamic>? ?? const [];
      return rows
          .whereType<Map<String, dynamic>>()
          .map(SearchStoryModel.fromJson)
          .where((story) => story.id.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
