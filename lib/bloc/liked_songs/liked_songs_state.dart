import 'package:equatable/equatable.dart';
import 'package:spotify_clone/data/model/album_track.dart';

abstract class LikedSongsState extends Equatable {
  const LikedSongsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class LikedSongsInitial extends LikedSongsState {
  const LikedSongsInitial();
}

/// Loading liked songs
class LikedSongsLoading extends LikedSongsState {
  const LikedSongsLoading();
}

/// Liked songs loaded successfully
class LikedSongsLoaded extends LikedSongsState {
  final List<AlbumTrack> likedSongs;
  final Set<String> likedSongKeys;

  const LikedSongsLoaded({
    required this.likedSongs,
    required this.likedSongKeys,
  });

  @override
  List<Object?> get props => [likedSongs, likedSongKeys];

  /// Check if a song is in liked songs
  bool isSongLiked(AlbumTrack song) {
    final key = '${song.trackName}_${song.singers}';
    return likedSongKeys.contains(key);
  }

  /// Create a copy with updated values
  LikedSongsLoaded copyWith({
    List<AlbumTrack>? likedSongs,
    Set<String>? likedSongKeys,
  }) {
    return LikedSongsLoaded(
      likedSongs: likedSongs ?? this.likedSongs,
      likedSongKeys: likedSongKeys ?? this.likedSongKeys,
    );
  }
}

/// No liked songs
class LikedSongsEmpty extends LikedSongsState {
  const LikedSongsEmpty();
}

/// Error state
class LikedSongsError extends LikedSongsState {
  final String message;

  const LikedSongsError(this.message);

  @override
  List<Object?> get props => [message];
}
