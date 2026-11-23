import 'package:coingecko_mini/core/state/view_status.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/coin.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/market_chart.dart';
import 'package:equatable/equatable.dart';

class CoinDetailState extends Equatable {
  const CoinDetailState({
    this.status = ViewStatus.initial,
    this.chartStatus = ViewStatus.initial,
    this.detail,
    this.chart,
    this.days = '7',
    this.source = '',
    this.message,
    this.chartMessage,
    this.isRefreshing = false,
  });

  final ViewStatus status;
  final ViewStatus chartStatus;
  final CoinDetail? detail;
  final MarketChart? chart;
  final String days;
  final String source;
  final String? message;
  final String? chartMessage;
  final bool isRefreshing;

  CoinDetailState copyWith({
    ViewStatus? status,
    ViewStatus? chartStatus,
    CoinDetail? detail,
    MarketChart? chart,
    String? days,
    String? source,
    String? message,
    String? chartMessage,
    bool clearMessage = false,
    bool clearChartMessage = false,
    bool? isRefreshing,
  }) {
    return CoinDetailState(
      status: status ?? this.status,
      chartStatus: chartStatus ?? this.chartStatus,
      detail: detail ?? this.detail,
      chart: chart ?? this.chart,
      days: days ?? this.days,
      source: source ?? this.source,
      message: clearMessage ? null : message ?? this.message,
      chartMessage: clearChartMessage
          ? null
          : chartMessage ?? this.chartMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    status,
    chartStatus,
    detail,
    chart,
    days,
    source,
    message,
    chartMessage,
    isRefreshing,
  ];
}
