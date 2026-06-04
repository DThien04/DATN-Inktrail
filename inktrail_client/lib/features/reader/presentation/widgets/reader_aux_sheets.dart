part of '../pages/reader_page.dart';

class _ChapterSheet extends StatelessWidget {
  final List<ReaderChapter> chapters;
  final int currentIndex;
  final bool isDarkMode;
  final ValueChanged<int> onSelect;

  const _ChapterSheet({
    required this.chapters,
    required this.currentIndex,
    required this.isDarkMode,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final background =
        isDarkMode ? const Color(0xFF201C19) : kReaderLightSurface;
    final border = isDarkMode ? const Color(0xFF4A4038) : kReaderLightBorder;
    final titleColor =
        isDarkMode ? const Color(0xFFF6EFE6) : kReaderLightTitle;
    final activeBackground = isDarkMode
        ? border.withValues(alpha: 0.22)
        : kReaderLightAccentWash(0.14);
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          itemCount: chapters.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, index) {
            if (index == 0) {
              return Text(
                'Danh sách chương',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              );
            }
            final chapter = chapters[index - 1];
            final active = currentIndex == index - 1;
            return GestureDetector(
              onTap: () => onSelect(index - 1),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: active ? activeBackground : background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: active ? kReaderBrand : border,
                  ),
                ),
                child: Text(
                  'Chương ${chapter.number} · ${chapter.title}',
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ReaderSettingsSheet extends StatelessWidget {
  final double bodyFontSize;
  final double lineHeight;
  final ReaderThemeMode themeMode;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<double> onLineHeightChanged;
  final ValueChanged<ReaderThemeMode> onThemeChanged;

  const _ReaderSettingsSheet({
    required this.bodyFontSize,
    required this.lineHeight,
    required this.themeMode,
    required this.onFontSizeChanged,
    required this.onLineHeightChanged,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = themeMode == ReaderThemeMode.dark;
    final backgroundColor =
        isDarkMode ? const Color(0xFF201C19) : kReaderLightSurface;
    final titleColor =
        isDarkMode ? const Color(0xFFF6EFE6) : kReaderLightTitle;
    final bodyColor =
        isDarkMode ? const Color(0xFFE2D7CC) : kReaderLightBody;
    final borderColor =
        isDarkMode ? const Color(0xFF4A4038) : kReaderLightBorder;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tùy chỉnh đọc',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ThemeButton(
                      label: 'Sáng',
                      active: themeMode == ReaderThemeMode.light,
                      onTap: () => onThemeChanged(ReaderThemeMode.light),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ThemeButton(
                      label: 'Tối',
                      active: themeMode == ReaderThemeMode.dark,
                      onTap: () => onThemeChanged(ReaderThemeMode.dark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Cỡ chữ', style: TextStyle(color: titleColor)),
                  const Spacer(),
                  Text(
                    '${bodyFontSize.toStringAsFixed(0)} px',
                    style: TextStyle(
                      color: bodyColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Slider(
                value: bodyFontSize,
                min: 14,
                max: 36,
                divisions: 22,
                activeColor: kReaderBrand,
                inactiveColor: borderColor,
                onChanged: onFontSizeChanged,
              ),
              Row(
                children: [
                  Text('Giãn dòng', style: TextStyle(color: titleColor)),
                  const Spacer(),
                  Text(
                    lineHeight.toStringAsFixed(2),
                    style: TextStyle(
                      color: bodyColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Slider(
                value: lineHeight,
                min: 1.2,
                max: 2.4,
                divisions: 12,
                activeColor: kReaderBrand,
                inactiveColor: borderColor,
                onChanged: onLineHeightChanged,
              ),
              const SizedBox(height: 4),
              Text(
                'Đang dùng: ${themeMode == ReaderThemeMode.light ? 'Chế độ sáng' : 'Chế độ tối'}',
                style: TextStyle(
                  color: bodyColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? (isDarkMode
                  ? kReaderBrand.withValues(alpha: 0.16)
                  : kReaderLightAccentWash(0.14))
              : (isDarkMode
                  ? const Color(0xFF2A241F)
                  : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? kReaderBrand
                : (isDarkMode ? const Color(0xFFE7DACD) : kReaderLightBorder),
            width: active ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: active
                ? kReaderBrand
                : (isDarkMode ? const Color(0xFFE2D7CC) : kReaderLightMuted),
          ),
        ),
      ),
    );
  }
}

class _ReaderTtsSheet extends StatelessWidget {
  final bool isPlaying;
  final bool isPaused;
  final double speechRate;
  final int progressChunk;
  final int totalChunks;
  final Future<void> Function() onTogglePlayPause;
  final Future<void> Function() onStop;
  final ValueChanged<double> onSpeechRateChanged;

  const _ReaderTtsSheet({
    required this.isPlaying,
    required this.isPaused,
    required this.speechRate,
    required this.progressChunk,
    required this.totalChunks,
    required this.onTogglePlayPause,
    required this.onStop,
    required this.onSpeechRateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? const Color(0xFF201C19) : kReaderLightSurface;
    final titleColor =
        isDarkMode ? const Color(0xFFF6EFE6) : kReaderLightTitle;
    final bodyColor =
        isDarkMode ? const Color(0xFFE2D7CC) : kReaderLightBody;
    final borderColor =
        isDarkMode ? const Color(0xFF4A4038) : kReaderLightBorder;
    final progressText = totalChunks <= 0
        ? 'Chưa bắt đầu'
        : 'Đang đọc đoạn ${progressChunk.clamp(0, totalChunks)}/$totalChunks';
    final canStop = isPlaying || isPaused;
    final actionLabel = isPlaying
        ? 'Tạm dừng'
        : (isPaused ? 'Tiếp tục' : 'Bắt đầu đọc');
    final actionIcon = isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đọc bằng giọng nói',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                progressText,
                style: TextStyle(
                  fontSize: 12,
                  color: bodyColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => unawaited(onTogglePlayPause()),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: kReaderBrand,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(actionIcon, size: 18),
                      label: Text(actionLabel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: canStop ? () => unawaited(onStop()) : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDarkMode
                            ? const Color(0xFFE2D7CC)
                            : kReaderLightBody,
                        side: BorderSide(color: borderColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.stop_rounded, size: 18),
                      label: const Text('Dừng'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Tốc độ đọc',
                    style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${speechRate.toStringAsFixed(2)}x',
                    style: TextStyle(
                      color: bodyColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Slider(
                value: speechRate.clamp(0.2, 0.8),
                min: 0.2,
                max: 0.8,
                divisions: 12,
                activeColor: kReaderBrand,
                inactiveColor: borderColor,
                onChanged: onSpeechRateChanged,
              ),
              const SizedBox(height: 2),
              Text(
                'Mẹo: Nếu giọng quá nhanh, giảm về khoảng 0.40 - 0.50.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? const Color(0xFFB7A89A) : kReaderLightMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


