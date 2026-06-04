import 'package:flutter/material.dart';
import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';
import 'story_card.dart';

class StoryHorizontalList extends StatelessWidget {
  final String title;
  final List<StoryEntity> stories;
  final void Function(StoryEntity) onTap;
  final VoidCallback? onSeeMore;
  final VoidCallback? onReachEnd;

  const StoryHorizontalList({
    super.key,
    required this.title,
    required this.stories,
    required this.onTap,
    this.onSeeMore,
    this.onReachEnd,
  });

  @override
  Widget build(BuildContext context) {
    return _StoryHorizontalListBody(
      title: title,
      stories: stories,
      onTap: onTap,
      onSeeMore: onSeeMore,
      onReachEnd: onReachEnd,
    );
  }
}

class _StoryHorizontalListBody extends StatefulWidget {
  final String title;
  final List<StoryEntity> stories;
  final void Function(StoryEntity) onTap;
  final VoidCallback? onSeeMore;
  final VoidCallback? onReachEnd;

  const _StoryHorizontalListBody({
    required this.title,
    required this.stories,
    required this.onTap,
    this.onSeeMore,
    this.onReachEnd,
  });

  @override
  State<_StoryHorizontalListBody> createState() =>
      _StoryHorizontalListBodyState();
}

class _StoryHorizontalListBodyState extends State<_StoryHorizontalListBody> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    if (position.pixels >= position.maxScrollExtent - 180) {
      widget.onReachEnd?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              if (widget.onSeeMore != null)
                GestureDetector(
                  onTap: widget.onSeeMore,
                  child: const Text(
                    'Xem thêm',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFC4773B),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 228,
          child: ListView.separated(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: widget.stories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => StoryCard(
              story: widget.stories[i],
              onTap: () => widget.onTap(widget.stories[i]),
            ),
          ),
        ),
      ],
    );
  }
}
