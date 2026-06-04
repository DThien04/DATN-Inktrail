part of '../pages/reader_page.dart';

class _ReaderTopBar extends StatelessWidget {
  final String storyTitle;
  final String chapterTitle;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color borderColor;
  final Color titleColor;
  final Color subtitleColor;
  final bool isTtsActive;
  final VoidCallback onOpenTts;
  final VoidCallback onOpenSettings;
  final Future<void> Function() onBack;

  const _ReaderTopBar({
    required this.storyTitle,
    required this.chapterTitle,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.borderColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.isTtsActive,
    required this.onOpenTts,
    required this.onOpenSettings,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.96),
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => unawaited(onBack()),
              child: _barButton(
                surfaceColor,
                borderColor,
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: titleColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    chapterTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  Text(
                    storyTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: subtitleColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onOpenTts,
              child: _barButton(
                isTtsActive ? kReaderLightAccentWash(0.14) : surfaceColor,
                borderColor,
                Icon(
                  isTtsActive
                      ? Icons.record_voice_over_rounded
                      : Icons.volume_up_rounded,
                  size: 17,
                  color: isTtsActive ? kReaderBrand : titleColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onOpenSettings,
              child: _barButton(
                surfaceColor,
                borderColor,
                Icon(Icons.more_horiz_rounded, size: 16, color: titleColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barButton(Color surfaceColor, Color borderColor, Widget child) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Center(child: child),
    );
  }
}

class _ReaderCommentComposer extends StatelessWidget {
  final Color surfaceColor;
  final Color borderColor;
  final Color textColor;
  final Color mutedColor;
  final bool isDarkMode;
  final Color accentColor;
  final VoidCallback onTap;

  const _ReaderCommentComposer({
    required this.surfaceColor,
    required this.borderColor,
    required this.textColor,
    required this.mutedColor,
    required this.isDarkMode,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        decoration: BoxDecoration(
          color: surfaceColor.withValues(alpha: 0.98),
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: 0.38),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Viết cảm nhận về chương này...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: mutedColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? borderColor.withValues(alpha: 0.22)
                      : kReaderLightAccentWash(0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: isDarkMode
                      ? Border.all(
                          color: borderColor.withValues(alpha: 0.65),
                        )
                      : null,
                ),
                child: Icon(
                  Icons.send_rounded,
                  size: 18,
                  color: accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReaderBottomBar extends StatelessWidget {
  final double bottomInset;
  final int currentIndex;
  final int totalChapters;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color borderColor;
  final Color textColor;
  final Color mutedColor;
  final VoidCallback onOpenContents;
  final VoidCallback onComposeComment;
  final VoidCallback onPrevious;
  final VoidCallback onComment;
  final VoidCallback onToggleLike;
  final VoidCallback onNext;
  final bool isLiked;
  final bool isLikeAnimating;
  final bool isLikeDisabled;

  const _ReaderBottomBar({
    required this.bottomInset,
    required this.currentIndex,
    required this.totalChapters,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.borderColor,
    required this.textColor,
    required this.mutedColor,
    required this.onOpenContents,
    required this.onComposeComment,
    required this.onPrevious,
    required this.onComment,
    required this.onToggleLike,
    required this.onNext,
    required this.isLiked,
    required this.isLikeAnimating,
    required this.isLikeDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 8 + bottomInset),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ReaderCommentComposer(
            surfaceColor: backgroundColor,
            borderColor: borderColor,
            textColor: textColor,
            mutedColor: mutedColor,
            isDarkMode: Theme.of(context).brightness == Brightness.dark,
            accentColor: kReaderBrand,
            onTap: onComposeComment,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Row(
              children: [
                _item(Icons.format_list_bulleted_rounded, 'Mục lục', onOpenContents),
                _navItem(
                  Icons.chevron_left_rounded,
                  'Trước',
                  currentIndex == 0 ? null : onPrevious,
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      'Chương ${currentIndex + 1}/$totalChapters',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                _navItem(
                  Icons.chevron_right_rounded,
                  'Sau',
                  currentIndex == totalChapters - 1 ? null : onNext,
                ),
                _item(Icons.maps_ugc_outlined, 'Bình luận', onComment),
                _item(
                  isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  'Thích chương',
                  onToggleLike,
                  iconColor: isLiked ? const Color(0xFFC95E53) : null,
                  isActive: isLiked,
                  isAnimating: isLikeAnimating,
                  isDisabled: isLikeDisabled,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(
    IconData icon,
    String label,
    VoidCallback? onTap, {
    Color? iconColor,
    bool isActive = false,
    bool isAnimating = false,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: onTap == null ? 0.35 : (isDisabled ? 0.6 : 1),
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                scale: isAnimating ? 1.16 : 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isActive
                        ? kReaderLightAccentWash(0.14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor ?? textColor,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  height: 1.1,
                  color: mutedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.35 : 1,
        child: SizedBox(
          width: 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: textColor),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(fontSize: 10, color: mutedColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


