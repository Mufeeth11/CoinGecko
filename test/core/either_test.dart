import 'package:coingecko_mini/core/utils/either.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Either', () {
    test('Right folds into the success branch', () {
      final result = const Right<String, int>(42);
      final value = result.fold(
        onLeft: (error) => -1,
        onRight: (value) => value,
      );
      expect(value, 42);
      expect(result.isRight, isTrue);
      expect(result.getOrElse(() => 0), 42);
    });

    test('Left folds into the error branch', () {
      final result = const Left<String, int>('boom');
      final value = result.fold(
        onLeft: (error) => error.length,
        onRight: (value) => value,
      );
      expect(value, 4);
      expect(result.isLeft, isTrue);
      expect(result.getOrElse(() => 7), 7);
    });
  });
}
