import 'package:coingecko_mini/app.dart';
import 'package:coingecko_mini/core/di/app_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final dependencies = AppDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: dependencies.marketCubit),
        BlocProvider.value(value: dependencies.statsCubit),
        BlocProvider.value(value: dependencies.watchlistCubit),
      ],
      child: CryptoApp(dependencies: dependencies),
    ),
  );
}
