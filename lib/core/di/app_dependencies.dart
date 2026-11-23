import 'package:coingecko_mini/core/network/api_client.dart';
import 'package:coingecko_mini/features/crypto/data/datasources/crypto_remote_data_source.dart';
import 'package:coingecko_mini/features/crypto/data/repositories/crypto_repository_impl.dart';
import 'package:coingecko_mini/features/crypto/domain/usecases/get_coin_detail.dart';
import 'package:coingecko_mini/features/crypto/domain/usecases/get_coins.dart';
import 'package:coingecko_mini/features/crypto/domain/usecases/get_global_stats.dart';
import 'package:coingecko_mini/features/crypto/domain/usecases/get_market_chart.dart';
import 'package:coingecko_mini/features/crypto/presentation/cubit/coin_detail_cubit.dart';
import 'package:coingecko_mini/features/crypto/presentation/cubit/market_cubit.dart';
import 'package:coingecko_mini/features/crypto/presentation/cubit/stats_cubit.dart';
import 'package:coingecko_mini/features/watchlist/data/datasources/watchlist_local_data_source.dart';
import 'package:coingecko_mini/features/watchlist/data/repositories/watchlist_repository_impl.dart';
import 'package:coingecko_mini/features/watchlist/domain/usecases/get_watchlist.dart';
import 'package:coingecko_mini/features/watchlist/domain/usecases/toggle_watchlist.dart';
import 'package:coingecko_mini/features/watchlist/presentation/cubit/watchlist_cubit.dart';

/// Manual dependency injection keeps the graph explicit and makes it easy to
/// swap fakes in widget tests without a code-generation package.
class AppDependencies {
  AppDependencies({
    ApiClient? apiClient,
    WatchlistLocalDataSource? watchlistLocalDataSource,
  }) {
    final cryptoRepository = CryptoRepositoryImpl(
      CryptoRemoteDataSourceImpl(apiClient ?? ApiClient()),
    );
    final watchlistRepository = WatchlistRepositoryImpl(
      watchlistLocalDataSource ?? WatchlistLocalDataSourceImpl(),
    );

    getCoins = GetCoins(cryptoRepository);
    getCoinDetail = GetCoinDetail(cryptoRepository);
    getMarketChart = GetMarketChart(cryptoRepository);
    getGlobalStats = GetGlobalStats(cryptoRepository);
    getWatchlist = GetWatchlist(watchlistRepository);
    toggleWatchlist = ToggleWatchlist(watchlistRepository);

    marketCubit = MarketCubit(getCoins: getCoins);
    statsCubit = StatsCubit(getGlobalStats: getGlobalStats, getCoins: getCoins);
    watchlistCubit = WatchlistCubit(
      getWatchlist: getWatchlist,
      toggleWatchlist: toggleWatchlist,
    );
  }

  late final GetCoins getCoins;
  late final GetCoinDetail getCoinDetail;
  late final GetMarketChart getMarketChart;
  late final GetGlobalStats getGlobalStats;
  late final GetWatchlist getWatchlist;
  late final ToggleWatchlist toggleWatchlist;

  late final MarketCubit marketCubit;
  late final StatsCubit statsCubit;
  late final WatchlistCubit watchlistCubit;

  CoinDetailCubit createCoinDetailCubit() => CoinDetailCubit(
    getCoinDetail: getCoinDetail,
    getMarketChart: getMarketChart,
  );
}
