class MyStoryEntity {
  final String id;
  final String title;
  final String slug;
  final String description;
  final String coverUrl;
  final String status;
  final String moderationStatus;
  final DateTime? moderationCheckedAt;
  final String moderationReason;
  final double? moderationConfidence;
  final List<String> moderationCategories;
  final int readCount;
  final int likeCount;
  final int chapterCount;
  final double rating;
  final int ratingCount;
  final List<String> tags;
  final DateTime? updatedAt;

  const MyStoryEntity({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.coverUrl,
    required this.status,
    required this.moderationStatus,
    required this.moderationCheckedAt,
    required this.moderationReason,
    required this.moderationConfidence,
    required this.moderationCategories,
    required this.readCount,
    required this.likeCount,
    required this.chapterCount,
    required this.rating,
    required this.ratingCount,
    required this.tags,
    required this.updatedAt,
  });
}
