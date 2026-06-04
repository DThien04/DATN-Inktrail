class MyStoryChapterEntity {
  final String id;
  final int chapterNumber;
  final String title;
  final String content;
  final String status;
  final String moderationStatus;
  final String moderationReason;
  final List<String> moderationCategories;
  final int likeCount;
  final int commentCount;
  final DateTime? updatedAt;

  const MyStoryChapterEntity({
    required this.id,
    required this.chapterNumber,
    required this.title,
    required this.content,
    required this.status,
    required this.moderationStatus,
    required this.moderationReason,
    required this.moderationCategories,
    required this.likeCount,
    required this.commentCount,
    required this.updatedAt,
  });

  int get wordCount {
    final text = content.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((item) => item.isNotEmpty).length;
  }
}
