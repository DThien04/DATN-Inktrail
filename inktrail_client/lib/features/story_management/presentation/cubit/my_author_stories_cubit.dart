import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/features/story_management/domain/entities/my_story_entity.dart';
import 'package:ink_trail_client/features/story_management/domain/usecases/story_management_usecases.dart';
import 'package:ink_trail_client/features/story_management/presentation/cubit/my_author_stories_state.dart';

class MyAuthorStoriesCubit extends Cubit<MyAuthorStoriesState> {
  final GetMyStoriesUsecase _getMyStories;
  final CreateMyStoryUsecase _createMyStory;
  final UpdateMyStoryUsecase _updateMyStory;
  final UpdateMyStoryStatusUsecase _updateMyStoryStatus;
  final DeleteMyStoryUsecase _deleteMyStory;

  MyAuthorStoriesCubit({
    required GetMyStoriesUsecase getMyStories,
    required CreateMyStoryUsecase createMyStory,
    required UpdateMyStoryUsecase updateMyStory,
    required UpdateMyStoryStatusUsecase updateMyStoryStatus,
    required DeleteMyStoryUsecase deleteMyStory,
  }) : _getMyStories = getMyStories,
       _createMyStory = createMyStory,
       _updateMyStory = updateMyStory,
       _updateMyStoryStatus = updateMyStoryStatus,
       _deleteMyStory = deleteMyStory,
       super(const MyAuthorStoriesState());

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(isLoading: true, errorMessage: null));
    }
    try {
      final stories = await _getMyStories();
      emit(
        state.copyWith(
          isLoading: silent ? state.isLoading : false,
          errorMessage: null,
          stories: stories,
        ),
      );
    } catch (e) {
      if (silent) return;
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<String?> createStory({
    required String title,
    required String description,
    required String status,
    List<String> tags = const [],
    List<int>? coverBytes,
    String? fileName,
    String? mimeType,
  }) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    try {
      await _createMyStory(
        title: title,
        description: description,
        status: status,
        tags: tags,
        coverBytes: coverBytes,
        fileName: fileName,
        mimeType: mimeType,
      );
      await load();
      emit(state.copyWith(isSaving: false));
      return null;
    } catch (e) {
      final message = e.toString();
      emit(state.copyWith(isSaving: false, errorMessage: message));
      return message;
    }
  }

  Future<String?> updateStory({
    required String storyId,
    required String title,
    required String description,
    required String status,
    List<String> tags = const [],
    List<int>? coverBytes,
    String? fileName,
    String? mimeType,
  }) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    try {
      await _updateMyStory(
        storyId: storyId,
        title: title,
        description: description,
        status: status,
        tags: tags,
        coverBytes: coverBytes,
        fileName: fileName,
        mimeType: mimeType,
      );
      await load();
      emit(state.copyWith(isSaving: false));
      return null;
    } catch (e) {
      final message = e.toString();
      emit(state.copyWith(isSaving: false, errorMessage: message));
      return message;
    }
  }

  Future<String?> deleteStory(MyStoryEntity story) async {
    emit(state.copyWith(deletingStoryId: story.id, errorMessage: null));
    try {
      await _deleteMyStory(storyId: story.id);
      await load();
      emit(state.copyWith(deletingStoryId: null));
      return null;
    } catch (e) {
      final message = e.toString();
      emit(state.copyWith(deletingStoryId: null, errorMessage: message));
      return message;
    }
  }

  Future<String?> updateStoryStatus({
    required String storyId,
    required String status,
  }) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    try {
      await _updateMyStoryStatus(
        storyId: storyId,
        status: status,
      );
      await load();
      emit(state.copyWith(isSaving: false));
      return null;
    } catch (e) {
      final message = e.toString();
      emit(state.copyWith(isSaving: false, errorMessage: message));
      return message;
    }
  }
}
