import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/features/story_rating/domain/entities/story_rating_entity.dart';
import 'package:ink_trail_client/features/story_rating/domain/usecases/story_rating_usecases.dart';

import 'story_rating_state.dart';

class StoryRatingCubit extends Cubit<StoryRatingState> {
  final GetStoryRatingsUsecase _getStoryRatings;
  final SubmitStoryRatingUsecase _submitStoryRating;

  StoryRatingCubit({
    required StoryRatingSeed seed,
    required GetStoryRatingsUsecase getStoryRatings,
    required SubmitStoryRatingUsecase submitStoryRating,
  }) : _getStoryRatings = getStoryRatings,
       _submitStoryRating = submitStoryRating,
       super(StoryRatingState.initial(seed));

  Future<void> initialize() async {
    await loadRatings();
  }

  Future<void> loadRatings({bool showLoading = true}) async {
    if (showLoading) {
      emit(state.copyWith(isLoading: true));
    }

    try {
      final ratings = await _getStoryRatings(storyId: state.storyId);
      if (isClosed) return;

      final myRating = ratings.myRating == null
          ? null
          : StoryRatingMyRatingView.fromEntity(ratings.myRating!);
      emit(
        state.copyWith(
          averageRating: ratings.averageRating,
          ratingCount: ratings.ratingCount,
          myRating: myRating,
          reviews: ratings.reviews.map(_mapReview).toList(),
          isLoading: false,
          draftScore: myRating?.score ?? state.draftScore,
          draftContent: myRating?.content ?? '',
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false));
    }
  }

  void setDraftScore(int score) {
    emit(state.copyWith(draftScore: score.clamp(1, 5)));
  }

  void setDraftContent(String content) {
    emit(state.copyWith(draftContent: content));
  }

  void startEditing() {
    emit(
      state.copyWith(
        isEditing: true,
        draftScore: state.myRating?.score ?? state.draftScore,
        draftContent: state.myRating?.content ?? state.draftContent,
      ),
    );
  }

  void cancelEditing() {
    emit(
      state.copyWith(
        isEditing: false,
        draftScore: state.myRating?.score ?? 5,
        draftContent: state.myRating?.content ?? '',
      ),
    );
  }

  Future<void> submitRating() async {
    if (!state.isAuthenticated) {
      _emitMessage(
        const StoryRatingMessage(
          text: 'Đăng nhập để đánh giá truyện.',
          isError: true,
        ),
      );
      return;
    }

    final content = state.draftContent.trim();
    if (content.isEmpty || state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true));
    try {
      await _submitStoryRating(
        storyId: state.storyId,
        score: state.draftScore,
        content: content,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          isSubmitting: false,
          isEditing: false,
        ),
      );
      await loadRatings(showLoading: false);
      if (isClosed) return;
      _emitMessage(
        const StoryRatingMessage(
          text: 'Đã gửi đánh giá thành công.',
          isError: false,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isSubmitting: false));
      _emitMessage(
        const StoryRatingMessage(
          text: 'Không thể gửi đánh giá lúc này.',
          isError: true,
        ),
      );
    }
  }

  void clearMessage() {
    emit(state.copyWith(message: null));
  }

  StoryRatingSheetResult buildResult() {
    return StoryRatingSheetResult(
      averageRating: state.averageRating,
      ratingCount: state.ratingCount,
      myRating: state.myRating,
    );
  }

  StoryRatingReviewView _mapReview(StoryRatingReviewEntity review) {
    return StoryRatingReviewView(
      id: review.id,
      author: review.author,
      score: review.score,
      content: review.content,
      timeLabel: _formatTimeLabel(review.createdAt),
    );
  }

  String _formatTimeLabel(DateTime? value) {
    if (value == null) return 'Vừa xong';
    final now = DateTime.now().toUtc();
    final diff = now.difference(value.toUtc());
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${value.day}/${value.month}/${value.year}';
  }

  void _emitMessage(StoryRatingMessage message) {
    emit(
      state.copyWith(
        message: message,
        messageVersion: state.messageVersion + 1,
      ),
    );
  }
}
