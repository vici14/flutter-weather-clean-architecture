import 'failure.dart';

class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});

  factory CacheFailure.notFound() => const CacheFailure(
        message: 'Data not found in cache',
        code: 'CACHE_NOT_FOUND',
      );

  factory CacheFailure.writeError() => const CacheFailure(
        message: 'Failed to write to cache',
        code: 'CACHE_WRITE_ERROR',
      );

  factory CacheFailure.readError() => const CacheFailure(
        message: 'Failed to read from cache',
        code: 'CACHE_READ_ERROR',
      );
}
