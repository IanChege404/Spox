import 'package:equatable/equatable.dart';
import 'package:spotify_clone/data/model/album_track.dart';

abstract class QueueEvent extends Equatable {
  const QueueEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize queue with songs
class InitializeQueueEvent extends QueueEvent {
  final List<AlbumTrack> songs;
  final int currentIndex;

  const InitializeQueueEvent({
    required this.songs,
    this.currentIndex = 0,
  });

  @override
  List<Object?> get props => [songs, currentIndex];
}

/// Event to add song to queue
class AddToQueueEvent extends QueueEvent {
  final AlbumTrack song;
  final int position; // position in queue to insert, -1 for end

  const AddToQueueEvent({
    required this.song,
    this.position = -1,
  });

  @override
  List<Object?> get props => [song, position];
}

/// Event to remove song from queue
class RemoveFromQueueEvent extends QueueEvent {
  final int index;

  const RemoveFromQueueEvent(this.index);

  @override
  List<Object?> get props => [index];
}

/// Event to reorder queue
class ReorderQueueEvent extends QueueEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderQueueEvent({
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

/// Event to toggle shuffle mode
class ToggleShuffleEvent extends QueueEvent {
  const ToggleShuffleEvent();
}

/// Event to cycle through repeat modes
class CycleRepeatModeEvent extends QueueEvent {
  const CycleRepeatModeEvent();
}

/// Event to clear the queue
class ClearQueueEvent extends QueueEvent {
  const ClearQueueEvent();
}
