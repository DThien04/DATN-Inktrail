import 'package:flutter/material.dart';

class StoryDetailTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onDownload;
  final VoidCallback? onMore;
  final bool showMore;

  const StoryDetailTopBar({
    super.key,
    required this.onBack,
    required this.onDownload,
    this.onMore,
    this.showMore = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _iconButton(
            scheme: scheme,
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
          ),
          const Spacer(),
          _iconButton(
            scheme: scheme,
            icon: Icons.file_download_outlined,
            onTap: onDownload,
          ),
          if (showMore) ...[
            const SizedBox(width: 8),
            _iconButton(
              scheme: scheme,
              icon: Icons.warning_amber_rounded,
              onTap: onMore ?? () {},
            ),
          ],
        ],
      ),
    );
  }

  Widget _iconButton({
    required ColorScheme scheme,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: scheme.onSurfaceVariant, size: 18),
      ),
    );
  }
}
