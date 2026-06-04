import 'package:ink_trail_client/features/story_management/domain/entities/my_story_entity.dart';

class MyAuthorStoriesState {
  final bool isLoading;
  final bool isSaving;
  final String? deletingStoryId;
  final String? errorMessage;
  final List<MyStoryEntity> stories;

  const MyAuthorStoriesState({
    this.isLoading = false,
    this.isSaving = false,
    this.deletingStoryId,
    this.errorMessage,
    this.stories = const <MyStoryEntity>[],
  });

  MyAuthorStoriesState copyWith({
    bool? isLoading,
    bool? isSaving,
    Object? deletingStoryId = _sentinel,
    Object? errorMessage = _sentinel,
    List<MyStoryEntity>? stories,
  }) {
    return MyAuthorStoriesState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      deletingStoryId: deletingStoryId == _sentinel
          ? this.deletingStoryId
          : deletingStoryId as String?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      stories: stories ?? this.stories,
    );
  }
}

const Object _sentinel = Object();
