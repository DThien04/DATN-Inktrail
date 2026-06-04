class LibraryHistoryItem {
  final String storyId;
  final String storyTitle;
  final String storySlug;
  final String coverUrl;
  final int lastChapterIndex;
  final int? lastPosition;
  final DateTime updatedAt;

  const LibraryHistoryItem({
    required this.storyId,
    required this.storyTitle,
    required this.storySlug,
    required this.coverUrl,
    required this.lastChapterIndex,
    this.lastPosition,
    required this.updatedAt,
  });

  String get chapterLabel => 'Chương ${lastChapterIndex + 1}';
}

enum LibraryHistoryStatus { initial, loading, success, failure }

class LibraryState {
  final LibraryHistoryStatus status;
  final List<LibraryHistoryItem> historyItems;
  final bool isLoggedIn;
  final String? errorMessage;

  const LibraryState({
    this.status = LibraryHistoryStatus.initial,
    this.historyItems = const [],
    this.isLoggedIn = false,
    this.errorMessage,
  });

  LibraryState copyWith({
    LibraryHistoryStatus? status,
    List<LibraryHistoryItem>? historyItems,
    bool? isLoggedIn,
    String? errorMessage,
  }) {
    return LibraryState(
      status: status ?? this.status,
      historyItems: historyItems ?? this.historyItems,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      errorMessage: errorMessage,
    );
  }
}
