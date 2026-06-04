import 'package:flutter/material.dart';

class StoryDetailChapterListItem {
  final int number;
  final String title;
  final String subtitle;
  final int likeCount;
  final int commentCount;

  const StoryDetailChapterListItem({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.likeCount,
    required this.commentCount,
  });
}

class StoryDetailChapterTab extends StatelessWidget {
  final bool isLoading;
  final List<StoryDetailChapterListItem> chapters;
  final ValueChanged<int> onTapChapter;

  const StoryDetailChapterTab({
    super.key,
    required this.isLoading,
    required this.chapters,
    required this.onTapChapter,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: Color(0xFFC4773B))),
      );
    }

    if (chapters.isEmpty) {
      return Container(
        key: const ValueKey('chapter-empty'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Text(
          'Truyện này chưa có chương nào',
          style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
        ),
      );
    }

    return Column(
      key: const ValueKey('chapter-tab'),
      children: List.generate(
        chapters.length,
        (index) => _chapterTile(
          context,
          chapters[index],
          onTap: () => onTapChapter(index),
        ),
      ),
    );
  }

  Widget _chapterTile(
    BuildContext context,
    StoryDetailChapterListItem chapter, {
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${chapter.number}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    chapter.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _chapterMeta(
                        context,
                        icon: Icons.favorite_border_rounded,
                        value: _formatCount(chapter.likeCount),
                      ),
                      const SizedBox(width: 12),
                      _chapterMeta(
                        context,
                        icon: Icons.forum_outlined,
                        value: chapter.commentCount.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFD9CECA),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chapterMeta(
    BuildContext context, {
    required IconData icon,
    required String value,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: scheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
