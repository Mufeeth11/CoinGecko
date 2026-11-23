import 'package:coingecko_mini/core/error/exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class WatchlistLocalDataSource {
  Future<List<String>> readIds();

  Future<List<String>> writeIds(List<String> ids);
}

class WatchlistLocalDataSourceImpl implements WatchlistLocalDataSource {
  const WatchlistLocalDataSourceImpl(this._preferences);

  static const storageKey = 'crypto_watchlist_ids';

  final SharedPreferences _preferences;

  @override
  Future<List<String>> readIds() {
    try {
      return Future.value(
        _preferences.getStringList(storageKey) ?? const <String>[],
      );
    } catch (error) {
      throw CacheException('Could not read the watchlist: $error');
    }
  }

  @override
  Future<List<String>> writeIds(List<String> ids) async {
    try {
      final saved = await _preferences.setStringList(storageKey, ids);
      if (!saved) throw const CacheException('Could not save the watchlist.');
      return ids;
    } on CacheException {
      rethrow;
    } catch (error) {
      throw CacheException('Could not save the watchlist: $error');
    }
  }
}
