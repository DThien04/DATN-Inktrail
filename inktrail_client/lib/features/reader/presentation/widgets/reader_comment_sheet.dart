part of '../pages/reader_page.dart';

enum _ReaderCommentSort { hot, latest }

class _ReaderCommentSheet extends StatefulWidget {
  final String title;
  final String placeholder;
  final List<ReaderCommentView> comments;
  final bool isDarkMode;
  final Color surfaceColor;
  final Color borderColor;
  final Color titleColor;
  final Color bodyColor;
  final Color mutedColor;
  final Color accentColor;
  final VoidCallback onSendTap;

  const _ReaderCommentSheet({
    required this.title,
    required this.placeholder,
    required this.comments,
    required this.isDarkMode,
    required this.surfaceColor,
    required this.borderColor,
    required this.titleColor,
    required this.bodyColor,
    required this.mutedColor,
    required this.accentColor,
    required this.onSendTap,
  });

  @override
  State<_ReaderCommentSheet> createState() => _ReaderCommentSheetState();
}

class _ReaderCommentSheetState extends State<_ReaderCommentSheet> {
  _ReaderCommentSort _sort = _ReaderCommentSort.hot;

  List<ReaderCommentView> get _comments {
    final baseComments = widget.comments;
    final items = List<ReaderCommentView>.from(baseComments);
    if (_sort == _ReaderCommentSort.hot) {
      items.sort((a, b) {
        final highlightedOrder =
            (b.isHighlighted ? 1 : 0).compareTo(a.isHighlighted ? 1 : 0);
        if (highlightedOrder != 0) return highlightedOrder;
        return b.timestampOrder.compareTo(a.timestampOrder);
      });
    } else {
      items.sort((a, b) => b.timestampOrder.compareTo(a.timestampOrder));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final comments = _comments;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(top: mediaQuery.padding.top + 20),
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
                      'Tổng ${comments.length} bình luận',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: widget.titleColor,
                      ),
                    ),
                    const Spacer(),
                    _buildSortButton(
                      label: 'Hot',
                      active: _sort == _ReaderCommentSort.hot,
                      onTap: () => setState(() => _sort = _ReaderCommentSort.hot),
                    ),
                    const SizedBox(width: 8),
                    _buildSortButton(
                      label: 'Mới',
                      active: _sort == _ReaderCommentSort.latest,
                      onTap: () =>
                          setState(() => _sort = _ReaderCommentSort.latest),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  itemCount: comments.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: widget.borderColor.withValues(alpha: 0.65),
                  ),
                  itemBuilder: (_, index) => _ReaderCommentTile(
                    comment: comments[index],
                    isDarkMode: widget.isDarkMode,
                    borderColor: widget.borderColor,
                    titleColor: widget.titleColor,
                    bodyColor: widget.bodyColor,
                    mutedColor: widget.mutedColor,
                    accentColor: widget.accentColor,
                    onToggleLike: () {},
                    onAuthorTap: comments[index].userId.isEmpty
                        ? null
                        : () => openUserProfile(
                              context,
                              userId: comments[index].userId,
                              initialName: comments[index].author,
                            ),
                  ),
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
                child: Row(
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
                        child: Text(
                          widget.placeholder,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.mutedColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: widget.onSendTap,
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
                        child: Icon(
                          Icons.send_rounded,
                          size: 19,
                          color: widget.accentColor,
                        ),
                      ),
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

  Widget _buildSortButton({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? widget.borderColor.withValues(alpha: 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? widget.accentColor.withValues(alpha: 0.35) : widget.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? widget.accentColor : widget.mutedColor,
          ),
        ),
      ),
    );
  }
}

class _ReaderCommentTile extends StatelessWidget {
  final ReaderCommentView comment;
  final bool isDarkMode;
  final Color borderColor;
  final Color titleColor;
  final Color bodyColor;
  final Color mutedColor;
  final Color accentColor;
  final bool isLiking;
  final VoidCallback onToggleLike;
  final VoidCallback? onLongPress;
  final VoidCallback? onMoreTap;
  final VoidCallback? onAuthorTap;

  const _ReaderCommentTile({
    required this.comment,
    required this.isDarkMode,
    required this.borderColor,
    required this.titleColor,
    required this.bodyColor,
    required this.mutedColor,
    required this.accentColor,
    this.isLiking = false,
    required this.onToggleLike,
    this.onLongPress,
    this.onMoreTap,
    this.onAuthorTap,
  });

  @override
  Widget build(BuildContext context) {
    final showRejectedState = comment.isMine && comment.isRejected;
    final displayContent = showRejectedState
        ? 'Bình luận này không thể hiển thị vì chứa nội dung không phù hợp.'
        : comment.content;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onAuthorTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? borderColor.withValues(alpha: 0.22)
                        : kReaderLightAccentWash(0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    comment.author.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: onAuthorTap,
                                behavior: HitTestBehavior.opaque,
                                child: Text(
                                  comment.author,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: titleColor,
                                  ),
                                ),
                              ),
                            ),
                            if (comment.isHighlighted) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: borderColor.withValues(alpha: 0.22),
                                  border: Border.all(
                                    color: borderColor.withValues(alpha: 0.65),
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Nổi bật',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (onMoreTap != null)
                        SizedBox(
                          width: 26,
                          height: 26,
                          child: IconButton(
                            onPressed: onMoreTap,
                            padding: EdgeInsets.zero,
                            splashRadius: 16,
                            icon: Icon(
                              Icons.more_horiz_rounded,
                              size: 18,
                              color: mutedColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.timeText,
                    style: TextStyle(
                      fontSize: 11,
                      color: mutedColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    displayContent,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: showRejectedState ? mutedColor : bodyColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: isLiking || comment.isPending || showRejectedState
                        ? null
                        : onToggleLike,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity:
                          isLiking || comment.isPending || showRejectedState
                              ? 0.58
                              : 1,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: isLiking
                                ? Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.8,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        comment.isLiked
                                            ? const Color(0xFFC95E53)
                                            : mutedColor,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    comment.isLiked
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: 16,
                                    color: comment.isLiked
                                        ? const Color(0xFFC95E53)
                                        : mutedColor,
                                  ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            comment.likeCount <= 0
                                ? 'Thích'
                                : '${comment.likeCount} lượt thích',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: comment.isLiked
                                  ? const Color(0xFFC95E53)
                                  : mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


