import 'package:flutter/material.dart';

class StoryDetailTabBar extends StatelessWidget {
  final int tabIndex;
  final int chapterCount;
  final ValueChanged<int> onTabChanged;

  const StoryDetailTabBar({
    super.key,
    required this.tabIndex,
    required this.chapterCount,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final chapterLabel = tabIndex == 1 ? 'Chương ($chapterCount)' : 'Chương';

    return Container(
      height: 54,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                alignment: tabIndex == 0
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: constraints.maxWidth / 2,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(child: _tabButton(context, 'Chi tiết', 0)),
                  Expanded(child: _tabButton(context, chapterLabel, 1)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tabButton(BuildContext context, String title, int index) {
    final active = tabIndex == index;
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => onTabChanged(index),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          style: TextStyle(
            fontSize: 14,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: active ? scheme.onSurface : scheme.onSurfaceVariant,
          ),
          child: Text(title, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
