import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/features/chapter_management/domain/usecases/chapter_management_usecases.dart';
import 'package:ink_trail_client/features/chapter_management/presentation/cubit/my_story_details_state.dart';

class MyStoryDetailsCubit extends Cubit<MyStoryDetailsState> {
  final GetMyStoryChaptersUsecase _getMyStoryChapters;
  final CreateMyStoryChapterUsecase _createMyStoryChapter;
  final UpdateMyStoryChapterUsecase _updateMyStoryChapter;
  final PublishMyStoryChapterUsecase _publishMyStoryChapter;
  final UnpublishMyStoryChapterUsecase _unpublishMyStoryChapter;
  final DeleteMyStoryChapterUsecase _deleteMyStoryChapter;

  MyStoryDetailsCubit({
    required GetMyStoryChaptersUsecase getMyStoryChapters,
    required CreateMyStoryChapterUsecase createMyStoryChapter,
    required UpdateMyStoryChapterUsecase updateMyStoryChapter,
    required PublishMyStoryChapterUsecase publishMyStoryChapter,
    required UnpublishMyStoryChapterUsecase unpublishMyStoryChapter,
    required DeleteMyStoryChapterUsecase deleteMyStoryChapter,
  }) : _getMyStoryChapters = getMyStoryChapters,
       _createMyStoryChapter = createMyStoryChapter,
       _updateMyStoryChapter = updateMyStoryChapter,
       _publishMyStoryChapter = publishMyStoryChapter,
       _unpublishMyStoryChapter = unpublishMyStoryChapter,
       _deleteMyStoryChapter = deleteMyStoryChapter,
       super(const MyStoryDetailsState());

  Future<void> load(String storyId, {bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(isLoading: true, errorMessage: null));
    }
    try {
      final chapters = await _getMyStoryChapters(storyId: storyId);
      final sortedChapters = List.of(chapters)
        ..sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
      emit(
        state.copyWith(
          isLoading: silent ? state.isLoading : false,
          chapters: sortedChapters,
          errorMessage: null,
        ),
      );
    } catch (e) {
      if (silent) return;
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<String?> createChapter({
    required String storyId,
    required int chapterNumber,
    required String title,
    required String content,
  }) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    try {
      await _createMyStoryChapter(
        storyId: storyId,
        chapterNumber: chapterNumber,
        title: title,
        content: content,
      );
      await load(storyId);
      emit(state.copyWith(isSaving: false));
      return null;
    } catch (e) {
      final message = e.toString();
      emit(state.copyWith(isSaving: false, errorMessage: message));
      return message;
    }
  }

  Future<String?> updateChapter({
    required String storyId,
    required String chapterId,
    required int chapterNumber,
    required String title,
    required String content,
  }) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    try {
      await _updateMyStoryChapter(
        chapterId: chapterId,
        chapterNumber: chapterNumber,
        title: title,
        content: content,
      );
      await load(storyId);
      emit(state.copyWith(isSaving: false));
      return null;
    } catch (e) {
      final message = e.toString();
      emit(state.copyWith(isSaving: false, errorMessage: message));
      return message;
    }
  }

  Future<String?> publishChapter({
    required String storyId,
    required String chapterId,
  }) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    try {
      await _publishMyStoryChapter(chapterId: chapterId);
      await load(storyId);
      emit(state.copyWith(isSaving: false));
      return null;
    } catch (e) {
      final message = e.toString();
      emit(state.copyWith(isSaving: false, errorMessage: message));
      return message;
    }
  }

  Future<String?> unpublishChapter({
    required String storyId,
    required String chapterId,
  }) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    try {
      await _unpublishMyStoryChapter(chapterId: chapterId);
      await load(storyId);
      emit(state.copyWith(isSaving: false));
      return null;
    } catch (e) {
      final message = e.toString();
      emit(state.copyWith(isSaving: false, errorMessage: message));
      return message;
    }
  }

  Future<String?> deleteChapter({
    required String storyId,
    required String chapterId,
  }) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    try {
      await _deleteMyStoryChapter(chapterId: chapterId);
      await load(storyId);
      emit(state.copyWith(isSaving: false));
      return null;
    } catch (e) {
      final message = e.toString();
      emit(state.copyWith(isSaving: false, errorMessage: message));
      return message;
    }
  }

  int nextChapterNumber() {
    if (state.chapters.isEmpty) return 1;
    final maxNumber = state.chapters
        .map((chapter) => chapter.chapterNumber)
        .fold<int>(0, (prev, value) => value > prev ? value : prev);
    return maxNumber + 1;
  }
}
