import 'package:ink_trail_client/features/story_rating/domain/entities/story_rating_entity.dart';

class StoryRatingMyRatingView {
  final int score;
  final String content;
  final int editCount;
  final bool canEdit;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StoryRatingMyRatingView({
    required this.score,
    required this.content,
    required this.editCount,
    required this.canEdit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoryRatingMyRatingView.fromEntity(StoryRatingMyRatingEntity entity) {
    return StoryRatingMyRatingView(
      score: entity.score,
      content: entity.content,
      editCount: entity.editCount,
      canEdit: entity.canEdit,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  StoryRatingMyRatingEntity toEntity() {
    return StoryRatingMyRatingEntity(
      score: score,
      content: content,
      editCount: editCount,
      canEdit: canEdit,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class StoryRatingReviewView {
  final String id;
  final String author;
  final int score;
  final String content;
  final String timeLabel;

  const StoryRatingReviewView({
    required this.id,
    required this.author,
    required this.score,
    required this.content,
    required this.timeLabel,
  });
}

class StoryRatingSheetResult {
  final double averageRating;
  final int ratingCount;
  final StoryRatingMyRatingView? myRating;

  const StoryRatingSheetResult({
    required this.averageRating,
    required this.ratingCount,
    required this.myRating,
  });
}

class StoryRatingMessage {
  final String text;
  final bool isError;

  const StoryRatingMessage({
    required this.text,
    required this.isError,
  });
}

class StoryRatingState {
  final String storyId;
  final bool isAuthenticated;
  final double averageRating;
  final int ratingCount;
  final StoryRatingMyRatingView? myRating;
  final List<StoryRatingReviewView> reviews;
  final bool isLoading;
  final bool isEditing;
  final bool isSubmitting;
  final int draftScore;
  final String draftContent;
  final StoryRatingMessage? message;
  final int messageVersion;

  const StoryRatingState({
    required this.storyId,
    required this.isAuthenticated,
    required this.averageRating,
    required this.ratingCount,
    required this.myRating,
    required this.reviews,
    required this.isLoading,
    required this.isEditing,
    required this.isSubmitting,
    required this.draftScore,
    required this.draftContent,
    required this.message,
    required this.messageVersion,
  });

  factory StoryRatingState.initial(StoryRatingSeed seed) {
    return StoryRatingState(
      storyId: seed.storyId,
      isAuthenticated: seed.isAuthenticated,
      averageRating: seed.initialAverageRating,
      ratingCount: seed.initialRatingCount,
      myRating: seed.initialMyRating,
      reviews: const <StoryRatingReviewView>[],
      isLoading: true,
      isEditing: false,
      isSubmitting: false,
      draftScore: seed.initialMyRating?.score ?? 5,
      draftContent: seed.initialMyRating?.content ?? '',
      message: null,
      messageVersion: 0,
    );
  }

  StoryRatingState copyWith({
    String? storyId,
    bool? isAuthenticated,
    double? averageRating,
    int? ratingCount,
    Object? myRating = _sentinel,
    List<StoryRatingReviewView>? reviews,
    bool? isLoading,
    bool? isEditing,
    bool? isSubmitting,
    int? draftScore,
    String? draftContent,
    Object? message = _sentinel,
    int? messageVersion,
  }) {
    return StoryRatingState(
      storyId: storyId ?? this.storyId,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      myRating: identical(myRating, _sentinel)
          ? this.myRating
          : myRating as StoryRatingMyRatingView?,
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      draftScore: draftScore ?? this.draftScore,
      draftContent: draftContent ?? this.draftContent,
      message: identical(message, _sentinel)
          ? this.message
          : message as StoryRatingMessage?,
      messageVersion: messageVersion ?? this.messageVersion,
    );
  }
}

class StoryRatingSeed {
  final String storyId;
  final double initialAverageRating;
  final int initialRatingCount;
  final StoryRatingMyRatingView? initialMyRating;
  final bool isAuthenticated;

  const StoryRatingSeed({
    required this.storyId,
    required this.initialAverageRating,
    required this.initialRatingCount,
    required this.initialMyRating,
    required this.isAuthenticated,
  });
}

const Object _sentinel = Object();
