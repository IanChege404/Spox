import 'package:equatable/equatable.dart';
import 'package:spotify_clone/data/model/user_stats.dart';

abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no stats calculated
class StatsInitial extends StatsState {
  const StatsInitial();
}

/// Loading state - calculating stats
class StatsLoading extends StatsState {
  final StatsPeriod period;

  const StatsLoading(this.period);

  @override
  List<Object?> get props => [period];
}

/// Loaded state - stats available
class StatsLoaded extends StatsState {
  final UserStats stats;
  final StatsPeriod period;

  const StatsLoaded({
    required this.stats,
    required this.period,
  });

  @override
  List<Object?> get props => [stats, period];

  /// Create a copy with modified fields
  StatsLoaded copyWith({
    UserStats? stats,
    StatsPeriod? period,
  }) {
    return StatsLoaded(
      stats: stats ?? this.stats,
      period: period ?? this.period,
    );
  }
}

/// No data state - insufficient history
class StatsEmpty extends StatsState {
  final StatsPeriod period;

  const StatsEmpty(this.period);

  @override
  List<Object?> get props => [period];
}

/// Error state - failed to calculate stats
class StatsError extends StatsState {
  final String message;
  final StatsPeriod? period;

  const StatsError(this.message, {this.period});

  @override
  List<Object?> get props => [message, period];
}
