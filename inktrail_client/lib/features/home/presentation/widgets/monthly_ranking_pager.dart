import 'package:flutter/material.dart';
import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';

class MonthlyRankingPager extends StatefulWidget {
  final List<StoryEntity> stories;
  final void Function(StoryEntity story) onTap;
  final VoidCallback? onSeeMore;

  const MonthlyRankingPager({
    super.key,
    required this.stories,
    required this.onTap,
    this.onSeeMore,
  });

  @override
  State<MonthlyRankingPager> createState() => _MonthlyRankingPagerState();
}

class _MonthlyRankingPagerState extends State<MonthlyRankingPager> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stories = widget.stories.take(9).toList();
    final pages = <List<StoryEntity>>[];
    for (var i = 0; i < stories.length; i += 3) {
      pages.add(stories.sublist(i, (i + 3).clamp(0, stories.length)));
    }
    if (pages.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Bảng xếp hạng tháng này',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const Spacer(),
              if (widget.onSeeMore != null)
                GestureDetector(
                  onTap: widget.onSeeMore,
                  child: const Text(
                    'Xem thêm',
                    style: TextStyle(fontSize: 12, color: Color(0xFFC4773B)),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            onPageChanged: (index) => setState(() => _page = index),
            itemBuilder: (_, index) {
              final pageStories = pages[index];
              final startRank = index * 3 + 1;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: List.generate(pageStories.length, (i) {
                    final story = pageStories[i];
                    final rank = startRank + i;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i == 2 ? 0 : 12),
                        child: _RankCard(
                          story: story,
                          rank: rank,
                          onTap: () => widget.onTap(story),
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pages.length, (index) {
            final selected = index == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: selected ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFC4773B)
                    : const Color(0xFFD8CCBF),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _RankCard extends StatelessWidget {
  final StoryEntity story;
  final int rank;
  final VoidCallback onTap;

  const _RankCard({
    required this.story,
    required this.rank,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  height: 158,
                  color: scheme.surfaceContainerHighest,
                  child: story.coverUrl.trim().isEmpty
                      ? Icon(
                          Icons.menu_book_rounded,
                          color: scheme.primary,
                          size: 32,
                        )
                      : Image.network(
                          story.coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.menu_book_rounded,
                            color: scheme.primary,
                            size: 32,
                          ),
                        ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: _RankBadge(rank: rank),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            story.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            story.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.remove_red_eye_outlined,
                size: 12,
                color: Color(0xFFB09E90),
              ),
              const SizedBox(width: 3),
              Text(
                _formatRankReadCount(story.readCount),
                style: TextStyle(
                  fontSize: 10,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatRankReadCount(int count) {
  if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
  return count.toString();
}

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    final fillColor = rank == 1
        ? const Color(0xFFFFD54D)
        : rank == 2
            ? const Color(0xFFD7DEE8)
            : const Color(0xFFE7B07B);
    final ringColor = rank == 1
        ? const Color(0xFFE1B100)
        : rank == 2
            ? const Color(0xFFAFB7C4)
            : const Color(0xFFC98B44);
    final textColor = rank == 1
        ? const Color(0xFFBE9000)
        : rank == 2
            ? const Color(0xFF6F7886)
            : const Color(0xFF9E5F23);

    if (isTop3) {
      return SizedBox(
        width: 18,
        height: 18,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fillColor,
            border: Border.all(color: ringColor, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                color: textColor,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x805F5248),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '#$rank',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
