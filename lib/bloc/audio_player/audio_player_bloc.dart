import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_event.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_state.dart';
import 'package:spotify_clone/bloc/history/history_event.dart';
import 'package:spotify_clone/bloc/history/history_bloc.dart';
import 'package:spotify_clone/bloc/queue/queue_bloc.dart';
import 'package:spotify_clone/bloc/queue/queue_event.dart';
import 'package:spotify_clone/data/model/album_track.dart';
import 'package:spotify_clone/services/audio_handler.dart';
import 'package:spotify_clone/services/audio_player_service.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayerService _audioPlayerService;
  final HistoryBloc? _historyBloc;
  final QueueBloc? _queueBloc;
  final AppAudioHandler? _audioHandler;
  late StreamSubscription<Duration?> _positionSubscription;
  late StreamSubscription<Duration?> _durationSubscription;
  late StreamSubscription<PlayerState> _playerStateSubscription;
  late StreamSubscription<SequenceState?> _sequenceStateSubscription;

  Duration? _currentDuration;
  Timer? _sleepTimer;
  Duration? _sleepTimerRemaining;

  /// Track the currently playing song to avoid recording duplicates
  String? _currentSongTitle;
  String? _currentSongArtist;
  String? _currentSongArt;
  bool _hasRecordedCurrentSong = false;

  AudioPlayerBloc({
    required AudioPlayerService audioPlayerService,
    HistoryBloc? historyBloc,
    QueueBloc? queueBloc,
    AppAudioHandler? audioHandler,
  })  : _audioPlayerService = audioPlayerService,
        _historyBloc = historyBloc,
        _queueBloc = queueBloc,
        _audioHandler = audioHandler,
        super(const AudioPlayerInitial()) {
    on<PlaySongEvent>(_onPlaySong);
    on<PauseSongEvent>(_onPauseSong);
    on<ResumeSongEvent>(_onResumeSong);
    on<StopSongEvent>(_onStopSong);
    on<SeekToEvent>(_onSeekTo);
    on<SkipNextEvent>(_onSkipNext);
    on<SkipPreviousEvent>(_onSkipPrevious);
    on<SetLoopModeEvent>(_onSetLoopMode);
    on<SetShuffleModeEvent>(_onSetShuffleMode);
    on<SetPlaybackSpeedEvent>(_onSetPlaybackSpeed);
    on<PositionUpdateEvent>(_onPositionUpdate);
    on<SetSleepTimerEvent>(_onSetSleepTimer);
    on<CancelSleepTimerEvent>(_onCancelSleepTimer);
    on<SleepTimerTickEvent>(_onSleepTimerTick);
    on<PlayerStateChangedEvent>(_onPlayerStateChanged);

    _setupStreamListeners();
  }

  /// Setup listeners for position, duration, and player state changes
  void _setupStreamListeners() {
    _positionSubscription =
        _audioPlayerService.positionStream.listen((position) {
      if (position != null) {
        add(PositionUpdateEvent(position));
      }
    });

    _durationSubscription =
        _audioPlayerService.durationStream.listen((duration) {
      _currentDuration = duration;
    });

    _playerStateSubscription =
        _audioPlayerService.playerStateStream.listen((playerState) {
      add(PlayerStateChangedEvent(playerState));
    });

    _sequenceStateSubscription =
        _audioPlayerService.sequenceStateStream.listen((sequenceState) {
      if (sequenceState != null &&
          sequenceState.currentIndex < (sequenceState.sequence.length - 1)) {
        // Queue has more items
      }
    });
  }

  /// Handle player state changes
  void _onPlayerStateChanged(
    PlayerStateChangedEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    final playerState = event.playerState;
    final currentState = state;

    if (playerState.processingState == ProcessingState.completed) {
      if (currentState is AudioPlaying) {
        emit(AudioCompleted(currentState.songTitle));
      } else if (currentState is AudioPaused) {
        emit(AudioCompleted(currentState.songTitle));
      }
      return;
    }

    if (currentState is AudioPlaying) {
      emit(AudioPlaying(
        songTitle: currentState.songTitle,
        artist: currentState.artist,
        albumArt: currentState.albumArt,
        current: currentState.current,
        total: currentState.total,
        isBuffering: playerState.processingState == ProcessingState.buffering,
      ));
    } else if (currentState is AudioPaused) {
      emit(AudioPaused(
        songTitle: currentState.songTitle,
        artist: currentState.artist,
        albumArt: currentState.albumArt,
        current: currentState.current,
        total: currentState.total,
      ));
    }
  }

  /// Handle play song event
  FutureOr<void> _onPlaySong(
      PlaySongEvent event, Emitter<AudioPlayerState> emit) async {
    try {
      emit(AudioLoading(event.songTitle));

      // Reset recording flag when starting a new song
      _currentSongTitle = event.songTitle;
      _currentSongArtist = event.artist;
      _currentSongArt = event.albumArt;
      _hasRecordedCurrentSong = false;

      final queueTracks = event.queueTracks;

      if (queueTracks != null && queueTracks.isNotEmpty) {
        final queueUrls = queueTracks
            .map((track) => track.audioUrl)
            .whereType<String>()
            .where((url) => url.isNotEmpty)
            .toList();

        if (queueUrls.isEmpty) {
          throw StateError('Queue does not contain playable audio URLs');
        }

        final queueStartIndex = event.startIndex.clamp(0, queueUrls.length - 1);

        _queueBloc?.add(
          InitializeQueueEvent(
            songs: queueTracks,
            currentIndex: queueStartIndex,
          ),
        );

        final handler = _audioHandler;
        if (handler != null) {
          final metadata = queueTracks
              .map(
                (track) => MediaItem(
                  id: track.audioUrl ?? track.trackName,
                  title: track.trackName,
                  artist: track.singers,
                  artUri: event.albumArt.isNotEmpty
                      ? Uri.tryParse(event.albumArt)
                      : null,
                ),
              )
              .toList();

          await handler.initializePlaylist(
            queueUrls,
            metadata,
            startIndex: queueStartIndex,
          );
        } else {
          await _audioPlayerService.initializePlaylist(
            queueUrls,
            startIndex: queueStartIndex,
          );
        }
      } else {
        // Single song playback
        _queueBloc?.add(
          InitializeQueueEvent(
            songs: [
              AlbumTrack(
                event.songTitle,
                event.artist,
                audioUrl: event.audioUrl,
              ),
            ],
            currentIndex: 0,
          ),
        );

        final handler = _audioHandler;
        if (handler != null) {
          await handler.playSingle(
            event.audioUrl,
            MediaItem(
              id: event.audioUrl,
              title: event.songTitle,
              artist: event.artist,
              artUri: event.albumArt.isNotEmpty
                  ? Uri.tryParse(event.albumArt)
                  : null,
            ),
          );
        } else {
          await _audioPlayerService.playSingle(event.audioUrl);
        }
      }

      emit(AudioPlaying(
        songTitle: event.songTitle,
        artist: event.artist,
        albumArt: event.albumArt,
        current: Duration.zero,
        total: _currentDuration ?? Duration.zero,
      ));
    } catch (e) {
      emit(AudioError('Failed to play song: ${e.toString()}',
          songTitle: event.songTitle));
    }
  }

  /// Handle pause song event
  FutureOr<void> _onPauseSong(
      PauseSongEvent event, Emitter<AudioPlayerState> emit) async {
    try {
      final handler = _audioHandler;
      if (handler != null) {
        await handler.pause();
      } else {
        await _audioPlayerService.pause();
      }

      if (state is AudioPlaying) {
        final playingState = state as AudioPlaying;
        emit(AudioPaused(
          songTitle: playingState.songTitle,
          artist: playingState.artist,
          albumArt: playingState.albumArt,
          current: playingState.current,
          total: playingState.total,
        ));
      }
    } catch (e) {
      emit(AudioError('Failed to pause: ${e.toString()}'));
    }
  }

  /// Handle resume song event
  FutureOr<void> _onResumeSong(
      ResumeSongEvent event, Emitter<AudioPlayerState> emit) async {
    try {
      final handler = _audioHandler;
      if (handler != null) {
        await handler.play();
      } else {
        await _audioPlayerService.play();
      }

      if (state is AudioPaused) {
        final pausedState = state as AudioPaused;
        emit(AudioPlaying(
          songTitle: pausedState.songTitle,
          artist: pausedState.artist,
          albumArt: pausedState.albumArt,
          current: pausedState.current,
          total: pausedState.total,
        ));
      }
    } catch (e) {
      emit(AudioError('Failed to resume: ${e.toString()}'));
    }
  }

  /// Handle stop song event
  FutureOr<void> _onStopSong(
      StopSongEvent event, Emitter<AudioPlayerState> emit) async {
    try {
      final handler = _audioHandler;
      if (handler != null) {
        await handler.stop();
      } else {
        await _audioPlayerService.stop();
      }
      emit(const AudioStopped());
    } catch (e) {
      emit(AudioError('Failed to stop: ${e.toString()}'));
    }
  }

  /// Handle seek event
  FutureOr<void> _onSeekTo(
      SeekToEvent event, Emitter<AudioPlayerState> emit) async {
    try {
      final handler = _audioHandler;
      if (handler != null) {
        await handler.seek(event.position);
      } else {
        await _audioPlayerService.seek(event.position);
      }

      if (state is AudioPlaying) {
        final playingState = state as AudioPlaying;
        emit(AudioPlaying(
          songTitle: playingState.songTitle,
          artist: playingState.artist,
          albumArt: playingState.albumArt,
          current: event.position,
          total: playingState.total,
        ));
      } else if (state is AudioPaused) {
        final pausedState = state as AudioPaused;
        emit(AudioPaused(
          songTitle: pausedState.songTitle,
          artist: pausedState.artist,
          albumArt: pausedState.albumArt,
          current: event.position,
          total: pausedState.total,
        ));
      }
    } catch (e) {
      emit(AudioError('Failed to seek: ${e.toString()}'));
    }
  }

  /// Handle skip next event
  FutureOr<void> _onSkipNext(
      SkipNextEvent event, Emitter<AudioPlayerState> emit) async {
    try {
      final handler = _audioHandler;
      if (handler != null) {
        await handler.skipToNext();
      } else {
        await _audioPlayerService.skipToNext();
      }
    } catch (e) {
      emit(AudioError('Failed to skip to next: ${e.toString()}'));
    }
  }

  /// Handle skip previous event
  FutureOr<void> _onSkipPrevious(
      SkipPreviousEvent event, Emitter<AudioPlayerState> emit) async {
    try {
      final handler = _audioHandler;
      if (handler != null) {
        await handler.skipToPrevious();
      } else {
        await _audioPlayerService.skipToPrevious();
      }
    } catch (e) {
      emit(AudioError('Failed to skip to previous: ${e.toString()}'));
    }
  }

  /// Handle set loop mode event
  FutureOr<void> _onSetLoopMode(
      SetLoopModeEvent event, Emitter<AudioPlayerState> emit) async {
    try {
      await _audioPlayerService.setLoopMode(event.loopMode);
    } catch (e) {
      emit(AudioError('Failed to set loop mode: ${e.toString()}'));
    }
  }

  /// Handle set shuffle mode event
  FutureOr<void> _onSetShuffleMode(
      SetShuffleModeEvent event, Emitter<AudioPlayerState> emit) async {
    try {
      await _audioPlayerService.setShuffle(event.enabled);
    } catch (e) {
      emit(AudioError('Failed to set shuffle mode: ${e.toString()}'));
    }
  }

  /// Handle set playback speed event
  FutureOr<void> _onSetPlaybackSpeed(
      SetPlaybackSpeedEvent event, Emitter<AudioPlayerState> emit) async {
    try {
      final handler = _audioHandler;
      if (handler != null) {
        await handler.setSpeed(event.speed);
      } else {
        await _audioPlayerService.setSpeed(event.speed);
      }
    } catch (e) {
      emit(AudioError('Failed to set playback speed: ${e.toString()}'));
    }
  }

  /// Handle position update event
  FutureOr<void> _onPositionUpdate(
      PositionUpdateEvent event, Emitter<AudioPlayerState> emit) {
    final currentState = state;
    if (currentState is AudioPlaying) {
      // Update position
      emit(AudioPlaying(
        songTitle: currentState.songTitle,
        artist: currentState.artist,
        albumArt: currentState.albumArt,
        current: event.position,
        total: currentState.total,
        isBuffering: currentState.isBuffering,
      ));

      // Record play when song reaches 95% or more
      if (!_hasRecordedCurrentSong &&
          _currentSongTitle != null &&
          _currentSongArtist != null &&
          currentState.total.inMilliseconds > 0) {
        final progressPercent = (event.position.inMilliseconds /
                currentState.total.inMilliseconds) *
            100;

        if (progressPercent >= 95) {
          _recordCurrentPlay(currentState);
        }
      }
    }
  }

  /// Record current song play to history when song finishes
  void _recordCurrentPlay(AudioPlaying audioState) {
    if (_hasRecordedCurrentSong || _historyBloc == null) return;

    _hasRecordedCurrentSong = true;

    // Dispatch RecordPlayEvent to HistoryBloc
    _historyBloc.add(
      RecordPlayEvent(
        trackName: _currentSongTitle ?? audioState.songTitle,
        artists: _currentSongArtist ?? audioState.artist,
        duration: audioState.total.inMilliseconds,
        albumImage: _currentSongArt ?? audioState.albumArt,
      ),
    );
  }

  /// Handle set sleep timer event
  FutureOr<void> _onSetSleepTimer(
      SetSleepTimerEvent event, Emitter<AudioPlayerState> emit) async {
    try {
      // Cancel existing timer if any
      _sleepTimer?.cancel();

      _sleepTimerRemaining = event.duration;
      emit(SleepTimerActive(
        remainingTime: _sleepTimerRemaining!,
        totalDuration: event.duration,
      ));

      // Create a periodic timer that ticks every 1 second
      _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _sleepTimerRemaining =
            _sleepTimerRemaining! - const Duration(seconds: 1);

        if (_sleepTimerRemaining!.inSeconds <= 0) {
          // Timer finished, pause the audio
          timer.cancel();
          _sleepTimer = null;
          add(const PauseSongEvent());
          add(const CancelSleepTimerEvent());
        } else {
          // Update the UI with remaining time
          add(SleepTimerTickEvent(_sleepTimerRemaining!));
        }
      });
    } catch (e) {
      emit(AudioError('Failed to set sleep timer: ${e.toString()}'));
    }
  }

  /// Handle cancel sleep timer event
  FutureOr<void> _onCancelSleepTimer(
      CancelSleepTimerEvent event, Emitter<AudioPlayerState> emit) {
    try {
      _sleepTimer?.cancel();
      _sleepTimer = null;
      _sleepTimerRemaining = null;
      emit(const SleepTimerCancelled());
    } catch (e) {
      emit(AudioError('Failed to cancel sleep timer: ${e.toString()}'));
    }
  }

  /// Handle sleep timer tick event (updates remaining time)
  FutureOr<void> _onSleepTimerTick(
      SleepTimerTickEvent event, Emitter<AudioPlayerState> emit) {
    _sleepTimerRemaining = event.remainingTime;
    emit(SleepTimerActive(
      remainingTime: event.remainingTime,
      totalDuration: _sleepTimerRemaining ?? event.remainingTime,
    ));
  }

  @override
  Future<void> close() async {
    _sleepTimer?.cancel();
    await _positionSubscription.cancel();
    await _durationSubscription.cancel();
    await _playerStateSubscription.cancel();
    await _sequenceStateSubscription.cancel();
    await _audioPlayerService.dispose();
    return super.close();
  }
}
