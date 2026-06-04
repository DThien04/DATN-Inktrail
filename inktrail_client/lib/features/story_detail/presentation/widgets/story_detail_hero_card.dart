import 'package:flutter/material.dart';

class StoryDetailHeroCard extends StatelessWidget {
  final String title;
  final String author;
  final VoidCallback? onTapAuthor;
  final String category;
  final String coverUrl;
  final List<String> tags;

  const StoryDetailHeroCard({
    super.key,
    required this.title,
    required this.author,
    this.onTapAuthor,
    required this.category,
    required this.coverUrl,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: isDark
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8B6E5E), Color(0xFFA5836F)],
              ),
        color: isDark ? scheme.surface : null,
        borderRadius: BorderRadius.circular(28),
        border: isDark ? Border.all(color: scheme.outlineVariant) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCover(context),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: isDark ? scheme.onSurface : Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: onTapAuthor,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDark
                                ? scheme.surfaceContainerHighest
                                : Colors.white.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            author.isNotEmpty ? author[0].toUpperCase() : 'A',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? scheme.onSurface : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? scheme.onSurfaceVariant
                                  : Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                        if (onTapAuthor != null)
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: isDark
                                ? scheme.onSurfaceVariant
                                : Colors.white.withValues(alpha: 0.72),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? scheme.onSurfaceVariant
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...tags.take(2).map((t) => _heroTag(context, t)),
                    _heroTag(context, 'Đã full'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final normalized = coverUrl.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        height: 138,
        decoration: BoxDecoration(
          color: isDark ? scheme.surfaceContainerHighest : const Color(0xFFF5EDE2),
        ),
        child: normalized.isNotEmpty
            ? Image.network(
                normalized,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _coverPlaceholder(context),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFC4773B),
                      ),
                    ),
                  );
                },
              )
            : _coverPlaceholder(context),
      ),
    );
  }

  Widget _coverPlaceholder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      alignment: Alignment.center,
      color: isDark ? scheme.surfaceContainerHighest : const Color(0xFFF5EDE2),
      child: const Icon(
        Icons.menu_book_rounded,
        size: 38,
        color: Color(0xFFC4773B),
      ),
    );
  }

  Widget _heroTag(BuildContext context, String label) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHighest
            : Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: scheme.outlineVariant) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isDark ? scheme.onSurfaceVariant : Colors.white,
        ),
      ),
    );
  }
}
