import 'package:ink_trail_client/features/report/domain/repositories/report_repository.dart';

class SubmitStoryReportUsecase {
  final ReportRepository _repository;

  const SubmitStoryReportUsecase(this._repository);

  Future<void> call({
    required String storyId,
    required String reason,
    required String description,
  }) => _repository.reportStory(
    storyId: storyId,
    reason: reason,
    description: description,
  );
}

class SubmitChapterReportUsecase {
  final ReportRepository _repository;

  const SubmitChapterReportUsecase(this._repository);

  Future<void> call({
    required String chapterId,
    required String reason,
    required String description,
  }) => _repository.reportChapter(
    chapterId: chapterId,
    reason: reason,
    description: description,
  );
}

class SubmitChapterCommentReportUsecase {
  final ReportRepository _repository;

  const SubmitChapterCommentReportUsecase(this._repository);

  Future<void> call({
    required String commentId,
    required String reason,
    required String description,
  }) => _repository.reportChapterComment(
    commentId: commentId,
    reason: reason,
    description: description,
  );
}

