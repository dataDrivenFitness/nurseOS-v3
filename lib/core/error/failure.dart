sealed class Failure {
  final String message;
  const Failure(this.message);

  factory Failure.unexpected(String msg) = UnexpectedFailure;
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(String msg) : super(msg);
}
