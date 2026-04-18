import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify_clone/data/model/album_track.dart';

abstract class AudioPlayerEvent extends Equatable {
  const AudioPlayerEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load and play a song
///
/// [audioUrl] - URL of the audio file
/// [songTitle] - Name of the song
/// [artist] - Artist name
/// [albumArt] - Album art image URL
class PlaySongEvent extends AudioPlayerEvent {
  final String audioUrl;
  final String songTitle;
  final String artist;
  final String albumArt;
  final List<String>? audioUrls; // For queue playback
  final List<AlbumTrack>? queueTracks;
  final int startIndex;

  const PlaySongEvent({
    required this.audioUrl,
    required this.songTitle,
    required this.artist,
    required this.albumArt,
    this.audioUrls,
    this.queueTracks,
    this.startIndex = 0,
  });

  @override
  List<Object?> get props => [
        audioUrl,
        songTitle,
        artist,
        albumArt,
        audioUrls,
        queueTracks,
        startIndex,
      ];
}

/// Event to pause playback
class PauseSongEvent extends AudioPlayerEvent {
  const PauseSongEvent();
}

/// Event to resume playback
class ResumeSongEvent extends AudioPlayerEvent {
  const ResumeSongEvent();
}

/// Event to stop playback
class StopSongEvent extends AudioPlayerEvent {
  const StopSongEvent();
}

/// Event to seek to a specific position
class SeekToEvent extends AudioPlayerEvent {
  final Duration position;

  const SeekToEvent(this.position);

  @override
  List<Object?> get props => [position];
}

/// Event to skip to the next track
class SkipNextEvent extends AudioPlayerEvent {
  const SkipNextEvent();
}

/// Event to skip to the previous track
class SkipPreviousEvent extends AudioPlayerEvent {
  const SkipPreviousEvent();
}

/// Event to set loop mode
class SetLoopModeEvent extends AudioPlayerEvent {
  final int loopMode; // 0 = off, 1 = all, 2 = one

  const SetLoopModeEvent(this.loopMode);

  @override
  List<Object?> get props => [loopMode];
}

/// Event to toggle shuffle mode
class SetShuffleModeEvent extends AudioPlayerEvent {
  final bool enabled;

  const SetShuffleModeEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Event to set playback speed
class SetPlaybackSpeedEvent extends AudioPlayerEvent {
  final double speed;

  const SetPlaybackSpeedEvent(this.speed);

  @override
  List<Object?> get props => [speed];
}

/// Event emitted periodically to update position (for UI sync)
class PositionUpdateEvent extends AudioPlayerEvent {
  final Duration position;

  const PositionUpdateEvent(this.position);

  @override
  List<Object?> get props => [position];
}

/// Event to set a sleep timer
class SetSleepTimerEvent extends AudioPlayerEvent {
  final Duration duration; // 15, 30, 45, 60 mins

  const SetSleepTimerEvent(this.duration);

  @override
  List<Object?> get props => [duration];
}

/// Event to cancel the sleep timer
class CancelSleepTimerEvent extends AudioPlayerEvent {
  const CancelSleepTimerEvent();
}

/// Event emitted periodically to update sleep timer countdown
class SleepTimerTickEvent extends AudioPlayerEvent {
  final Duration remainingTime;

  const SleepTimerTickEvent(this.remainingTime);

  @override
  List<Object?> get props => [remainingTime];
}

/// Internal event used to react to player state changes from just_audio
class PlayerStateChangedEvent extends AudioPlayerEvent {
  final PlayerState playerState;

  const PlayerStateChangedEvent(this.playerState);

  @override
  List<Object?> get props => [playerState];
}
