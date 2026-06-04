import 'package:ink_trail_client/features/home/domain/repositories/home_notifications_repository.dart';

class SubmitReportAppealUsecase {
  final HomeNotificationsRepository _repository;

  const SubmitReportAppealUsecase(this._repository);

  Future<void> call({
    required String caseId,
    required String reason,
  }) =>
      _repository.submitReportAppeal(caseId: caseId, reason: reason);
}
