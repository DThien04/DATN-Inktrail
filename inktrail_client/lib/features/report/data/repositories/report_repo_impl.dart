import 'package:ink_trail_client/features/report/data/resources/report_remote_datasource.dart';
import 'package:ink_trail_client/features/report/domain/repositories/report_repository.dart';

class ReportRepoImpl implements ReportRepository {
  final ReportRemoteDatasource _datasource;

  const ReportRepoImpl(this._datasource);

  @override
  Future<void> reportStory({
    required String storyId,
    required String reason,
    required String description,
  }) => _datasource.reportStory(
    storyId: storyId,
    reason: reason,
    description: description,
  );

  @override
  Future<void> reportChapter({
    required String chapterId,
    required String reason,
    required String description,
  }) => _datasource.reportChapter(
    chapterId: chapterId,
    reason: reason,
    description: description,
  );

  @override
  Future<void> reportChapterComment({
    required String commentId,
    required String reason,
    required String description,
  }) => _datasource.reportChapterComment(
    commentId: commentId,
    reason: reason,
    description: description,
  );

  @override
  Future<void> submitReportAppeal({
    required String caseId,
    required String reason,
  }) => _datasource.submitReportAppeal(
    caseId: caseId,
    reason: reason,
  );
}

