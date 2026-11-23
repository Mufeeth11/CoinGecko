/// Minimal functional result type for Clean Architecture repository returns.
sealed class Either<L, R> {
  const Either();

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  T fold<T>({
    required T Function(L left) onLeft,
    required T Function(R right) onRight,
  }) {
    return switch (this) {
      Left(:final value) => onLeft(value),
      Right(:final value) => onRight(value),
    };
  }

  R getOrElse(R Function() orElse) => switch (this) {
    Left() => orElse(),
    Right(:final value) => value,
  };
}

final class Left<L, R> extends Either<L, R> {
  const Left(this.value);

  final L value;

  @override
  String toString() => 'Left($value)';
}

final class Right<L, R> extends Either<L, R> {
  const Right(this.value);

  final R value;

  @override
  String toString() => 'Right($value)';
}
