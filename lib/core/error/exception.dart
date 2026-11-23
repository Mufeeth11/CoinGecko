/// Exceptions live in the data layer and are translated into [Failure] objects
/// by repository implementations.
abstract class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException(super.message, {this.statusCode});

  final int? statusCode;
}

class ConnectionException extends AppException {
  const ConnectionException(super.message);
}

class ParsingException extends AppException {
  const ParsingException(super.message);
}

class CacheException extends AppException {
  const CacheException(super.message);
}
