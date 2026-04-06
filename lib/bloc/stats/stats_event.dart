import 'package:equatable/equatable.dart';
import 'package:spotify_clone/data/model/user_stats.dart';

abstract class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object?> get props => [];
}

/// Generate statistics for a period
class GenerateStatsEvent extends StatsEvent {
  final StatsPeriod period;

  const GenerateStatsEvent(this.period);

  @override
  List<Object?> get props => [period];
}

/// Change the statistics time period
class ChangePeriodEvent extends StatsEvent {
  final StatsPeriod period;

  const ChangePeriodEvent(this.period);

  @override
  List<Object?> get props => [period];
}
