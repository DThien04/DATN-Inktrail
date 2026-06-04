import 'dart:async';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/core/auth/auth_gate.dart';
import 'package:ink_trail_client/core/di/service_locator.dart';
import 'package:ink_trail_client/core/network/api_exception.dart';
import 'package:ink_trail_client/core/network/token_storage.dart';
import 'package:ink_trail_client/core/storage/reading_progress_local_cache.dart';
import 'package:ink_trail_client/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ink_trail_client/features/auth/presentation/cubit/auth_state.dart';
import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';
import 'package:ink_trail_client/features/profile/presentation/utils/profile_navigation.dart';
import 'package:ink_trail_client/features/reader/presentation/models/reader_view_models.dart'
    as reader_vm;
import 'package:ink_trail_client/features/reader/presentation/pages/reader_page.dart';
import 'package:ink_trail_client/features/report/domain/usecases/report_usecases.dart';
import 'package:ink_trail_client/features/report/presentation/models/report_submission_payload.dart';
import 'package:ink_trail_client/features/report/presentation/widgets/report_submit_sheet.dart';

import 'package:ink_trail_client/features/story_detail/domain/entities/story_detail_info_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/entities/story_suggestion_entity.dart';
import 'package:ink_trail_client/features/story_detail/domain/usecases/sync_story_reading_progress_usecase.dart';
import 'package:ink_trail_client/features/story_detail/presentation/cubit/story_detail_cubit.dart';
import 'package:ink_trail_client/features/story_detail/presentation/cubit/story_detail_state.dart';
import 'package:ink_trail_client/features/story_detail/presentation/widgets/story_detail_chapter_tab.dart';
import 'package:ink_trail_client/features/story_detail/presentation/widgets/story_detail_detail_tab.dart';
import 'package:ink_trail_client/features/story_detail/presentation/widgets/story_detail_hero_card.dart';
import 'package:ink_trail_client/features/story_detail/presentation/widgets/story_detail_highlighted_comments_section.dart';
import 'package:ink_trail_client/features/story_detail/presentation/widgets/story_detail_stats_card.dart';
import 'package:ink_trail_client/features/story_detail/presentation/widgets/story_detail_tab_bar.dart';
import 'package:ink_trail_client/features/story_detail/presentation/widgets/story_detail_top_bar.dart';
import 'package:ink_trail_client/features/story_download/domain/entities/story_download_chapter_entity.dart';
import 'package:ink_trail_client/features/story_download/presentation/cubit/story_download_cubit.dart';
import 'package:ink_trail_client/features/story_download/presentation/pages/story_download_page.dart';
import 'package:ink_trail_client/features/story_rating/presentation/cubit/story_rating_cubit.dart';
import 'package:ink_trail_client/features/story_rating/presentation/cubit/story_rating_state.dart';
import 'package:ink_trail_client/features/story_rating/presentation/widgets/story_rating_sheet.dart';

class StoryDetailPage extends StatefulWidget {
  final StoryEntity? story;
  final String initialOpenChapterId;

  const StoryDetailPage({
    super.key,
    this.story,
    this.initialOpenChapterId = '',
  });

  @override
  State<StoryDetailPage> createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage> {
  int _tabIndex = 0;
  final _authCubit = sl<AuthCubit>();
  final _reportStory = sl<SubmitStoryReportUsecase>();
  late final StoryDetailCubit _storyDetailCubit;
  final _tokenStorage = sl<TokenStorage>();
  final _readingProgressLocalCache = sl<ReadingProgressLocalCache>();
  final _syncStoryReadingProgress = sl<SyncStoryReadingProgressUsecase>();
  StreamSubscription<AuthState>? _authStateSub;
  int? _resumeChapterIndex;
  int? _resumeLastPosition;
  bool _didOpenInitialChapter = false;
  bool _isSubmittingStoryReport = false;

  bool get _hasStory => widget.story != null;
  StoryEntity get _story => widget.story!;
  StoryDetailState get _detailState => _storyDetailCubit.state;
  List<reader_vm.ReaderChapter> get _activeReaderChapters => _detailState.chapters
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
  bool get _isOwnStory {
    final currentUserId = _authCubit.state.user?.id ?? '';
    return currentUserId.isNotEmpty &&
        _detailState.authorId.isNotEmpty &&
        currentUserId == _detailState.authorId;
  }

  String get _storyId => _detailState.storyId;

  @override
  void initState() {
    super.initState();
    _storyDetailCubit = sl<StoryDetailCubit>(
      param1: StoryDetailSeed(story: widget.story),
    )..initialize();
    _authStateSub = _authCubit.stream.listen(_handleAuthStateChanged);
  }

  @override
  void dispose() {
    _authStateSub?.cancel();
    _storyDetailCubit.close();
    super.dispose();
  }

  void _handleAuthStateChanged(AuthState state) {
    if (!mounted) return;

    if (state.status == AuthStatus.authenticated ||
        state.status == AuthStatus.unauthenticated) {
      _storyDetailCubit.handleAuthStateChanged(
        isAuthenticated: state.status == AuthStatus.authenticated,
      );
    }
  }

  Future<void> _openAuthorProfile() async {
    if (_detailState.authorId.isEmpty) return;

    await openUserProfile(
      context,
      userId: _detailState.authorId,
      initialName: _story.author,
      initialBio: _detailState.authorBio,
      initialStoryCount: _detailState.authorStoryCount,
    );
  }

  Future<void> _maybeOpenInitialChapter() async {
    if (!mounted || _didOpenInitialChapter) return;
    final targetChapterId = widget.initialOpenChapterId.trim();
    if (targetChapterId.isEmpty || _activeReaderChapters.isEmpty) return;

    final chapterIndex = _activeReaderChapters.indexWhere(
      (chapter) => chapter.id == targetChapterId,
    );
    if (chapterIndex < 0) return;

    _didOpenInitialChapter = true;
    await _openReader(chapterIndex: chapterIndex);
  }

  Future<void> _loadReadingProgress() async {
    final snapshot = await _loadReadingProgressSnapshot();
    if (!mounted) return;
    setState(() {
      _resumeChapterIndex = snapshot.chapterIndex;
      _resumeLastPosition = snapshot.lastPosition;
    });
  }

  Future<void> _openReader({required int chapterIndex}) async {
    final safeInitialIndex = _normalizeChapterIndex(
      chapterIndex,
      _activeReaderChapters.length,
    );
    if (safeInitialIndex == null) return;
    final initialScrollPercent =
        safeInitialIndex == _resumeChapterIndex ? _resumeLastPosition : null;

    final readerResult =
        await Navigator.of(context).push<reader_vm.ReaderSessionResult>(
      MaterialPageRoute(
        builder: (_) => ReaderPage(
          storyId: _storyId,
          storyTitle: _story.title,
          chapters: _activeReaderChapters,
          initialChapterIndex: safeInitialIndex,
          initialScrollPercent: initialScrollPercent,
          isOwnStory: _isOwnStory,
        ),
      ),
    );

    if (readerResult == null) return;
    final hiddenMessage = readerResult.chapterHiddenMessage?.trim();
    if (hiddenMessage != null && hiddenMessage.isNotEmpty) {
      _showStoryToast(hiddenMessage);
      unawaited(_storyDetailCubit.loadChapters());
      return;
    }
    final safeIndex = _normalizeChapterIndex(
      readerResult.chapterIndex,
      _detailState.chapters.length,
    );
    if (safeIndex == null) return;

    final didApplyReaderResult = _storyDetailCubit.applyReaderSessionResult(
      readerResult,
    );
    if (!didApplyReaderResult) return;

    await _saveReadingProgressSnapshot(
      storyId: _storyId,
      chapterIndex: safeIndex,
      lastPosition: readerResult.lastScrollPercent,
      storyTitle: _story.title,
      storyCoverUrl: _story.coverUrl,
      storySlug: _story.slug,
    );

    if (!mounted) return;
    setState(() {
      _resumeChapterIndex = safeIndex;
      _resumeLastPosition = readerResult.lastScrollPercent;
    });
  }

  Future<void> _handleStoryDetailChaptersChanged(StoryDetailState state) async {
    if (state.chapters.isEmpty) return;
    await _loadReadingProgress();
    await _maybeOpenInitialChapter();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasStory) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                const Spacer(),
                Center(
                  child: Text(
                    'Không có dữ liệu truyện để hiển thị',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
    }

    return BlocProvider.value(
      value: _storyDetailCubit,
      child: BlocConsumer<StoryDetailCubit, StoryDetailState>(
        listenWhen: (previous, current) => previous.chapters != current.chapters,
        listener: (context, state) {
          unawaited(_handleStoryDetailChaptersChanged(state));
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        StoryDetailTopBar(
                          onBack: () => Navigator.of(context).pop(),
                          onDownload: _openDownloadChaptersScreen,
                          onMore: _isOwnStory ? null : _openStoryReportSheet,
                          showMore: !_isOwnStory,
                        ),
                        const SizedBox(height: 14),
                        StoryDetailHeroCard(
                          title: _story.title,
                          author: _story.author,
                          onTapAuthor: state.authorId.isEmpty ? null : _openAuthorProfile,
                          category: state.storyCategory,
                          coverUrl: _story.coverUrl,
                          tags: state.storyTags,
                        ),
                        const SizedBox(height: 16),
                        StoryDetailStatsCard(
                          likeText: _formatCount(state.storyLikeCount),
                          readText: _formatCount(state.storyReadCount),
                          ratingText: state.storyRating.toStringAsFixed(1),
                          onTapRating: _openRatingBottomSheet,
                        ),
                        const SizedBox(height: 16),
                        StoryDetailTabBar(
                          tabIndex: _tabIndex,
                          chapterCount: _activeReaderChapters.isNotEmpty
                              ? _activeReaderChapters.length
                              : _story.totalChapters,
                          onTabChanged: (index) => setState(() => _tabIndex = index),
                        ),
                        const SizedBox(height: 16),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            final slideAnimation =
                                Tween<Offset>(
                                  begin: const Offset(0, 0.02),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  ),
                                );

                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: slideAnimation,
                                child: child,
                              ),
                            );
                          },
                          child: _tabIndex == 0
                              ? StoryDetailDetailTab(
                                  storyDescription: state.storyDescription,
                                  bottomAction: _buildBottomAction(isCompact: true),
                                  highlightedCommentsSection:
                                      StoryDetailHighlightedCommentsSection(
                                        isLoading: state.isLoadingHighlightedComments,
                                        comments: state.highlightedChapterComments
                                            .map(
                                              (comment) =>
                                                  StoryDetailHighlightedCommentItem(
                                                    author: comment.author,
                                                    content: comment.content,
                                                    meta: comment.meta,
                                                    chapterLabel: comment.chapterLabel,
                                                  ),
                                            )
                                            .toList(),
                                      ),
                                  authorName: _story.author,
                                  authorBio: state.authorBio,
                                  authorStoryCount: state.authorStoryCount ?? 0,
                                  onTapAuthor:
                                      state.authorId.isEmpty ? null : _openAuthorProfile,
                                  isLoadingSimilarStories: state.isLoadingSimilarStories,
                                  similarStories: state.similarStories
                                      .map(_toSuggestionItem)
                                      .toList(),
                                  isLoadingRecommendedStories:
                                      state.isLoadingRecommendedStories,
                                  recommendedStories: state.recommendedStories
                                      .map(_toSuggestionItem)
                                      .toList(),
                                  onTapSuggestion: (suggestion) => _openSuggestedStory(
                                    _fromSuggestionItem(suggestion),
                                  ),
                                )
                              : StoryDetailChapterTab(
                                  isLoading: state.isLoadingChapters,
                                  chapters:
                                      List<StoryDetailChapterListItem>.generate(
                                    _activeReaderChapters.length,
                                    (index) => StoryDetailChapterListItem(
                                      number: state.chapters[index].number,
                                      title: state.chapters[index].title,
                                      subtitle: index == state.chapters.length - 1
                                          ? 'Chương mới nhất'
                                          : 'Nhấn để đọc',
                                      likeCount: state.chapters[index].likeCount,
                                      commentCount:
                                          state.chapters[index].commentCount,
                                    ),
                                  ),
                                  onTapChapter: (index) => _openReader(
                                    chapterIndex: index,
                                  ),
                                ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openSuggestedStory(StorySuggestionEntity story) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryDetailPage(
          story: StoryEntity(
            id: story.id,
            slug: story.slug,
            title: story.title,
            description: story.description,
            author: story.author,
            coverUrl: story.coverUrl,
            category: story.category,
            rating: 0,
            totalChapters: story.chapterCount,
            readCount: story.readCount,
            likeCount: story.likeCount,
            isLiked: story.isLiked,
            tags: story.tags,
          ),
        ),
      ),
    );
  }

  StoryDetailSuggestionItem _toSuggestionItem(StorySuggestionEntity story) {
    return StoryDetailSuggestionItem(
      id: story.id,
      slug: story.slug,
      title: story.title,
      description: story.description,
      author: story.author,
      coverUrl: story.coverUrl,
      category: story.category,
      readCount: story.readCount,
      likeCount: story.likeCount,
      chapterCount: story.chapterCount,
      isLiked: story.isLiked,
      tags: List<String>.from(story.tags),
    );
  }

  StorySuggestionEntity _fromSuggestionItem(StoryDetailSuggestionItem story) {
    return StorySuggestionEntity(
      id: story.id,
      slug: story.slug,
      title: story.title,
      description: story.description,
      author: story.author,
      coverUrl: story.coverUrl,
      category: story.category,
      readCount: story.readCount,
      likeCount: story.likeCount,
      chapterCount: story.chapterCount,
      isLiked: story.isLiked,
      tags: List<String>.from(story.tags),
    );
  }

  
  Future<void> _openStoryReportSheet() async {
    final isAuthenticated = await AuthGate.requireAuth(context);
    if (!mounted || !isAuthenticated) return;

    final reportPayload = await showReportSubmitSheet(
      context: context,
      title: 'Báo cáo truyện',
      subtitle: 'Hãy chọn lý do phù hợp để chúng tôi xem xét tác phẩm này.',
      initialReason: 'misleading',
      requireDescriptionForAll: true,
      descriptionHint:
          'Mô tả rõ vấn đề để quản trị viên xử lý nhanh hơn.',
      reasonOptions: const [
        ReportReasonOption(value: 'misleading', label: 'Sai lệch'),
        ReportReasonOption(value: 'spam', label: 'Spam'),
        ReportReasonOption(value: 'copyright', label: 'Bản quyền'),
        ReportReasonOption(value: 'sexual', label: 'Tình dục'),
        ReportReasonOption(value: 'violence', label: 'Bạo lực'),
        ReportReasonOption(value: 'hate', label: 'Thù ghét'),
        ReportReasonOption(value: 'other', label: 'Khác'),
      ],
      accentColor: const Color(0xFFC4773B),
    );

    if (reportPayload == null || !mounted) return;
    await _submitStoryReport(
      reason: reportPayload.reason,
      description: reportPayload.description,
    );
  }

  Future<void> _submitStoryReport({
    required String reason,
    required String description,
  }) async {
    if (_isSubmittingStoryReport) return;

    setState(() => _isSubmittingStoryReport = true);
    try {
      await _reportStory(
        storyId: _storyId,
        reason: reason,
        description: description,
      );
      if (!mounted) return;
      _showStoryToast(
        'Đã gửi báo cáo truyện thành công.',
        isSuccess: true,
      );
    } catch (error) {
      if (!mounted) return;
      if (_isStoryHiddenError(error)) {
        _handleHiddenStory();
        return;
      }
      _showStoryToast(_extractStoryReportErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isSubmittingStoryReport = false);
      }
    }
  }

  void _showStoryToast(String message, {bool isSuccess = false}) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        final topInset = MediaQuery.of(context).padding.top;
        return Positioned(
          top: topInset + 12,
          left: 16,
          right: 16,
          child: IgnorePointer(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isSuccess ? const Color(0xFF2E7D32) : const Color(0xFF323232),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      isSuccess
                          ? Icons.check_circle_rounded
                          : Icons.info_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    Future<void>.delayed(const Duration(seconds: 2, milliseconds: 200)).then((_) {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  void _handleHiddenStory() {
    if (!mounted) return;
    _showStoryToast('Truyện này đã bị ẩn bởi quản trị viên.');
    Future<void>.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      Navigator.of(context).maybePop();
    });
  }

  String _extractStoryReportErrorMessage(Object error) {
    if (error is ApiException) {
      final lowered = error.message.toLowerCase();
      if (lowered.contains('already reported') ||
          lowered.contains('already_reported') ||
          lowered.contains('da bao cao')) {
        return 'Bạn đã báo cáo truyện này rồi.';
      }
      if (lowered.contains('vui long nhap mo ta') ||
          lowered.contains('thieu mo ta')) {
        return 'Vui lòng nhập mô tả báo cáo.';
      }
      if (lowered.contains('chinh minh') || lowered.contains('own story')) {
        return 'Bạn không thể báo cáo truyện của chính mình.';
      }
      if (error.message.trim().isNotEmpty) return error.message;
    }
    return 'Không thể gửi báo cáo truyện lúc này.';
  }

  bool _isStoryHiddenError(Object error) {
    if (error is ApiException) {
      final message = error.message.toLowerCase();
      return message.contains('ẩn') ||
          message.contains('hidden') ||
          message.contains('không khả dụng') ||
          message.contains('khong kha dung') ||
          message.contains('chưa được xuất bản') ||
          message.contains('chua duoc xuat ban');
    }
    return false;
  }

  Future<void> _openDownloadChaptersScreen() async {
    final chapters = _activeReaderChapters;
    final downloadItems = List<StoryDownloadChapterEntity>.generate(
      chapters.length,
      (index) {
        final chapter = chapters[index];
        final id = chapter.id.trim().isNotEmpty
            ? chapter.id.trim()
            : '${_storyId}_${chapter.number}_$index';
        return StoryDownloadChapterEntity(
          id: id,
          number: chapter.number,
          title: chapter.title,
          paragraphs: List<String>.from(chapter.paragraphs),
        );
      },
    );

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<StoryDownloadCubit>(
            param1: StoryDownloadSeed(
              storyId: _storyId,
              storyTitle: _story.title,
              storySlug: _story.slug,
              storyAuthor: _story.author,
              storyCoverUrl: _story.coverUrl,
              isLoadingSource: _detailState.isLoadingChapters,
              chapters: downloadItems,
            ),
          )..initialize(),
          child: const StoryDownloadPage(),
        ),
      ),
    );
  }

  void _openRatingBottomSheet() {
    showModalBottomSheet<StoryRatingSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => sl<StoryRatingCubit>(
          param1: StoryRatingSeed(
            storyId: _storyId,
            initialAverageRating: _detailState.storyRating,
            initialRatingCount: _detailState.storyRatingCount,
            initialMyRating: _detailState.myStoryRating == null
                ? null
                : StoryRatingMyRatingView(
                    score: _detailState.myStoryRating!.score,
                    content: _detailState.myStoryRating!.content,
                    editCount: _detailState.myStoryRating!.editCount,
                    canEdit: _detailState.myStoryRating!.canEdit,
                    createdAt: _detailState.myStoryRating!.createdAt,
                    updatedAt: _detailState.myStoryRating!.updatedAt,
                  ),
            isAuthenticated: _authCubit.state.isAuthenticated,
          ),
        )..initialize(),
        child: const StoryRatingSheet(),
      ),
    ).then((result) {
      if (result == null) return;
      _storyDetailCubit.updateRating(
        averageRating: result.averageRating,
        ratingCount: result.ratingCount,
        myRating: result.myRating == null
            ? null
            : StoryMyRatingEntity(
                score: result.myRating!.score,
                content: result.myRating!.content,
                editCount: result.myRating!.editCount,
                canEdit: result.myRating!.canEdit,
                createdAt: result.myRating!.createdAt,
                updatedAt: result.myRating!.updatedAt,
              ),
      );
    });
  }

  Widget _buildBottomAction({bool isCompact = false}) {
    final canRead = _activeReaderChapters.isNotEmpty;
    final resumeIndex = _normalizeChapterIndex(
      _resumeChapterIndex ?? -1,
      _activeReaderChapters.length,
    );
    final actionChapterIndex = resumeIndex ?? 0;
    final actionChapterNumber = canRead
        ? _activeReaderChapters[actionChapterIndex].number
        : 0;
    final actionLabel = resumeIndex == null
        ? 'Bắt đầu đọc'
        : 'Đọc tiếp chương $actionChapterNumber';

    return SizedBox(
      width: double.infinity,
      height: isCompact ? 48 : 54,
      child: ElevatedButton(
        onPressed: canRead
            ? () => _openReader(chapterIndex: actionChapterIndex)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC4773B),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isCompact ? 16 : 18),
          ),
        ),
        child: Text(
          actionLabel,
          style: TextStyle(
            fontSize: isCompact ? 15 : 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  int? _normalizeChapterIndex(int index, int chapterCount) {
    if (chapterCount <= 0 || index < 0) return null;
    if (index >= chapterCount) return chapterCount - 1;
    return index;
  }

  Future<_StoryDetailReadingProgressSnapshot> _loadReadingProgressSnapshot() async {
    if (_storyId.trim().isEmpty || _activeReaderChapters.isEmpty) {
      return const _StoryDetailReadingProgressSnapshot(
        chapterIndex: null,
        lastPosition: null,
      );
    }

    final localProgress = await _readingProgressLocalCache.getProgress(_storyId);
    var snapshot = _StoryDetailReadingProgressSnapshot(
      chapterIndex: _normalizeChapterIndex(
        localProgress?.chapterIndex ?? -1,
        _activeReaderChapters.length,
      ),
      lastPosition: localProgress?.lastPosition,
    );

    final hasToken = await _tokenStorage.hasToken();
    if (!hasToken) return snapshot;

    try {
      final remoteProgress = await _syncStoryReadingProgress.getRemote(
        storyId: _storyId,
      );
      if (remoteProgress == null) {
        if (localProgress != null) {
          await _pushProgressToServer(
            chapterIndex: localProgress.chapterIndex,
            lastPosition: localProgress.lastPosition,
          );
        }
        return snapshot;
      }

      final normalizedServerIndex = _normalizeChapterIndex(
        remoteProgress.chapterIndex,
        _activeReaderChapters.length,
      );
      if (normalizedServerIndex == null) return snapshot;

      if (localProgress == null ||
          remoteProgress.updatedAt.isAfter(localProgress.updatedAt)) {
        await _readingProgressLocalCache.saveLastChapterIndex(
          storyId: _storyId,
          chapterIndex: normalizedServerIndex,
          lastPosition: remoteProgress.lastPosition,
          updatedAt: remoteProgress.updatedAt,
          storyTitle: _story.title,
          storyCoverUrl: _story.coverUrl,
          storySlug: _story.slug,
        );
        return _StoryDetailReadingProgressSnapshot(
          chapterIndex: normalizedServerIndex,
          lastPosition: remoteProgress.lastPosition,
        );
      }

      if (localProgress.updatedAt.isAfter(remoteProgress.updatedAt)) {
        await _pushProgressToServer(
          chapterIndex: localProgress.chapterIndex,
          lastPosition: localProgress.lastPosition,
        );
      }
    } catch (_) {}

    return snapshot;
  }

  Future<void> _saveReadingProgressSnapshot({
    required String storyId,
    required int chapterIndex,
    required int? lastPosition,
    required String storyTitle,
    required String storyCoverUrl,
    required String storySlug,
  }) async {
    if (storyId.trim().isEmpty || chapterIndex < 0) return;

    final now = DateTime.now().toUtc();
    await _readingProgressLocalCache.saveLastChapterIndex(
      storyId: storyId,
      chapterIndex: chapterIndex,
      lastPosition: lastPosition,
      updatedAt: now,
      storyTitle: storyTitle,
      storyCoverUrl: storyCoverUrl,
      storySlug: storySlug,
    );

    final hasToken = await _tokenStorage.hasToken();
    if (!hasToken) return;

    await _pushProgressToServer(
      chapterIndex: chapterIndex,
      lastPosition: lastPosition,
    );
  }

  Future<void> _pushProgressToServer({
    required int chapterIndex,
    required int? lastPosition,
  }) async {
    try {
      await _syncStoryReadingProgress.saveRemote(
        storyId: _storyId,
        chapterIndex: chapterIndex,
        lastPosition: lastPosition,
      );
    } catch (_) {}
  }

}

class _StoryDetailReadingProgressSnapshot {
  final int? chapterIndex;
  final int? lastPosition;

  const _StoryDetailReadingProgressSnapshot({
    required this.chapterIndex,
    required this.lastPosition,
  });
}
