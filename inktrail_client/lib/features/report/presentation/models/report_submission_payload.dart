class ReportSubmissionPayload {
  final String reason;
  final String description;

  const ReportSubmissionPayload({
    required this.reason,
    required this.description,
  });
}

class ReportReasonOption {
  final String value;
  final String label;

  const ReportReasonOption({
    required this.value,
    required this.label,
  });
}
