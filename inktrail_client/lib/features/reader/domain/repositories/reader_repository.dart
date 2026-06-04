import 'package:ink_trail_client/features/reader/domain/entities/reader_comment_entity.dart';

abstract class ReaderRepository {
  String? get socketBaseUrl;

  Future<void> trackReadEvent({
    required String storyId,
    required int chapterIndex,
    required int timeSpentSeconds,
    required int maxScrollPercent,
    required String deviceId,
  });

  Future<ReaderLikeResultEntity> setChapterLike({
    required String chapterId,
    required bool liked,
    required int fallbackLikeCount,
  });

  Future<void> reportChapter({
    required String chapterId,
    required String reason,
    required String description,
  });

  Future<ReaderCommentEntity?> getFeaturedChapterComment({
    required String chapterId,
  });

  Future<ReaderCommentsEntity> getChapterComments({
    required String chapterId,
    int limit = 50,
  });

  Future<ReaderLikeResultEntity> setChapterCommentLike({
    required String commentId,
    required bool liked,
    required int fallbackLikeCount,
  });

  Future<ReaderCommentEntity?> createChapterComment({
    required String chapterId,
    required String content,
  });

  Future<ReaderCommentEntity?> updateChapterComment({
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
