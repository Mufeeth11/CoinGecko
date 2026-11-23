import 'package:coingecko_mini/core/di/app_dependencies.dart';
import 'package:coingecko_mini/core/error/failure.dart';
import 'package:coingecko_mini/features/crypto/domain/usecases/get_coins.dart';
import 'package:coingecko_mini/features/crypto/presentation/cubit/market_cubit.dart';
import 'package:coingecko_mini/features/crypto/presentation/screens/market_screen.dart';
import 'package:coingecko_mini/features/watchlist/data/repositories/watchlist_repository_impl.dart';
import 'package:coingecko_mini/features/watchlist/domain/usecases/get_watchlist.dart';
import 'package:coingecko_mini/features/watchlist/domain/usecases/toggle_watchlist.dart';
import 'package:coingecko_mini/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

Widget _wrap(Widget child, MarketCubit marketCubit) {
  final watchlistRepository = WatchlistRepositoryImpl(
    InMemoryWatchlistDataSource(),
  );
  final watchlistCubit = WatchlistCubit(
    getWatchlist: GetWatchlist(watchlistRepository),
    toggleWatchlist: ToggleWatchlist(watchlistRepository),
  );
  return MultiBlocProvider(
    providers: [
      BlocProvider.value(value: marketCubit),
      BlocProvider.value(value: watchlistCubit),
    ],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  testWidgets('market screen renders loading, list and search results', (
    tester,
  ) async {
    final marketCubit = MarketCubit(
      getCoins: GetCoins(
        FakeCryptoRepository(
          coins: [
            makeCoin(id: 'bitcoin', name: 'Bitcoin', symbol: 'BTC'),
            makeCoin(
              id: 'ethereum',
              name: 'Ethereum',
              symbol: 'ETH',
              rank: 2,
              marketCap: 500,
            ),
          ],
        ),
      ),
    );
    addTearDown(marketCubit.close);

    final loading = marketCubit.load();
    await tester.pumpWidget(
      _wrap(MarketScreen(dependencies: AppDependencies()), marketCubit),
    );
    await tester.pump();

    expect(find.text('Markets'), findsOneWidget);

    await loading;
    await tester.pumpAndSettle();
    expect(marketCubit.state.visibleCoins, hasLength(2));
    expect(find.text('Bitcoin'), findsOneWidget);
    expect(find.text('Ethereum'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'eth');
    await tester.pump();
    expect(find.text('Bitcoin'), findsNothing);
    expect(find.text('Ethereum'), findsOneWidget);
  });

  testWidgets('market screen renders a retryable error state', (tester) async {
    final marketCubit = MarketCubit(
      getCoins: GetCoins(
        FakeCryptoRepository(failure: const ConnectionFailure('offline')),
      ),
    );
    addTearDown(marketCubit.close);

    final loading = marketCubit.load();
    await tester.pumpWidget(
      _wrap(MarketScreen(dependencies: AppDependencies()), marketCubit),
    );
    await loading;
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
