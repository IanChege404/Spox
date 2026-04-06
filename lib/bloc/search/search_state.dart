import 'package:equatable/equatable.dart';
import 'package:spotify_clone/data/model/album.dart';
import 'package:spotify_clone/data/model/artist.dart';
import 'package:spotify_clone/data/model/playlist.dart';
import 'package:spotify_clone/data/model/album_track.dart';

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
  final List<AlbumTrack> songs;
  final List<Artist> artists;
  final List<Album> albums;
  final List<Playlist> playlists;
  final String query;

  const SearchLoaded({
    required this.songs,
    required this.artists,
    required this.albums,
    required this.playlists,
    required this.query,
  });

  /// Check if no results found
  bool get isEmpty =>
      songs.isEmpty && artists.isEmpty && albums.isEmpty && playlists.isEmpty;

  @override
  List<Object?> get props => [songs, artists, albums, playlists, query];

  /// Create a copy with modified fields
  SearchLoaded copyWith({
    List<AlbumTrack>? songs,
    List<Artist>? artists,
    List<Album>? albums,
    List<Playlist>? playlists,
    String? query,
  }) {
    return SearchLoaded(
      songs: songs ?? this.songs,
      artists: artists ?? this.artists,
      albums: albums ?? this.albums,
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
