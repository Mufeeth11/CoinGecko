import 'package:equatable/equatable.dart';

class Coin extends Equatable {
  const Coin({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.category,
    required this.currentPrice,
    required this.marketCap,
    required this.marketCapRank,
    required this.totalVolume,
    required this.circulatingSupply,
    required this.totalSupply,
    required this.maxSupply,
    required this.priceChange24h,
    required this.priceChange7d,
    required this.sparkline,
  });

  final String id;
  final String symbol;
  final String name;
  final String image;
  final String category;
  final double currentPrice;
  final double marketCap;
  final int marketCapRank;
  final double totalVolume;
  final double? circulatingSupply;
  final double? totalSupply;
  final double? maxSupply;
  final double priceChange24h;
  final double priceChange7d;
  final List<double> sparkline;

  bool get isPositive => priceChange24h >= 0;

  @override
  List<Object?> get props => [
    id,
    symbol,
    name,
    image,
    category,
    currentPrice,
    marketCap,
    marketCapRank,
    totalVolume,
    circulatingSupply,
    totalSupply,
    maxSupply,
    priceChange24h,
    priceChange7d,
    sparkline,
  ];
}

class CoinDetail extends Coin {
  const CoinDetail({
    required super.id,
    required super.symbol,
    required super.name,
    required super.image,
    required super.category,
    required super.currentPrice,
    required super.marketCap,
    required super.marketCapRank,
    required super.totalVolume,
    required super.circulatingSupply,
    required super.totalSupply,
    required super.maxSupply,
    required super.priceChange24h,
    required super.priceChange7d,
    required super.sparkline,
    required this.description,
    required this.categories,
    required this.high24h,
    required this.low24h,
    required this.ath,
    required this.atl,
    required this.priceChange30d,
    required this.priceChange1y,
  });

  final String description;
  final List<String> categories;
  final double high24h;
  final double low24h;
  final double ath;
  final double atl;
  final double priceChange30d;
  final double priceChange1y;

  @override
  List<Object?> get props => [
    ...super.props,
    description,
    categories,
    high24h,
    low24h,
    ath,
    atl,
    priceChange30d,
    priceChange1y,
  ];
}
