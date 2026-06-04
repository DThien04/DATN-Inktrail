class ReportAppealState {
  final String reason;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  const ReportAppealState({
    this.reason = '',
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  bool get canSubmit => reason.trim().length >= 20 && !isSubmitting;

  ReportAppealState copyWith({
    String? reason,
    bool? isSubmitting,
    bool? isSuccess,
    Object? errorMessage = _reportAppealSentinel,
  }) {
    return ReportAppealState(
      reason: reason ?? this.reason,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: identical(errorMessage, _reportAppealSentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _reportAppealSentinel = Object();
