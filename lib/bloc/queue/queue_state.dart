import 'package:equatable/equatable.dart';
import 'package:spotify_clone/data/model/album_track.dart';

enum RepeatMode { off, all, one }

enum ShuffleMode { off, on }

abstract class QueueState extends Equatable {
  const QueueState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class QueueInitial extends QueueState {
  const QueueInitial();
}

/// Queue state when loaded
class QueueLoaded extends QueueState {
  final List<AlbumTrack> queue;
  final int currentIndex;
  final RepeatMode repeatMode;
  final bool isShuffle;

  const QueueLoaded({
    required this.queue,
    required this.currentIndex,
    this.repeatMode = RepeatMode.off,
    this.isShuffle = false,
  });

  @override
  List<Object?> get props => [queue, currentIndex, repeatMode, isShuffle];

  /// Get current song
  AlbumTrack? getCurrentSong() {
    if (queue.isEmpty || currentIndex < 0 || currentIndex >= queue.length) {
      return null;
    }
    return queue[currentIndex];
  }

  /// Check if has next song
  bool hasNext() {
    return currentIndex < queue.length - 1;
  }

  /// Check if has previous song
  bool hasPrevious() {
    return currentIndex > 0;
  }

  /// Create a copy with updated values
  QueueLoaded copyWith({
    List<AlbumTrack>? queue,
    int? currentIndex,
    RepeatMode? repeatMode,
    bool? isShuffle,
  }) {
    return QueueLoaded(
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      repeatMode: repeatMode ?? this.repeatMode,
      isShuffle: isShuffle ?? this.isShuffle,
    );
  }
}

/// Queue is empty
class QueueEmpty extends QueueState {
  const QueueEmpty();
}

/// Queue error state
class QueueError extends QueueState {
  final String message;

  const QueueError(this.message);

  @override
  List<Object?> get props => [message];
}
