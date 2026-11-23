import 'package:coingecko_mini/core/error/failure.dart';
import 'package:coingecko_mini/core/state/view_status.dart';
import 'package:coingecko_mini/core/usecase/usecase.dart';
import 'package:coingecko_mini/features/watchlist/domain/usecases/get_watchlist.dart';
import 'package:coingecko_mini/features/watchlist/domain/usecases/toggle_watchlist.dart';
import 'package:coingecko_mini/features/watchlist/presentation/cubit/watchlist_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WatchlistCubit extends Cubit<WatchlistState> {
  WatchlistCubit({required this.getWatchlist, required this.toggleWatchlist})
    : super(const WatchlistState());

  final GetWatchlist getWatchlist;
  final ToggleWatchlist toggleWatchlist;

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading));
    final result = await getWatchlist(const NoParams());
    result.fold(
      onLeft: (Failure failure) => emit(
        state.copyWith(status: ViewStatus.failure, message: failure.message),
      ),
      onRight: (ids) => emit(
        state.copyWith(
          ids: ids.toSet(),
          status: ViewStatus.success,
          clearMessage: true,
        ),
      ),
    );
  }

  Future<void> toggle(String coinId) async {
    final previous = Set<String>.from(state.ids);
    final optimistic = Set<String>.from(previous);
    if (!optimistic.add(coinId)) optimistic.remove(coinId);
    emit(state.copyWith(ids: optimistic, clearMessage: true));

    final result = await toggleWatchlist(coinId);
    result.fold(
      onLeft: (Failure failure) =>
          emit(state.copyWith(ids: previous, message: failure.message)),
      onRight: (ids) =>
          emit(state.copyWith(ids: ids.toSet(), clearMessage: true)),
    );
  }
}
