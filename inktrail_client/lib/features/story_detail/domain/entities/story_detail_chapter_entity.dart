class StoryDetailChapterEntity {
  final String id;
  final int number;
  final String title;
  final List<String> paragraphs;
  final int likeCount;
  final int commentCount;
  final bool isLiked;

  const StoryDetailChapterEntity({
    required this.id,
    required this.number,
    required this.title,
    required this.paragraphs,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
  });
}
