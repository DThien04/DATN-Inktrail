import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/features/story_download/domain/entities/story_download_chapter_entity.dart';
import 'package:ink_trail_client/features/story_download/domain/usecases/story_download_usecases.dart';

import 'story_download_state.dart';

class StoryDownloadCubit extends Cubit<StoryDownloadState> {
  final GetDownloadedStoryChapterIdsUsecase _getDownloadedIds;
  final DownloadStoryChapterUsecase _downloadChapter;

  StoryDownloadCubit({
    required StoryDownloadSeed seed,
    required GetDownloadedStoryChapterIdsUsecase getDownloadedIds,
    required DownloadStoryChapterUsecase downloadChapter,
  }) : _getDownloadedIds = getDownloadedIds,
       _downloadChapter = downloadChapter,
       super(StoryDownloadState.initial(seed));

  Future<void> initialize() async {
    try {
      final downloadedIds = await _getDownloadedIds(state.seed.storyId);
      if (isClosed) return;
      emit(
        state.copyWith(
          downloadedChapterIds: downloadedIds,
          selectedChapterIds: _initialSelection(
            chapters: state.chapters,
            downloadedChapterIds: downloadedIds,
          ),
          isLoadingDownloadedIds: false,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isLoadingDownloadedIds: false));
    }
  }

  void toggleSelectAll() {
    if (!state.hasChapters || state.downloadableCount == 0 || state.isDownloading) {
      return;
    }

    if (state.isAllSelected) {
      emit(state.copyWith(selectedChapterIds: <String>{}));
      return;
    }

    emit(
      state.copyWith(
        selectedChapterIds: state.chapters
            .where((item) => !state.downloadedChapterIds.contains(item.id))
            .map((item) => item.id)
            .toSet(),
      ),
    );
  }

  void toggleChapter(String chapterId) {
    if (state.downloadedChapterIds.contains(chapterId) || state.isDownloading) {
      return;
    }

    final next = Set<String>.from(state.selectedChapterIds);
    if (next.contains(chapterId)) {
      next.remove(chapterId);
    } else {
      next.add(chapterId);
    }
    emit(state.copyWith(selectedChapterIds: next));
  }

  Future<void> downloadSelected() async {
    final selected = state.chapters
        .where((item) => state.selectedChapterIds.contains(item.id))
        .toList();
    if (selected.isEmpty || state.isDownloading) return;

    emit(
      state.copyWith(
        isDownloading: true,
        downloadProgressDone: 0,
        downloadProgressTotal: selected.length,
      ),
    );

    var success = 0;
    var failed = 0;
    final downloadedIds = Set<String>.from(state.downloadedChapterIds);
    final selectedIds = Set<String>.from(state.selectedChapterIds);

    for (var i = 0; i < selected.length; i++) {
      final chapter = selected[i];
      try {
        await _downloadChapter(
          storyId: state.seed.storyId,
          storyTitle: state.seed.storyTitle,
          storySlug: state.seed.storySlug,
          storyAuthor: state.seed.storyAuthor,
          storyCoverUrl: state.seed.storyCoverUrl,
          chapter: chapter,
        );
        success++;
        downloadedIds.add(chapter.id);
        selectedIds.remove(chapter.id);
      } catch (_) {
        failed++;
      }

      if (isClosed) return;
      emit(
        state.copyWith(
          downloadedChapterIds: downloadedIds,
          selectedChapterIds: selectedIds,
          downloadProgressDone: i + 1,
        ),
      );
    }

    if (isClosed) return;
    final total = selected.length;
    emit(
      state.copyWith(
        isDownloading: false,
        message: StoryDownloadMessage(
          failed == 0
              ? 'Đã tải $success/$total chương mới.'
              : 'Đã tải $success/$total chương mới, lỗi $failed.',
        ),
        messageVersion: state.messageVersion + 1,
      ),
    );
  }

  void clearMessage() {
    emit(state.copyWith(message: null));
  }

  Set<String> _initialSelection({
    required List<StoryDownloadChapterEntity> chapters,
    required Set<String> downloadedChapterIds,
  }) {
    for (final chapter in chapters) {
      if (!downloadedChapterIds.contains(chapter.id)) {
        return <String>{chapter.id};
      }
    }
    return <String>{};
  }
}
