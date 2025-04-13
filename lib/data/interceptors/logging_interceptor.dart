import 'package:dio/dio.dart';
import '../../core/utils/logger.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.info('REQUEST[${options.method}] => PATH: ${options.path}');
    // AppLogger.debug('Request Headers: ${options.headers}');
    AppLogger.debug('Request Data: ${options.data}');
    AppLogger.debug('Request Query Parameters: ${options.queryParameters}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.info(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    // AppLogger.debug('Response Headers: ${response.headers}');
    AppLogger.debug('Response Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      err.error,
      err.stackTrace,
    );
    handler.next(err);
  }
}
