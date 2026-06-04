part of '../pages/reader_page.dart';

class _ChapterEngagementSection extends StatelessWidget {
  final ReaderChapter chapter;
  final ReaderCommentView? highlightedComment;
  final bool isDarkMode;
  final Color titleColor;
  final Color bodyColor;
  final Color mutedColor;
  final Color surfaceColor;
  final Color borderColor;
  final Color accentColor;
  final bool isLiked;
  final bool isLikeAnimating;
  final bool isLikeDisabled;
  final bool isFollowing;
  final int likeCount;
  final int commentCount;
  final VoidCallback onToggleLike;
  final VoidCallback onOpenComments;
  final VoidCallback onToggleFollow;

  const _ChapterEngagementSection({
    required this.chapter,
    required this.highlightedComment,
    required this.isDarkMode,
    required this.titleColor,
    required this.bodyColor,
    required this.mutedColor,
    required this.surfaceColor,
    required this.borderColor,
    required this.accentColor,
    required this.isLiked,
    required this.isLikeAnimating,
    required this.isLikeDisabled,
    required this.isFollowing,
    required this.likeCount,
    required this.commentCount,
    required this.onToggleLike,
    required this.onOpenComments,
    required this.onToggleFollow,
  });

  @override
  Widget build(BuildContext context) {
    final highlighted = highlightedComment;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: isDarkMode ? 0.72 : 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Chạm nhẹ để tương tác với chương này',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onToggleFollow,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        isFollowing ? kReaderLightAccentWash(0.14) : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isFollowing ? accentColor : borderColor,
                    ),
                  ),
                  child: Text(
                    isFollowing ? 'Đang theo dõi' : 'Theo dõi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isFollowing ? accentColor : mutedColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ActionPill(
                      icon: isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      label: isLiked ? 'Đã thích chương' : 'Thích chương',
                      tint: isLiked ? const Color(0xFFC95E53) : accentColor,
                      isActive: isLiked,
                      isAnimating: isLikeAnimating,
                      isDisabled: isLikeDisabled,
                      onTap: onToggleLike,
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '$likeCount lượt yêu thích',
                        style: TextStyle(
                          fontSize: 11,
                          color: mutedColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ActionPill(
                      icon: Icons.maps_ugc_outlined,
                      label: 'Bình luận',
                      tint: accentColor,
                      onTap: onOpenComments,
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '$commentCount bình luận',
                        style: TextStyle(
                          fontSize: 11,
                          color: mutedColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                'Bình luận nổi bật',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (highlighted == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF26211D)
                    : kReaderLightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Text(
                'Chưa có bình luận nổi bật cho chương này. Hãy là người mở lời đầu tiên.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: bodyColor,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF26211D)
                    : kReaderLightSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF302923)
                              : kReaderLightAccentWash(0.2),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          highlighted.author.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              highlighted.author,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              highlighted.timeText,
                              style: TextStyle(
                                fontSize: 11,
                                color: mutedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF302923)
                              : kReaderLightAccentWash(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Nổi bật',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    highlighted.content,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: bodyColor,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          _InlineChapterCommentComposer(
            borderColor: borderColor,
            mutedColor: mutedColor,
            accentColor: accentColor,
            isDarkMode: isDarkMode,
            onTap: onOpenComments,
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color tint;
  final VoidCallback onTap;
  final bool isActive;
  final bool isAnimating;
  final bool isDisabled;

  const _ActionPill({
    required this.icon,
    required this.label,
    required this.tint,
    required this.onTap,
    this.isActive = false,
    this.isAnimating = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isDisabled ? 0.64 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? tint.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? tint.withValues(alpha: 0.4)
                  : (isDark ? const Color(0xFF4A4038) : kReaderLightBorder),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: tint.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                scale: isAnimating ? 1.16 : 1,
                child: Icon(icon, size: 18, color: tint),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: tint,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineChapterCommentComposer extends StatelessWidget {
  final Color borderColor;
  final Color mutedColor;
  final Color accentColor;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _InlineChapterCommentComposer({
    required this.borderColor,
    required this.mutedColor,
    required this.accentColor,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF26211D) : kReaderLightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Viết bình luận cho chương này...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: mutedColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? borderColor.withValues(alpha: 0.22)
                    : kReaderLightAccentWash(0.14),
                borderRadius: BorderRadius.circular(11),
                border: isDarkMode
                    ? Border.all(
                        color: borderColor.withValues(alpha: 0.65),
                      )
                    : null,
              ),
              child: Icon(
                Icons.send_rounded,
                size: 15,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
