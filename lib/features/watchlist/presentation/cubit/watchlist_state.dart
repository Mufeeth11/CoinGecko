import 'package:coingecko_mini/core/state/view_status.dart';
import 'package:equatable/equatable.dart';

class WatchlistState extends Equatable {
  const WatchlistState({
    this.ids = const <String>{},
    this.status = ViewStatus.initial,
    this.message,
  });

  final Set<String> ids;
  final ViewStatus status;
  final String? message;

  bool isWatched(String coinId) => ids.contains(coinId);

  WatchlistState copyWith({
    Set<String>? ids,
    ViewStatus? status,
    String? message,
    bool clearMessage = false,
  }) {
    return WatchlistState(
      ids: ids ?? this.ids,
      status: status ?? this.status,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [ids.toList()..sort(), status, message];
}
