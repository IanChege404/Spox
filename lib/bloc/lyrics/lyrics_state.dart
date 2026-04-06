import 'package:equatable/equatable.dart';
import 'package:spotify_clone/data/model/lyrics.dart';

abstract class LyricsState extends Equatable {
  const LyricsState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no lyrics loaded
class LyricsInitial extends LyricsState {
  const LyricsInitial();
}

/// Loading state - fetching lyrics
class LyricsLoading extends LyricsState {
  const LyricsLoading();
}

/// Loaded state - lyrics available
class LyricsLoaded extends LyricsState {
  final Lyrics lyrics;
  final Duration currentPosition;
  final LyricLine? currentLine;

  const LyricsLoaded({
    required this.lyrics,
    required this.currentPosition,
    this.currentLine,
  });

  @override
  List<Object?> get props => [lyrics, currentPosition, currentLine];

  /// Create a copy with modified fields
  LyricsLoaded copyWith({
    Lyrics? lyrics,
    Duration? currentPosition,
    LyricLine? currentLine,
  }) {
    return LyricsLoaded(
      lyrics: lyrics ?? this.lyrics,
      currentPosition: currentPosition ?? this.currentPosition,
      currentLine: currentLine ?? this.currentLine,
    );
  }

  /// Get percentage through the song
  double getProgress() {
    if (lyrics.lines.isEmpty) return 0;
    final lastLineTime = lyrics.lines.last.timestamp;
    if (lastLineTime.inMilliseconds == 0) return 0;
    return (currentPosition.inMilliseconds / lastLineTime.inMilliseconds)
        .clamp(0, 1);
  }
}

/// Not found state - no lyrics available for this track
class LyricsNotFound extends LyricsState {
  final String trackName;
  final String artistName;

  const LyricsNotFound({
    required this.trackName,
    required this.artistName,
  });

  @override
  List<Object?> get props => [trackName, artistName];
}

/// Error state - failed to fetch lyrics
class LyricsError extends LyricsState {
  final String message;
  final String? trackName;

  const LyricsError(this.message, {this.trackName});

  @override
  List<Object?> get props => [message, trackName];
}
