import 'package:equatable/equatable.dart';

abstract class LyricsEvent extends Equatable {
  const LyricsEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch lyrics for a track
class FetchLyricsEvent extends LyricsEvent {
  final String trackName;
  final String artistName;

  const FetchLyricsEvent({
    required this.trackName,
    required this.artistName,
  });

  @override
  List<Object?> get props => [trackName, artistName];
}

/// Update current playback position
class UpdateLyricsPositionEvent extends LyricsEvent {
  final Duration position;

  const UpdateLyricsPositionEvent(this.position);

  @override
  List<Object?> get props => [position];
}

/// Clear current lyrics
class ClearLyricsEvent extends LyricsEvent {
  const ClearLyricsEvent();
}
