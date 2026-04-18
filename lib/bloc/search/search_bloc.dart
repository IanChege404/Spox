import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/bloc/search/search_event.dart';
import 'package:spotify_clone/bloc/search/search_state.dart';
import 'package:spotify_clone/data/model/spotify_models.dart';
import 'package:spotify_clone/services/hive_service.dart';
import 'package:spotify_clone/services/spotify_api_service.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SpotifyApiService _spotifyApiService;
  final HiveService _hiveService;

  /// Timer for debouncing search queries
  Timer? _debounceTimer;

  /// Completer to wake any pending debounced handler
  Completer<void>? _debounceCompleter;

  /// Duration to debounce search (300ms)
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  SearchBloc({
    required SpotifyApiService spotifyApiService,
    required HiveService hiveService,
  })  : _spotifyApiService = spotifyApiService,
        _hiveService = hiveService,
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
  /// Fetches from Spotify API - no caching for fresh results
  Future<void> _performSearch(String query, Emitter<SearchState> emit) async {
    try {
      emit(SearchLoading(query));

      // Search across all types: tracks, albums, artists, playlists
      // Direct Spotify API call - always fresh results
      final searchResult = await _spotifyApiService.search(
        query,
        type: 'track,album,artist,playlist',
        limit: 20,
      );

      await _hiveService.saveRecentSearch(query);

      if (searchResult.isEmpty) {
        emit(SearchEmpty(query));
        return;
      }

      // Parse results using Spotify models
      final tracks = _parseSpotifyTracks(searchResult);
      final albums = _parseSpotifyAlbums(searchResult);
      final artists = _parseSpotifyArtists(searchResult);
      final playlists = _parseSpotifyPlaylists(searchResult);

      // Check if any results found
      if (tracks.isEmpty &&
          albums.isEmpty &&
          artists.isEmpty &&
          playlists.isEmpty) {
        emit(SearchEmpty(query));
        return;
      }

      emit(SearchLoaded(
        tracks: tracks,
        albums: albums,
        artists: artists,
        playlists: playlists,
        query: query,
      ));
    } catch (e) {
      print('[SearchBloc] ✗ Search error: $e');
      emit(SearchError('Failed to search: ${e.toString()}', query: query));
    }
  }

  /// Parse albums from Spotify search result
  List<SpotifyAlbum> _parseSpotifyAlbums(Map<String, dynamic> result) {
    final albums = <SpotifyAlbum>[];

    try {
      if (result['albums'] != null && result['albums']['items'] != null) {
        final items = result['albums']['items'] as List<dynamic>;

        for (final item in items) {
          try {
            final album = item as Map<String, dynamic>;
            final albumObj = SpotifyAlbum.fromJson(album);
            albums.add(albumObj);
          } catch (e) {
            print('[SearchBloc] Warning: Error parsing album: $e');
            continue;
          }
        }
      }
    } catch (e) {
      print('[SearchBloc] ⚠ Error parsing albums: $e');
    }

    return albums;
  }

  /// Parse tracks from Spotify search result
  /// Returns SpotifyTrack objects with all necessary fields
  List<SpotifyTrack> _parseSpotifyTracks(Map<String, dynamic> result) {
    final tracks = <SpotifyTrack>[];

    try {
      if (result['tracks'] != null && result['tracks']['items'] != null) {
        final items = result['tracks']['items'] as List<dynamic>;

        for (final item in items) {
          try {
            final track = item as Map<String, dynamic>;
            final track_obj = SpotifyTrack.fromJson(track);
            tracks.add(track_obj);
          } catch (e) {
            print('[SearchBloc] Warning: Error parsing track: $e');
            continue;
          }
        }
      }
    } catch (e) {
      print('[SearchBloc] ⚠ Error parsing tracks: $e');
    }

    return tracks;
  }

  /// Parse artists from Spotify search result
  /// Returns SpotifyArtist objects with all fields
  List<SpotifyArtist> _parseSpotifyArtists(Map<String, dynamic> result) {
    final artists = <SpotifyArtist>[];

    try {
      if (result['artists'] != null && result['artists']['items'] != null) {
        final items = result['artists']['items'] as List<dynamic>;

        for (final item in items) {
          try {
            final artist = item as Map<String, dynamic>;
            final artist_obj = SpotifyArtist.fromJson(artist);
            artists.add(artist_obj);
          } catch (e) {
            print('[SearchBloc] Warning: Error parsing artist: $e');
            continue;
          }
        }
      }
    } catch (e) {
      print('[SearchBloc] ⚠ Error parsing artists: $e');
    }

    return artists;
  }

  /// Parse playlists from Spotify search result
  /// Returns SpotifyPlaylist objects with all fields
  List<SpotifyPlaylist> _parseSpotifyPlaylists(Map<String, dynamic> result) {
    final playlists = <SpotifyPlaylist>[];

    try {
      if (result['playlists'] != null && result['playlists']['items'] != null) {
        final items = result['playlists']['items'] as List<dynamic>;

        for (final item in items) {
          try {
            final playlist = item as Map<String, dynamic>;
            final playlist_obj = SpotifyPlaylist.fromJson(playlist);
            playlists.add(playlist_obj);
          } catch (e) {
            print('[SearchBloc] Warning: Error parsing playlist: $e');
            continue;
          }
        }
      }
    } catch (e) {
      print('[SearchBloc] ⚠ Error parsing playlists: $e');
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
