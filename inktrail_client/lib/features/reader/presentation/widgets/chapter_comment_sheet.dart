part of '../pages/reader_page.dart';

class _ChapterCommentSheet extends StatefulWidget {
  final String chapterId;
  final String title;
  final String placeholder;
  final TokenStorage tokenStorage;
  final int initialCommentCount;
  final Future<void> Function() onChapterHidden;
  final ValueChanged<int> onCommentCountChanged;
  final bool isDarkMode;
  final Color surfaceColor;
  final Color borderColor;
  final Color titleColor;
  final Color bodyColor;
  final Color mutedColor;
  final Color accentColor;

  const _ChapterCommentSheet({
    required this.chapterId,
    required this.title,
    required this.placeholder,
    required this.tokenStorage,
    required this.initialCommentCount,
    required this.onChapterHidden,
    required this.onCommentCountChanged,
    required this.isDarkMode,
    required this.surfaceColor,
    required this.borderColor,
    required this.titleColor,
    required this.bodyColor,
    required this.mutedColor,
    required this.accentColor,
  });

  @override
  State<_ChapterCommentSheet> createState() => _ChapterCommentSheetState();
}

class _ChapterCommentSheetState extends State<_ChapterCommentSheet> {
  final GetChapterCommentsUsecase _getChapterComments =
      sl<GetChapterCommentsUsecase>();
  final SetChapterCommentLikeUsecase _setCommentLike =
      sl<SetChapterCommentLikeUsecase>();
  final SaveChapterCommentUsecase _saveComment = sl<SaveChapterCommentUsecase>();
  final SubmitChapterCommentReportUsecase _reportComment =
      sl<SubmitChapterCommentReportUsecase>();
  final DeleteChapterCommentUsecase _deleteChapterComment =
      sl<DeleteChapterCommentUsecase>();
  final GetReaderSocketBaseUrlUsecase _getSocketBaseUrl =
      sl<GetReaderSocketBaseUrlUsecase>();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  io.Socket? _socket;
  _ReaderCommentSort _sort = _ReaderCommentSort.hot;
  List<ReaderCommentView> _comments = <ReaderCommentView>[];
  final Set<String> _likingCommentIds = <String>{};
  int _totalComments = 0;
  bool _isLoading = true;
  bool _isSending = false;
  String? _editingCommentId;
  String? _replyTargetCommentId;
  String? _errorMessage;
  _ReaderPageState? get _readerPageState =>
      context.findAncestorStateOfType<_ReaderPageState>();
  String get _currentUserId => _readerPageState?._currentUserId ?? '';
  bool get _isAdmin => _readerPageState?._isCurrentUserAdmin ?? false;
  bool _belongsToCurrentUser(ReaderCommentView comment) =>
      comment.isMine ||
      (_currentUserId.isNotEmpty && comment.userId == _currentUserId);
  int get _approvedCommentCount =>
      _comments.where((item) => item.isApproved).length;
  int get _effectiveApprovedTotal =>
      _totalComments > _approvedCommentCount ? _totalComments : _approvedCommentCount;
  int get _visibleCommentCount =>
      _effectiveApprovedTotal +
      _comments
          .where((item) => _belongsToCurrentUser(item) && !item.isApproved)
          .length;

  List<ReaderCommentView> get _rootComments =>
      _comments.where((item) => !item.isReply).toList();

  List<ReaderCommentView> _repliesFor(String parentId) => _comments
      .where((item) => item.parentId == parentId)
      .toList()
    ..sort((a, b) => a.timestampOrder.compareTo(b.timestampOrder));

  List<ReaderCommentView> get _sortedComments {
    final items = List<ReaderCommentView>.from(_rootComments);
    if (_sort == _ReaderCommentSort.hot) {
      items.sort((a, b) {
        final highlightedOrder =
            (b.isHighlighted ? 1 : 0).compareTo(a.isHighlighted ? 1 : 0);
        if (highlightedOrder != 0) return highlightedOrder;
        return b.timestampOrder.compareTo(a.timestampOrder);
      });
      return items;
    }

    items.sort((a, b) => b.timestampOrder.compareTo(a.timestampOrder));
    return items;
  }

  bool get _canSend => !_isSending && _controller.text.trim().isNotEmpty;

  ReaderCommentView? get _editingComment {
    final editingId = _editingCommentId;
    if (editingId == null || editingId.isEmpty) return null;
    for (final item in _comments) {
      if (item.id == editingId) return item;
    }
    return null;
  }

  ReaderCommentView? get _replyTargetComment {
    final replyId = _replyTargetCommentId;
    if (replyId == null || replyId.isEmpty) return null;
    for (final item in _comments) {
      if (item.id == replyId) return item;
    }
    return null;
  }

  Future<void> _handleHiddenChapter() async {
    if (!mounted) return;
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(widget.onChapterHidden());
    });
  }

  void _clearComposerState() {
    _editingCommentId = null;
    _replyTargetCommentId = null;
    _controller.clear();
    _focusNode.unfocus();
  }

  void _beginReplyToComment(ReaderCommentView comment) {
    setState(() {
      _replyTargetCommentId = comment.id;
      _editingCommentId = null;
    });
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _removeCommentLocally(String commentId) {
    if (commentId.isEmpty) return;
    final removedItems = _comments
        .where((item) => item.id == commentId || item.parentId == commentId)
        .toList();
    if (removedItems.isEmpty) return;

    setState(() {
      _comments = _comments
          .where((item) => item.id != commentId && item.parentId != commentId)
          .toList();
      final approvedRemovedCount =
          removedItems.where((item) => item.isApproved).length;
      if (approvedRemovedCount > 0) {
        _totalComments =
            _totalComments > approvedRemovedCount ? _totalComments - approvedRemovedCount : 0;
      }
      if (_editingCommentId == commentId ||
          removedItems.any((item) => item.id == _editingCommentId)) {
        _clearComposerState();
      } else if (_replyTargetCommentId == commentId ||
          removedItems.any((item) => item.id == _replyTargetCommentId)) {
        _replyTargetCommentId = null;
      }
    });
    widget.onCommentCountChanged(_approvedCommentCount);
  }

  Future<void> _toggleCommentLike(ReaderCommentView comment) async {
    if (comment.id.isEmpty || _likingCommentIds.contains(comment.id)) return;
    if (!comment.isApproved) {
      showReaderCommentMessage(
        context,
        'Bình luận này đang được kiểm duyệt, chưa thể tương tác.',
      );
      return;
    }
    if (!await AuthGate.requireAuth(context)) return;

    final previousLiked = comment.isLiked;
    final previousCount = comment.likeCount;
    final nextLiked = !previousLiked;
    final optimisticCount = nextLiked
        ? previousCount + 1
        : (previousCount > 0 ? previousCount - 1 : 0);

    setState(() {
      _likingCommentIds.add(comment.id);
      _comments = _comments
          .map(
            (item) => item.id == comment.id
                ? item.copyWith(
                    likeCount: optimisticCount,
                    isLiked: nextLiked,
                  )
                : item,
          )
          .toList();
    });

    try {
      final result = await _setCommentLike(
        commentId: comment.id,
        liked: nextLiked,
        fallbackLikeCount: optimisticCount,
      );
      if (!mounted) return;
      setState(() {
        _comments = _comments
            .map(
              (item) => item.id == comment.id
                  ? item.copyWith(
                      likeCount: result.likeCount,
                      isLiked: result.liked,
                    )
                  : item,
            )
            .toList();
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      if (isReaderCommentHiddenError(error)) {
        _removeCommentLocally(comment.id);
        showReaderCommentMessage(context, 'Bình luận này đã bị gỡ.');
        return;
      }
      setState(() {
        _comments = _comments
            .map(
              (item) => item.id == comment.id
                  ? item.copyWith(
                      likeCount: previousCount,
                      isLiked: previousLiked,
                    )
                  : item,
            )
            .toList();
      });
      showReaderCommentMessage(context, 'Không thể cập nhật lượt thích bình luận lúc này.');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _comments = _comments
            .map(
              (item) => item.id == comment.id
                  ? item.copyWith(
                      likeCount: previousCount,
                      isLiked: previousLiked,
                    )
                  : item,
            )
            .toList();
      });
      showReaderCommentMessage(context, 'Không thể cập nhật lượt thích bình luận lúc này.');
    } finally {
      if (mounted) {
        setState(() => _likingCommentIds.remove(comment.id));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleComposerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onCommentCountChanged(widget.initialCommentCount);
    });
    unawaited(_loadComments());
    unawaited(_connectSocket());
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleComposerChanged)
      ..dispose();
    _focusNode.dispose();
    _socket?.emit(
      'comments:unsubscribe-chapter',
      <String, dynamic>{'chapter_id': widget.chapterId},
    );
    _socket?.dispose();
    _socket = null;
    super.dispose();
  }

  void _handleComposerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadComments() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _getChapterComments(chapterId: widget.chapterId);
      final comments = data.items
          .map(
            (item) => ReaderCommentView.fromEntity(
              item,
              currentUserId: _currentUserId,
            ),
          )
          .toList();
      if (!mounted) return;
      setState(() {
        _comments = comments;
        _totalComments = data.total;
        _isLoading = false;
      });
      widget.onCommentCountChanged(_approvedCommentCount);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (isReaderChapterHiddenError(e)) {
        await _handleHiddenChapter();
        return;
      }
      setState(() {
        _errorMessage = extractReaderCommentErrorMessage(e);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể tải bình luận chương lúc này.';
        _isLoading = false;
      });
    }
  }

  Future<void> _connectSocket() async {
    final socketUrl = _getSocketBaseUrl();
    if (socketUrl == null) return;

    final accessToken = await widget.tokenStorage.getAccessToken();
    final socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(<String>['websocket'])
          .disableAutoConnect()
          .enableForceNew()
          .setAuth(
            accessToken == null || accessToken.isEmpty
                ? <String, dynamic>{}
                : <String, dynamic>{'token': 'Bearer $accessToken'},
          )
          .build(),
    );

    socket.onConnect((_) {
      socket.emit(
        'comments:subscribe-chapter',
        <String, dynamic>{'chapter_id': widget.chapterId},
      );
    });

    socket.on('chapter-comment:new', (dynamic payload) {
      final comment = ReaderCommentView.tryFromChapterCommentJson(
        payload,
        currentUserId: _currentUserId,
      );
      if (comment == null || comment.chapterId != widget.chapterId) return;
      if (!mounted) return;
      setState(() {
        _comments = mergeReaderCommentViews(_comments, comment);
        if (_totalComments < _approvedCommentCount) {
          _totalComments = _approvedCommentCount;
        }
      });
      widget.onCommentCountChanged(_approvedCommentCount);
    });

    socket.on('chapter-comment:removed', (dynamic payload) {
      if (payload is! Map) return;
      final commentId = (payload['comment_id'] ?? '').toString();
      final chapterId = (payload['chapter_id'] ?? '').toString();
      final userId = (payload['user_id'] ?? '').toString();
      if (commentId.isEmpty || chapterId != widget.chapterId) return;
      if (!mounted) return;
      final currentUserId = _currentUserId;
      final removedComment = _comments.cast<ReaderCommentView?>().firstWhere(
            (item) => item?.id == commentId,
            orElse: () => null,
          );
      if (removedComment == null) return;

      if (_belongsToCurrentUser(removedComment) ||
          (currentUserId.isNotEmpty && userId == currentUserId)) {
        final reason = (payload['reason'] ?? '').toString().trim();
        setState(() {
          _comments = _comments
              .map(
                (item) => item.id == commentId
                    ? item.copyWith(
                        moderationStatus: 'rejected',
                        moderationReason: reason.isEmpty ? null : reason,
                      )
                    : item,
              )
              .toList();
        });
        return;
      }
      _removeCommentLocally(commentId);
    });

    socket.connect();
    _socket = socket;
  }

  Future<void> _sendComment() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    if (!await AuthGate.requireAuth(context)) return;
    final editingComment = _editingComment;
    final replyTarget = _replyTargetComment;

    setState(() => _isSending = true);
    try {
      final savedComment = editingComment == null
          ? await _saveComment.create(
              chapterId: widget.chapterId,
              content: content,
              parentId: replyTarget?.id,
            )
          : await _saveComment.update(
              commentId: editingComment.id,
              content: content,
            );
      final comment =
          savedComment == null
              ? null
              : ReaderCommentView.fromEntity(
                  savedComment,
                  currentUserId: _currentUserId,
                );
      if (!mounted) return;
      setState(() {
        _clearComposerState();
      });
      if (comment != null) {
        setState(() {
          _comments = mergeReaderCommentViews(_comments, comment);
        });
        widget.onCommentCountChanged(_approvedCommentCount);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      if (isReaderChapterHiddenError(e)) {
        await _handleHiddenChapter();
        return;
      }
      showReaderCommentMessage(context, extractReaderCommentErrorMessage(e));
    } catch (_) {
      if (!mounted) return;
      showReaderCommentMessage(context, 'Không thể gửi bình luận lúc này.');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _openCommentActions(ReaderCommentView comment) async {
    final isAuthenticated = await AuthGate.requireAuth(context);
    if (!mounted || !isAuthenticated) return;
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        final canManage = _belongsToCurrentUser(comment) || _isAdmin;
        final canReply = !comment.isReply && comment.isApproved;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canReply)
                ListTile(
                  leading: const Icon(Icons.reply_rounded),
                  title: const Text('Trả lời bình luận'),
                  onTap: () => Navigator.of(context).pop('reply'),
                ),
              if (canManage) ...[
                ListTile(
                  leading: const Icon(Icons.edit_rounded),
                  title: const Text('Sửa bình luận'),
                  onTap: () => Navigator.of(context).pop('edit'),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title: const Text('Xóa bình luận'),
                  textColor: Colors.red,
                  onTap: () => Navigator.of(context).pop('delete'),
                ),
              ] else
                ListTile(
                  leading: const Icon(Icons.flag_outlined, color: kReaderBrand),
                  title: const Text('Báo cáo bình luận'),
                  onTap: () => Navigator.of(context).pop('report'),
                ),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) return;
    if (action == 'reply') {
      _beginReplyToComment(comment);
      return;
    }
    if (action == 'report') {
      await _openReportCommentSheet(comment);
      return;
    }
    if (action == 'edit') {
      setState(() {
        _editingCommentId = comment.id;
        _replyTargetCommentId = null;
      });
      _controller.text = comment.content;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
      _focusNode.requestFocus();
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa bình luận'),
          content: const Text('Bạn có chắc muốn xóa bình luận này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;
    await _deleteComment(comment);
  }

  Future<void> _openReportCommentSheet(ReaderCommentView comment) async {
    final reportPayload = await showReportSubmitSheet(
      context: context,
      title: 'Báo cáo bình luận',
      subtitle: 'Chọn lý do phù hợp để chúng tôi xem xét bình luận này.',
      initialReason: 'spam',
      descriptionRequiredReasons: const {'other'},
      descriptionHint: 'Mô tả thêm nếu cần...',
      reasonOptions: const [
        ReportReasonOption(value: 'spam', label: 'Spam'),
        ReportReasonOption(value: 'abuse', label: 'Quấy rối'),
        ReportReasonOption(value: 'hate', label: 'Thù ghét'),
        ReportReasonOption(value: 'sexual', label: 'Tình dục'),
        ReportReasonOption(value: 'violence', label: 'Bạo lực'),
        ReportReasonOption(value: 'other', label: 'Khác'),
      ],
      surfaceColor: widget.surfaceColor,
      borderColor: widget.borderColor,
      titleColor: widget.titleColor,
      mutedColor: widget.mutedColor,
      accentColor: widget.accentColor,
    );

    if (reportPayload == null || !mounted) return;
    await _submitCommentReport(
      comment: comment,
      reason: reportPayload.reason,
      description: reportPayload.description,
    );
  }

  Future<void> _submitCommentReport({
    required ReaderCommentView comment,
    required String reason,
    required String description,
  }) async {
    try {
      await _reportComment(
        commentId: comment.id,
        reason: reason,
        description: description,
      );
      if (!mounted) return;
      showReaderCommentMessage(
        context,
        'Đã gửi báo cáo bình luận thành công.',
        isSuccess: true,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      if (isReaderChapterHiddenError(e)) {
        await _handleHiddenChapter();
        return;
      }
      if (isReaderCommentHiddenError(e)) {
        _removeCommentLocally(comment.id);
        showReaderCommentMessage(context, 'Bình luận này đã bị gỡ.');
        return;
      }
      showReaderCommentMessage(context, extractReaderCommentErrorMessage(e));
    } catch (_) {
      if (!mounted) return;
      showReaderCommentMessage(context, 'Không thể gửi báo cáo lúc này.');
    }
  }

  Future<void> _deleteComment(ReaderCommentView comment) async {
    final previousItems = List<ReaderCommentView>.from(_comments);
    final previousTotal = _totalComments;
    final removedItems = _comments
        .where((item) => item.id == comment.id || item.parentId == comment.id)
        .toList();
    final approvedRemovedCount =
        removedItems.where((item) => item.isApproved).length;

    setState(() {
      _comments = _comments
          .where((item) => item.id != comment.id && item.parentId != comment.id)
          .toList();
      if (approvedRemovedCount > 0) {
        _totalComments =
            _totalComments > approvedRemovedCount ? _totalComments - approvedRemovedCount : 0;
      }
      if (removedItems.any((item) => item.id == _editingCommentId) ||
          removedItems.any((item) => item.id == _replyTargetCommentId)) {
        _clearComposerState();
      }
    });
    widget.onCommentCountChanged(_approvedCommentCount);

    try {
      await _deleteChapterComment(commentId: comment.id);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (isReaderChapterHiddenError(e)) {
        await _handleHiddenChapter();
        return;
      }
      if (isReaderCommentHiddenError(e)) {
        _removeCommentLocally(comment.id);
        showReaderCommentMessage(context, 'Bình luận này đã bị gỡ.');
        return;
      }
      setState(() {
        _comments = previousItems;
        _totalComments = previousTotal;
      });
      widget.onCommentCountChanged(_approvedCommentCount);
      showReaderCommentMessage(context, extractReaderCommentErrorMessage(e));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _comments = previousItems;
        _totalComments = previousTotal;
      });
      widget.onCommentCountChanged(_approvedCommentCount);
      showReaderCommentMessage(context, 'Không thể xóa bình luận lúc này.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final comments = _sortedComments;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          top: mediaQuery.padding.top + 20,
          bottom: mediaQuery.viewInsets.bottom,
        ),
        child: Container(
          height: mediaQuery.size.height * 0.76,
          decoration: BoxDecoration(
            color: widget.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: widget.borderColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 14, 10),
                child: Row(
                  children: [
                    const SizedBox(width: 34),
                    Expanded(
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: widget.titleColor,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 34,
                      height: 34,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        splashRadius: 18,
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: widget.titleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Row(
                  children: [
                    Text(
                      'Tổng $_visibleCommentCount bình luận',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: widget.titleColor,
                      ),
                    ),
                    const Spacer(),
                    _CommentSortButton(
                      label: 'Nổi bật',
                      active: _sort == _ReaderCommentSort.hot,
                      borderColor: widget.borderColor,
                      accentColor: widget.accentColor,
                      mutedColor: widget.mutedColor,
                      onTap: () => setState(() => _sort = _ReaderCommentSort.hot),
                    ),
                    const SizedBox(width: 8),
                    _CommentSortButton(
                      label: 'Mới',
                      active: _sort == _ReaderCommentSort.latest,
                      borderColor: widget.borderColor,
                      accentColor: widget.accentColor,
                      mutedColor: widget.mutedColor,
                      onTap: () =>
                          setState(() => _sort = _ReaderCommentSort.latest),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (_isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (_errorMessage != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: widget.mutedColor,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () => unawaited(_loadComments()),
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (comments.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Chưa có bình luận nào cho chương này.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: widget.mutedColor,
                              height: 1.5,
                            ),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      itemCount: comments.length,
                      itemBuilder: (_, index) {
                        final comment = comments[index];
                        final replies = _repliesFor(comment.id);
                        return Column(
                          children: [
                            _ReaderCommentTile(
                              comment: comment,
                              isDarkMode: widget.isDarkMode,
                              borderColor: widget.borderColor,
                              titleColor: widget.titleColor,
                              bodyColor: widget.bodyColor,
                              mutedColor: widget.mutedColor,
                              accentColor: widget.accentColor,
                              isLiking: _likingCommentIds.contains(comment.id),
                              onToggleLike: () =>
                                  unawaited(_toggleCommentLike(comment)),
                              onAuthorTap: comment.userId.isEmpty
                                  ? null
                                  : () => openUserProfile(
                                        context,
                                        userId: comment.userId,
                                        initialName: comment.author,
                                      ),
                              onLongPress: () =>
                                  unawaited(_openCommentActions(comment)),
                              onMoreTap: () =>
                                  unawaited(_openCommentActions(comment)),
                              onReplyTap: !comment.isApproved
                                  ? null
                                  : () => _beginReplyToComment(comment),
                            ),
                            if (replies.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 54),
                                child: Column(
                                  children: replies
                                      .map(
                                        (reply) => _ReaderCommentTile(
                                          comment: reply,
                                          isDarkMode: widget.isDarkMode,
                                          borderColor: widget.borderColor,
                                          titleColor: widget.titleColor,
                                          bodyColor: widget.bodyColor,
                                          mutedColor: widget.mutedColor,
                                          accentColor: widget.accentColor,
                                          isCompact: true,
                                          isLiking: _likingCommentIds.contains(reply.id),
                                          onToggleLike: () =>
                                              unawaited(_toggleCommentLike(reply)),
                                          onAuthorTap: reply.userId.isEmpty
                                              ? null
                                              : () => openUserProfile(
                                                    context,
                                                    userId: reply.userId,
                                                    initialName: reply.author,
                                                  ),
                                          onLongPress: () =>
                                              unawaited(_openCommentActions(reply)),
                                          onMoreTap: () =>
                                              unawaited(_openCommentActions(reply)),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            Divider(
                              height: 1,
                              color: widget.borderColor.withValues(alpha: 0.65),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  12 + mediaQuery.padding.bottom,
                ),
                decoration: BoxDecoration(
                  color: widget.surfaceColor,
                  border: Border(top: BorderSide(color: widget.borderColor)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_replyTargetComment != null || _editingComment != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: widget.borderColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _editingComment != null
                                    ? 'Đang sửa bình luận'
                                    : 'Đang trả lời ${_replyTargetComment!.author}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: widget.titleColor,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _replyTargetCommentId = null;
                                  _editingCommentId = null;
                                  _controller.clear();
                                });
                              },
                              child: const Text('Hủy'),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: widget.borderColor.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.centerLeft,
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              minLines: 1,
                              maxLines: 1,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => unawaited(_sendComment()),
                              decoration: InputDecoration(
                                isCollapsed: true,
                                border: InputBorder.none,
                                hintText: _editingComment != null
                                    ? 'Chỉnh sửa bình luận...'
                                    : _replyTargetComment != null
                                        ? 'Trả lời ${_replyTargetComment!.author}...'
                                        : widget.placeholder,
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: widget.mutedColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: widget.titleColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _canSend ? () => unawaited(_sendComment()) : null,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 150),
                            opacity: _canSend ? 1 : 0.56,
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: widget.isDarkMode
                                    ? widget.borderColor.withValues(alpha: 0.22)
                                    : kReaderLightAccentWash(0.14),
                                borderRadius: BorderRadius.circular(16),
                                border: widget.isDarkMode
                                    ? Border.all(
                                        color: widget.borderColor.withValues(alpha: 0.65),
                                      )
                                    : null,
                              ),
                              child: _isSending
                                  ? Padding(
                                      padding: const EdgeInsets.all(13),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          widget.accentColor,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.send_rounded,
                                      size: 19,
                                      color: widget.accentColor,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _CommentSortButton extends StatelessWidget {
  final String label;
  final bool active;
  final Color borderColor;
  final Color accentColor;
  final Color mutedColor;
  final VoidCallback onTap;

  const _CommentSortButton({
    required this.label,
    required this.active,
    required this.borderColor,
    required this.accentColor,
    required this.mutedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active
              ? borderColor.withValues(alpha: 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? accentColor.withValues(alpha: 0.55) : borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? accentColor : mutedColor,
          ),
        ),
      ),
    );
  }
}

