import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';
import 'package:ink_trail_client/features/reader/presentation/models/reader_view_models.dart'
    as reader_vm;
import 'package:ink_trail_client/features/story_detail/domain/entities/story_detail_chapter_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/entities/story_detail_info_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/usecases/get_highlighted_comments_usecase.dart';
import 'package:ink_trail_client/features/story_detail/domain/usecases/get_story_chapters_usecase.dart';
import 'package:ink_trail_client/features/story_detail/domain/usecases/get_story_detail_info_usecase.dart';
import 'package:ink_trail_client/features/story_detail/domain/usecases/get_story_suggestions_usecase.dart';

import 'story_detail_state.dart';

class StoryDetailSeed {
  final StoryEntity? story;

  const StoryDetailSeed({required this.story});
}

class StoryDetailCubit extends Cubit<StoryDetailState> {
  final GetHighlightedCommentsUsecase _getHighlightedComments;
  final GetStorySuggestionsUsecase _getStorySuggestions;
  final GetStoryDetailInfoUsecase _getStoryDetailInfo;
  final GetStoryChaptersUsecase _getStoryChapters;

  StoryDetailCubit({
    required StoryDetailSeed seed,
    required GetHighlightedCommentsUsecase getHighlightedComments,
    required GetStorySuggestionsUsecase getStorySuggestions,
    required GetStoryDetailInfoUsecase getStoryDetailInfo,
    required GetStoryChaptersUsecase getStoryChapters,
  }) : _getHighlightedComments = getHighlightedComments,
       _getStorySuggestions = getStorySuggestions,
       _getStoryDetailInfo = getStoryDetailInfo,
       _getStoryChapters = getStoryChapters,
       super(StoryDetailState.initial(seed.story));

  Future<void> initialize() async {
    await Future.wait([
      loadStoryDetail(),
      loadChapters(),
      loadHighlightedComments(),
      loadSimilarStories(),
      loadRecommendedStories(),
    ]);
  }

  void handleAuthStateChanged({required bool isAuthenticated}) {
    if (!isAuthenticated) {
      final nextChapters = state.chapters
          .map(
            (chapter) => StoryDetailChapterEntity(
              id: chapter.id,
              number: chapter.number,
              title: chapter.title,
              paragraphs: chapter.paragraphs,
              likeCount: chapter.likeCount,
              commentCount: chapter.commentCount,
              isLiked: false,
            ),
          )
          .toList();
      emit(state.copyWith(chapters: nextChapters));
    }

    unawaited(loadStoryDetail());
    unawaited(loadChapters());
    unawaited(loadHighlightedComments());
    unawaited(loadSimilarStories());
    unawaited(loadRecommendedStories());
  }

  Future<void> loadStoryDetail() async {
    final story = state.story;
    if (story == null || story.slug.isEmpty) return;

    try {
      final detail = await _getStoryDetailInfo(slug: story.slug);
      if (isClosed) return;

      final incomingId = (detail.storyId ?? '').trim();
      emit(
        state.copyWith(
          resolvedStoryId:
              incomingId.isNotEmpty ? incomingId : state.resolvedStoryId,
          storyLikeCount: detail.likeCount,
          storyReadCount: detail.readCount,
          storyRating: detail.rating,
          storyRatingCount: detail.ratingCount,
          myStoryRating: detail.myRating == null
              ? null
              : StoryMyRatingEntity(
                  score: detail.myRating!.score,
                  content: detail.myRating!.content,
                  editCount: detail.myRating!.editCount,
                  canEdit: detail.myRating!.canEdit,
                  createdAt: detail.myRating!.createdAt,
                  updatedAt: detail.myRating!.updatedAt,
                ),
          storyDescription: detail.description.isEmpty
              ? state.storyDescription
              : detail.description,
          storyCategory: detail.category.isEmpty
              ? state.storyCategory
              : detail.category,
          storyTags: detail.tags.isEmpty
              ? state.storyTags
              : List<String>.from(detail.tags),
          authorId: detail.authorId,
          authorBio: detail.authorBio,
          authorStoryCount: detail.authorStoryCount,
        ),
      );

      final widgetIdWasEmpty = (story.id).trim().isEmpty;
      if (widgetIdWasEmpty && incomingId.isNotEmpty) {
        unawaited(loadChapters());
        unawaited(loadHighlightedComments());
        unawaited(loadSimilarStories());
        unawaited(loadRecommendedStories());
      }
    } catch (_) {}
  }

  Future<void> loadChapters() async {
    if (state.story == null || state.storyId.isEmpty) return;

    emit(state.copyWith(isLoadingChapters: true));
    try {
      final chapters = await _getStoryChapters(storyId: state.storyId);
      if (isClosed) return;
      emit(
        state.copyWith(
          chapters: chapters,
          isLoadingChapters: false,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isLoadingChapters: false));
    }
  }

  Future<void> loadHighlightedComments() async {
    if (state.story == null || state.storyId.isEmpty) return;

    emit(state.copyWith(isLoadingHighlightedComments: true));
    try {
      final comments = await _getHighlightedComments(storyId: state.storyId);
      if (isClosed) return;
      emit(
        state.copyWith(
          highlightedChapterComments: comments,
          isLoadingHighlightedComments: false,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          highlightedChapterComments: const [],
          isLoadingHighlightedComments: false,
        ),
      );
    }
  }

  Future<void> loadSimilarStories() async {
    if (state.story == null || state.storyId.isEmpty) return;

    emit(state.copyWith(isLoadingSimilarStories: true));
    try {
      final stories = (await _getStorySuggestions.similar(
        storyId: state.storyId,
        limit: 10,
      ))
          .where((item) => item.id != state.storyId)
          .toList();
      if (isClosed) return;
      emit(
        state.copyWith(
          similarStories: stories,
          isLoadingSimilarStories: false,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          similarStories: const [],
          isLoadingSimilarStories: false,
        ),
      );
    }
  }

  Future<void> loadRecommendedStories() async {
    if (state.story == null || state.storyId.isEmpty) return;

    emit(state.copyWith(isLoadingRecommendedStories: true));
    try {
      final stories = (await _getStorySuggestions.recommended(
        storyId: state.storyId,
        limit: 12,
      ))
          .where((item) => item.id != state.storyId)
          .toList();
      if (isClosed) return;
      emit(
        state.copyWith(
          recommendedStories: stories,
          isLoadingRecommendedStories: false,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          recommendedStories: const [],
          isLoadingRecommendedStories: false,
        ),
      );
    }
  }

  void updateRating({
    required double averageRating,
    required int ratingCount,
    required StoryMyRatingEntity? myRating,
  }) {
    emit(
      state.copyWith(
        storyRating: averageRating,
        storyRatingCount: ratingCount,
        myStoryRating: myRating,
      ),
    );
  }

  void replaceChapters(List<StoryDetailChapterEntity> chapters) {
    emit(
      state.copyWith(
        chapters: chapters,
        storyLikeCount: _totalChapterLikes(chapters),
      ),
    );
  }

  bool applyReaderSessionResult(reader_vm.ReaderSessionResult readerResult) {
    final safeIndex = _normalizeChapterIndex(
      readerResult.chapterIndex,
      state.chapters.length,
    );
    if (safeIndex == null) return false;

    final nextChapters = state.chapters.map((chapter) {
      final nextLiked = readerResult.chapterLikeStates[chapter.id];
      final nextCount = readerResult.chapterLikeCounts[chapter.id];
      final nextCommentCount = readerResult.chapterCommentCounts[chapter.id];
      if (nextLiked == null && nextCount == null && nextCommentCount == null) {
        return chapter;
      }
      return StoryDetailChapterEntity(
        id: chapter.id,
        number: chapter.number,
        title: chapter.title,
        paragraphs: chapter.paragraphs,
        likeCount: nextCount ?? chapter.likeCount,
        commentCount: nextCommentCount ?? chapter.commentCount,
        isLiked: nextLiked ?? chapter.isLiked,
      );
    }).toList();

    replaceChapters(nextChapters);
    return true;
  }

  int _totalChapterLikes(List<StoryDetailChapterEntity> chapters) {
    return chapters.fold<int>(0, (sum, chapter) => sum + chapter.likeCount);
  }

  int? _normalizeChapterIndex(int index, int chapterCount) {
    if (chapterCount <= 0 || index < 0) return null;
    if (index >= chapterCount) return chapterCount - 1;
    return index;
  }
}
