import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/bloc/stats/stats_event.dart';
import 'package:spotify_clone/bloc/stats/stats_state.dart';

import 'package:spotify_clone/services/stats_service.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final StatsService _statsService;

  StatsBloc({required StatsService statsService})
      : _statsService = statsService,
        super(const StatsInitial()) {
    on<GenerateStatsEvent>(_onGenerateStats);
    on<ChangePeriodEvent>(_onChangePeriod);
  }

  /// Handle generating stats
  Future<void> _onGenerateStats(
    GenerateStatsEvent event,
    Emitter<StatsState> emit,
  ) async {
    try {
      emit(StatsLoading(event.period));

      // Calculate stats from play history
      final stats = await _statsService.calculateStats(event.period);

      if (stats == null) {
        emit(StatsEmpty(event.period));
        return;
      }

      emit(StatsLoaded(
        stats: stats,
        period: event.period,
      ));
    } catch (e) {
      print('Stats generation error: $e');
      emit(StatsError('Failed to generate stats: ${e.toString()}',
          period: event.period));
    }
  }

  /// Handle period change
  Future<void> _onChangePeriod(
    ChangePeriodEvent event,
    Emitter<StatsState> emit,
  ) async {
    try {
      emit(StatsLoading(event.period));

      // Re-calculate stats for new period
      final stats = await _statsService.calculateStats(event.period);

      if (stats == null) {
        emit(StatsEmpty(event.period));
        return;
      }

      emit(StatsLoaded(
        stats: stats,
        period: event.period,
      ));
    } catch (e) {
      print('Period change error: $e');
      emit(StatsError('Failed to change period: ${e.toString()}',
          period: event.period));
    }
  }
}
