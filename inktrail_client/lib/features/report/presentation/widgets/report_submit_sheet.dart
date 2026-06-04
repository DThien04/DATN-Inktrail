import 'package:flutter/material.dart';
import 'package:ink_trail_client/features/report/presentation/models/report_submission_payload.dart';

Future<ReportSubmissionPayload?> showReportSubmitSheet({
  required BuildContext context,
  required String title,
  required String subtitle,
  required List<ReportReasonOption> reasonOptions,
  String initialReason = 'other',
  String? descriptionHint,
  Set<String> descriptionRequiredReasons = const <String>{},
  bool requireDescriptionForAll = false,
  Color? surfaceColor,
  Color? borderColor,
  Color? titleColor,
  Color? mutedColor,
  Color? accentColor,
}) {
  var selectedReason = initialReason;
  var description = '';

  return showModalBottomSheet<ReportSubmissionPayload>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final scheme = Theme.of(context).colorScheme;
          final effectiveSurfaceColor = surfaceColor ?? scheme.surface;
          final effectiveBorderColor = borderColor ?? scheme.outlineVariant;
          final effectiveTitleColor = titleColor ?? scheme.onSurface;
          final effectiveMutedColor = mutedColor ?? scheme.onSurfaceVariant;
          final effectiveAccentColor = accentColor ?? scheme.primary;
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          final needsDescription = requireDescriptionForAll ||
              descriptionRequiredReasons.contains(selectedReason);
          final canSubmit = needsDescription
              ? description.trim().isNotEmpty
              : true;

          return Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Container(
              decoration: BoxDecoration(
                color: effectiveSurfaceColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: effectiveBorderColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: effectiveTitleColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: effectiveMutedColor,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: reasonOptions
                            .map(
                              (option) => _ReportReasonChip(
                                label: option.label,
                                active: selectedReason == option.value,
                                onTap: () => setModalState(
                                  () => selectedReason = option.value,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        decoration: BoxDecoration(
                          color: effectiveBorderColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: effectiveBorderColor),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: TextField(
                          minLines: 3,
                          maxLines: 4,
                          onChanged: (value) => setModalState(() {
                            description = value;
                          }),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText:
                                descriptionHint ?? 'Mô tả thêm nếu cần...',
                            hintStyle: TextStyle(
                              color: effectiveMutedColor,
                              fontSize: 13,
                            ),
                          ),
                          style: TextStyle(
                            color: effectiveTitleColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        needsDescription
                            ? 'Mô tả là bắt buộc để chúng tôi xem xét báo cáo này.'
                            : 'Bạn có thể bổ sung mô tả để quản trị viên xử lý nhanh hơn.',
                        style: TextStyle(
                          fontSize: 12,
                          color: effectiveMutedColor,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              child: const Text('Hủy'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: effectiveAccentColor,
                              ),
                              onPressed: canSubmit
                                  ? () => Navigator.of(sheetContext).pop(
                                        ReportSubmissionPayload(
                                          reason: selectedReason,
                                          description: description.trim(),
                                        ),
                                      )
                                  : null,
                              child: const Text('Gửi báo cáo'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class _ReportReasonChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ReportReasonChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: active
              ? scheme.primary.withValues(alpha: isDarkMode ? 0.16 : 0.14)
              : scheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
