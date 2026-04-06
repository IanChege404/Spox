import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/bloc/lyrics/lyrics_event.dart';
import 'package:spotify_clone/bloc/lyrics/lyrics_state.dart';
import 'package:spotify_clone/services/lyrics_service.dart';

class LyricsBloc extends Bloc<LyricsEvent, LyricsState> {
  final LyricsService _lyricsService;

  LyricsBloc({required LyricsService lyricsService})
      : _lyricsService = lyricsService,
        super(const LyricsInitial()) {
    on<FetchLyricsEvent>(_onFetchLyrics);
    on<UpdateLyricsPositionEvent>(_onUpdatePosition);
    on<ClearLyricsEvent>(_onClearLyrics);
  }

  /// Handle fetching lyrics
  Future<void> _onFetchLyrics(
    FetchLyricsEvent event,
    Emitter<LyricsState> emit,
  ) async {
    try {
      emit(const LyricsLoading());

      // Fetch lyrics from service
      final lyrics = await _lyricsService.fetchLyrics(
        trackName: event.trackName,
        artistName: event.artistName,
      );

      if (lyrics == null) {
        emit(LyricsNotFound(
          trackName: event.trackName,
          artistName: event.artistName,
        ));
        return;
      }

      emit(LyricsLoaded(
        lyrics: lyrics,
        currentPosition: Duration.zero,
        currentLine: lyrics.lines.isNotEmpty ? lyrics.lines.first : null,
      ));
    } catch (e) {
      print('Lyrics fetch error: $e');
      emit(LyricsError('Failed to fetch lyrics: ${e.toString()}',
          trackName: event.trackName));
    }
  }

  /// Handle position update (for auto-scroll)
  Future<void> _onUpdatePosition(
    UpdateLyricsPositionEvent event,
    Emitter<LyricsState> emit,
  ) async {
    if (state is! LyricsLoaded) return;

    final currentState = state as LyricsLoaded;
    final currentLine = currentState.lyrics.getCurrentLine(event.position);

    emit(currentState.copyWith(
      currentPosition: event.position,
      currentLine: currentLine,
    ));
  }

  /// Handle clearing lyrics
  Future<void> _onClearLyrics(
    ClearLyricsEvent event,
    Emitter<LyricsState> emit,
  ) async {
    emit(const LyricsInitial());
  }
}
