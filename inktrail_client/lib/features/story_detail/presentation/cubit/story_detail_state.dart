import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/entities/highlighted_chapter_comment_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/entities/story_detail_chapter_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/entities/story_detail_info_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/entities/story_suggestion_entity.dart';

class StoryDetailState {
  final StoryEntity? story;
  final String resolvedStoryId;
  final int storyLikeCount;
  final int storyReadCount;
  final double storyRating;
  final int storyRatingCount;
  final StoryMyRatingEntity? myStoryRating;
  final String storyDescription;
  final String storyCategory;
  final List<String> storyTags;
  final String authorId;
  final String authorBio;
  final int? authorStoryCount;
  final List<StoryDetailChapterEntity> chapters;
  final bool isLoadingChapters;
  final List<StorySuggestionEntity> similarStories;
  final List<StorySuggestionEntity> recommendedStories;
  final bool isLoadingSimilarStories;
  final bool isLoadingRecommendedStories;
  final List<HighlightedChapterCommentEntity> highlightedChapterComments;
  final bool isLoadingHighlightedComments;

  const StoryDetailState({
    required this.story,
    this.resolvedStoryId = '',
    this.storyLikeCount = 0,
    this.storyReadCount = 0,
    this.storyRating = 0,
    this.storyRatingCount = 0,
    this.myStoryRating,
    this.storyDescription = '',
    this.storyCategory = '',
    this.storyTags = const <String>[],
    this.authorId = '',
    this.authorBio = '',
    this.authorStoryCount,
    this.chapters = const <StoryDetailChapterEntity>[],
    this.isLoadingChapters = false,
    this.similarStories = const <StorySuggestionEntity>[],
    this.recommendedStories = const <StorySuggestionEntity>[],
    this.isLoadingSimilarStories = false,
    this.isLoadingRecommendedStories = false,
    this.highlightedChapterComments = const <HighlightedChapterCommentEntity>[],
    this.isLoadingHighlightedComments = false,
  });

  factory StoryDetailState.initial(StoryEntity? story) {
    return StoryDetailState(
      story: story,
      resolvedStoryId: (story?.id ?? '').trim(),
      storyLikeCount: story?.likeCount ?? 0,
      storyReadCount: story?.readCount ?? 0,
      storyRating: story?.rating ?? 0,
      storyDescription: story?.description.trim() ?? '',
      storyCategory: story?.category.trim() ?? '',
      storyTags: List<String>.from(story?.tags ?? const <String>[]),
    );
  }

  String get storyId {
    final resolved = resolvedStoryId.trim();
    if (resolved.isNotEmpty) return resolved;
    return (story?.id ?? '').trim();
  }

  StoryDetailState copyWith({
    StoryEntity? story,
    String? resolvedStoryId,
    int? storyLikeCount,
    int? storyReadCount,
    double? storyRating,
    int? storyRatingCount,
    Object? myStoryRating = _sentinel,
    String? storyDescription,
    String? storyCategory,
    List<String>? storyTags,
    String? authorId,
    String? authorBio,
    Object? authorStoryCount = _sentinel,
    List<StoryDetailChapterEntity>? chapters,
    bool? isLoadingChapters,
    List<StorySuggestionEntity>? similarStories,
    List<StorySuggestionEntity>? recommendedStories,
    bool? isLoadingSimilarStories,
    bool? isLoadingRecommendedStories,
    List<HighlightedChapterCommentEntity>? highlightedChapterComments,
    bool? isLoadingHighlightedComments,
  }) {
    return StoryDetailState(
      story: story ?? this.story,
      resolvedStoryId: resolvedStoryId ?? this.resolvedStoryId,
      storyLikeCount: storyLikeCount ?? this.storyLikeCount,
      storyReadCount: storyReadCount ?? this.storyReadCount,
      storyRating: storyRating ?? this.storyRating,
      storyRatingCount: storyRatingCount ?? this.storyRatingCount,
      myStoryRating: identical(myStoryRating, _sentinel)
          ? this.myStoryRating
          : myStoryRating as StoryMyRatingEntity?,
      storyDescription: storyDescription ?? this.storyDescription,
      storyCategory: storyCategory ?? this.storyCategory,
      storyTags: storyTags ?? this.storyTags,
      authorId: authorId ?? this.authorId,
      authorBio: authorBio ?? this.authorBio,
      authorStoryCount: identical(authorStoryCount, _sentinel)
          ? this.authorStoryCount
          : authorStoryCount as int?,
      chapters: chapters ?? this.chapters,
      isLoadingChapters: isLoadingChapters ?? this.isLoadingChapters,
      similarStories: similarStories ?? this.similarStories,
      recommendedStories: recommendedStories ?? this.recommendedStories,
      isLoadingSimilarStories:
          isLoadingSimilarStories ?? this.isLoadingSimilarStories,
      isLoadingRecommendedStories:
          isLoadingRecommendedStories ?? this.isLoadingRecommendedStories,
      highlightedChapterComments:
          highlightedChapterComments ?? this.highlightedChapterComments,
      isLoadingHighlightedComments:
          isLoadingHighlightedComments ?? this.isLoadingHighlightedComments,
    );
  }
}

const Object _sentinel = Object();
