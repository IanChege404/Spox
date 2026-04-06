import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify_clone/services/audio_player_service.dart';

/// AudioHandler bridges audio_service with just_audio
///
/// Implements BaseAudioHandler to provide OS-level media controls,
/// persistent notifications, and lock screen integration on both
/// Android and iOS platforms.
class AppAudioHandler extends BaseAudioHandler {
  final AudioPlayerService _audioPlayerService;

  // Keep track of current queue for metadata updates
  final List<MediaItem> _queue = [];
  int _currentIndex = 0;

  AppAudioHandler(this._audioPlayerService) {
    _setupAudioPlayerListeners();
    _setupMediaSessionCallbacks();
  }

  /// Set up listeners on the underlying audio player
  void _setupAudioPlayerListeners() {
    final audioPlayer = _audioPlayerService.getAudioPlayer();

    // Update playback state when player state changes
    audioPlayer.playerStateStream.listen((playerState) {
      _updatePlaybackState(playerState);
    });

    // Update playback state when position changes
    audioPlayer.positionStream.listen((position) {
      _updatePlaybackState(audioPlayer.playerState);
    });

    // Update metadata when sequence changes
    audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (sequenceState != null) {
        final index = sequenceState.currentIndex;
        if (index >= 0 && index < _queue.length) {
          _currentIndex = index;
          mediaItem.add(_queue[index]);
        }
      }
    });
  }

  /// Set up media session callbacks for user controls
  void _setupMediaSessionCallbacks() {
    playbackState.listen((state) {
      // Forward state updates to AudioService
    });
  }

  /// Update the playback state in the media session
  Future<void> _updatePlaybackState(PlayerState playerState) async {
    final isPlaying = playerState.playing;
    final position = _audioPlayerService.currentPosition;

    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (isPlaying) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        processingState: () {
          if (playerState.processingState == ProcessingState.loading) {
            return AudioProcessingState.loading;
          } else if (playerState.processingState == ProcessingState.buffering) {
            return AudioProcessingState.buffering;
          } else if (playerState.processingState == ProcessingState.completed) {
            return AudioProcessingState.completed;
          } else {
            return AudioProcessingState.ready;
          }
        }(),
        playing: isPlaying,
        updatePosition: position,
        bufferedPosition: position,
        speed: 1.0,
      ),
    );
  }

  /// Initialize the queue with a list of audio URLs and metadata
  ///
  /// [urls] - List of audio URLs to queue
  /// [metadata] - List of MediaItem objects with song metadata
  /// [startIndex] - Index to start playback from
  Future<void> initializePlaylist(
    List<String> urls,
    List<MediaItem> metadata, {
    int startIndex = 0,
  }) async {
    _queue.clear();
    _queue.addAll(metadata);
    _currentIndex = startIndex;

    // Update media item to current song
    if (_queue.isNotEmpty) {
      mediaItem.add(_queue[_currentIndex]);
    }

    // Initialize the audio player playlist
    await _audioPlayerService.initializePlaylist(urls, startIndex: startIndex);
  }

  /// Play a single song with metadata
  ///
  /// [url] - Audio URL to play
  /// [metadata] - MediaItem with song metadata
  Future<void> playSingle(String url, MediaItem metadata) async {
    _queue.clear();
    _queue.add(metadata);
    _currentIndex = 0;

    mediaItem.add(metadata);
    await _audioPlayerService.playSingle(url);
  }

  @override
  Future<void> play() => _audioPlayerService.play();

  @override
  Future<void> pause() => _audioPlayerService.pause();

  @override
  Future<void> stop() async {
    await _audioPlayerService.stop();
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.play,
          MediaControl.skipToNext,
        ],
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
  }

  @override
  Future<void> seek(Duration position) => _audioPlayerService.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      if (_queue.isNotEmpty) {
        mediaItem.add(_queue[_currentIndex]);
      }
    }
    await _audioPlayerService.skipToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      if (_queue.isNotEmpty) {
        mediaItem.add(_queue[_currentIndex]);
      }
    }
    await _audioPlayerService.skipToPrevious();
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    _currentIndex = index;
    if (index >= 0 && index < _queue.length) {
      mediaItem.add(_queue[index]);
      await _audioPlayerService.seek(Duration.zero);
    }
  }

  @override
  Future<void> setSpeed(double speed) => _audioPlayerService.setSpeed(speed);

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enable = shuffleMode != AudioServiceShuffleMode.none;
    await _audioPlayerService.setShuffle(enable);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    final repeatIndex = repeatMode.index;
    await _audioPlayerService.setLoopMode(repeatIndex);
  }
}
