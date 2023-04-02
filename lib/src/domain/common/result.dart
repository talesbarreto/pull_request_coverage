class Result<T> {}

class ResultError<T> implements Result<T> {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  const ResultError(this.message, this.error, this.stackTrace);
}

class ResultSuccess<T> implements Result<T> {
  final T data;
  const ResultSuccess(this.data);
}
