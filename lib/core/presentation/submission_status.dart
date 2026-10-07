enum SubmissionStatus {
  idle,
  inProgress,
  success,
  failure;

  bool get isInProgress => this == SubmissionStatus.inProgress;
}
