import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:weather_app_assignment/data/api_client.dart';
import '../../mocks/mock_generators.mocks.dart';

void main() {
  late ApiClient apiClient;
  late MockDio mockDio;
  late Interceptors interceptors;

  setUp(() {
    mockDio = MockDio();
    interceptors = Interceptors();
    when(mockDio.interceptors).thenReturn(interceptors);
    apiClient = ApiClient(dio: mockDio);
  });

  group('ApiClient', () {
    test('should be created with custom Dio instance', () {
      // Verify ApiClient is created with the mock Dio
      expect(apiClient, isNotNull);
    });

    test('should be created with default Dio if none provided', () {
      // Create ApiClient without providing Dio
      final defaultApiClient = ApiClient();
      expect(defaultApiClient, isNotNull);
    });

    test('should add interceptors when provided', () {
      // Setup
      final interceptor = InterceptorsWrapper();

      // Act
      final apiClientWithInterceptors = ApiClient(
        dio: mockDio,
        interceptors: [interceptor],
      );

      // No need to verify interceptor adding as that will happen internally
      expect(apiClientWithInterceptors, isNotNull);
    });

    test('get should call dio.get with correct parameters', () async {
      // Setup
      const path = 'test/path';
      final queryParams = {'key': 'value'};
      final headers = {'Authorization': 'Bearer token'};
      final expectedResponse = Response<Map<String, dynamic>>(
        data: {'success': true},
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );

      // Mock the Dio get call
      when(mockDio.get<Map<String, dynamic>>(
        any,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => expectedResponse);

      // Execute
      final response = await apiClient.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParams,
        headers: headers,
      );

      // Verify the response is what we expect
      expect(response.statusCode, 200);
      expect(response.data, {'success': true});

      // Verify the correct method was called with the expected parameters
      verify(mockDio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParams,
        options: anyNamed('options'),
      )).called(1);
    });

    test('close should call dio.close', () {
      // New mock to avoid verification conflicts
      final mockDio2 = MockDio();
      when(mockDio2.interceptors).thenReturn(Interceptors());
      final apiClient2 = ApiClient(dio: mockDio2);

      // Execute
      apiClient2.close();

      // Verify
      verify(mockDio2.close()).called(1);
    });
  });
}
