import 'failure.dart';

class ApiFailure extends Failure {
  const ApiFailure({required super.message, super.code});

  factory ApiFailure.invalidApiKey() => const ApiFailure(
        message: 'Invalid API key',
        code: 'API_INVALID_KEY',
      );

  factory ApiFailure.notFound() => const ApiFailure(
        message: 'Resource not found',
        code: 'API_NOT_FOUND',
      );

  factory ApiFailure.rateLimitExceeded() => const ApiFailure(
        message: 'API rate limit exceeded',
        code: 'API_RATE_LIMIT',
      );
}
