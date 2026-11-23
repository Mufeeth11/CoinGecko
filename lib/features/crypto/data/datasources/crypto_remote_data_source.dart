import 'package:coingecko_mini/core/network/api_client.dart';
import 'package:coingecko_mini/features/crypto/data/models/coin_model.dart';
import 'package:coingecko_mini/features/crypto/data/models/global_stats_model.dart';
import 'package:coingecko_mini/features/crypto/data/models/market_chart_model.dart';
import 'package:coingecko_mini/features/crypto/data/models/market_snapshot_model.dart';

abstract interface class CryptoRemoteDataSource {
  Future<MarketSnapshotModel> getCoins();

  Future<CoinDetailModel> getCoinDetail(String coinId);

  Future<MarketChartModel> getMarketChart({
    required String coinId,
    required String days,
  });

  Future<GlobalStatsModel> getGlobalStats();
}

class CryptoRemoteDataSourceImpl implements CryptoRemoteDataSource {
  const CryptoRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<MarketSnapshotModel> getCoins() async {
    final body = await _client.getMap('/coins');
    return MarketSnapshotModel.fromJson(body);
  }

  @override
  Future<CoinDetailModel> getCoinDetail(String coinId) async {
    final body = await _client.getMap('/coins/${Uri.encodeComponent(coinId)}');
    return CoinDetailModel.fromJson(body);
  }

  @override
  Future<MarketChartModel> getMarketChart({
    required String coinId,
    required String days,
  }) async {
    final body = await _client.getMap(
      '/coins/${Uri.encodeComponent(coinId)}/market_chart',
      queryParameters: {'days': days},
    );
    return MarketChartModel.fromJson(body);
  }

  @override
  Future<GlobalStatsModel> getGlobalStats() async {
    final body = await _client.getMap('/global');
    return GlobalStatsModel.fromJson(body);
  }
}
