import 'package:coingecko_mini/core/error/exception.dart';
import 'package:coingecko_mini/core/state/view_status.dart';
import 'package:coingecko_mini/features/watchlist/data/datasources/watchlist_local_data_source.dart';
import 'package:coingecko_mini/features/watchlist/data/repositories/watchlist_repository_impl.dart';
import 'package:coingecko_mini/features/watchlist/domain/usecases/get_watchlist.dart';
import 'package:coingecko_mini/features/watchlist/domain/usecases/toggle_watchlist.dart';
import 'package:coingecko_mini/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

class _FailingLocalDataSource implements WatchlistLocalDataSource {
  @override
  Future<List<String>> readIds() =>
      Future.error(const CacheException('disk error'));

  @override
  Future<List<String>> writeIds(List<String> ids) =>
      Future.error(const CacheException('disk error'));
}

WatchlistCubit _buildCubit(WatchlistLocalDataSource source) {
  final repository = WatchlistRepositoryImpl(source);
  return WatchlistCubit(
    getWatchlist: GetWatchlist(repository),
    toggleWatchlist: ToggleWatchlist(repository),
  );
}

void main() {
  group('WatchlistCubit', () {
    test('loads persisted ids and toggles them', () async {
      final cubit = _buildCubit(InMemoryWatchlistDataSource(['bitcoin']));
      addTearDown(cubit.close);

      await cubit.load();
      expect(cubit.state.status, ViewStatus.success);
      expect(cubit.state.isWatched('bitcoin'), isTrue);

      await cubit.toggle('ethereum');
      expect(cubit.state.ids, {'bitcoin', 'ethereum'});

      await cubit.toggle('bitcoin');
      expect(cubit.state.ids, {'ethereum'});
    });

    test('rolls back optimistic updates when persistence fails', () async {
      final cubit = _buildCubit(_FailingLocalDataSource());
      addTearDown(cubit.close);

      await cubit.load();
      expect(cubit.state.status, ViewStatus.failure);

      await cubit.toggle('solana');
      expect(cubit.state.isWatched('solana'), isFalse);
      expect(cubit.state.message, isNotNull);
    });
  });
}
