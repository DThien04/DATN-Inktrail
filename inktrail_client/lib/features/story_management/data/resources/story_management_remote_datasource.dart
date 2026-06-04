import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:ink_trail_client/core/network/api_exception.dart';
import 'package:ink_trail_client/features/story_management/data/models/my_story_model.dart';

abstract class StoryManagementRemoteDatasource {
  Future<List<MyStoryModel>> getMyStories({String? status});

  Future<MyStoryModel> createMyStory({
    required String title,
    required String description,
    required String status,
    List<String> tags = const [],
    List<int>? coverBytes,
    String? fileName,
    String? mimeType,
  });

  Future<MyStoryModel> updateMyStory({
    required String storyId,
    required String title,
    required String description,
    required String status,
    List<String> tags = const [],
    List<int>? coverBytes,
    String? fileName,
    String? mimeType,
  });

  Future<MyStoryModel> updateMyStoryStatus({
    required String storyId,
    required String status,
  });

  Future<void> deleteMyStory({required String storyId});
}

class StoryManagementRemoteDatasourceImpl
    implements StoryManagementRemoteDatasource {
  final Dio _dio;

  const StoryManagementRemoteDatasourceImpl(this._dio);

  @override
  Future<List<MyStoryModel>> getMyStories({String? status}) async {
    try {
      final response = await _dio.get(
        '/stories/me/list',
        queryParameters: status == null ? null : {'status': status},
      );
      final rows = response.data as List<dynamic>? ?? const [];
      return rows
          .whereType<Map<String, dynamic>>()
          .map(MyStoryModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<MyStoryModel> createMyStory({
    required String title,
    required String description,
    required String status,
    List<String> tags = const [],
    List<int>? coverBytes,
    String? fileName,
    String? mimeType,
  }) async {
    try {
      final requestData =
          (coverBytes != null && fileName != null && mimeType != null)
          ? FormData.fromMap({
              'title': title,
              'description': description,
              'status': status,
              'tag_names': jsonEncode(tags),
              'cover_file': MultipartFile.fromBytes(
                coverBytes,
                filename: fileName,
                contentType: MediaType.parse(mimeType),
              ),
            })
          : {
              'title': title,
              'description': description,
              'status': status,
              'tag_names': tags,
            };
      final response = await _dio.post('/stories', data: requestData);
      final storyJson = response.data['story'] as Map<String, dynamic>;
      return MyStoryModel.fromJson(storyJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<MyStoryModel> updateMyStory({
    required String storyId,
    required String title,
    required String description,
    required String status,
    List<String> tags = const [],
    List<int>? coverBytes,
    String? fileName,
    String? mimeType,
  }) async {
    try {
      final requestData =
          (coverBytes != null && fileName != null && mimeType != null)
          ? FormData.fromMap({
              'title': title,
              'description': description,
              'status': status,
              'tag_names': jsonEncode(tags),
              'cover_file': MultipartFile.fromBytes(
                coverBytes,
                filename: fileName,
                contentType: MediaType.parse(mimeType),
              ),
            })
          : {
              'title': title,
              'description': description,
              'status': status,
              'tag_names': tags,
            };
      final response = await _dio.patch('/stories/$storyId', data: requestData);
      final storyJson = response.data['story'] as Map<String, dynamic>;
      return MyStoryModel.fromJson(storyJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<MyStoryModel> updateMyStoryStatus({
    required String storyId,
    required String status,
  }) async {
    try {
      final response = await _dio.patch(
        '/stories/$storyId/status',
        data: {'status': status},
      );
      final storyJson = response.data['story'] as Map<String, dynamic>;
      return MyStoryModel.fromJson(storyJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteMyStory({required String storyId}) async {
    try {
      await _dio.delete('/stories/$storyId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
