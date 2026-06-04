import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/features/report/domain/usecases/submit_report_appeal_usecase.dart';
import 'package:ink_trail_client/features/report/presentation/cubit/report_appeal_state.dart';

class ReportAppealCubit extends Cubit<ReportAppealState> {
  final SubmitReportAppealUsecase _submitReportAppeal;

  ReportAppealCubit({
    required SubmitReportAppealUsecase submitReportAppeal,
  }) : _submitReportAppeal = submitReportAppeal,
       super(const ReportAppealState());

  void reasonChanged(String value) {
    emit(
      state.copyWith(
        reason: value,
        errorMessage: null,
        isSuccess: false,
      ),
    );
  }

  Future<bool> submit({required String caseId}) async {
    final reason = state.reason.trim();
    if (reason.length < 20) {
      emit(
        state.copyWith(
          errorMessage: 'Nhập lý do kháng nghị tối thiểu 20 ký tự.',
        ),
      );
      return false;
    }

    emit(
      state.copyWith(
        isSubmitting: true,
        errorMessage: null,
      ),
    );

    try {
      await _submitReportAppeal(
        caseId: caseId,
        reason: reason,
      );
      emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          errorMessage: null,
        ),
      );
      return true;
    } catch (_) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage:
              'Không thể gửi kháng nghị lúc này. Vui lòng thử lại sau.',
        ),
      );
      return false;
    }
  }
}
