/// Custom result wrapper for API responses
class Result<T> {
  final T? data;
  final Exception? error;
  final bool isSuccess;

  Result.success(this.data)
      : error = null,
        isSuccess = true;

  Result.failure(this.error)
      : data = null,
        isSuccess = false;
}
