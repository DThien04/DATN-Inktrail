class StoryEntity {
  final String id;
  final String slug;
  final String title;
  final String description;
  final String author;
  final String coverUrl;
  final String category;
  final double rating;
  final int totalChapters;
  final int readCount;
  final int likeCount;
  final bool isLiked;
  final List<String> tags;
  final bool isFeatured;

  const StoryEntity({
    required this.id,
    this.slug = '',
    required this.title,
    this.description = '',
    required this.author,
    required this.coverUrl,
    required this.category,
    required this.rating,
    required this.totalChapters,
    required this.readCount,
    this.likeCount = 0,
    this.isLiked = false,
    required this.tags,
    this.isFeatured = false,
  });
}
