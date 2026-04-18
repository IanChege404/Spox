import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/bloc/playlist/playlist_event.dart';
import 'package:spotify_clone/bloc/playlist/playlist_state.dart';
import 'package:spotify_clone/data/model/spotify_models.dart';
import 'package:spotify_clone/data/repository/spotify_repository.dart';

const int _pageSize = 20; // Tracks per page

/// BLoC for managing playlist details and track pagination
class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final SpotifyRepository _spotifyRepository;

  List<SpotifyTrack> _cachedTracks = [];
  int _currentOffset = 0;

  PlaylistBloc({required SpotifyRepository spotifyRepository})
      : _spotifyRepository = spotifyRepository,
        super(const PlaylistInitial()) {
    on<PlaylistFetchEvent>(_onPlaylistFetch);
    on<PlaylistLoadMoreEvent>(_onLoadMore);
    on<PlaylistRefreshEvent>(_onRefresh);
  }

  /// Fetch playlist details and first page of tracks
  Future<void> _onPlaylistFetch(
    PlaylistFetchEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(const PlaylistLoading());
    try {
      // Reset pagination
      _currentOffset = 0;
      _cachedTracks = [];

      print('[PlaylistBloc] Fetching playlist: ${event.playlistId}');

      // Fetch playlist details and tracks in parallel
      final results = await Future.wait([
        _spotifyRepository.getPlaylist(event.playlistId),
        _spotifyRepository.getPlaylistTracks(
          event.playlistId,
          limit: _pageSize,
          offset: 0,
        ),
      ]);

      final playlist = results[0] as SpotifyPlaylist;
      final tracks = results[1] as List<SpotifyTrack>;

      _cachedTracks = tracks;
      _currentOffset = _pageSize;

      final hasMore = tracks.length == _pageSize;
      print(
          '[PlaylistBloc] Loaded ${tracks.length} tracks, hasMore: $hasMore');

      emit(PlaylistLoaded(
        playlist: playlist,
        tracks: tracks,
        offset: 0,
        total: playlist.trackCount,
        hasMore: hasMore,
      ));
    } catch (e) {
      print('[PlaylistBloc] Error fetching playlist: $e');
      emit(PlaylistError('Failed to load playlist: ${e.toString()}'));
    }
  }

  /// Load next page of tracks (pagination)
  Future<void> _onLoadMore(
    PlaylistLoadMoreEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    if (state is! PlaylistLoaded) return;

    final currentState = state as PlaylistLoaded;
    if (currentState.tracks.length >= currentState.total) {
      return; // Already loaded all tracks
    }

    emit(PlaylistLoadingMore(currentState.tracks));

    try {
      print(
          '[PlaylistBloc] Loading more tracks at offset: $_currentOffset');

      final moreTracks = await _spotifyRepository.getPlaylistTracks(
        event.playlistId,
        limit: _pageSize,
        offset: _currentOffset,
      );

      _cachedTracks.addAll(moreTracks);
      _currentOffset += _pageSize;

      final hasMore = moreTracks.length == _pageSize;
      print(
          '[PlaylistBloc] Loaded ${moreTracks.length} more tracks, hasMore: $hasMore');

      emit(PlaylistLoaded(
        playlist: currentState.playlist,
        tracks: _cachedTracks,
        offset: _currentOffset,
        total: currentState.total,
        hasMore: hasMore,
      ));
    } catch (e) {
      print('[PlaylistBloc] Error loading more tracks: $e');
      // Keep current state on error, don't emit error state
      emit(PlaylistLoaded(
        playlist: currentState.playlist,
        tracks: currentState.tracks,
        offset: currentState.offset,
        total: currentState.total,
        hasMore: currentState.hasMore,
      ));
    }
  }

  /// Refresh playlist (force reload from API)
  Future<void> _onRefresh(
    PlaylistRefreshEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    await _onPlaylistFetch(
      PlaylistFetchEvent(event.playlistId, forceRefresh: true),
      emit,
    );
  }
}
