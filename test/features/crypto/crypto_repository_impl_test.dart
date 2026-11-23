import 'package:coingecko_mini/core/error/exception.dart';
import 'package:coingecko_mini/core/error/failure.dart';
import 'package:coingecko_mini/features/crypto/data/datasources/crypto_remote_data_source.dart';
import 'package:coingecko_mini/features/crypto/data/models/coin_model.dart';
import 'package:coingecko_mini/features/crypto/data/models/global_stats_model.dart';
import 'package:coingecko_mini/features/crypto/data/models/market_chart_model.dart';
import 'package:coingecko_mini/features/crypto/data/models/market_snapshot_model.dart';
import 'package:coingecko_mini/features/crypto/data/repositories/crypto_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

class _SuccessRemote implements CryptoRemoteDataSource {
  @override
  Future<MarketSnapshotModel> getCoins() async => MarketSnapshotModel.fromJson({
    'coins': [coinJson()],
    'source': 'live',
    'updatedAt': '2026-11-23T10:00:00.000Z',
  });

  @override
  Future<CoinDetailModel> getCoinDetail(String coinId) async =>
      CoinDetailModel.fromJson({
        ...coinJson(),
        'description': 'A native asset.',
        'categories': ['Layer 1'],
      });

  @override
  Future<MarketChartModel> getMarketChart({
    required String coinId,
    required String days,
  }) async => MarketChartModel.fromJson({
    'id': coinId,
    'days': days,
    'source': 'live',
    'prices': [
      [1700000000000, 100],
      [1700003600000, 110],
    ],
  });

  @override
  Future<GlobalStatsModel> getGlobalStats() async => GlobalStatsModel.fromJson({
    'totalMarketCap': 1000,
    'totalVolume': 100,
    'source': 'live',
  });
}

class _FailingRemote implements CryptoRemoteDataSource {
  _FailingRemote(this.exception);

  final AppException exception;

  @override
  Future<MarketSnapshotModel> getCoins() => Future.error(exception);

  @override
  Future<CoinDetailModel> getCoinDetail(String coinId) =>
      Future.error(exception);

  @override
  Future<MarketChartModel> getMarketChart({
    required String coinId,
    required String days,
  }) => Future.error(exception);

  @override
  Future<GlobalStatsModel> getGlobalStats() => Future.error(exception);
}

void main() {
  group('CryptoRepositoryImpl', () {
    test('returns domain entities on success', () async {
      final repository = CryptoRepositoryImpl(_SuccessRemote());

      final result = await repository.getCoins();

      result.fold(
        onLeft: (failure) => fail('Expected success, got $failure'),
        onRight: (snapshot) {
          expect(snapshot.source, 'live');
          expect(snapshot.coins.single.name, 'Bitcoin');
        },
      );
    });

    test('maps connection exceptions to ConnectionFailure', () async {
      final repository = CryptoRepositoryImpl(
        _FailingRemote(const ConnectionException('offline')),
      );

      final result = await repository.getGlobalStats();

      expect(result.isLeft, isTrue);
      result.fold(
        onLeft: (failure) => expect(failure, isA<ConnectionFailure>()),
        onRight: (_) => fail('Expected failure'),
      );
    });

    test('maps HTTP 404 to NotFoundFailure', () async {
      final repository = CryptoRepositoryImpl(
        _FailingRemote(const ServerException('missing', statusCode: 404)),
      );

      final result = await repository.getCoinDetail('unknown');

      result.fold(
        onLeft: (failure) => expect(failure, isA<NotFoundFailure>()),
        onRight: (_) => fail('Expected failure'),
      );
    });
  });
}
