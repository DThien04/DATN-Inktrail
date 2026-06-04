import 'package:ink_trail_client/features/story_download/domain/entities/story_download_chapter_entity.dart';

class StoryDownloadMessage {
  final String text;

  const StoryDownloadMessage(this.text);
}

class StoryDownloadState {
  final StoryDownloadSeed seed;
  final Set<String> downloadedChapterIds;
  final Set<String> selectedChapterIds;
  final bool isLoadingDownloadedIds;
  final bool isDownloading;
  final int downloadProgressDone;
  final int downloadProgressTotal;
  final StoryDownloadMessage? message;
  final int messageVersion;

  const StoryDownloadState({
    required this.seed,
    required this.downloadedChapterIds,
    required this.selectedChapterIds,
    required this.isLoadingDownloadedIds,
    required this.isDownloading,
    required this.downloadProgressDone,
    required this.downloadProgressTotal,
    required this.message,
    required this.messageVersion,
  });

  factory StoryDownloadState.initial(StoryDownloadSeed seed) {
    return StoryDownloadState(
      seed: seed,
      downloadedChapterIds: const <String>{},
      selectedChapterIds: const <String>{},
      isLoadingDownloadedIds: true,
      isDownloading: false,
      downloadProgressDone: 0,
      downloadProgressTotal: 0,
      message: null,
      messageVersion: 0,
    );
  }

  List<StoryDownloadChapterEntity> get chapters => seed.chapters;
  bool get isLoading => seed.isLoadingSource || isLoadingDownloadedIds;
  bool get hasChapters => chapters.isNotEmpty;
  int get downloadableCount =>
      chapters.where((item) => !downloadedChapterIds.contains(item.id)).length;
  bool get isAllSelected =>
      downloadableCount > 0 && selectedChapterIds.length == downloadableCount;

  StoryDownloadState copyWith({
    StoryDownloadSeed? seed,
    Set<String>? downloadedChapterIds,
    Set<String>? selectedChapterIds,
    bool? isLoadingDownloadedIds,
    bool? isDownloading,
    int? downloadProgressDone,
    int? downloadProgressTotal,
    Object? message = _sentinel,
    int? messageVersion,
  }) {
    return StoryDownloadState(
      seed: seed ?? this.seed,
      downloadedChapterIds: downloadedChapterIds ?? this.downloadedChapterIds,
      selectedChapterIds: selectedChapterIds ?? this.selectedChapterIds,
      isLoadingDownloadedIds:
          isLoadingDownloadedIds ?? this.isLoadingDownloadedIds,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgressDone: downloadProgressDone ?? this.downloadProgressDone,
      downloadProgressTotal: downloadProgressTotal ?? this.downloadProgressTotal,
      message: identical(message, _sentinel)
          ? this.message
          : message as StoryDownloadMessage?,
      messageVersion: messageVersion ?? this.messageVersion,
    );
  }
}

const Object _sentinel = Object();
