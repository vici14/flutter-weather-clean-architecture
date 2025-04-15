import 'package:dio/dio.dart';
import 'package:weather_app_assignment/data/api_client.dart';

class MockApiClient implements ApiClient {
  Map<String, dynamic> Function(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  })? onGet;

  int statusCode = 200;
  bool throwDioError = false;
  bool throwGenericError = false;
  String errorMessage = '';
  DioExceptionType dioErrorType = DioExceptionType.connectionTimeout;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    if (throwDioError) {
      throw DioException(
        type: dioErrorType,
        requestOptions: RequestOptions(path: path),
        message: errorMessage,
      );
    }

    if (throwGenericError) {
      throw Exception(errorMessage);
    }

    final data = onGet?.call(
      path,
      queryParameters: queryParameters,
      headers: headers,
    );

    return Response<T>(
      statusCode: statusCode,
      data: data as T,
      requestOptions: RequestOptions(path: path),
    ) as Response<T>;
  }

  @override
  void close() {
    // Do nothing in the mock
  }
}
