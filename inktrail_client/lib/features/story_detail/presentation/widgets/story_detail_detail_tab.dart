import 'package:flutter/material.dart';

class StoryDetailSuggestionItem {
  final String id;
  final String slug;
  final String title;
  final String description;
  final String author;
  final String coverUrl;
  final String category;
  final int readCount;
  final int likeCount;
  final int chapterCount;
  final bool isLiked;
  final List<String> tags;

  const StoryDetailSuggestionItem({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.author,
    required this.coverUrl,
    required this.category,
    required this.readCount,
    required this.likeCount,
    required this.chapterCount,
    required this.isLiked,
    required this.tags,
  });
}

class StoryDetailDetailTab extends StatelessWidget {
  final String storyDescription;
  final Widget bottomAction;
  final Widget highlightedCommentsSection;
  final String authorName;
  final String authorBio;
  final int authorStoryCount;
  final VoidCallback? onTapAuthor;
  final bool isLoadingSimilarStories;
  final List<StoryDetailSuggestionItem> similarStories;
  final bool isLoadingRecommendedStories;
  final List<StoryDetailSuggestionItem> recommendedStories;
  final ValueChanged<StoryDetailSuggestionItem> onTapSuggestion;

  const StoryDetailDetailTab({
    super.key,
    required this.storyDescription,
    required this.bottomAction,
    required this.highlightedCommentsSection,
    required this.authorName,
    required this.authorBio,
    required this.authorStoryCount,
    this.onTapAuthor,
    required this.isLoadingSimilarStories,
    required this.similarStories,
    required this.isLoadingRecommendedStories,
    required this.recommendedStories,
    required this.onTapSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      key: const ValueKey('detail-tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionCard(
          context,
          title: 'Giới thiệu',
          child: Text(
            storyDescription.isEmpty
                ? 'Chưa có mô tả cho truyện này.'
                : storyDescription,
            style: TextStyle(
              fontSize: 14,
              height: 1.68,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 12),
        bottomAction,
        const SizedBox(height: 16),
        highlightedCommentsSection,
        const SizedBox(height: 14),
        _sectionCard(
          context,
          title: 'Tác giả',
          trailing: Text(
            '$authorStoryCount tác phẩm',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
          child: InkWell(
            onTap: onTapAuthor,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: scheme.primary,
                    child: Icon(Icons.person_rounded, color: scheme.onPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorName,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authorBio,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTapAuthor != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Tác phẩm tương tự',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (isLoadingSimilarStories)
          const SizedBox(
            height: 244,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFC4773B)),
            ),
          )
        else if (similarStories.isEmpty)
          _emptySuggestionBox(context, 'Chưa có tác phẩm tương tự phù hợp.')
        else
          SizedBox(
            height: 244,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: similarStories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _horizontalBookCard(context, similarStories[index]),
            ),
          ),
        const SizedBox(height: 20),
        Text(
          'Người thích tác phẩm này cũng thích',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (isLoadingRecommendedStories)
          const SizedBox(
            height: 240,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFC4773B)),
            ),
          )
        else if (recommendedStories.isEmpty)
          _emptySuggestionBox(context, 'Chưa có dữ liệu gợi ý cho mục này.')
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recommendedStories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 14,
              childAspectRatio: 0.48,
            ),
            itemBuilder: (context, index) =>
                _gridBookCard(context, recommendedStories[index]),
          ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0x00CDB8A5), Color(0x66CDB8A5)],
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0x66CDB8A5),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [Color(0x00CDB8A5), Color(0x66CDB8A5)],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Cảm ơn bạn đã dành thời gian cho câu chuyện này, hy vọng nó để lại một điều gì đó trong bạn.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.65,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _horizontalBookCard(BuildContext context, StoryDetailSuggestionItem book) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => onTapSuggestion(book),
      child: SizedBox(
        width: 132,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _suggestedCover(book, height: 170),
            const SizedBox(height: 10),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_formatCount(book.readCount)} đọc',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridBookCard(BuildContext context, StoryDetailSuggestionItem book) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => onTapSuggestion(book),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.72,
            child: _suggestedCover(book),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 16,
            child: Text(
              book.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _suggestedCover(StoryDetailSuggestionItem book, {double? height}) {
    final coverUrl = book.coverUrl.trim();
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF9B765E), Color(0xFF5A3F33)],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: coverUrl.isNotEmpty
          ? Image.network(
              coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                Icons.menu_book_rounded,
                color: Colors.white70,
                size: 34,
              ),
            )
          : const Icon(
              Icons.menu_book_rounded,
              color: Colors.white70,
              size: 34,
            ),
    );
  }

  Widget _emptySuggestionBox(BuildContext context, String message) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 13,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
