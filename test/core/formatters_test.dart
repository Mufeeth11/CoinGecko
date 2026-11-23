import 'package:coingecko_mini/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Formatters', () {
    test('formats prices with precision based on magnitude', () {
      expect(Formatters.currency(67432.18), r'$67432.18');
      expect(Formatters.currency(0.6128), r'$0.6128');
      expect(Formatters.currency(null), '—');
    });

    test('formats compact market caps and supplies', () {
      expect(Formatters.compact(1_331_800_000_000), '1.33T');
      expect(Formatters.compactCurrency(34_250_000_000), r'$34.25B');
      expect(Formatters.supply(19_750_000, 'BTC'), '19.75M BTC');
    });

    test('formats signed percentages', () {
      expect(Formatters.signedPercent(2.341), '+2.34%');
      expect(Formatters.signedPercent(-1.256), '-1.26%');
    });
  });
}
