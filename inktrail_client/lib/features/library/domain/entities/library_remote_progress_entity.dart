class LibraryRemoteProgressEntity {
  final String storyId;
  final int lastChapterIndex;
  final int? lastPosition;
  final DateTime updatedAt;
  final String storyTitle;
  final String storySlug;
  final String coverUrl;

  const LibraryRemoteProgressEntity({
    required this.storyId,
    required this.lastChapterIndex,
    required this.lastPosition,
    required this.updatedAt,
    required this.storyTitle,
    required this.storySlug,
    required this.coverUrl,
  });
}
