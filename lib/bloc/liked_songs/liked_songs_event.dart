import 'package:equatable/equatable.dart';
import 'package:spotify_clone/data/model/album_track.dart';

abstract class LikedSongsEvent extends Equatable {
  const LikedSongsEvent();

  @override
  List<Object?> get props => [];
}

/// Load all liked songs
class LoadLikedSongsEvent extends LikedSongsEvent {
  const LoadLikedSongsEvent();
}

/// Add a song to liked songs
class AddLikeEvent extends LikedSongsEvent {
  final AlbumTrack song;
  final String albumImage;

  const AddLikeEvent({required this.song, required this.albumImage});

  @override
  List<Object?> get props => [song, albumImage];
}

/// Remove a song from liked songs
class RemoveLikeEvent extends LikedSongsEvent {
  final AlbumTrack song;

  const RemoveLikeEvent({required this.song});

  @override
  List<Object?> get props => [song];
}

/// Toggle like status
class ToggleLikeEvent extends LikedSongsEvent {
  final AlbumTrack song;
  final String albumImage;

  const ToggleLikeEvent({required this.song, required this.albumImage});

  @override
  List<Object?> get props => [song, albumImage];
}

/// Clear all liked songs
class ClearLikedSongsEvent extends LikedSongsEvent {
  const ClearLikedSongsEvent();
}
