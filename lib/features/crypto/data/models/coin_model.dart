import 'package:coingecko_mini/features/crypto/data/models/json_helpers.dart';
import 'package:coingecko_mini/features/crypto/domain/entities/coin.dart';

class CoinModel extends Coin {
  const CoinModel({
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
  });

  factory CoinModel.fromJson(Map<String, dynamic> json) {
    return CoinModel(
      id: json.stringAt('id'),
      symbol: json.stringAt('symbol'),
      name: json.stringAt('name'),
      image: json.stringAt('image'),
      category: json.stringAt('category', 'Other'),
      currentPrice: json.doubleAt('currentPrice'),
      marketCap: json.doubleAt('marketCap'),
      marketCapRank: json.intAt('marketCapRank', 999),
      totalVolume: json.doubleAt('totalVolume'),
      circulatingSupply: json.nullableDoubleAt('circulatingSupply'),
      totalSupply: json.nullableDoubleAt('totalSupply'),
      maxSupply: json.nullableDoubleAt('maxSupply'),
      priceChange24h: json.doubleAt('priceChange24h'),
      priceChange7d: json.doubleAt('priceChange7d'),
      sparkline: json.doubleListAt('sparkline'),
    );
  }
}

class CoinDetailModel extends CoinDetail {
  const CoinDetailModel({
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
    required super.description,
    required super.categories,
    required super.high24h,
    required super.low24h,
    required super.ath,
    required super.atl,
    required super.priceChange30d,
    required super.priceChange1y,
  });

  factory CoinDetailModel.fromJson(Map<String, dynamic> json) {
    return CoinDetailModel(
      id: json.stringAt('id'),
      symbol: json.stringAt('symbol'),
      name: json.stringAt('name'),
      image: json.stringAt('image'),
      category: json.stringAt('category', 'Other'),
      currentPrice: json.doubleAt('currentPrice'),
      marketCap: json.doubleAt('marketCap'),
      marketCapRank: json.intAt('marketCapRank', 999),
      totalVolume: json.doubleAt('totalVolume'),
      circulatingSupply: json.nullableDoubleAt('circulatingSupply'),
      totalSupply: json.nullableDoubleAt('totalSupply'),
      maxSupply: json.nullableDoubleAt('maxSupply'),
      priceChange24h: json.doubleAt('priceChange24h'),
      priceChange7d: json.doubleAt('priceChange7d'),
      sparkline: json.doubleListAt('sparkline'),
      description: json.stringAt('description'),
      categories: json.stringListAt('categories'),
      high24h: json.doubleAt('high24h'),
      low24h: json.doubleAt('low24h'),
      ath: json.doubleAt('ath'),
      atl: json.doubleAt('atl'),
      priceChange30d: json.doubleAt('priceChange30d'),
      priceChange1y: json.doubleAt('priceChange1y'),
    );
  }
}
