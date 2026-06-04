import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ink_trail_client/core/widgets/hashtag_grid_nav_icon.dart';

class NavItem {
  final IconData icon;
  final String label;

  const NavItem({
    required this.icon,
    required this.label,
  });
}

class InktrailBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const InktrailBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    NavItem(
      icon: Iconsax.home,
      label: 'Trang chủ',
    ),
    NavItem(
      icon: Iconsax.search_normal,
      label: 'Tags',
    ),
    NavItem(
      icon: Iconsax.bookmark,
      label: 'Thư viện',
    ),
    NavItem(
      icon: Iconsax.user,
      label: 'Tôi',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outline, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final active = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        duration: const Duration(milliseconds: 180),
                        scale: active ? 1.06 : 1.0,
                        child: i == 1
                            ? HashtagGridNavIcon(
                                color: active
                                    ? scheme.primary
                                    : scheme.onSurfaceVariant,
                                size: 22,
                              )
                            : Icon(
                                item.icon,
                                size: 22,
                                color: active
                                    ? scheme.primary
                                    : scheme.onSurfaceVariant,
                              ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: active ? scheme.primary : scheme.onSurfaceVariant,
                        ),
                        child: Text(item.label),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
