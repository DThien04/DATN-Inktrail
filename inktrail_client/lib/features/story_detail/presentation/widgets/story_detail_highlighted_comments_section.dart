import 'package:flutter/material.dart';

class StoryDetailHighlightedCommentItem {
  final String author;
  final String content;
  final String meta;
  final String chapterLabel;

  const StoryDetailHighlightedCommentItem({
    required this.author,
    required this.content,
    required this.meta,
    this.chapterLabel = '',
  });
}

class StoryDetailHighlightedCommentsSection extends StatelessWidget {
  final bool isLoading;
  final List<StoryDetailHighlightedCommentItem> comments;

  const StoryDetailHighlightedCommentsSection({
    super.key,
    required this.isLoading,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Bình luận nổi bật',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
            ),
            Text(
              '${comments.length} bình luận nổi bật',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const SizedBox(
            height: 172,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (comments.isEmpty)
          Container(
            height: 132,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Text(
              'Chưa có bình luận nổi bật từ các chương của truyện này.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: scheme.onSurfaceVariant,
              ),
            ),
          )
        else
          SizedBox(
            height: 154,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: comments.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _commentCard(context, comments[index]),
            ),
          ),
      ],
    );
  }

  Widget _commentCard(
    BuildContext context,
    StoryDetailHighlightedCommentItem comment,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final first = comment.author.isNotEmpty ? comment.author[0].toUpperCase() : 'U';
    final compactChapterLabel = _compactChapterLabel(comment.chapterLabel);

    return Container(
      width: 286,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  first,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC4773B),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            comment.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            comment.meta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (compactChapterLabel.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          compactChapterLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFC4773B),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _compactChapterLabel(String rawLabel) {
    final label = rawLabel.trim();
    if (label.isEmpty) return '';
    final match = RegExp(r'Chương\s*(\d+)', caseSensitive: false).firstMatch(label);
    if (match == null) return label;
    return 'Chương ${match.group(1)}';
  }
}
