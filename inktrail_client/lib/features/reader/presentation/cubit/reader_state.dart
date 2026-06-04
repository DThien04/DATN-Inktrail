import 'package:ink_trail_client/features/reader/presentation/models/reader_view_models.dart';

class ReaderSeed {
  final int initialChapterIndex;
  final ReaderThemeMode initialThemeMode;
  final double initialBodyFontSize;
  final double initialLineHeight;
  final List<ReaderChapterSnapshot> chapters;

  const ReaderSeed({
    required this.initialChapterIndex,
    required this.initialThemeMode,
    this.initialBodyFontSize = 22,
    this.initialLineHeight = 1.75,
    required this.chapters,
  });
}

class ReaderChapterSnapshot {
  final String id;
  final bool isLiked;
  final int likeCount;
  final int commentCount;

  const ReaderChapterSnapshot({
    required this.id,
    required this.isLiked,
    required this.likeCount,
    required this.commentCount,
  });
}

enum ReaderThemeMode { light, dark }

class ReaderChapterState {
  final String id;
  final bool isLiked;
  final int likeCount;
  final int commentCount;
  final bool isLikeCoolingDown;
  final bool isLikeAnimating;
  final bool isLikeRequesting;
  final ReaderCommentView? featuredComment;

  const ReaderChapterState({
    required this.id,
    required this.isLiked,
    required this.likeCount,
    required this.commentCount,
    this.isLikeCoolingDown = false,
    this.isLikeAnimating = false,
    this.isLikeRequesting = false,
    this.featuredComment,
  });

  factory ReaderChapterState.fromSnapshot(ReaderChapterSnapshot snapshot) {
    return ReaderChapterState(
      id: snapshot.id,
      isLiked: snapshot.isLiked,
      likeCount: snapshot.likeCount,
      commentCount: snapshot.commentCount,
    );
  }

  ReaderChapterState copyWith({
    bool? isLiked,
    int? likeCount,
    int? commentCount,
    bool? isLikeCoolingDown,
    bool? isLikeAnimating,
    bool? isLikeRequesting,
    Object? featuredComment = _readerChapterStateSentinel,
  }) {
    return ReaderChapterState(
      id: id,
      isLiked: isLiked ?? this.isLiked,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLikeCoolingDown: isLikeCoolingDown ?? this.isLikeCoolingDown,
      isLikeAnimating: isLikeAnimating ?? this.isLikeAnimating,
      isLikeRequesting: isLikeRequesting ?? this.isLikeRequesting,
      featuredComment: identical(featuredComment, _readerChapterStateSentinel)
          ? this.featuredComment
          : featuredComment as ReaderCommentView?,
    );
  }
}

class ReaderState {
  final int currentChapterIndex;
  final bool isFollowingStory;
  final Map<String, ReaderChapterState> chapters;
  final double bodyFontSize;
  final double lineHeight;
  final ReaderThemeMode themeMode;

  const ReaderState({
    required this.currentChapterIndex,
    required this.isFollowingStory,
    required this.chapters,
    required this.bodyFontSize,
    required this.lineHeight,
    required this.themeMode,
  });

  factory ReaderState.initial(ReaderSeed seed) {
    final safeIndex = seed.chapters.isEmpty
        ? 0
        : seed.initialChapterIndex.clamp(0, seed.chapters.length - 1);
    final chapters = <String, ReaderChapterState>{
      for (final chapter in seed.chapters)
        chapter.id: ReaderChapterState.fromSnapshot(chapter),
    };

    return ReaderState(
      currentChapterIndex: safeIndex,
      isFollowingStory: false,
      chapters: chapters,
      bodyFontSize: seed.initialBodyFontSize,
      lineHeight: seed.initialLineHeight,
      themeMode: seed.initialThemeMode,
    );
  }

  ReaderChapterState? chapterStateOf(String chapterId) => chapters[chapterId];

  Map<String, bool> get chapterLikeStates => <String, bool>{
    for (final entry in chapters.entries) entry.key: entry.value.isLiked,
  };

  Map<String, int> get chapterLikeCounts => <String, int>{
    for (final entry in chapters.entries) entry.key: entry.value.likeCount,
  };

  Map<String, int> get chapterCommentCounts => <String, int>{
    for (final entry in chapters.entries) entry.key: entry.value.commentCount,
  };

  Map<String, bool> get chapterLikeCoolingDown => <String, bool>{
    for (final entry in chapters.entries)
      entry.key: entry.value.isLikeCoolingDown,
  };

  Map<String, bool> get chapterLikeAnimating => <String, bool>{
    for (final entry in chapters.entries) entry.key: entry.value.isLikeAnimating,
  };

  Map<String, bool> get chapterLikeRequesting => <String, bool>{
    for (final entry in chapters.entries) entry.key: entry.value.isLikeRequesting,
  };

  Map<String, ReaderCommentView?> get featuredComments =>
      <String, ReaderCommentView?>{
        for (final entry in chapters.entries)
          entry.key: entry.value.featuredComment,
      };

  ReaderState copyWith({
    int? currentChapterIndex,
    bool? isFollowingStory,
    Map<String, ReaderChapterState>? chapters,
    double? bodyFontSize,
    double? lineHeight,
    ReaderThemeMode? themeMode,
  }) {
    return ReaderState(
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      isFollowingStory: isFollowingStory ?? this.isFollowingStory,
      chapters: chapters ?? this.chapters,
      bodyFontSize: bodyFontSize ?? this.bodyFontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

const Object _readerChapterStateSentinel = Object();
