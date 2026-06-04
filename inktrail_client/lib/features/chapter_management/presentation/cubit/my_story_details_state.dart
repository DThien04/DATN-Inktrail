import 'package:ink_trail_client/features/chapter_management/domain/entities/my_story_chapter_entity.dart';

class MyStoryDetailsState {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final List<MyStoryChapterEntity> chapters;

  const MyStoryDetailsState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.chapters = const [],
  });

  MyStoryDetailsState copyWith({
    bool? isLoading,
    bool? isSaving,
    Object? errorMessage = _sentinel,
    List<MyStoryChapterEntity>? chapters,
  }) {
    return MyStoryDetailsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
      chapters: chapters ?? this.chapters,
    );
  }
}

const Object _sentinel = Object();
