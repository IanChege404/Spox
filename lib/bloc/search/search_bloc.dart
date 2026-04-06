import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/bloc/search/search_event.dart';
import 'package:spotify_clone/bloc/search/search_state.dart';
import 'package:spotify_clone/data/model/album.dart';
import 'package:spotify_clone/data/model/album_track.dart';
import 'package:spotify_clone/data/model/artist.dart';
import 'package:spotify_clone/data/model/playlist.dart';
import 'package:spotify_clone/services/spotify_api_service.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SpotifyApiService _spotifyApiService;

  /// Timer for debouncing search queries
  Timer? _debounceTimer;

  /// Completer to wake any pending debounced handler
  Completer<void>? _debounceCompleter;

  /// Duration to debounce search (300ms)
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  SearchBloc({required SpotifyApiService spotifyApiService})
      : _spotifyApiService = spotifyApiService,
        super(const SearchInitial()) {
    on<SearchQueryEvent>(_onSearchQuery);
    on<SearchClearEvent>(_onSearchClear);
  }

  /// Handle search query with debounce
  Future<void> _onSearchQuery(
      SearchQueryEvent event, Emitter<SearchState> emit) async {
    // Cancel previous timer if exists
    _debounceTimer?.cancel();

    // Wake previous pending handler so it can exit
    if (_debounceCompleter != null && !_debounceCompleter!.isCompleted) {
      _debounceCompleter!.complete();
    }

    // If query is empty, emit initial state
    if (event.query.trim().isEmpty) {
      emit(const SearchInitial());
      return;
    }

    final completer = Completer<void>();
    _debounceCompleter = completer;

    // Create a new debounce timer
    _debounceTimer = Timer(_debounceDuration, () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    await completer.future;

    if (emit.isDone) {
      return;
    }

    // Ignore stale handlers when newer queries arrive
    if (!identical(_debounceCompleter, completer)) {
      return;
    }

    await _performSearch(event.query, emit);
  }

  /// Handle search clear
  Future<void> _onSearchClear(
      SearchClearEvent event, Emitter<SearchState> emit) async {
    _debounceTimer?.cancel();
    emit(const SearchInitial());
  }

  /// Perform actual search after debounce
  Future<void> _performSearch(String query, Emitter<SearchState> emit) async {
    try {
      emit(SearchLoading(query));

      // Search across all types: tracks, artists, albums, playlists
      final searchResult = await _spotifyApiService.search(
        query,
        type: 'track,artist,album,playlist',
        limit: 20,
      );

      if (searchResult.isEmpty) {
        emit(SearchEmpty(query));
        return;
      }

      // Parse tracks
      final tracks = _parseTracks(searchResult);

      // Parse artists
      final artists = _parseArtists(searchResult);

      // Parse albums
      final albums = _parseAlbums(searchResult);

      // Parse playlists
      final playlists = _parsePlaylists(searchResult);

      // Check if any results found
      if (tracks.isEmpty &&
          artists.isEmpty &&
          albums.isEmpty &&
          playlists.isEmpty) {
        emit(SearchEmpty(query));
        return;
      }

      emit(SearchLoaded(
        songs: tracks,
        artists: artists,
        albums: albums,
        playlists: playlists,
        query: query,
      ));
    } catch (e) {
      print('Search error: $e');
      emit(SearchError('Failed to search: ${e.toString()}', query: query));
    }
  }

  /// Parse tracks from search result
  List<AlbumTrack> _parseTracks(Map<String, dynamic> result) {
    final tracks = <AlbumTrack>[];

    try {
      if (result['tracks'] != null && result['tracks']['items'] != null) {
        final items = result['tracks']['items'] as List<dynamic>;

        for (final item in items) {
          try {
            final track = item as Map<String, dynamic>;
            final artists = track['artists'] as List<dynamic>? ?? [];
            final artistNames = artists
                .whereType<Map<String, dynamic>>()
                .map((a) => a['name'] as String? ?? 'Unknown')
                .join(', ');

            tracks.add(AlbumTrack(
              track['name'] as String? ?? 'Unknown',
              artistNames.isNotEmpty ? artistNames : 'Unknown',
            ));
          } catch (e) {
            print('Error parsing track: $e');
            continue;
          }
        }
      }
    } catch (e) {
      print('Error parsing tracks: $e');
    }

    return tracks;
  }

  /// Parse artists from search result
  List<Artist> _parseArtists(Map<String, dynamic> result) {
    final artists = <Artist>[];

    try {
      if (result['artists'] != null && result['artists']['items'] != null) {
        final items = result['artists']['items'] as List<dynamic>;

        for (final item in items) {
          try {
            final artist = item as Map<String, dynamic>;
            final images = artist['images'] as List<dynamic>? ?? [];
            String imageUrl = 'https://via.placeholder.com/300x300?text=Artist';

            if (images.isNotEmpty) {
              final firstImage = images[0] as Map<String, dynamic>;
              imageUrl = firstImage['url'] as String? ?? imageUrl;
            }

            artists.add(Artist(
              imageUrl,
              artist['name'] as String? ?? 'Unknown',
            ));
          } catch (e) {
            print('Error parsing artist: $e');
            continue;
          }
        }
      }
    } catch (e) {
      print('Error parsing artists: $e');
    }

    return artists;
  }

  /// Parse albums from search result
  List<Album> _parseAlbums(Map<String, dynamic> result) {
    final albums = <Album>[];

    try {
      if (result['albums'] != null && result['albums']['items'] != null) {
        final items = result['albums']['items'] as List<dynamic>;

        for (final item in items) {
          try {
            final album = item as Map<String, dynamic>;
            final images = album['images'] as List<dynamic>? ?? [];
            String imageUrl = 'https://via.placeholder.com/300x300?text=Album';

            if (images.isNotEmpty) {
              final firstImage = images[0] as Map<String, dynamic>;
              imageUrl = firstImage['url'] as String? ?? imageUrl;
            }

            final artists = album['artists'] as List<dynamic>? ?? [];
            final artistNames = artists
                .whereType<Map<String, dynamic>>()
                .map((a) => a['name'] as String? ?? 'Unknown')
                .join(', ');

            albums.add(Album(
              imageUrl,
              album['name'] as String? ?? 'Unknown',
              artistNames.isNotEmpty ? artistNames : 'Unknown',
              [],
              '',
              '',
              [],
            ));
          } catch (e) {
            print('Error parsing album: $e');
            continue;
          }
        }
      }
    } catch (e) {
      print('Error parsing albums: $e');
    }

    return albums;
  }

  /// Parse playlists from search result
  List<Playlist> _parsePlaylists(Map<String, dynamic> result) {
    final playlists = <Playlist>[];

    try {
      if (result['playlists'] != null && result['playlists']['items'] != null) {
        final items = result['playlists']['items'] as List<dynamic>;

        for (final item in items) {
          try {
            final playlist = item as Map<String, dynamic>;
            final images = playlist['images'] as List<dynamic>? ?? [];
            String imageUrl =
                'https://via.placeholder.com/300x300?text=Playlist';

            if (images.isNotEmpty) {
              final firstImage = images[0] as Map<String, dynamic>;
              imageUrl = firstImage['url'] as String? ?? imageUrl;
            }

            playlists.add(Playlist(
              '',
              [],
            ));
          } catch (e) {
            print('Error parsing playlist: $e');
            continue;
          }
        }
      }
    } catch (e) {
      print('Error parsing playlists: $e');
    }

    return playlists;
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    if (_debounceCompleter != null && !_debounceCompleter!.isCompleted) {
      _debounceCompleter!.complete();
    }
    return super.close();
  }
}
