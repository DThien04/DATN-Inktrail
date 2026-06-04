import 'package:dio/dio.dart';
import 'package:ink_trail_client/core/network/api_exception.dart';

abstract class ReportRemoteDatasource {
  Future<void> reportStory({
    required String storyId,
    required String reason,
    required String description,
  });

  Future<void> reportChapter({
    required String chapterId,
    required String reason,
    required String description,
  });

  Future<void> reportChapterComment({
    required String commentId,
    required String reason,
    required String description,
  });

  Future<void> submitReportAppeal({
    required String caseId,
    required String reason,
  });
}

class ReportRemoteDatasourceImpl implements ReportRemoteDatasource {
  final Dio _dio;

  const ReportRemoteDatasourceImpl(this._dio);

  @override
  Future<void> reportStory({
    required String storyId,
    required String reason,
    required String description,
  }) async {
    try {
      await _dio.post(
        '/reports/stories/$storyId',
        data: {
          'reason': reason,
          'description': description,
        },
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
        data: {
          'reason': reason,
          'description': description,
        },
      );
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
        data: {
          'reason': reason,
          'description': description,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> submitReportAppeal({
    required String caseId,
    required String reason,
  }) async {
    try {
      await _dio.post(
        '/reports/cases/$caseId/appeal',
        data: {'reason': reason},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

