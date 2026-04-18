import 'dart:async';
import 'package:just_audio/just_audio.dart';

/// Service that wraps just_audio AudioPlayer with convenient methods
/// for playback control, seeking, and queue management
class AudioPlayerService {
  final AudioPlayer _audioPlayer;
  Duration _crossFadeDuration = const Duration(seconds: 3);
  Timer? _volumeFadeTimer;

  /// Constructor that accepts an optional AudioPlayer for dependency injection
  /// Used for testing to inject mock AudioPlayer instances
  AudioPlayerService({AudioPlayer? audioPlayer})
      : _audioPlayer = audioPlayer ?? AudioPlayer();

  // Getters for audio player streams
  Stream<Duration?> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<SequenceState?> get sequenceStateStream =>
      _audioPlayer.sequenceStateStream;

  // Getters for current state
  Duration get currentPosition => _audioPlayer.position;
  Duration? get duration => _audioPlayer.duration;
  PlayerState get playerState => _audioPlayer.playerState;
  bool get isPlaying => _audioPlayer.playing;

  /// Initialize audio player with a list of audio URLs
  ///
  /// [audioUrls] - List of audio file URLs to queue
  /// [startIndex] - Index of the song to start playback from
  Future<void> initializePlaylist(
    List<String> audioUrls, {
    int startIndex = 0,
  }) async {
    final playlist = ConcatenatingAudioSource(
      children: [
        for (final url in audioUrls) AudioSource.uri(Uri.parse(url)),
      ],
    );

    try {
      await _audioPlayer.setAudioSource(
        playlist,
        initialIndex: startIndex,
        preload: true,
      );
      await _audioPlayer.setVolume(1.0);
    } catch (e) {
      print('Error initializing playlist: $e');
      rethrow;
    }
  }

  /// Load and play a single audio source
  ///
  /// [url] - URL of the audio file to play
  Future<void> playSingle(String url) async {
    try {
      await _audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(url)),
        preload: true,
      );
      await _audioPlayer.setVolume(1.0);
      await play();
    } catch (e) {
      print('Error loading audio: $e');
      rethrow;
    }
  }

  /// Start or resume playback
  Future<void> play() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing: $e');
      rethrow;
    }
  }

  /// Pause playback
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      print('Error pausing: $e');
      rethrow;
    }
  }

  /// Stop playback and reset position
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping: $e');
      rethrow;
    }
  }

  /// Seek to a specific position in the current audio
  ///
  /// [position] - Duration to seek to
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('Error seeking: $e');
      rethrow;
    }
  }

  /// Skip to the next track in the queue
  Future<void> skipToNext() async {
    try {
      if (_crossFadeDuration > Duration.zero && _audioPlayer.playing) {
        await _fadeVolumeTo(0.0, _crossFadeDuration);
      }
      await _audioPlayer.seekToNext();
      if (_crossFadeDuration > Duration.zero && _audioPlayer.playing) {
        await _fadeVolumeTo(1.0, _crossFadeDuration);
      }
    } catch (e) {
      print('Error skipping to next: $e');
      rethrow;
    }
  }

  /// Skip to the previous track in the queue
  Future<void> skipToPrevious() async {
    try {
      if (_crossFadeDuration > Duration.zero && _audioPlayer.playing) {
        await _fadeVolumeTo(0.0, _crossFadeDuration);
      }
      await _audioPlayer.seekToPrevious();
      if (_crossFadeDuration > Duration.zero && _audioPlayer.playing) {
        await _fadeVolumeTo(1.0, _crossFadeDuration);
      }
    } catch (e) {
      print('Error skipping to previous: $e');
      rethrow;
    }
  }

  /// Set the looping mode
  ///
  /// [loopMode] - 0 = no loop, 1 = loop all, 2 = loop one
  Future<void> setLoopMode(int loopMode) async {
    try {
      await _audioPlayer.setLoopMode(LoopMode.values[loopMode]);
    } catch (e) {
      print('Error setting loop mode: $e');
      rethrow;
    }
  }

  /// Set shuffle mode on/off
  Future<void> setShuffle(bool shuffle) async {
    try {
      await _audioPlayer.setShuffleModeEnabled(shuffle);
    } catch (e) {
      print('Error setting shuffle: $e');
      rethrow;
    }
  }

  /// Set playback speed
  ///
  /// [speed] - Playback speed (e.g., 1.0 = normal, 1.5 = 1.5x)
  Future<void> setSpeed(double speed) async {
    try {
      await _audioPlayer.setSpeed(speed);
    } catch (e) {
      print('Error setting speed: $e');
      rethrow;
    }
  }

  /// Configure the crossfade duration used for track transitions.
  Future<void> setCrossFadeDuration(Duration? duration) async {
    _crossFadeDuration = duration ?? Duration.zero;
  }

  Future<void> _fadeVolumeTo(double targetVolume, Duration duration) async {
    _volumeFadeTimer?.cancel();

    final startVolume = _audioPlayer.volume;
    final steps = (duration.inMilliseconds / 50).ceil().clamp(1, 120);
    final stepDuration =
        Duration(milliseconds: (duration.inMilliseconds / steps).round());
    final volumeDelta = (targetVolume - startVolume) / steps;

    var currentStep = 0;
    final completer = Completer<void>();

    _volumeFadeTimer = Timer.periodic(stepDuration, (timer) async {
      currentStep++;
      final nextVolume = currentStep >= steps
          ? targetVolume
          : (startVolume + (volumeDelta * currentStep));

      try {
        await _audioPlayer.setVolume(nextVolume.clamp(0.0, 1.0));
      } catch (_) {
        // Ignore transient volume errors during fades.
      }

      if (currentStep >= steps) {
        timer.cancel();
        completer.complete();
      }
    });

    await completer.future;
  }

  /// Get the underlying AudioPlayer instance for advanced operations
  AudioPlayer getAudioPlayer() => _audioPlayer;

  /// Dispose resources when done
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
    } catch (e) {
      print('Error disposing audio player: $e');
    }
  }
}
