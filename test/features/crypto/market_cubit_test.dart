import 'package:coingecko_mini/core/error/failure.dart';
import 'package:coingecko_mini/core/state/view_status.dart';
import 'package:coingecko_mini/features/crypto/domain/usecases/get_coins.dart';
import 'package:coingecko_mini/features/crypto/presentation/cubit/market_cubit.dart';
import 'package:coingecko_mini/features/crypto/presentation/cubit/market_filter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  group('MarketCubit', () {
    late MarketCubit cubit;

    setUp(() {
      cubit = MarketCubit(
        getCoins: GetCoins(
          FakeCryptoRepository(
            coins: [
              makeCoin(
                id: 'bitcoin',
                symbol: 'BTC',
                name: 'Bitcoin',
                price: 100,
                change24h: 2,
                rank: 1,
                marketCap: 1000,
              ),
              makeCoin(
                id: 'ethereum',
                symbol: 'ETH',
                name: 'Ethereum',
                price: 50,
                change24h: -1,
                rank: 2,
                marketCap: 500,
                category: 'Smart Contract',
              ),
              makeCoin(
                id: 'dogecoin',
                symbol: 'DOGE',
                name: 'Dogecoin',
                price: 0.1,
                change24h: 5,
                rank: 3,
                marketCap: 100,
                category: 'Meme',
              ),
              makeCoin(
                id: 'solana',
                symbol: 'SOL',
                name: 'Solana',
                price: 200,
                change24h: -3,
                rank: 4,
                marketCap: 2000,
              ),
            ],
          ),
        ),
      );
    });

    tearDown(() => cubit.close());

    test('loads all coins from the repository', () async {
      await cubit.load();
      expect(cubit.state.status, ViewStatus.success);
      expect(cubit.state.visibleCoins, hasLength(4));
      expect(cubit.state.source, 'live');
    });

    test('filters by search query, quick filter and category', () async {
      await cubit.load();

      cubit.setQuery('eth');
      expect(cubit.state.visibleCoins.map((coin) => coin.id), ['ethereum']);

      cubit.setQuery('');
      cubit.setQuickFilter(MarketQuickFilter.losers);
      expect(
        cubit.state.visibleCoins.map((coin) => coin.id),
        containsAll(['ethereum', 'solana']),
      );
      expect(cubit.state.visibleCoins, hasLength(2));

      cubit.setQuickFilter(MarketQuickFilter.all);
      cubit.setCategory('Meme');
      expect(cubit.state.visibleCoins.single.id, 'dogecoin');
    });

    test('sorts by the selected field and direction', () async {
      await cubit.load();

      cubit.setSort(MarketSort.price);
      expect(cubit.state.descending, isTrue);
      expect(cubit.state.visibleCoins.first.symbol, 'SOL');

      cubit.toggleSortDirection();
      expect(cubit.state.visibleCoins.first.symbol, 'DOGE');
    });

    test('clears filters and exposes an empty state', () async {
      await cubit.load();
      cubit.setQuery('unknown');
      expect(cubit.state.visibleCoins, isEmpty);
      expect(cubit.state.hasActiveFilters, isTrue);

      cubit.clearFilters();
      expect(cubit.state.visibleCoins, hasLength(4));
      expect(cubit.state.hasActiveFilters, isFalse);
    });

    test('surfaces failures when there is no cached data', () async {
      final failing = MarketCubit(
        getCoins: GetCoins(
          FakeCryptoRepository(failure: const ConnectionFailure('offline')),
        ),
      );
      addTearDown(failing.close);

      await failing.load();

      expect(failing.state.status, ViewStatus.failure);
      expect(failing.state.message, 'offline');
    });
  });
}
