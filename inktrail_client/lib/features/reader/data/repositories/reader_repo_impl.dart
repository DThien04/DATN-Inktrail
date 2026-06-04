import 'package:ink_trail_client/features/reader/data/resources/reader_remote_datasource.dart';
import 'package:ink_trail_client/features/reader/domain/entities/reader_comment_entity.dart';
import 'package:ink_trail_client/features/reader/domain/repositories/reader_repository.dart';

class ReaderRepoImpl implements ReaderRepository {
  final ReaderRemoteDatasource _datasource;

  const ReaderRepoImpl(this._datasource);

  @override
  String? get socketBaseUrl => _datasource.socketBaseUrl;

  @override
  Future<void> trackReadEvent({
    required String storyId,
    required int chapterIndex,
    required int timeSpentSeconds,
    required int maxScrollPercent,
    required String deviceId,
  }) {
    return _datasource.trackReadEvent(
      storyId: storyId,
      chapterIndex: chapterIndex,
      timeSpentSeconds: timeSpentSeconds,
      maxScrollPercent: maxScrollPercent,
      deviceId: deviceId,
    );
  }

  @override
  Future<ReaderLikeResultEntity> setChapterLike({
    required String chapterId,
    required bool liked,
    required int fallbackLikeCount,
  }) {
    return _datasource.setChapterLike(
      chapterId: chapterId,
      liked: liked,
      fallbackLikeCount: fallbackLikeCount,
    );
  }

  @override
  Future<void> reportChapter({
    required String chapterId,
    required String reason,
    required String description,
  }) {
    return _datasource.reportChapter(
      chapterId: chapterId,
      reason: reason,
      description: description,
    );
  }

  @override
  Future<ReaderCommentEntity?> getFeaturedChapterComment({
    required String chapterId,
  }) {
    return _datasource.getFeaturedChapterComment(chapterId: chapterId);
  }

  @override
  Future<ReaderCommentsEntity> getChapterComments({
    required String chapterId,
    int limit = 50,
  }) {
    return _datasource.getChapterComments(chapterId: chapterId, limit: limit);
  }

  @override
  Future<ReaderLikeResultEntity> setChapterCommentLike({
    required String commentId,
    required bool liked,
    required int fallbackLikeCount,
  }) {
    return _datasource.setChapterCommentLike(
      commentId: commentId,
      liked: liked,
      fallbackLikeCount: fallbackLikeCount,
    );
  }

  @override
  Future<ReaderCommentEntity?> createChapterComment({
    required String chapterId,
    required String content,
  }) {
    return _datasource.createChapterComment(
      chapterId: chapterId,
      content: content,
    );
  }

  @override
  Future<ReaderCommentEntity?> updateChapterComment({
    required String commentId,
    required String content,
  }) {
    return _datasource.updateChapterComment(
      commentId: commentId,
      content: content,
    );
  }

  @override
  Future<void> reportChapterComment({
    required String commentId,
    required String reason,
    required String description,
  }) {
    return _datasource.reportChapterComment(
      commentId: commentId,
      reason: reason,
      description: description,
    );
  }

  @override
  Future<void> deleteChapterComment({required String commentId}) {
    return _datasource.deleteChapterComment(commentId: commentId);
  }
}
