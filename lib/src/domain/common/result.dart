class Result<T> {}

class ResultError<T> implements Result<T> {
  final String message;

  const ResultError(this.message);
}

class ResultSuccess<T> implements Result<T> {
  final T data;
  const ResultSuccess(this.data);
}
