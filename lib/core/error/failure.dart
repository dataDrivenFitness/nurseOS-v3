sealed class Failure {
  final String message;
  const Failure(this.message);

  factory Failure.unexpected(String msg) = UnexpectedFailure;
  factory Failure.notFound(String msg) = NotFoundFailure; // ✅ Added
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(String msg) : super(msg);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(String msg) : super(msg);
}
