import 'package:equatable/equatable.dart';

abstract class CloudSyncEvent extends Equatable {
  const CloudSyncEvent();

  @override
  List<Object?> get props => [];
}

/// Event to sync liked songs to Firebase
class SyncLikedSongsEvent extends CloudSyncEvent {
  final List<Map<String, dynamic>> likedSongs;

  const SyncLikedSongsEvent(this.likedSongs);

  @override
  List<Object?> get props => [likedSongs];
}

/// Event to load liked songs from Firebase
class LoadLikedSongsEvent extends CloudSyncEvent {
  const LoadLikedSongsEvent();
}

/// Event to add a single liked song to Firebase
class AddLikedSongEvent extends CloudSyncEvent {
  final String spotifyId;
  final String title;
  final String artist;
  final String albumArt;

  const AddLikedSongEvent({
    required this.spotifyId,
    required this.title,
    required this.artist,
    required this.albumArt,
  });

  @override
  List<Object?> get props => [spotifyId, title, artist, albumArt];
}

/// Event to remove a liked song from Firebase
class RemoveLikedSongEvent extends CloudSyncEvent {
  final String spotifyId;

  const RemoveLikedSongEvent(this.spotifyId);

  @override
  List<Object?> get props => [spotifyId];
}
