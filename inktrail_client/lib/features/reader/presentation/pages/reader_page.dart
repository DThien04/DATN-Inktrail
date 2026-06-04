import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/core/auth/auth_gate.dart';
import 'package:ink_trail_client/core/di/service_locator.dart';
import 'package:ink_trail_client/core/navigation/app_router.dart';
import 'package:ink_trail_client/core/network/api_exception.dart';
import 'package:ink_trail_client/core/network/token_storage.dart';
import 'package:ink_trail_client/core/storage/device_identity_storage.dart';
import 'package:ink_trail_client/core/theme/theme_cubit.dart';
import 'package:ink_trail_client/core/theme/theme_state.dart';
import 'package:ink_trail_client/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ink_trail_client/features/profile/presentation/utils/profile_navigation.dart';
import 'package:ink_trail_client/features/report/domain/usecases/report_usecases.dart';
import 'package:ink_trail_client/features/report/presentation/models/report_submission_payload.dart';
import 'package:ink_trail_client/features/report/presentation/widgets/report_submit_sheet.dart';
import 'package:ink_trail_client/features/reader/domain/usecases/reader_usecases.dart';
import 'package:ink_trail_client/features/reader/presentation/cubit/reader_cubit.dart';
import 'package:ink_trail_client/features/reader/presentation/cubit/reader_state.dart';
import 'package:ink_trail_client/features/reader/presentation/controllers/reader_tts_controller.dart';
import 'package:ink_trail_client/features/reader/presentation/models/reader_view_models.dart';
import 'package:ink_trail_client/features/reader/presentation/utils/reader_comment_utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

part '../widgets/reader_top_widgets.dart';
part '../widgets/chapter_comment_sheet.dart';
part '../widgets/reader_comment_sheet.dart';
part '../widgets/reader_aux_sheets.dart';
part '../widgets/chapter_engagement_section.dart';

/// Light reader shell: neutral surfaces like [AppTheme.light]; brand only on accents.
const Color kReaderLightCanvas = Color(0xFFF8F9FA);
const Color kReaderLightSurface = Color(0xFFFFFFFF);
const Color kReaderLightBorder = Color(0xFFE5E7EB);
const Color kReaderLightTitle = Color(0xFF1A1A1A);
const Color kReaderLightBody = Color(0xFF374151);
const Color kReaderLightMuted = Color(0xFF6B7280);
const Color kReaderBrand = Color(0xFFC4773B);

Color kReaderLightAccentWash([double opacity = 0.14]) =>
    kReaderBrand.withValues(alpha: opacity);

class ReaderPage extends StatefulWidget {
  final String? storyId;
  final String storyTitle;
  final List<ReaderChapter> chapters;
  final int initialChapterIndex;
  final int? initialScrollPercent;
  final bool isOwnStory;

  const ReaderPage({
    super.key,
    this.storyId,
    required this.storyTitle,
    required this.chapters,
    this.initialChapterIndex = 0,
    this.initialScrollPercent,
    this.isOwnStory = false,
  });

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  static const _qualifiedReadSeconds = 30;
  static const _qualifiedScrollPercent = 50.0;
  static const _chromeRevealOffset = 24.0;

  final AuthCubit _authCubit = sl<AuthCubit>();
  final DeviceIdentityStorage _deviceIdentityStorage = DeviceIdentityStorage();
  final TrackReaderReadEventUsecase _trackReadEvent =
      sl<TrackReaderReadEventUsecase>();
  late final ReaderCubit _readerCubit;

  late final ScrollController _scrollController;
  late final Stopwatch _readStopwatch;
  late final ReaderTtsController _ttsController;
  Timer? _readTrackingTimer;

  bool _chromeVisible = true;
  bool _hasTrackedRead = false;
  bool _isTrackingRead = false;
  double _maxScrollPercent = 0;
  bool _didRestoreInitialScroll = false;
  double _ttsRate = 0.5;
  bool _isTtsPlaying = false;
  bool _isTtsPaused = false;
  int _ttsProgressChunk = 0;
  int _ttsTotalChunks = 0;
  int? _ttsActiveParagraphIndex;
  int? _ttsActiveSentenceIndex;
  final Map<int, GlobalKey> _paragraphKeys = <int, GlobalKey>{};

  ReaderState get _readerState => _readerCubit.state;
  ReaderChapter get _chapter => widget.chapters[_readerState.currentChapterIndex];
  ReaderChapterState? get _currentChapterState =>
      _readerCubit.chapterStateOf(_chapter.id);
  bool get _isCurrentChapterLiked =>
      _currentChapterState?.isLiked ?? _chapter.isLiked;
  bool get _isDarkMode => _readerState.themeMode == ReaderThemeMode.dark;
  bool get _isLastChapter =>
      _readerState.currentChapterIndex >= widget.chapters.length - 1;
  bool get _canTrackRead =>
      widget.storyId != null &&
      widget.storyId!.isNotEmpty &&
      widget.storyId != 'story-detail';
  String get _currentUserId => _authCubit.state.user?.id ?? '';
  bool get _isCurrentUserAdmin => _authCubit.state.user?.role.name == 'admin';
  Color get _backgroundColor =>
      _isDarkMode ? const Color(0xFF171412) : kReaderLightCanvas;
  Color get _surfaceColor =>
      _isDarkMode ? const Color(0xFF201C19) : kReaderLightSurface;
  Color get _borderColor =>
      _isDarkMode ? const Color(0xFF3A332D) : kReaderLightBorder;
  Color get _titleColor =>
      _isDarkMode ? const Color(0xFFF6EFE6) : kReaderLightTitle;
  Color get _bodyColor =>
      _isDarkMode ? const Color(0xFFE2D7CC) : kReaderLightBody;
  Color get _mutedColor =>
      _isDarkMode ? const Color(0xFFB7A89A) : kReaderLightMuted;
  Color get _accentColor => kReaderBrand;

  @override
  void initState() {
    super.initState();
    _readerCubit = sl<ReaderCubit>(
      param1: ReaderSeed(
        initialChapterIndex: widget.initialChapterIndex,
        initialThemeMode: ReaderThemeMode.light,
        chapters: widget.chapters
            .map(
              (chapter) => ReaderChapterSnapshot(
                id: chapter.id,
                isLiked: chapter.isLiked,
                likeCount: chapter.likeCount,
                commentCount: chapter.commentCount,
              ),
            )
            .toList(),
      ),
    );
    _scrollController = ScrollController()..addListener(_handleScroll);
    _ttsController = ReaderTtsController(
      onStateChanged: _syncTtsState,
      onProgress: _handleTtsProgress,
      onError: _handleTtsError,
    );
    unawaited(_ttsController.init());
    _readStopwatch = Stopwatch()..start();
    _readTrackingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => unawaited(_tryTrackReadEvent()),
    );
    _scheduleInitialScrollRestore();
    unawaited(_loadChapterFeaturedComment(_chapter.id));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = context.read<ThemeCubit>().state.isDarkMode;
    final next = isDark ? ReaderThemeMode.dark : ReaderThemeMode.light;
    _readerCubit.setThemeMode(next);
  }

  @override
  void dispose() {
    _readerCubit.close();
    unawaited(_ttsController.dispose());
    _readTrackingTimer?.cancel();
    _readStopwatch.stop();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) {
      _maxScrollPercent = 100;
    } else {
      _maxScrollPercent =
          ((offset / maxExtent) * 100).clamp(0, 100).toDouble();
    }

    if (!_chromeVisible && offset <= _chromeRevealOffset) {
      setState(() => _chromeVisible = true);
    }
    unawaited(_tryTrackReadEvent());
  }

  void _handleReaderTap() {
    if (_chromeVisible) return;
    setState(() => _chromeVisible = true);
  }

  void _scheduleInitialScrollRestore([int attempt = 0]) {
    if (_didRestoreInitialScroll) return;
    final initialPercent = widget.initialScrollPercent;
    if (initialPercent == null || initialPercent <= 0) {
      _didRestoreInitialScroll = true;
      return;
    }
    if (attempt > 12) {
      _didRestoreInitialScroll = true;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didRestoreInitialScroll) return;
      if (!_scrollController.hasClients) {
        _scheduleInitialScrollRestore(attempt + 1);
        return;
      }

      final maxExtent = _scrollController.position.maxScrollExtent;
      final safePercent = initialPercent.clamp(0, 100);
      final target = (maxExtent * (safePercent / 100)).clamp(0.0, maxExtent);

      _scrollController.jumpTo(target);
      _maxScrollPercent = safePercent.toDouble();
      _didRestoreInitialScroll = true;
    });
  }

  Future<void> _tryTrackReadEvent({bool force = false}) async {
    if (!_canTrackRead || _hasTrackedRead || _isTrackingRead) return;
    final qualified = force ||
        _readerState.currentChapterIndex >= 1 ||
        _readStopwatch.elapsed.inSeconds >= _qualifiedReadSeconds ||
        _maxScrollPercent >= _qualifiedScrollPercent;
    if (!qualified) return;

    _isTrackingRead = true;
    try {
      final deviceId = await _deviceIdentityStorage.getOrCreateDeviceId();
      debugPrint(
        '[read-event] sending storyId=${widget.storyId} '
        'chapter=${_readerState.currentChapterIndex} '
        'seconds=${_readStopwatch.elapsed.inSeconds} '
        'scroll=${_maxScrollPercent.round()} '
        'force=$force '
        'deviceId=$deviceId',
      );

      await _trackReadEvent(
        storyId: widget.storyId!,
        chapterIndex: _readerState.currentChapterIndex,
        timeSpentSeconds: _readStopwatch.elapsed.inSeconds,
        maxScrollPercent: _maxScrollPercent.round(),
        deviceId: deviceId,
      );

      debugPrint('[read-event] success storyId=${widget.storyId}');
      _hasTrackedRead = true;
    } on ApiException catch (e) {
      debugPrint('[read-event] api-error status=${e.statusCode} message=${e.message}');
    } catch (e) {
      debugPrint('[read-event] error $e');
    } finally {
      _isTrackingRead = false;
    }
  }

  Future<void> _handleBack() async {
    await _ttsController.stop();
    await _tryTrackReadEvent(force: true);
    if (!mounted) return;
    Navigator.of(context).pop(
      _readerCubit.buildSessionResult(
        lastScrollPercent: _maxScrollPercent.round().clamp(0, 100),
      ),
    );
  }

  void _openChapter(int index) {
    unawaited(_ttsController.stop());
    _readerCubit.openChapter(index);
    setState(() {
      _chromeVisible = true;
      _ttsActiveParagraphIndex = null;
      _ttsActiveSentenceIndex = null;
      _paragraphKeys.clear();
    });
    _scrollController.jumpTo(0);
    unawaited(_tryTrackReadEvent());
    unawaited(_loadChapterFeaturedComment(_chapter.id));
  }

  void _goToPreviousChapter() {
    if (_readerState.currentChapterIndex > 0) {
      _openChapter(_readerState.currentChapterIndex - 1);
    }
  }

  void _goToNextChapter() {
    if (_readerState.currentChapterIndex < widget.chapters.length - 1) {
      _openChapter(_readerState.currentChapterIndex + 1);
    }
  }

  Future<void> _toggleCurrentChapterLike() async {
    if (!await AuthGate.requireAuth(context)) return;

    final chapterId = _chapter.id;
    if (chapterId.isEmpty) {
      return;
    }

    final outcome = await _readerCubit.toggleChapterLike(chapterId: chapterId);
    if (!mounted) return;

    switch (outcome.status) {
      case ReaderChapterLikeStatus.success:
      case ReaderChapterLikeStatus.ignored:
        return;
      case ReaderChapterLikeStatus.hidden:
        await _handleHiddenChapter();
        return;
      case ReaderChapterLikeStatus.failed:
        showReaderCommentMessage(
          context,
          'Không thể cập nhật lượt thích chương lúc này.',
        );
    }
  }

  void _syncTtsState() {
    if (!mounted) return;
    setState(() {
      _isTtsPlaying = _ttsController.isPlaying;
      _isTtsPaused = _ttsController.isPaused;
      _ttsRate = _ttsController.speechRate;
    });
  }

  void _handleTtsProgress(
    int currentChunk,
    int totalChunks,
    int? activeParagraph,
    int? activeSentence,
  ) {
    if (!mounted) return;
    setState(() {
      _ttsProgressChunk = currentChunk;
      _ttsTotalChunks = totalChunks;
      _ttsActiveParagraphIndex = activeParagraph;
      _ttsActiveSentenceIndex = activeSentence;
    });
  }

  void _handleTtsError(String _) {
    if (!mounted) return;
    showReaderCommentMessage(context, 'Không thể bật đọc bằng giọng nói lúc này.');
  }

  Future<void> _toggleTts() async {
    if (_isTtsPlaying) {
      await _ttsController.pause();
      return;
    }
    if (_isTtsPaused) {
      await _ttsController.resume();
      return;
    }
    await _startTtsForCurrentChapter();
  }

  Future<void> _startTtsForCurrentChapter() async {
    if (_chapter.paragraphs.isEmpty) {
      showReaderCommentMessage(context, 'Chương này chưa có nội dung để đọc.');
      return;
    }
    await _ttsController.speakChapter(
      chapterTitle: 'Chương ${_chapter.number}. ${_chapter.title}',
      paragraphs: _chapter.paragraphs,
    );
  }

  Future<void> _stopTts() async {
    await _ttsController.stop();
    if (!mounted) return;
    setState(() {
      _ttsActiveParagraphIndex = null;
      _ttsActiveSentenceIndex = null;
    });
  }

  Future<void> _jumpToActiveTtsParagraph() async {
    final paragraphIndex = _ttsActiveParagraphIndex;
    if (paragraphIndex == null) return;

    if (!_scrollController.hasClients) return;

    final key = _paragraphKeys[paragraphIndex];
    final targetContext = key?.currentContext;
    if (targetContext != null) {
      await Scrollable.ensureVisible(
        targetContext,
        alignment: 0.16,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    final totalParagraphs = _chapter.paragraphs.length;
    if (totalParagraphs <= 0) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) return;

    final ratio = (paragraphIndex / totalParagraphs).clamp(0.0, 1.0);
    final targetOffset = (maxExtent * ratio).clamp(0.0, maxExtent);
    await _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  GlobalKey _paragraphKeyFor(int index) {
    return _paragraphKeys.putIfAbsent(index, () => GlobalKey());
  }

  Future<void> _showChapterCommentsSheet() {
    return _guardedOpenCommentsSheet(_showChapterCommentsSheetInternal);
  }

  Future<void> _showReaderMoreSheet() async {
    if (widget.isOwnStory) {
      await _showSettingsSheet(context);
      return;
    }

    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.tune_rounded),
                title: const Text('Cài đặt đọc'),
                onTap: () => Navigator.of(context).pop('settings'),
              ),
              if (!widget.isOwnStory)
                ListTile(
                  leading: const Icon(
                    Icons.flag_outlined,
                    color: kReaderBrand,
                  ),
                  title: const Text('Báo cáo chương này'),
                  onTap: () => Navigator.of(context).pop('report_chapter'),
                ),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) return;
    if (action == 'settings') {
      await _showSettingsSheet(context);
      return;
    }
    if (action == 'report_chapter') {
      await _openChapterReportSheet();
    }
  }

  Future<void> _openChapterReportSheet() async {
    final chapterId = _chapter.id;
    if (chapterId.isEmpty) {
      showReaderCommentMessage(context, 'Chưa thể báo cáo chương này lúc này.');
      return;
    }
    final isAuthenticated = await AuthGate.requireAuth(context);
    if (!mounted || !isAuthenticated) return;

    final reportPayload = await showReportSubmitSheet(
      context: context,
      title: 'Báo cáo chương ${_chapter.number}',
      subtitle:
          'Chọn lý do phù hợp và mô tả rõ vấn đề để chúng tôi xem xét chương này.',
      initialReason: 'misleading',
      requireDescriptionForAll: true,
      descriptionHint:
          'Mô tả rõ đoạn hoặc vấn đề của chương này để quản trị viên xử lý nhanh hơn.',
      reasonOptions: const [
        ReportReasonOption(value: 'misleading', label: 'Sai lệch'),
        ReportReasonOption(value: 'spam', label: 'Spam'),
        ReportReasonOption(value: 'copyright', label: 'Bản quyền'),
        ReportReasonOption(value: 'sexual', label: 'Tình dục'),
        ReportReasonOption(value: 'violence', label: 'Bạo lực'),
        ReportReasonOption(value: 'hate', label: 'Thù ghét'),
        ReportReasonOption(value: 'other', label: 'Khác'),
      ],
      surfaceColor: _surfaceColor,
      borderColor: _borderColor,
      titleColor: _titleColor,
      mutedColor: _mutedColor,
      accentColor: _accentColor,
    );

    if (reportPayload == null || !mounted) return;
    await _submitChapterReport(
      chapterId: chapterId,
      reason: reportPayload.reason,
      description: reportPayload.description,
    );
  }

  Future<void> _submitChapterReport({
    required String chapterId,
    required String reason,
    required String description,
  }) async {
    try {
      await _readerCubit.submitChapterReport(
        chapterId: chapterId,
        reason: reason,
        description: description,
      );
      if (!mounted) return;
      showReaderCommentMessage(
        context,
        'Đã gửi báo cáo chương thành công.',
        isSuccess: true,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      if (isReaderChapterHiddenError(error)) {
        await _handleHiddenChapter();
        return;
      }
      showReaderCommentMessage(context, extractReaderCommentErrorMessage(error));
    } catch (_) {
      if (!mounted) return;
      showReaderCommentMessage(context, 'Không thể gửi báo cáo chương lúc này.');
    }
  }

  Future<void> _showChapterCommentsSheetInternal() {
    final chapterId = _chapter.id;
    if (chapterId.isEmpty) {
      showReaderCommentMessage(context, 'Chưa thể tải bình luận chương lúc này.');
      return Future<void>.value();
    }

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChapterCommentSheet(
        chapterId: chapterId,
        title: 'Bình luận chương ${_chapter.number}',
        placeholder: 'Viết cảm nhận cho chương này...',
        tokenStorage: sl<TokenStorage>(),
        initialCommentCount:
            _currentChapterState?.commentCount ?? _chapter.commentCount,
        onChapterHidden: _handleHiddenChapter,
        onCommentCountChanged: (count) {
          if (!mounted) return;
          _readerCubit.updateChapterCommentCount(
            chapterId: chapterId,
            count: count,
          );
        },
        isDarkMode: _isDarkMode,
        surfaceColor: _surfaceColor,
        borderColor: _borderColor,
        titleColor: _titleColor,
        bodyColor: _bodyColor,
        mutedColor: _mutedColor,
        accentColor: _accentColor,
      ),
    ).whenComplete(() => unawaited(_loadChapterFeaturedComment(chapterId)));
  }

  Future<void> _guardedOpenCommentsSheet(
    Future<void> Function() openSheet,
  ) async {
    if (!await AuthGate.requireAuth(context)) return;
    if (!mounted) return;
    await openSheet();
  }

  Future<void> _loadChapterFeaturedComment(String chapterId) async {
    if (chapterId.isEmpty) return;
    try {
      await _readerCubit.loadFeaturedComment(
        chapterId: chapterId,
        currentUserId: _currentUserId,
      );
      if (!mounted) return;
    } on ApiException catch (error) {
      if (!mounted) return;
      if (isReaderChapterHiddenError(error)) {
        await _handleHiddenChapter();
      }
    } catch (_) {}
  }

  Future<void> _handleHiddenChapter() async {
    if (!mounted) return;
    await _stopTts();
    if (!mounted) return;
    Navigator.of(context).pop(
      _readerCubit.buildSessionResult(
        lastScrollPercent: null,
        chapterHiddenMessage: 'Chương này đã bị ẩn bởi quản trị viên.',
      ),
    );
  }

  Future<void> _handleFinishStory() async {
    await _ttsController.stop();
    await _tryTrackReadEvent(force: true);
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đã đọc xong'),
        content: const Text(
          'Bạn đã hoàn thành câu chuyện này. Về trang chủ để khám phá thêm truyện khác nhé.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ở lại'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppRouter.pushReplacement(AppRouter.home);
            },
            child: const Text('Về trang chủ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return BlocProvider.value(
      value: _readerCubit,
      child: BlocListener<ThemeCubit, ThemeState>(
        listener: (context, state) {
          final next =
              state.isDarkMode ? ReaderThemeMode.dark : ReaderThemeMode.light;
          _readerCubit.setThemeMode(next);
        },
        child: BlocBuilder<ReaderCubit, ReaderState>(
          builder: (context, readerState) {
            final currentChapterState = _readerCubit.chapterStateOf(_chapter.id);
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (didPop) return;
                unawaited(_handleBack());
              },
              child: Scaffold(
                backgroundColor: _backgroundColor,
                body: Stack(
                  children: [
                    Listener(
                      behavior: HitTestBehavior.translucent,
                      onPointerDown: (_) => _handleReaderTap(),
                      child: NotificationListener<UserScrollNotification>(
                        onNotification: (notification) {
                          if (notification.direction == ScrollDirection.reverse &&
                              _chromeVisible) {
                            setState(() => _chromeVisible = false);
                          }
                          return false;
                        },
                        child: CustomScrollView(
                          controller: _scrollController,
                          slivers: [
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                20,
                                68,
                                20,
                                150 + bottomInset,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildListDelegate([
                                  Text(
                                    'Chương ${_chapter.number}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _accentColor,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _chapter.title,
                                    style: TextStyle(
                                      fontSize: 30,
                                      height: 1.22,
                                      fontWeight: FontWeight.w700,
                                      color: _titleColor,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  ...List<Widget>.generate(
                                    _chapter.paragraphs.length,
                                    (index) {
                                      final paragraph = _chapter.paragraphs[index];
                                      final isSpeakingParagraph =
                                          _ttsActiveParagraphIndex == index;
                                      return AnimatedContainer(
                                        key: _paragraphKeyFor(index),
                                        duration: const Duration(milliseconds: 180),
                                        margin: const EdgeInsets.only(bottom: 22),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSpeakingParagraph
                                              ? _accentColor.withValues(alpha: 0.14)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isSpeakingParagraph
                                                ? _accentColor.withValues(
                                                    alpha: 0.35,
                                                  )
                                                : Colors.transparent,
                                          ),
                                        ),
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: readerState.bodyFontSize,
                                              height: readerState.lineHeight,
                                              color: _bodyColor,
                                            ),
                                            children: _buildParagraphSentenceSpans(
                                              paragraph: paragraph,
                                              paragraphIndex: index,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  _ChapterEngagementSection(
                                    chapter: _chapter,
                                    highlightedComment:
                                        currentChapterState?.featuredComment,
                                    isDarkMode: _isDarkMode,
                                    titleColor: _titleColor,
                                    bodyColor: _bodyColor,
                                    mutedColor: _mutedColor,
                                    surfaceColor: _surfaceColor,
                                    borderColor: _borderColor,
                                    accentColor: _accentColor,
                                    isLiked: _isCurrentChapterLiked,
                                    isLikeAnimating:
                                        currentChapterState?.isLikeAnimating ??
                                        false,
                                    isLikeDisabled:
                                        (currentChapterState?.isLikeCoolingDown ??
                                            false) ||
                                        (currentChapterState?.isLikeRequesting ??
                                            false),
                                    isFollowing: readerState.isFollowingStory,
                                    likeCount:
                                        currentChapterState?.likeCount ??
                                        _chapter.likeCount,
                                    commentCount:
                                        currentChapterState?.commentCount ??
                                        _chapter.commentCount,
                                    onToggleLike: () => unawaited(
                                      _toggleCurrentChapterLike(),
                                    ),
                                    onOpenComments: () => unawaited(
                                      _showChapterCommentsSheet(),
                                    ),
                                    onToggleFollow: _readerCubit.toggleFollowStory,
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed:
                                              readerState.currentChapterIndex == 0
                                              ? null
                                              : _goToPreviousChapter,
                                          child: const Text('Chương trước'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: _isLastChapter
                                              ? _handleFinishStory
                                              : _goToNextChapter,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _accentColor,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: Text(
                                            _isLastChapter
                                                ? 'Hoàn thành'
                                                : 'Chương sau',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 220),
                      top: _chromeVisible ? 0 : -76,
                      left: 0,
                      right: 0,
                      child: _ReaderTopBar(
                        storyTitle: widget.storyTitle,
                        chapterTitle: _chapter.title,
                        backgroundColor: _backgroundColor,
                        surfaceColor: _surfaceColor,
                        borderColor: _borderColor,
                        titleColor: _titleColor,
                        subtitleColor: _mutedColor,
                        isTtsActive: _isTtsPlaying || _isTtsPaused,
                        onOpenTts: () => _showTtsSheet(context),
                        onOpenSettings: () => unawaited(_showReaderMoreSheet()),
                        onBack: _handleBack,
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 220),
                      bottom: _chromeVisible ? 0 : -(126 + bottomInset),
                      left: 0,
                      right: 0,
                      child: _ReaderBottomBar(
                        bottomInset: bottomInset,
                        currentIndex: readerState.currentChapterIndex,
                        totalChapters: widget.chapters.length,
                        backgroundColor: _backgroundColor,
                        surfaceColor: _surfaceColor,
                        borderColor: _borderColor,
                        textColor: _titleColor,
                        mutedColor: _mutedColor,
                        onOpenContents: () => _showContentsSheet(context),
                        onComposeComment: () => unawaited(
                          _showChapterCommentsSheet(),
                        ),
                        onPrevious: _goToPreviousChapter,
                        onComment: () => unawaited(_showChapterCommentsSheet()),
                        onToggleLike: () => unawaited(_toggleCurrentChapterLike()),
                        onNext: _goToNextChapter,
                        isLiked: _isCurrentChapterLiked,
                        isLikeAnimating:
                            currentChapterState?.isLikeAnimating ?? false,
                        isLikeDisabled:
                            (currentChapterState?.isLikeCoolingDown ?? false) ||
                            (currentChapterState?.isLikeRequesting ?? false),
                      ),
                    ),
                    if (_ttsActiveParagraphIndex != null)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 220),
                        right: 16,
                        bottom: _chromeVisible
                            ? (138 + bottomInset)
                            : (16 + bottomInset),
                        child: FloatingActionButton.small(
                          heroTag: 'reader-jump-speaking',
                          onPressed: () => unawaited(_jumpToActiveTtsParagraph()),
                          backgroundColor: kReaderBrand,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          child: const Icon(
                            Icons.my_location_rounded,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showContentsSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChapterSheet(
        chapters: widget.chapters,
        currentIndex: _readerState.currentChapterIndex,
        isDarkMode: _isDarkMode,
        onSelect: (index) {
          Navigator.of(context).pop();
          _openChapter(index);
        },
      ),
    );
  }

  Future<void> _showSettingsSheet(BuildContext context) {
    var draftFontSize = _readerState.bodyFontSize;
    var draftLineHeight = _readerState.lineHeight;
    var draftThemeMode = _readerState.themeMode;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => _ReaderSettingsSheet(
          bodyFontSize: draftFontSize,
          lineHeight: draftLineHeight,
          themeMode: draftThemeMode,
          onFontSizeChanged: (value) {
            setModalState(() => draftFontSize = value);
            _readerCubit.setBodyFontSize(value);
          },
          onLineHeightChanged: (value) {
            setModalState(() => draftLineHeight = value);
            _readerCubit.setLineHeight(value);
          },
          onThemeChanged: (value) {
            setModalState(() => draftThemeMode = value);
            _readerCubit.setThemeMode(value);
            context.read<ThemeCubit>().setDarkMode(value == ReaderThemeMode.dark);
          },
        ),
      ),
    );
  }

  Future<void> _showTtsSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (sheetContext, setModalState) => _ReaderTtsSheet(
          isPlaying: _isTtsPlaying,
          isPaused: _isTtsPaused,
          speechRate: _ttsRate,
          progressChunk: _ttsProgressChunk,
          totalChunks: _ttsTotalChunks,
          onTogglePlayPause: () async {
            await _toggleTts();
            if (!mounted || !sheetContext.mounted) return;
            setModalState(() {});
          },
          onStop: () async {
            await _stopTts();
            if (!mounted || !sheetContext.mounted) return;
            setModalState(() {});
          },
          onSpeechRateChanged: (value) async {
            await _ttsController.setSpeechRate(value);
            if (!mounted || !sheetContext.mounted) return;
            setModalState(() {});
          },
        ),
      ),
    );
  }

  List<String> _splitParagraphIntoSentences(String paragraph) {
    return paragraph
        .trim()
        .split(RegExp(r'(?<=[\.\!\?…])\s+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<InlineSpan> _buildParagraphSentenceSpans({
    required String paragraph,
    required int paragraphIndex,
  }) {
    final sentences = _splitParagraphIntoSentences(paragraph);
    if (sentences.isEmpty) {
      return <InlineSpan>[TextSpan(text: paragraph)];
    }

    final spans = <InlineSpan>[];
    for (var i = 0; i < sentences.length; i++) {
      final isActive = _ttsActiveParagraphIndex == paragraphIndex &&
          _ttsActiveSentenceIndex == i;
      spans.add(
        TextSpan(
          text: sentences[i] + (i == sentences.length - 1 ? '' : ' '),
          style: isActive
              ? TextStyle(
                  backgroundColor: _accentColor.withValues(alpha: 0.22),
                )
              : null,
        ),
      );
    }
    return spans;
  }
}



