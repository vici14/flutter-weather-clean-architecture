/// Custom result wrapper for Weather API responses
class WeatherResult<T> {
  final T? data;
  final Exception? error;
  final bool isSuccess;

  WeatherResult.success(this.data)
      : error = null,
        isSuccess = true;

  WeatherResult.failure(this.error)
      : data = null,
        isSuccess = false;
}
