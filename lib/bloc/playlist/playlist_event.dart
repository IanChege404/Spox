import 'package:equatable/equatable.dart';

abstract class PlaylistEvent extends Equatable {
  const PlaylistEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch playlist details and tracks from Spotify API
class PlaylistFetchEvent extends PlaylistEvent {
  /// Playlist ID from Spotify
  final String playlistId;

  /// Whether to force refresh from API (skip cache)
  final bool forceRefresh;

  const PlaylistFetchEvent(this.playlistId, {this.forceRefresh = false});

  @override
  List<Object?> get props => [playlistId, forceRefresh];
}

/// Load more tracks (pagination)
class PlaylistLoadMoreEvent extends PlaylistEvent {
  /// Playlist ID
  final String playlistId;

  const PlaylistLoadMoreEvent(this.playlistId);

  @override
  List<Object?> get props => [playlistId];
}

/// Refresh playlist data
class PlaylistRefreshEvent extends PlaylistEvent {
  final String playlistId;

  const PlaylistRefreshEvent(this.playlistId);

  @override
  List<Object?> get props => [playlistId];
}
