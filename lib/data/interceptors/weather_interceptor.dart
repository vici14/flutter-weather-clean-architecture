import 'package:dio/dio.dart';

class WeatherInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add any weather service specific request handling here
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Add any weather service specific response handling here
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Add any weather service specific error handling here
    handler.next(err);
  }
}
