import '../../../../core/error/failure.dart';

enum UploadFailureReason {
  /// The file isn't a photo this device can read, or the backend turned it
  /// down (not WebP, over 2 MB).
  unusablePhoto,

  /// 30 uploads started in the last hour and not finished.
  tooManyUploads,
  signInRequired,
  network,
  unknown,
}

final class UploadFailure extends Failure {
  const UploadFailure(this.reason);

  final UploadFailureReason reason;

  @override
  List<Object?> get props => [reason];
}
