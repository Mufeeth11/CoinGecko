import 'package:coingecko_mini/core/di/app_dependencies.dart';
import 'package:coingecko_mini/core/theme/app_theme.dart';
import 'package:coingecko_mini/features/crypto/presentation/cubit/market_cubit.dart';
import 'package:coingecko_mini/features/crypto/presentation/cubit/stats_cubit.dart';
import 'package:coingecko_mini/features/crypto/presentation/screens/market_screen.dart';
import 'package:coingecko_mini/features/crypto/presentation/screens/stats_screen.dart';
import 'package:coingecko_mini/features/crypto/presentation/screens/watchlist_screen.dart';
import 'package:coingecko_mini/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CryptoApp extends StatelessWidget {
  const CryptoApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoinScope',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: AppShell(dependencies: dependencies),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<WatchlistCubit>().load();
    context.read<MarketCubit>().load();
    context.read<StatsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            MarketScreen(dependencies: widget.dependencies),
            StatsScreen(dependencies: widget.dependencies),
            WatchlistScreen(
              dependencies: widget.dependencies,
              onExploreMarkets: () => setState(() => _selectedIndex = 0),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.candlestick_chart_outlined),
              selectedIcon: Icon(Icons.candlestick_chart_rounded),
              label: 'MARKETS',
            ),
            NavigationDestination(
              icon: Icon(Icons.pie_chart_outline_rounded),
              selectedIcon: Icon(Icons.pie_chart_rounded),
              label: 'STATISTICS',
            ),
            NavigationDestination(
              icon: Icon(Icons.star_border_rounded),
              selectedIcon: Icon(Icons.star_rounded),
              label: 'WATCHLIST',
            ),
          ],
        ),
      ),
    );
  }
}
