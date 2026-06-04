class StoryDownloadChapterEntity {
  final String id;
  final int number;
  final String title;
  final List<String> paragraphs;

  const StoryDownloadChapterEntity({
    required this.id,
    required this.number,
    required this.title,
    required this.paragraphs,
  });
}

class StoryDownloadSeed {
  final String storyId;
  final String storyTitle;
  final String storySlug;
  final String storyAuthor;
  final String storyCoverUrl;
  final bool isLoadingSource;
  final List<StoryDownloadChapterEntity> chapters;

  const StoryDownloadSeed({
    required this.storyId,
    required this.storyTitle,
    required this.storySlug,
    required this.storyAuthor,
    required this.storyCoverUrl,
    required this.isLoadingSource,
    required this.chapters,
  });
}
