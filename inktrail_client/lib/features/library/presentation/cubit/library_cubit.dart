import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/core/network/token_storage.dart';
import 'package:ink_trail_client/core/storage/reading_progress_local_cache.dart';
import 'package:ink_trail_client/features/library/domain/entities/library_remote_progress_entity.dart';
import 'package:ink_trail_client/features/library/domain/usecases/library_remote_history_usecases.dart';

import 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> {
  final TokenStorage _tokenStorage;
  final ReadingProgressLocalCache _localCache;
  final GetLibraryRemoteHistoryUsecase _getRemoteHistory;
  final SaveLibraryRemoteProgressUsecase _saveRemoteProgress;

  LibraryCubit({
    required TokenStorage tokenStorage,
    required ReadingProgressLocalCache localCache,
    required GetLibraryRemoteHistoryUsecase getRemoteHistory,
    required SaveLibraryRemoteProgressUsecase saveRemoteProgress,
  })  : _tokenStorage = tokenStorage,
        _localCache = localCache,
        _getRemoteHistory = getRemoteHistory,
        _saveRemoteProgress = saveRemoteProgress,
        super(const LibraryState());

  Future<void> loadHistory({bool forceRefresh = false}) async {
    if (isClosed) return;
    if (state.status == LibraryHistoryStatus.loading && !forceRefresh) {
      return;
    }

    emit(
      state.copyWith(
        status: LibraryHistoryStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final hasToken = await _tokenStorage.hasToken();
      if (isClosed) return;
      if (hasToken) {
        await _syncWithServer();
        if (isClosed) return;
      }

      final localEntries = await _localCache.getAllProgress();
      if (isClosed) return;
      final items = localEntries
          .map(
            (entry) {
              final title = entry.storyTitle.isEmpty
                  ? 'Truyện không xác định'
                  : entry.storyTitle;

              return LibraryHistoryItem(
                storyId: entry.storyId,
                storyTitle: title,
                storySlug: entry.storySlug,
                coverUrl: entry.storyCoverUrl,
                lastChapterIndex: entry.chapterIndex,
                lastPosition: entry.lastPosition,
                updatedAt: entry.updatedAt,
              );
            },
          )
          .toList();

      if (isClosed) return;
      emit(
        state.copyWith(
          status: LibraryHistoryStatus.success,
          historyItems: items,
          isLoggedIn: hasToken,
          errorMessage: null,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: LibraryHistoryStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _syncWithServer() async {
    final serverItems = await _fetchServerHistory();
    final localItems = await _localCache.getAllProgress();

    final localByStory = {
      for (final item in localItems) item.storyId: item,
    };
    final serverByStory = {
      for (final item in serverItems) item.storyId: item,
    };

    final storyIds = <String>{
      ...localByStory.keys,
      ...serverByStory.keys,
    };

    for (final storyId in storyIds) {
      final local = localByStory[storyId];
      final server = serverByStory[storyId];

      if (local != null && server != null) {
        if (local.updatedAt.isAfter(server.updatedAt)) {
          await _pushProgressToServer(local);
        } else if (server.updatedAt.isAfter(local.updatedAt)) {
          await _localCache.saveLastChapterIndex(
            storyId: storyId,
            chapterIndex: server.lastChapterIndex,
            lastPosition: server.lastPosition,
            updatedAt: server.updatedAt,
            storyTitle: server.storyTitle,
            storyCoverUrl: server.coverUrl,
            storySlug: server.storySlug,
          );
        } else {
          await _localCache.saveLastChapterIndex(
            storyId: storyId,
            chapterIndex: local.chapterIndex,
            lastPosition: local.lastPosition ?? server.lastPosition,
            updatedAt: local.updatedAt,
            storyTitle: local.storyTitle.isNotEmpty
                ? local.storyTitle
                : server.storyTitle,
            storyCoverUrl: local.storyCoverUrl.isNotEmpty
                ? local.storyCoverUrl
                : server.coverUrl,
            storySlug:
                local.storySlug.isNotEmpty ? local.storySlug : server.storySlug,
          );
        }
        continue;
      }

      if (local != null) {
        await _pushProgressToServer(local);
        continue;
      }

      if (server != null) {
        await _localCache.saveLastChapterIndex(
          storyId: storyId,
          chapterIndex: server.lastChapterIndex,
          lastPosition: server.lastPosition,
          updatedAt: server.updatedAt,
          storyTitle: server.storyTitle,
          storyCoverUrl: server.coverUrl,
          storySlug: server.storySlug,
        );
      }
    }
  }

  Future<void> _pushProgressToServer(ReadingProgressCacheEntry item) async {
    try {
      await _saveRemoteProgress(
        storyId: item.storyId,
        chapterIndex: item.chapterIndex,
        lastPosition: _normalizeScrollPercent(item.lastPosition),
      );
    } catch (_) {}
  }

  Future<List<LibraryRemoteProgressEntity>> _fetchServerHistory() async {
    try {
      return _getRemoteHistory(limit: 100);
    } catch (_) {
      return const [];
    }
  }
}

int? _normalizeScrollPercent(int? value) {
  if (value == null || value < 0) return null;
  if (value > 100) return 100;
  return value;
}
