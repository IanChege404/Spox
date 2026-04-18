import 'package:spotify_clone/data/datasource/firestore_datasource.dart';
import 'package:spotify_clone/data/model/spotify_models.dart';
import 'package:spotify_clone/data/model/podcast.dart';
import 'package:spotify_clone/services/hive_service.dart';

/// Service to sync Firestore data with Hive cache
/// Provides offline-first data access with automatic sync
class FirestoreSyncService {
  final FirestoreDataSource _firestoreDataSource;
  final HiveService _hiveService;

  // Cache TTL: 24 hours
  static const Duration _cacheTtl = Duration(hours: 24);

  FirestoreSyncService(
    this._firestoreDataSource,
    this._hiveService,
  );

  // ============================================================================
  // PLAYLISTS
  // ============================================================================

  /// Sync playlists: returns cached data, refreshes in background if stale
  Future<List<SpotifyPlaylist>> syncPlaylists({
    bool forceRefresh = false,
  }) async {
    try {
      // Check if we have valid cache
      if (!forceRefresh && _isCacheValid('playlists')) {
        final cached = _hiveService.getCachedPlaylists();
        if (cached.isNotEmpty) {
          print('[Sync] Returning cached playlists (${cached.length} items)');
          return cached;
        }
      }

      // Fetch from Firestore
      print('[Sync] Fetching playlists from Firestore...');
      final playlists = await _firestoreDataSource.fetchPlaylists();

      // Cache in Hive
      await _hiveService.cachePlaylists(playlists);
      _setCacheTimestamp('playlists');

      print('[Sync] Cached ${playlists.length} playlists');
      return playlists;
    } catch (e) {
      print('[Sync] Error fetching playlists, using cache: $e');
      // Fallback to cache on error
      return _hiveService.getCachedPlaylists();
    }
  }

  /// Get playlist tracks with caching
  Future<List<SpotifyTrack>> syncPlaylistTracks(
    String playlistId, {
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = 'playlist_tracks_$playlistId';

      if (!forceRefresh && _isCacheValid(cacheKey)) {
        final cached = _hiveService.getCachedPlaylistTracks(playlistId);
        if (cached.isNotEmpty) {
          print('[Sync] Returning cached tracks for $playlistId');
          return cached;
        }
      }

      print('[Sync] Fetching tracks for $playlistId from Firestore...');
      final tracks =
          await _firestoreDataSource.fetchPlaylistTracks(playlistId);

      await _hiveService.cachePlaylistTracks(playlistId, tracks);
      _setCacheTimestamp(cacheKey);

      print('[Sync] Cached ${tracks.length} tracks for $playlistId');
      return tracks;
    } catch (e) {
      print('[Sync] Error fetching tracks, using cache: $e');
      return _hiveService.getCachedPlaylistTracks(playlistId);
    }
  }

  // ============================================================================
  // ARTISTS
  // ============================================================================

  /// Sync artists: returns cached data, refreshes in background if stale
  Future<List<SpotifyArtist>> syncArtists({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && _isCacheValid('artists')) {
        final cached = _hiveService.getCachedArtists();
        if (cached.isNotEmpty) {
          print('[Sync] Returning cached artists (${cached.length} items)');
          return cached;
        }
      }

      print('[Sync] Fetching artists from Firestore...');
      final artists = await _firestoreDataSource.fetchArtists();

      await _hiveService.cacheArtists(artists);
      _setCacheTimestamp('artists');

      print('[Sync] Cached ${artists.length} artists');
      return artists;
    } catch (e) {
      print('[Sync] Error fetching artists, using cache: $e');
      return _hiveService.getCachedArtists();
    }
  }

  // ============================================================================
  // PODCASTS
  // ============================================================================
  /// Sync podcasts: returns cached data, refreshes in background if stale
  Future<List<Podcast>> syncPodcasts({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && _isCacheValid('podcasts')) {
        final cached = _hiveService.getCachedPodcasts();
        if (cached.isNotEmpty) {
          print('[Sync] Returning cached podcasts (${cached.length} items)');
          return cached;
        }
      }

      print('[Sync] Fetching podcasts from Firestore...');
      final podcasts = await _firestoreDataSource.fetchPodcasts();

      await _hiveService.cachePodcasts(podcasts);
      _setCacheTimestamp('podcasts');

      print('[Sync] Cached ${podcasts.length} podcasts');
      return podcasts;
    } catch (e) {
      print('[Sync] Error fetching podcasts, using cache: $e');
      return _hiveService.getCachedPodcasts();
    }
  }

  // ============================================================================
  // HOME SCREEN CONFIG
  // ============================================================================

  /// Sync home screen configuration
  Future<Map<String, dynamic>> syncHomeScreenConfig({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && _isCacheValid('homeScreenConfig')) {
        final cached = _hiveService.getCachedHomeScreenConfig();
        if (cached.isNotEmpty) {
          print('[Sync] Returning cached home screen config');
          return cached;
        }
      }

      print('[Sync] Fetching home screen config from Firestore...');
      final config = await _firestoreDataSource.fetchHomeScreenConfig();

      await _hiveService.cacheHomeScreenConfig(config);
      _setCacheTimestamp('homeScreenConfig');

      return config;
    } catch (e) {
      print('[Sync] Error fetching home screen config, using cache: $e');
      return _hiveService.getCachedHomeScreenConfig();
    }
  }

  // ============================================================================
  // SYNC ALL DATA (used on app startup)
  // ============================================================================

  /// Sync all static data from Firestore
  /// Returns a map with all synced collections
  Future<Map<String, dynamic>> syncAllData({
    bool forceRefresh = false,
  }) async {
    print('[Sync] Starting full data sync (forceRefresh: $forceRefresh)...');

    final results = <String, dynamic>{};

    try {
      results['playlists'] = await syncPlaylists(forceRefresh: forceRefresh);
      results['artists'] = await syncArtists(forceRefresh: forceRefresh);
      results['podcasts'] = await syncPodcasts(forceRefresh: forceRefresh);
      results['homeScreenConfig'] =
          await syncHomeScreenConfig(forceRefresh: forceRefresh);

      print('[Sync] Full data sync completed successfully');
    } catch (e) {
      print('[Sync] Error during full data sync: $e');
    }

    return results;
  }

  // ============================================================================
  // CACHE MANAGEMENT
  // ============================================================================

  /// Check if cache is still valid (not expired)
  bool _isCacheValid(String cacheKey) {
    final lastSyncBox = _hiveService.getLastSyncBox();
    final lastSyncTime = lastSyncBox.get('${cacheKey}_lastSync');

    if (lastSyncTime == null) {
      return false;
    }

    final lastSync = DateTime.parse(lastSyncTime);
    final now = DateTime.now();
    final isValid = now.difference(lastSync) < _cacheTtl;

    return isValid;
  }

  /// Set cache timestamp
  void _setCacheTimestamp(String cacheKey) {
    final lastSyncBox = _hiveService.getLastSyncBox();
    lastSyncBox.put('${cacheKey}_lastSync', DateTime.now().toIso8601String());
  }

  /// Clear all caches
  Future<void> clearAllCaches() async {
    await _hiveService.clearAllCaches();
    final lastSyncBox = _hiveService.getLastSyncBox();
    await lastSyncBox.clear();
    print('[Sync] All caches cleared');
  }

  /// Get cache status for all collections
  Future<Map<String, dynamic>> getCacheStatus() async {
    return {
      'playlists': {
        'isCached': _isCacheValid('playlists'),
        'lastSync':
            _hiveService.getLastSyncBox().get('playlists_lastSync') ?? 'Never',
        'count': _hiveService.getCachedPlaylists().length,
      },
      'artists': {
        'isCached': _isCacheValid('artists'),
        'lastSync':
            _hiveService.getLastSyncBox().get('artists_lastSync') ?? 'Never',
        'count': _hiveService.getCachedArtists().length,
      },
      'podcasts': {
        'isCached': _isCacheValid('podcasts'),
        'lastSync':
            _hiveService.getLastSyncBox().get('podcasts_lastSync') ?? 'Never',
        'count': _hiveService.getCachedPodcasts().length,
      },
      'homeScreenConfig': {
        'isCached': _isCacheValid('homeScreenConfig'),
        'lastSync': _hiveService.getLastSyncBox().get(
                'homeScreenConfig_lastSync') ??
            'Never',
      },
    };
  }
}
