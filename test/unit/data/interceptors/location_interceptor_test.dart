import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_app_assignment/data/interceptors/location_interceptor.dart';

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockResponseInterceptorHandler extends Mock
    implements ResponseInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  late LocationInterceptor interceptor;
  late MockRequestInterceptorHandler requestHandler;
  late MockResponseInterceptorHandler responseHandler;
  late MockErrorInterceptorHandler errorHandler;

  setUp(() {
    interceptor = LocationInterceptor();
    requestHandler = MockRequestInterceptorHandler();
    responseHandler = MockResponseInterceptorHandler();
    errorHandler = MockErrorInterceptorHandler();
  });

  group('LocationInterceptor', () {
    test('onRequest should call next with original options', () {
      final options = RequestOptions(path: '/location', method: 'GET');

      interceptor.onRequest(options, requestHandler);

      verify(requestHandler.next(options)).called(1);
    });

    test('onResponse should call next with original response', () {
      final response = Response(
        requestOptions: RequestOptions(path: '/location'),
        statusCode: 200,
        data: {
          'countries': [
            {'name': 'USA', 'code': 'US'}
          ]
        },
      );

      interceptor.onResponse(response, responseHandler);

      verify(responseHandler.next(response)).called(1);
    });

    test('onError should call next with original error', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/location'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/location'),
          statusCode: 500,
        ),
      );

      interceptor.onError(error, errorHandler);

      verify(errorHandler.next(error)).called(1);
    });
  });
}
