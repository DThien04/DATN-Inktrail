import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/core/di/service_locator.dart';
import 'package:ink_trail_client/features/report/presentation/cubit/report_appeal_cubit.dart';
import 'package:ink_trail_client/features/report/presentation/cubit/report_appeal_state.dart';

class ReportAppealSheetResult {
  final bool isSuccess;
  final String message;

  const ReportAppealSheetResult._({
    required this.isSuccess,
    required this.message,
  });

  const ReportAppealSheetResult.success()
    : this._(
        isSuccess: true,
        message: 'Đã gửi kháng nghị thành công.',
      );

  const ReportAppealSheetResult.error(String message)
    : this._(
        isSuccess: false,
        message: message,
      );
}

class ReportAppealSheet extends StatelessWidget {
  final String caseId;

  const ReportAppealSheet({
    super.key,
    required this.caseId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportAppealCubit>(),
      child: _ReportAppealSheetView(caseId: caseId),
    );
  }
}

class _ReportAppealSheetView extends StatefulWidget {
  final String caseId;

  const _ReportAppealSheetView({required this.caseId});

  @override
  State<_ReportAppealSheetView> createState() => _ReportAppealSheetViewState();
}

class _ReportAppealSheetViewState extends State<_ReportAppealSheetView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cubit = context.read<ReportAppealCubit>();
    final isSuccess = await cubit.submit(caseId: widget.caseId);
    if (!mounted) return;

    if (isSuccess) {
      Navigator.of(context).pop(const ReportAppealSheetResult.success());
      return;
    }

    final message = cubit.state.errorMessage;
    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BlocBuilder<ReportAppealCubit, ReportAppealState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            18,
            22,
            MediaQuery.of(context).viewInsets.bottom + 22,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gửi kháng nghị',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hãy nêu rõ vì sao bạn cho rằng nội dung nên được hiển thị lại. '
                'Quản trị viên sẽ xem xét kháng nghị của bạn.',
                style: TextStyle(
                  fontSize: 15.5,
                  height: 1.58,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                minLines: 4,
                maxLines: 7,
                maxLength: 1000,
                enabled: !state.isSubmitting,
                onChanged: context.read<ReportAppealCubit>().reasonChanged,
                style: TextStyle(color: scheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Ví dụ: Nội dung bị hiểu nhầm vì...',
                  filled: true,
                  fillColor: scheme.surface,
                  hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                  counterStyle: TextStyle(color: scheme.onSurfaceVariant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: scheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: scheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: scheme.primary, width: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF241B15),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFB9AEA5),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    state.isSubmitting
                        ? 'Đang gửi...'
                        : 'Gửi kháng nghị',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
