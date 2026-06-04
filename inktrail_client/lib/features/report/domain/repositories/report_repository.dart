abstract class ReportRepository {
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

