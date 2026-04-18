import 'package:equatable/equatable.dart';
import 'package:spotify_clone/data/model/spotify_models.dart';

abstract class PlaylistState extends Equatable {
  const PlaylistState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class PlaylistInitial extends PlaylistState {
  const PlaylistInitial();
}

/// Loading state while fetching from API
class PlaylistLoading extends PlaylistState {
  const PlaylistLoading();
}

/// Successfully loaded playlist with tracks
class PlaylistLoaded extends PlaylistState {
  /// Playlist details from Spotify
  final SpotifyPlaylist playlist;

  /// Array of tracks in the playlist
  final List<SpotifyTrack> tracks;

  /// Current pagination offset
  final int offset;

  /// Total number of tracks in playlist
  final int total;

  /// Whether there are more tracks to load
  final bool hasMore;

  const PlaylistLoaded({
    required this.playlist,
    required this.tracks,
    required this.offset,
    required this.total,
    this.hasMore = true,
  });

  @override
  List<Object?> get props => [playlist, tracks, offset, total, hasMore];
}

/// Loading more tracks (pagination)
class PlaylistLoadingMore extends PlaylistState {
  /// Current tracks already loaded
  final List<SpotifyTrack> currentTracks;

  const PlaylistLoadingMore(this.currentTracks);

  @override
  List<Object?> get props => [currentTracks];
}

/// Error loading playlist
class PlaylistError extends PlaylistState {
  final String message;

  const PlaylistError(this.message);

  @override
  List<Object?> get props => [message];
}
