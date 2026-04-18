import 'package:equatable/equatable.dart';
import 'package:spotify_clone/data/model/spotify_models.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no search performed yet
class SearchInitial extends SearchState {
  const SearchInitial();
}

/// Loading state - search in progress
class SearchLoading extends SearchState {
  final String query;

  const SearchLoading(this.query);

  @override
  List<Object?> get props => [query];
}

/// Loaded state - search results available
class SearchLoaded extends SearchState {
  final List<SpotifyTrack> tracks;
  final List<SpotifyAlbum> albums;
  final List<SpotifyArtist> artists;
  final List<SpotifyPlaylist> playlists;
  final String query;

  const SearchLoaded({
    required this.tracks,
    required this.albums,
    required this.artists,
    required this.playlists,
    required this.query,
  });

  /// Check if no results found
  bool get isEmpty =>
      tracks.isEmpty && albums.isEmpty && artists.isEmpty && playlists.isEmpty;

  @override
  List<Object?> get props => [tracks, albums, artists, playlists, query];

  /// Create a copy with modified fields
  SearchLoaded copyWith({
    List<SpotifyTrack>? tracks,
    List<SpotifyAlbum>? albums,
    List<SpotifyArtist>? artists,
    List<SpotifyPlaylist>? playlists,
    String? query,
  }) {
    return SearchLoaded(
      tracks: tracks ?? this.tracks,
      albums: albums ?? this.albums,
      artists: artists ?? this.artists,
      playlists: playlists ?? this.playlists,
      query: query ?? this.query,
    );
  }
}

/// Empty state - search results are empty
class SearchEmpty extends SearchState {
  final String query;

  const SearchEmpty(this.query);

  @override
  List<Object?> get props => [query];
}

/// Error state - search failed
class SearchError extends SearchState {
  final String message;
  final String? query;

  const SearchError(this.message, {this.query});

  @override
  List<Object?> get props => [message, query];
}
