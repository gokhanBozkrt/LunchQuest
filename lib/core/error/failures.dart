import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error occurred']);
}

final class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure([super.message = 'Server error occurred', this.statusCode]);

  @override
  List<Object?> get props => [message, statusCode];
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found']);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred']);
}
