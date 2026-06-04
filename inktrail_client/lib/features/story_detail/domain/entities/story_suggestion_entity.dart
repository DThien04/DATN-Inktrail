class StorySuggestionEntity {
  final String id;
  final String slug;
  final String title;
  final String description;
  final String author;
  final String coverUrl;
  final String category;
  final int readCount;
  final int likeCount;
  final int chapterCount;
  final bool isLiked;
  final List<String> tags;

  const StorySuggestionEntity({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.author,
    required this.coverUrl,
    required this.category,
    required this.readCount,
    required this.likeCount,
    required this.chapterCount,
    required this.isLiked,
    required this.tags,
  });
}
