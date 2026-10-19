import '../../../../core/error/failure.dart';

enum SearchFailureReason { network, unknown }

final class SearchFailure extends Failure {
  const SearchFailure(this.reason);

  final SearchFailureReason reason;

  @override
  List<Object?> get props => [reason];
}
