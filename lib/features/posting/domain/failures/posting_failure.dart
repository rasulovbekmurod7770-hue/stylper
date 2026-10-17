import '../../../../core/error/failure.dart';

enum PostingFailureReason { signInRequired, invalid, network, unknown }

final class PostingFailure extends Failure {
  const PostingFailure(this.reason);

  final PostingFailureReason reason;

  @override
  List<Object?> get props => [reason];
}
