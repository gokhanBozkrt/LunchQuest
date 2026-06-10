import '../error/failures.dart';

export '../error/failures.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is AppFailure<T>;

  T? get data => switch (this) {
        Success<T>(value: final v) => v,
        _ => null,
      };

  Failure? get failure => switch (this) {
        AppFailure<T>(value: final f) => f,
        _ => null,
      };

  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) =>
      switch (this) {
        Success<T>(value: final v) => success(v),
        AppFailure<T>(value: final f) => failure(f),
      };
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

final class AppFailure<T> extends Result<T> {
  final Failure value;
  const AppFailure(this.value);
}
