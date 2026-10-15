import '../../../../core/error/failure.dart';

enum PostFailureReason { notFound, signInRequired, network, unknown }

final class PostFailure extends Failure {
  const PostFailure(this.reason);

  final PostFailureReason reason;

  @override
  List<Object?> get props => [reason];
}
