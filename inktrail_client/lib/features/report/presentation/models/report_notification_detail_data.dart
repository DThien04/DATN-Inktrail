import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';

class ReportNotificationDetailData {
  final String title;
  final String body;
  final String timeLabel;
  final DateTime createdAt;
  final String reportType;
  final String resolutionAction;
  final String audience;
  final String? caseId;
  final String? appealStatus;
  final String? storyTitle;
  final String? chapterTitle;
  final int? chapterNumber;
  final String? moderatedBy;
  final String? commentPreview;
  final StoryEntity? story;

  const ReportNotificationDetailData({
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.createdAt,
    required this.reportType,
    required this.resolutionAction,
    required this.audience,
    this.caseId,
    this.appealStatus,
    this.storyTitle,
    this.chapterTitle,
    this.chapterNumber,
    this.moderatedBy,
    this.commentPreview,
    this.story,
  });
}
