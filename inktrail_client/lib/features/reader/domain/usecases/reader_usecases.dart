import 'package:ink_trail_client/features/reader/domain/entities/reader_comment_entity.dart';
import 'package:ink_trail_client/features/reader/domain/repositories/reader_repository.dart';

class TrackReaderReadEventUsecase {
  final ReaderRepository _repository;

  const TrackReaderReadEventUsecase(this._repository);

  Future<void> call({
    required String storyId,
    required int chapterIndex,
    required int timeSpentSeconds,
    required int maxScrollPercent,
    required String deviceId,
  }) {
    return _repository.trackReadEvent(
      storyId: storyId,
      chapterIndex: chapterIndex,
      timeSpentSeconds: timeSpentSeconds,
      maxScrollPercent: maxScrollPercent,
      deviceId: deviceId,
    );
  }
}

class SetChapterLikeUsecase {
  final ReaderRepository _repository;

  const SetChapterLikeUsecase(this._repository);

  Future<ReaderLikeResultEntity> call({
    required String chapterId,
    required bool liked,
    required int fallbackLikeCount,
  }) {
    return _repository.setChapterLike(
      chapterId: chapterId,
      liked: liked,
      fallbackLikeCount: fallbackLikeCount,
    );
  }
}

class ReportReaderChapterUsecase {
  final ReaderRepository _repository;

  const ReportReaderChapterUsecase(this._repository);

  Future<void> call({
    required String chapterId,
    required String reason,
    required String description,
  }) {
    return _repository.reportChapter(
      chapterId: chapterId,
      reason: reason,
      description: description,
    );
  }
}

class GetFeaturedChapterCommentUsecase {
  final ReaderRepository _repository;

  const GetFeaturedChapterCommentUsecase(this._repository);

  Future<ReaderCommentEntity?> call({required String chapterId}) {
    return _repository.getFeaturedChapterComment(chapterId: chapterId);
  }
}

class GetChapterCommentsUsecase {
  final ReaderRepository _repository;

  const GetChapterCommentsUsecase(this._repository);

  Future<ReaderCommentsEntity> call({
    required String chapterId,
    int limit = 50,
  }) {
    return _repository.getChapterComments(chapterId: chapterId, limit: limit);
  }
}

class SetChapterCommentLikeUsecase {
  final ReaderRepository _repository;

  const SetChapterCommentLikeUsecase(this._repository);

  Future<ReaderLikeResultEntity> call({
    required String commentId,
    required bool liked,
    required int fallbackLikeCount,
  }) {
    return _repository.setChapterCommentLike(
      commentId: commentId,
      liked: liked,
      fallbackLikeCount: fallbackLikeCount,
    );
  }
}

class SaveChapterCommentUsecase {
  final ReaderRepository _repository;

  const SaveChapterCommentUsecase(this._repository);

  Future<ReaderCommentEntity?> create({
    required String chapterId,
    required String content,
  }) {
    return _repository.createChapterComment(
      chapterId: chapterId,
      content: content,
    );
  }

  Future<ReaderCommentEntity?> update({
    required String commentId,
    required String content,
  }) {
    return _repository.updateChapterComment(
      commentId: commentId,
      content: content,
    );
  }
}

class ReportChapterCommentUsecase {
  final ReaderRepository _repository;

  const ReportChapterCommentUsecase(this._repository);

  Future<void> call({
    required String commentId,
    required String reason,
    required String description,
  }) {
    return _repository.reportChapterComment(
      commentId: commentId,
      reason: reason,
      description: description,
    );
  }
}

class DeleteChapterCommentUsecase {
  final ReaderRepository _repository;

  const DeleteChapterCommentUsecase(this._repository);

  Future<void> call({required String commentId}) {
    return _repository.deleteChapterComment(commentId: commentId);
  }
}

class GetReaderSocketBaseUrlUsecase {
  final ReaderRepository _repository;

  const GetReaderSocketBaseUrlUsecase(this._repository);

  String? call() => _repository.socketBaseUrl;
}
