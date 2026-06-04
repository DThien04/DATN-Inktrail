import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/core/network/api_exception.dart';
import 'package:ink_trail_client/features/reader/domain/usecases/reader_usecases.dart';
import 'package:ink_trail_client/features/reader/presentation/cubit/reader_state.dart';
import 'package:ink_trail_client/features/reader/presentation/models/reader_view_models.dart';
import 'package:ink_trail_client/features/report/domain/usecases/report_usecases.dart';

enum ReaderChapterLikeStatus { success, hidden, failed, ignored }

class ReaderChapterLikeOutcome {
  final ReaderChapterLikeStatus status;
  final Object? error;

  const ReaderChapterLikeOutcome._(this.status, [this.error]);

  const ReaderChapterLikeOutcome.success()
    : this._(ReaderChapterLikeStatus.success);

  const ReaderChapterLikeOutcome.hidden(Object error)
    : this._(ReaderChapterLikeStatus.hidden, error);

  const ReaderChapterLikeOutcome.failed(Object error)
    : this._(ReaderChapterLikeStatus.failed, error);

  const ReaderChapterLikeOutcome.ignored()
    : this._(ReaderChapterLikeStatus.ignored);
}

class ReaderCubit extends Cubit<ReaderState> {
  ReaderCubit({
    required ReaderSeed seed,
    required GetFeaturedChapterCommentUsecase getFeaturedChapterComment,
    required SetChapterLikeUsecase setChapterLike,
    required SubmitChapterReportUsecase submitChapterReport,
  }) : _getFeaturedChapterComment = getFeaturedChapterComment,
       _setChapterLike = setChapterLike,
       _submitChapterReport = submitChapterReport,
       super(ReaderState.initial(seed));

  static const likeCooldown = Duration(milliseconds: 1400);
  static const likeAnimationDuration = Duration(milliseconds: 240);

  final GetFeaturedChapterCommentUsecase _getFeaturedChapterComment;
  final SetChapterLikeUsecase _setChapterLike;
  final SubmitChapterReportUsecase _submitChapterReport;
  final Map<String, Timer> _likeCooldownTimers = <String, Timer>{};
  final Map<String, Timer> _likeAnimationTimers = <String, Timer>{};

  ReaderChapterState? chapterStateOf(String chapterId) {
    return state.chapterStateOf(chapterId);
  }

  void openChapter(int index) {
    emit(state.copyWith(currentChapterIndex: index));
  }

  void toggleFollowStory() {
    emit(state.copyWith(isFollowingStory: !state.isFollowingStory));
  }

  Future<void> loadFeaturedComment({
    required String chapterId,
    required String currentUserId,
  }) async {
    if (chapterId.isEmpty) return;

    final comment = await _getFeaturedChapterComment(chapterId: chapterId);
    _updateChapter(
      chapterId,
      (chapter) => chapter.copyWith(
        featuredComment: comment == null
            ? null
            : ReaderCommentView.fromEntity(
                comment,
                currentUserId: currentUserId,
              ),
      ),
    );
  }

  Future<void> submitChapterReport({
    required String chapterId,
    required String reason,
    required String description,
  }) {
    return _submitChapterReport(
      chapterId: chapterId,
      reason: reason,
      description: description,
    );
  }

  void setThemeMode(ReaderThemeMode value) {
    if (state.themeMode == value) return;
    emit(state.copyWith(themeMode: value));
  }

  void setBodyFontSize(double value) {
    if (state.bodyFontSize == value) return;
    emit(state.copyWith(bodyFontSize: value));
  }

  void setLineHeight(double value) {
    if (state.lineHeight == value) return;
    emit(state.copyWith(lineHeight: value));
  }

  Future<ReaderChapterLikeOutcome> toggleChapterLike({
    required String chapterId,
  }) async {
    final chapter = state.chapterStateOf(chapterId);
    if (chapter == null ||
        chapter.id.isEmpty ||
        chapter.isLikeCoolingDown ||
        chapter.isLikeRequesting) {
      return const ReaderChapterLikeOutcome.ignored();
    }

    final previousLiked = chapter.isLiked;
    final previousCount = chapter.likeCount;
    final nextLiked = !previousLiked;
    final optimisticCount = nextLiked
        ? previousCount + 1
        : (previousCount > 0 ? previousCount - 1 : 0);

    _updateChapter(
      chapterId,
      (current) => current.copyWith(
        isLiked: nextLiked,
        likeCount: optimisticCount,
        isLikeCoolingDown: true,
        isLikeAnimating: true,
        isLikeRequesting: true,
      ),
    );
    _scheduleLikeAnimationRelease(chapterId);
    _scheduleLikeCooldownRelease(chapterId);

    try {
      final result = await _setChapterLike(
        chapterId: chapterId,
        liked: nextLiked,
        fallbackLikeCount: optimisticCount,
      );
      _updateChapter(
        chapterId,
        (current) => current.copyWith(
          isLiked: result.liked,
          likeCount: result.likeCount,
        ),
      );
      return const ReaderChapterLikeOutcome.success();
    } on ApiException catch (error) {
      _restoreChapterLike(
        chapterId: chapterId,
        previousLiked: previousLiked,
        previousCount: previousCount,
      );
      if (_isHiddenChapterError(error)) {
        return ReaderChapterLikeOutcome.hidden(error);
      }
      return ReaderChapterLikeOutcome.failed(error);
    } catch (error) {
      _restoreChapterLike(
        chapterId: chapterId,
        previousLiked: previousLiked,
        previousCount: previousCount,
      );
      return ReaderChapterLikeOutcome.failed(error);
    } finally {
      _updateChapter(
        chapterId,
        (current) => current.copyWith(isLikeRequesting: false),
      );
    }
  }

  void updateChapterCommentCount({
    required String chapterId,
    required int count,
  }) {
    _updateChapter(
      chapterId,
      (chapter) => chapter.copyWith(commentCount: count),
    );
  }

  ReaderSessionResult buildSessionResult({
    int? lastScrollPercent,
    String? chapterHiddenMessage,
  }) {
    return ReaderSessionResult(
      chapterIndex: state.currentChapterIndex,
      lastScrollPercent: lastScrollPercent,
      chapterLikeStates: state.chapterLikeStates,
      chapterLikeCounts: state.chapterLikeCounts,
      chapterCommentCounts: state.chapterCommentCounts,
      chapterHiddenMessage: chapterHiddenMessage,
    );
  }

  void _restoreChapterLike({
    required String chapterId,
    required bool previousLiked,
    required int previousCount,
  }) {
    _updateChapter(
      chapterId,
      (current) => current.copyWith(
        isLiked: previousLiked,
        likeCount: previousCount,
      ),
    );
  }

  void _updateChapter(
    String chapterId,
    ReaderChapterState Function(ReaderChapterState chapter) update,
  ) {
    final chapter = state.chapterStateOf(chapterId);
    if (chapter == null) return;

    emit(
      state.copyWith(
        chapters: Map<String, ReaderChapterState>.from(state.chapters)
          ..[chapterId] = update(chapter),
      ),
    );
  }

  void _scheduleLikeAnimationRelease(String chapterId) {
    _likeAnimationTimers.remove(chapterId)?.cancel();
    _likeAnimationTimers[chapterId] = Timer(likeAnimationDuration, () {
      if (isClosed) return;
      _updateChapter(
        chapterId,
        (chapter) => chapter.copyWith(isLikeAnimating: false),
      );
    });
  }

  void _scheduleLikeCooldownRelease(String chapterId) {
    _likeCooldownTimers.remove(chapterId)?.cancel();
    _likeCooldownTimers[chapterId] = Timer(likeCooldown, () {
      if (isClosed) return;
      _updateChapter(
        chapterId,
        (chapter) => chapter.copyWith(isLikeCoolingDown: false),
      );
    });
  }

  bool _isHiddenChapterError(ApiException error) {
    final message = error.message.toLowerCase();
    return message.contains('hidden') ||
        message.contains('not available') ||
        message.contains('khong kha dung') ||
        message.contains('unpublished') ||
        message.contains('chua duoc xuat ban');
  }

  @override
  Future<void> close() {
    for (final timer in _likeCooldownTimers.values) {
      timer.cancel();
    }
    for (final timer in _likeAnimationTimers.values) {
      timer.cancel();
    }
    _likeCooldownTimers.clear();
    _likeAnimationTimers.clear();
    return super.close();
  }
}
