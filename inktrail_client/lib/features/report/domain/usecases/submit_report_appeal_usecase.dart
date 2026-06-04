import 'package:ink_trail_client/features/report/domain/repositories/report_repository.dart';

class SubmitReportAppealUsecase {
  final ReportRepository _repository;

  const SubmitReportAppealUsecase(this._repository);

  Future<void> call({
    required String caseId,
    required String reason,
  }) =>
      _repository.submitReportAppeal(caseId: caseId, reason: reason);
}
