import 'package:equatable/equatable.dart';

abstract class AudioPlayerState extends Equatable {
  const AudioPlayerState();

  @override
  List<Object?> get props => [];
}

/// Initial state when audio player is not initialized
class AudioPlayerInitial extends AudioPlayerState {
  const AudioPlayerInitial();
}

/// State when audio is loading
class AudioLoading extends AudioPlayerState {
  final String songTitle;

  const AudioLoading(this.songTitle);

  @override
  List<Object?> get props => [songTitle];
}

/// State when audio is currently playing
class AudioPlaying extends AudioPlayerState {
  final String songTitle;
  final String artist;
  final String albumArt;
  final Duration current;
  final Duration total;
  final bool isBuffering;

  const AudioPlaying({
    required this.songTitle,
    required this.artist,
    required this.albumArt,
    required this.current,
    required this.total,
    this.isBuffering = false,
  });

  @override
  List<Object?> get props =>
      [songTitle, artist, albumArt, current, total, isBuffering];
}

/// State when audio is paused
class AudioPaused extends AudioPlayerState {
  final String songTitle;
  final String artist;
  final String albumArt;
  final Duration current;
  final Duration total;

  const AudioPaused({
    required this.songTitle,
    required this.artist,
    required this.albumArt,
    required this.current,
    required this.total,
  });

  @override
  List<Object?> get props => [songTitle, artist, albumArt, current, total];
}

/// State when audio has completed
class AudioCompleted extends AudioPlayerState {
  final String songTitle;

  const AudioCompleted(this.songTitle);

  @override
  List<Object?> get props => [songTitle];
}

/// State when audio playback encounters an error
class AudioError extends AudioPlayerState {
  final String message;
  final String? songTitle;

  const AudioError(this.message, {this.songTitle});

  @override
  List<Object?> get props => [message, songTitle];
}

/// State for position updates (used for UI sync)
class AudioPositionUpdate extends AudioPlayerState {
  final Duration position;
  final Duration duration;

  const AudioPositionUpdate({
    required this.position,
    required this.duration,
  });

  @override
  List<Object?> get props => [position, duration];
}

/// State when audio playback is stopped
class AudioStopped extends AudioPlayerState {
  const AudioStopped();
}

/// State when sleep timer is active
class SleepTimerActive extends AudioPlayerState {
  final Duration remainingTime;
  final Duration totalDuration;

  const SleepTimerActive({
    required this.remainingTime,
    required this.totalDuration,
  });

  @override
  List<Object?> get props => [remainingTime, totalDuration];
}

/// State when sleep timer has been cancelled
class SleepTimerCancelled extends AudioPlayerState {
  const SleepTimerCancelled();
}
