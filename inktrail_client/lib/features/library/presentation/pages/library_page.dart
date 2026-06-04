import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ink_trail_client/core/di/service_locator.dart';
import 'package:ink_trail_client/core/local/offline_repository.dart';
import 'package:ink_trail_client/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ink_trail_client/features/auth/presentation/cubit/auth_state.dart';
import 'package:ink_trail_client/features/library/presentation/cubit/library_cubit.dart';
import 'package:ink_trail_client/features/library/presentation/cubit/library_state.dart';
import 'package:ink_trail_client/features/reader/presentation/models/reader_view_models.dart'
    as reader_vm;
import 'package:ink_trail_client/features/reader/presentation/pages/reader_page.dart';
import 'package:ink_trail_client/features/story_detail/domain/usecases/get_story_chapters_usecase.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = sl<AuthCubit>();
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authCubit),
        BlocProvider(
          create: (_) {
            final cubit = sl<LibraryCubit>();
            cubit.loadHistory();
            return cubit;
          },
        ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated ||
              state.status == AuthStatus.unauthenticated) {
            context.read<LibraryCubit>().loadHistory(forceRefresh: true);
          }
        },
        child: const _LibraryBody(),
      ),
    );
  }
}

class _LibraryBody extends StatelessWidget {
  const _LibraryBody();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              const _LibraryHeader(),
              BlocBuilder<LibraryCubit, LibraryState>(
                builder: (context, state) => _LibrarySummaryRow(
                  itemCount: state.historyItems.length,
                  latestUpdatedAt: state.historyItems.isEmpty
                      ? null
                      : state.historyItems.first.updatedAt,
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  padding: const EdgeInsets.all(4),
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: scheme.outlineVariant,
                      width: 0.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                  labelColor: scheme.primary,
                  unselectedLabelColor: scheme.onSurfaceVariant,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'Lịch sử đọc'),
                    Tab(text: 'Đã tải'),
                  ],
                ),
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    _ReadingHistoryTab(),
                    _DownloadedTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryHeader extends StatelessWidget {
  const _LibraryHeader();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thư viện',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Lưu tiến độ và đọc tiếp nhanh',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibrarySummaryRow extends StatelessWidget {
  final int itemCount;
  final DateTime? latestUpdatedAt;

  const _LibrarySummaryRow({
    required this.itemCount,
    required this.latestUpdatedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              icon: Iconsax.book_1,
              title: 'Đang đọc',
              value: '$itemCount truyện',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryCard(
              icon: Iconsax.clock,
              title: 'Lần đọc cuối',
              value: latestUpdatedAt == null
                  ? '--'
                  : _formatRelativeTime(latestUpdatedAt!),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: scheme.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingHistoryTab extends StatelessWidget {
  const _ReadingHistoryTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        if (state.status == LibraryHistoryStatus.loading &&
            state.historyItems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == LibraryHistoryStatus.failure &&
            state.historyItems.isEmpty) {
          return _ErrorState(
            message: state.errorMessage ?? 'Không thể tải lịch sử đọc.',
            onRetry: () => context.read<LibraryCubit>().loadHistory(
              forceRefresh: true,
            ),
          );
        }

        if (state.historyItems.isEmpty) {
          return _EmptyState(
            isLoggedIn: state.isLoggedIn,
            onRefresh: () => context.read<LibraryCubit>().loadHistory(
              forceRefresh: true,
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFFC4773B),
          onRefresh: () => context.read<LibraryCubit>().loadHistory(
            forceRefresh: true,
          ),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              ...state.historyItems.map((item) => _HistoryCard(item: item)),
            ],
          ),
        );
      },
    );
  }
}

class _HistoryCard extends StatefulWidget {
  final LibraryHistoryItem item;

  const _HistoryCard({required this.item});

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool _isOpeningReader = false;

  LibraryHistoryItem get item => widget.item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.coverUrl.isNotEmpty
                ? Image.network(
                    item.coverUrl,
                    width: 76,
                    height: 106,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _fallbackCover(),
                  )
                : _fallbackCover(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.storyTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.chapterLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Iconsax.clock,
                      size: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatRelativeTime(item.updatedAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 34,
                  child: FilledButton.icon(
                    onPressed: _isOpeningReader ? null : _openReaderFromHistory,
                    icon: _isOpeningReader
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Iconsax.play, size: 14),
                    label: Text(_isOpeningReader ? 'Đang mở...' : 'Đọc tiếp'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFC4773B),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openReaderFromHistory() async {
    if (_isOpeningReader) return;
    setState(() => _isOpeningReader = true);

    try {
      final chapters = (await sl<GetStoryChaptersUsecase>()(
        storyId: item.storyId,
      ))
          .map(
            (chapter) => reader_vm.ReaderChapter(
              id: chapter.id,
              number: chapter.number,
              title: chapter.title,
              paragraphs: chapter.paragraphs,
              likeCount: chapter.likeCount,
              commentCount: chapter.commentCount,
              isLiked: chapter.isLiked,
            ),
          )
          .toList();

      if (!mounted) return;
      if (chapters.isEmpty) {
        _showMessage('Truyện này chưa có chương để đọc.');
        return;
      }

      final safeIndex = item.lastChapterIndex.clamp(0, chapters.length - 1);
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReaderPage(
            storyId: item.storyId,
            storyTitle: item.storyTitle,
            chapters: chapters,
            initialChapterIndex: safeIndex,
            initialScrollPercent: item.lastPosition,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('Không thể mở chương đang đọc dở lúc này.');
    } finally {
      if (mounted) {
        setState(() => _isOpeningReader = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  Widget _fallbackCover() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 76,
      height: 106,
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: const Icon(Iconsax.book_1, color: Color(0xFFC4773B)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFB8A89C),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8E8279),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC4773B),
                foregroundColor: Colors.white,
              ),
              child: const Text('Tải lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isLoggedIn;
  final VoidCallback onRefresh;

  const _EmptyState({
    required this.isLoggedIn,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.menu_book_rounded,
              color: Color(0xFFCCBBAA),
              size: 30,
            ),
            const SizedBox(height: 10),
            Text(
              isLoggedIn
                  ? 'Bạn chưa có lịch sử đọc.'
                  : 'Chưa có lịch sử đọc trên thiết bị này.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8E8279),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRefresh,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFC4773B),
                side: const BorderSide(color: Color(0xFFC4773B), width: 0.8),
              ),
              child: const Text('Làm mới'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadedTab extends StatelessWidget {
  const _DownloadedTab();

  @override
  Widget build(BuildContext context) {
    return const _DownloadedStoriesList();
  }
}

class _DownloadedStoriesList extends StatefulWidget {
  const _DownloadedStoriesList();

  @override
  State<_DownloadedStoriesList> createState() => _DownloadedStoriesListState();
}

class _DownloadedStoriesListState extends State<_DownloadedStoriesList> {
  late Future<List<DownloadedStoryLocal>> _storiesFuture;

  @override
  void initState() {
    super.initState();
    _storiesFuture = _loadStories();
  }

  Future<List<DownloadedStoryLocal>> _loadStories() {
    return sl<OfflineRepository>().getDownloadedStories();
  }

  Future<void> _refresh() async {
    final nextFuture = _loadStories();
    setState(() {
      _storiesFuture = nextFuture;
    });
    await nextFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DownloadedStoryLocal>>(
      future: _storiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFC4773B)),
          );
        }

        if (snapshot.hasError) {
          return _ErrorState(
            message: 'Không thể tải danh sách đã tải xuống.',
            onRetry: _refresh,
          );
        }

        final stories = snapshot.data ?? const <DownloadedStoryLocal>[];
        if (stories.isEmpty) {
          return RefreshIndicator(
            color: const Color(0xFFC4773B),
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: const [
                _DownloadedNotice(),
                SizedBox(height: 16),
                _DownloadedEmptyState(),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFFC4773B),
          onRefresh: _refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: stories.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == 0) return const SizedBox.shrink();
              final story = stories[index - 1];
              return _DownloadedStoryCard(
                story: story,
                onOpen: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _DownloadedStoryChaptersPage(story: story),
                    ),
                  );
                  if (!mounted) return;
                  await _refresh();
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _DownloadedNotice extends StatelessWidget {
  const _DownloadedNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Iconsax.mobile, size: 18, color: Color(0xFFC4773B)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Nội dung đã tải được lưu trên thiết bị này để đọc offline.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF775A45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadedEmptyState extends StatelessWidget {
  const _DownloadedEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32, horizontal: 18),
        child: Column(
          children: [
            Icon(Iconsax.cloud_remove, color: Color(0xFFCCBBAA), size: 30),
            SizedBox(height: 10),
            Text(
              'Bạn chưa tải chương nào. Mở trang chi tiết truyện để tải.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8E8279),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadedStoryCard extends StatelessWidget {
  final DownloadedStoryLocal story;
  final VoidCallback onOpen;

  const _DownloadedStoryCard({
    required this.story,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: story.coverUrl.trim().isNotEmpty
                    ? Image.network(
                        story.coverUrl,
                        width: 72,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _downloadedCoverFallback(context),
                      )
                    : _downloadedCoverFallback(context),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      story.author.trim().isEmpty ? 'Tác giả' : story.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${story.downloadedChapterCount} chương - ${_formatBytes(story.totalBytes)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cập nhật ${_formatRelativeTime(story.latestDownloadedAt)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Iconsax.arrow_right_3,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _downloadedCoverFallback(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 72,
      height: 100,
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: const Icon(Iconsax.book_1, color: Color(0xFFC4773B)),
    );
  }
}

class _DownloadedStoryChaptersPage extends StatefulWidget {
  final DownloadedStoryLocal story;

  const _DownloadedStoryChaptersPage({required this.story});

  @override
  State<_DownloadedStoryChaptersPage> createState() =>
      _DownloadedStoryChaptersPageState();
}

class _DownloadedStoryChaptersPageState
    extends State<_DownloadedStoryChaptersPage> {
  late Future<List<DownloadedChapterLocal>> _chaptersFuture;
  bool _isOpeningReader = false;

  @override
  void initState() {
    super.initState();
    _chaptersFuture = _loadChapters();
  }

  Future<List<DownloadedChapterLocal>> _loadChapters() {
    return sl<OfflineRepository>().getDownloadedChapters(widget.story.storyId);
  }

  Future<void> _refresh() async {
    final nextFuture = _loadChapters();
    setState(() {
      _chaptersFuture = nextFuture;
    });
    await nextFuture;
  }

  Future<void> _deleteChapter(DownloadedChapterLocal chapter) async {
    final shouldDelete = await _showDeleteChapterDialog(chapter);
    if (!shouldDelete || !mounted) return;

    await sl<OfflineRepository>().deleteDownloadedChapter(chapter.chapterId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Đã xóa chương khỏi danh sách đã tải.'),
      ),
    );
    await _refresh();
  }

  Future<bool> _showDeleteChapterDialog(DownloadedChapterLocal chapter) async {
    final chapterLabel = chapter.title.trim().isEmpty
        ? 'Chương ${chapter.chapterNumber}'
        : chapter.title.trim();
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Iconsax.trash,
                        size: 16,
                        color: Color(0xFFC4773B),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Xóa chương đã tải',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Bạn có chắc muốn xóa "$chapterLabel" khỏi thư viện không?',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: scheme.onSurfaceVariant,
                          side: BorderSide(color: scheme.outlineVariant),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Giữ lại'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFC4773B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Xóa'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  Future<void> _openDownloadedReader(
    List<DownloadedChapterLocal> chapters,
    DownloadedChapterLocal targetChapter,
  ) async {
    if (_isOpeningReader) return;
    setState(() => _isOpeningReader = true);

    try {
      final offlineRepository = sl<OfflineRepository>();
      final readable = <reader_vm.ReaderChapter>[];
      for (final chapter in chapters) {
        final parsed = await offlineRepository.readDownloadedChapter(chapter);
        if (parsed == null) continue;
        readable.add(
          reader_vm.ReaderChapter(
            id: parsed.chapterId,
            number: parsed.chapterNumber,
            title: parsed.chapterTitle,
            paragraphs: parsed.paragraphs,
          ),
        );
      }

      if (!mounted) return;
      if (readable.isEmpty) {
        _showMessage('Không có dữ liệu chương.');
        return;
      }

      final targetIndex = readable.indexWhere(
        (chapter) => chapter.id == targetChapter.chapterId,
      );

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReaderPage(
            storyId: widget.story.storyId,
            storyTitle: widget.story.title,
            chapters: readable,
            initialChapterIndex: targetIndex >= 0 ? targetIndex : 0,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('Không thể mở chương offline lúc này.');
    } finally {
      if (mounted) {
        setState(() => _isOpeningReader = false);
      }
    }
  }


  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.story.title),
        centerTitle: true,
      ),
      body: FutureBuilder<List<DownloadedChapterLocal>>(
        future: _chaptersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFC4773B)),
            );
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: 'Không thể tải danh sách chương đã tải.',
              onRetry: _refresh,
            );
          }

          final chapters = snapshot.data ?? const <DownloadedChapterLocal>[];
          if (chapters.isEmpty) {
            return RefreshIndicator(
              color: const Color(0xFFC4773B),
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 80),
                  Center(
                    child: Text(
                      'Không còn chương nào đã tải.',
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFFC4773B),
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: chapters.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                final label = chapter.title.trim().isEmpty
                    ? 'Chương ${chapter.chapterNumber}'
                    : chapter.title;
                return Material(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  shadowColor: Colors.black.withValues(alpha: 0.08),
                  elevation: 1,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _isOpeningReader
                        ? null
                        : () => _openDownloadedReader(chapters, chapter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: scheme.outlineVariant.withValues(alpha: 0.55),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            scheme.surfaceContainerLow,
                            scheme.surface,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chương ${chapter.chapterNumber}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: scheme.onSurfaceVariant,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  chapter.downloadedAt == null
                                      ? 'Đã tải'
                                      : 'Đã tải ${_formatRelativeTime(chapter.downloadedAt!)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: scheme.outlineVariant.withValues(
                                  alpha: 0.45,
                                ),
                              ),
                            ),
                            child: IconButton(
                              tooltip: 'Xóa chương',
                              onPressed: () => _deleteChapter(chapter),
                              icon: Icon(
                                Iconsax.trash,
                                size: 17,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

String _formatRelativeTime(DateTime updatedAt) {
  final now = DateTime.now().toUtc();
  final value = updatedAt.toUtc();
  final diff = now.difference(value);

  if (diff.inSeconds < 60) return 'Vừa xong';
  if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
  if (diff.inHours < 24) return '${diff.inHours} giờ trước';
  if (diff.inDays == 1) return 'Hôm qua';
  if (diff.inDays < 7) return '${diff.inDays} ngày trước';
  return '${value.day}/${value.month}/${value.year}';
}

String _formatBytes(int bytes) {
  if (bytes <= 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB'];
  var value = bytes.toDouble();
  var unitIndex = 0;

  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex++;
  }

  final precision = (unitIndex == 0 || value >= 10) ? 0 : 1;
  return '${value.toStringAsFixed(precision)} ${units[unitIndex]}';
}





