import 'package:flutter/material.dart';

class StoryDetailStatsCard extends StatelessWidget {
  final String likeText;
  final String readText;
  final String ratingText;
  final VoidCallback onTapRating;

  const StoryDetailStatsCard({
    super.key,
    required this.likeText,
    required this.readText,
    required this.ratingText,
    required this.onTapRating,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(child: _statCell(context, likeText, 'Lượt thích')),
          _divider(context),
          Expanded(child: _statCell(context, readText, 'Lượt đọc')),
          _divider(context),
          Expanded(
            child: GestureDetector(
              onTap: onTapRating,
              behavior: HitTestBehavior.opaque,
              child: _statCell(
                context,
                ratingText,
                'Đánh giá',
                trailing: const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: Color(0xFFF2B74A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 0.5,
      height: 32,
      color: scheme.outlineVariant,
    );
  }

  Widget _statCell(BuildContext context, String value, String label, {Widget? trailing}) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 4),
              trailing,
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
