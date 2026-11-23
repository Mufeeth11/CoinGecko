import 'package:coingecko_mini/core/state/view_status.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/coin.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/global_stats.dart';
import 'package:equatable/equatable.dart';

class StatsState extends Equatable {
  const StatsState({
    this.status = ViewStatus.initial,
    this.stats,
    this.gainers = const <Coin>[],
    this.losers = const <Coin>[],
    this.source = 'mock',
    this.message,
    this.isRefreshing = false,
  });

  final ViewStatus status;
  final GlobalStats? stats;
  final List<Coin> gainers;
  final List<Coin> losers;
  final String source;
  final String? message;
  final bool isRefreshing;

  StatsState copyWith({
    ViewStatus? status,
    GlobalStats? stats,
    List<Coin>? gainers,
    List<Coin>? losers,
    String? source,
    String? message,
    bool clearMessage = false,
    bool? isRefreshing,
  }) {
    return StatsState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      gainers: gainers ?? this.gainers,
      losers: losers ?? this.losers,
      source: source ?? this.source,
      message: clearMessage ? null : message ?? this.message,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    status,
    stats,
    gainers,
    losers,
    source,
    message,
    isRefreshing,
  ];
}
