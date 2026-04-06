import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/bloc/history/history_event.dart';
import 'package:spotify_clone/bloc/history/history_state.dart';
import 'package:spotify_clone/data/model/album_track.dart';
import 'package:spotify_clone/services/hive_service.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HiveService _hiveService;

  HistoryBloc({required HiveService hiveService})
      : _hiveService = hiveService,
        super(const HistoryInitial()) {
    on<LoadPlayHistoryEvent>(_onLoadPlayHistory);
    on<RecordPlayEvent>(_onRecordPlay);
    on<ClearPlayHistoryEvent>(_onClearPlayHistory);
  }

  /// Handle loading play history
  Future<void> _onLoadPlayHistory(
    LoadPlayHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      emit(const HistoryLoading());

      // Get play history from Hive
      final history = await _hiveService.getPlayHistory(limit: event.limit);

      if (history.isEmpty) {
        emit(const HistoryEmpty());
      } else {
        // Convert to HistoryEntry objects
        final entries = history
            .map((entry) => HistoryEntry(
                  trackName: entry['trackName'] as String? ?? 'Unknown',
                  artists: entry['artists'] as String? ?? 'Unknown',
                  playedAt: entry['playedAt'] is DateTime
                      ? entry['playedAt']
                      : DateTime.parse(entry['playedAt'].toString()),
                ))
            .toList();

        emit(HistoryLoaded(entries));
      }
    } catch (e) {
      emit(HistoryError('Failed to load history: ${e.toString()}'));
    }
  }

  /// Handle recording a play
  Future<void> _onRecordPlay(
    RecordPlayEvent event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      // Record in Hive using the data layer models with enhanced metadata
      await _hiveService.recordPlay(
        AlbumTrack(event.trackName, event.artists),
        duration: event.duration,
        albumImage: event.albumImage,
      );

      // Reload history to reflect new entry
      if (state is HistoryLoaded) {
        final current = state as HistoryLoaded;
        final newEntry = HistoryEntry(
          trackName: event.trackName,
          artists: event.artists,
          playedAt: DateTime.now(),
        );

        // Add to beginning of list (most recent first)
        final updated = [newEntry, ...current.entries];
        emit(HistoryLoaded(updated));
      }
    } catch (e) {
      emit(HistoryError('Failed to record play: ${e.toString()}'));
    }
  }

  /// Handle clearing play history
  Future<void> _onClearPlayHistory(
    ClearPlayHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      // Clear play history in Hive (if method exists)
      // For now, we'll just emit empty state
      emit(const HistoryEmpty());
    } catch (e) {
      emit(HistoryError('Failed to clear history: ${e.toString()}'));
    }
  }
}
