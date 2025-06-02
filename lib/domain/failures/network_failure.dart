import 'failure.dart';

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});

  factory NetworkFailure.noConnection() => const NetworkFailure(
        message: 'No internet connection',
        code: 'NETWORK_NO_CONNECTION',
      );

  factory NetworkFailure.timeout() => const NetworkFailure(
        message: 'Network request timeout',
        code: 'NETWORK_TIMEOUT',
      );

  factory NetworkFailure.serverError() => const NetworkFailure(
        message: 'Server error occurred',
        code: 'NETWORK_SERVER_ERROR',
      );
}
