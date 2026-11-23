enum MarketQuickFilter { all, gainers, losers }

extension MarketQuickFilterX on MarketQuickFilter {
  String get label => switch (this) {
    MarketQuickFilter.all => 'All',
    MarketQuickFilter.gainers => 'Gainers',
    MarketQuickFilter.losers => 'Losers',
  };
}

enum MarketSort { rank, marketCap, price, volume, change24h, name }

extension MarketSortX on MarketSort {
  String get label => switch (this) {
    MarketSort.rank => 'Rank',
    MarketSort.marketCap => 'Market cap',
    MarketSort.price => 'Price',
    MarketSort.volume => '24h volume',
    MarketSort.change24h => '24h change',
    MarketSort.name => 'Name (A–Z)',
  };

  bool get numeric => this != MarketSort.name;
}
