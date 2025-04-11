import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio, List<Interceptor>? interceptors}) : _dio = dio ?? Dio() {
    if (interceptors != null) {
      _dio.interceptors.addAll(interceptors);
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );
  }

  void close() {
    _dio.close();
  }
}
