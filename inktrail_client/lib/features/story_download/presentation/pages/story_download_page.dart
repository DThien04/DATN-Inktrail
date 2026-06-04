import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/features/story_download/presentation/cubit/story_download_cubit.dart';
import 'package:ink_trail_client/features/story_download/presentation/cubit/story_download_state.dart';

class StoryDownloadPage extends StatelessWidget {
  const StoryDownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoryDownloadCubit, StoryDownloadState>(
      listenWhen: (previous, current) =>
          previous.messageVersion != current.messageVersion,
      listener: (context, state) {
        final message = state.message;
        if (message == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(message.text),
          ),
        );
        context.read<StoryDownloadCubit>().clearMessage();
      },
      child: BlocBuilder<StoryDownloadCubit, StoryDownloadState>(
        builder: (context, state) {
          final scheme = Theme.of(context).colorScheme;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: const Text('Tải xuống'),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: scheme.outlineVariant, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.seed.storyTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Đã chọn ${state.selectedChapterIds.length}/${state.downloadableCount} chương mới',
                              style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: (state.isDownloading ||
                                      state.downloadableCount == 0)
                                  ? null
                                  : () => context
                                      .read<StoryDownloadCubit>()
                                      .toggleSelectAll(),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFC4773B),
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 24),
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                state.isAllSelected
                                    ? 'Bỏ chọn tất cả'
                                    : 'Chọn tất cả',
                              ),
                            ),
                          ],
                        ),
                        if (state.isDownloading) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: state.downloadProgressTotal == 0
                                  ? null
                                  : state.downloadProgressDone /
                                      state.downloadProgressTotal,
                              minHeight: 8,
                              backgroundColor: scheme.surfaceContainerHighest,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Đang tải ${state.downloadProgressDone}/${state.downloadProgressTotal} chương',
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(child: _buildBody(context, state)),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed:
                        (state.selectedChapterIds.isEmpty || state.isDownloading)
                        ? null
                        : () => context.read<StoryDownloadCubit>().downloadSelected(),
                    icon: state.isDownloading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.file_download_outlined),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC4773B),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: scheme.surfaceContainerHighest,
                      disabledForegroundColor: scheme.onSurfaceVariant,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    label: Text(
                      state.isDownloading
                          ? 'Đang tải...'
                          : 'Tải ${state.selectedChapterIds.length} chương mới',
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, StoryDownloadState state) {
    final scheme = Theme.of(context).colorScheme;

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFC4773B)),
      );
    }

    if (!state.hasChapters) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Truyện này chưa có chương để tải.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8E8279),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: state.chapters.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final chapter = state.chapters[index];
        final selected = state.selectedChapterIds.contains(chapter.id);
        final downloaded = state.downloadedChapterIds.contains(chapter.id);
        final cardColor = downloaded
            ? scheme.surfaceContainerLow
            : (selected
                  ? scheme.primaryContainer.withValues(alpha: 0.28)
                  : scheme.surface);
        final cardBorderColor = downloaded
            ? scheme.outlineVariant
            : (selected
                  ? scheme.primary.withValues(alpha: 0.55)
                  : scheme.outlineVariant);

        return Material(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: (state.isDownloading || downloaded)
                ? null
                : () => context.read<StoryDownloadCubit>().toggleChapter(chapter.id),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cardBorderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: downloaded
                          ? scheme.tertiaryContainer
                          : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: downloaded
                        ? Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: scheme.onTertiaryContainer,
                          )
                        : Text(
                            '${chapter.number}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          downloaded
                              ? 'Đã tải trên thiết bị'
                              : 'Sẵn sàng tải offline',
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: downloaded ? true : selected,
                    onChanged: downloaded || state.isDownloading
                        ? null
                        : (_) => context
                              .read<StoryDownloadCubit>()
                              .toggleChapter(chapter.id),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
