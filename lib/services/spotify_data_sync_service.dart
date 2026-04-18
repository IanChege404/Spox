import 'package:spotify_clone/services/hive_service.dart';
import 'package:spotify_clone/services/spotify_api_service.dart';

/// Orchestrates Spotify API calls with intelligent caching strategy
///
/// Uses a cache-first approach with TTL expiration:
/// 1. Check if data exists in Hive cache
/// 2. If cache exists and hasn't expired → return cached data
/// 3. If cache stale or missing → fetch from Spotify API
/// 4. Cache result in Hive with timestamp
/// 5. Return data to caller
///
/// This enables:
/// - Instant first-load from cache (if available)
/// - Offline support (cache serves data when network unavailable)
/// - Fresh data on demand (forceRefresh bypasses cache)
/// - Reduced API calls (respects TTL windows)
class SpotifyDataSyncService {
  final SpotifyApiService _spotifyApi;
  final HiveService _hiveService;

  // Cache TTL durations
  static const Duration _ttlFeaturedPlaylists = Duration(days: 1); // 24 hours
  static const Duration _ttlNewReleases = Duration(days: 7); // 1 week
  static const Duration _ttlTrendingTracks = Duration(days: 1); // 24 hours
  static const Duration _ttlArtistDetails = Duration(days: 30); // 1 month
  static const Duration _ttlPlaylistTracks = Duration(days: 7); // 1 week

  SpotifyDataSyncService({
    required SpotifyApiService spotifyApi,
    required HiveService hiveService,
  })  : _spotifyApi = spotifyApi,
        _hiveService = hiveService;

  /// Fetch featured playlists with smart caching
  ///
  /// [limit] - Max playlists to return (default 20)
  /// [forceRefresh] - Bypass cache and fetch fresh from API
  Future<List<Map<String, dynamic>>> fetchFeaturedPlaylists({
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    try {
      const syncKey = 'featured_playlists';

      // Check cache validity if not forcing refresh
      if (!forceRefresh && _isCacheValid(syncKey, _ttlFeaturedPlaylists)) {
        final cached = _hiveService.getFeaturedPlaylistsCache(limit: limit);
        if (cached.isNotEmpty) {
          print('[Sync] ✓ Featured playlists from cache');
          return cached;
        }
      }

      // Fetch from API
      print('[Sync] ↓ Fetching featured playlists from Spotify API...');
      final data = await _spotifyApi.getFeaturedPlaylists(limit: limit);

      // Cache result
      await _hiveService.cacheFeaturedPlaylists(data, limit: limit);
      await _updateSyncTime(syncKey);

      print('[Sync] ✓ Featured playlists cached (${data.length} items)');
      return data;
    } catch (e) {
      print('[Sync] ✗ Error fetching featured playlists: $e');
      // Return cached data even if stale
      final cached = _hiveService.getFeaturedPlaylistsCache(limit: limit);
      if (cached.isNotEmpty) {
        print('[Sync] ▲ Using stale cached data');
        return cached;
      }
      rethrow;
    }
  }

  /// Fetch new releases with smart caching
  ///
  /// [limit] - Max items to return (default 20)
  /// [offset] - Pagination offset (default 0)
  /// [forceRefresh] - Bypass cache and fetch fresh
  Future<Map<String, dynamic>> fetchNewReleases({
    int limit = 20,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    try {
      const syncKey = 'new_releases';

      if (!forceRefresh && _isCacheValid(syncKey, _ttlNewReleases)) {
        final cached = _hiveService.getNewReleasesCache();
        if (cached != null) {
          print('[Sync] ✓ New releases from cache');
          return cached;
        }
      }

      print('[Sync] ↓ Fetching new releases from Spotify API...');
      final data =
          await _spotifyApi.getNewReleases(limit: limit, offset: offset);

      await _hiveService.cacheNewReleases(data);
      await _updateSyncTime(syncKey);

      print('[Sync] ✓ New releases cached');
      return data;
    } catch (e) {
      print('[Sync] ✗ Error fetching new releases: $e');
      final cached = _hiveService.getNewReleasesCache();
      if (cached != null) {
        print('[Sync] ▲ Using stale cached data');
        return cached;
      }
      rethrow;
    }
  }

  /// Fetch trending tracks with smart caching
  ///
  /// [limit] - Max tracks to return (default 20)
  /// [forceRefresh] - Bypass cache
  Future<List<Map<String, dynamic>>> fetchTrendingTracks({
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    try {
      const syncKey = 'trending_tracks';

      if (!forceRefresh && _isCacheValid(syncKey, _ttlTrendingTracks)) {
        final cached = _hiveService.getTrendingTracksCache();
        if (cached.isNotEmpty) {
          print('[Sync] ✓ Trending tracks from cache');
          return cached;
        }
      }

      print('[Sync] ↓ Fetching trending tracks from Spotify API...');
      // No dedicated endpoint, use recommendations instead
      final data = await _spotifyApi.getRecommendations(limit: limit);

      await _hiveService.cacheTrendingTracks(data);
      await _updateSyncTime(syncKey);

      print('[Sync] ✓ Trending tracks cached');
      return data;
    } catch (e) {
      print('[Sync] ✗ Error fetching trending tracks: $e');
      final cached = _hiveService.getTrendingTracksCache();
      if (cached.isNotEmpty) {
        print('[Sync] ▲ Using stale cached data');
        return cached;
      }
      rethrow;
    }
  }

  /// Fetch artist details with smart caching
  ///
  /// [artistId] - Spotify artist ID
  /// [forceRefresh] - Bypass cache
  Future<Map<String, dynamic>> fetchArtistDetails(
    String artistId, {
    bool forceRefresh = false,
  }) async {
    try {
      final syncKey = 'artist_$artistId';

      if (!forceRefresh && _isCacheValid(syncKey, _ttlArtistDetails)) {
        final cached = _hiveService.getArtistCache(artistId);
        if (cached != null) {
          print('[Sync] ✓ Artist "$artistId" from cache');
          return cached;
        }
      }

      print('[Sync] ↓ Fetching artist "$artistId" from Spotify API...');
      final data = await _spotifyApi.getArtist(artistId);

      await _hiveService.cacheArtist(artistId, data);
      await _updateSyncTime(syncKey);

      print('[Sync] ✓ Artist cached');
      return data;
    } catch (e) {
      print('[Sync] ✗ Error fetching artist: $e');
      final cached = _hiveService.getArtistCache(artistId);
      if (cached != null) {
        print('[Sync] ▲ Using stale cached artist data');
        return cached;
      }
      rethrow;
    }
  }

  /// Fetch artist's top tracks with smart caching
  ///
  /// [artistId] - Spotify artist ID
  /// [market] - Country code (e.g., 'US')
  /// [limit] - Max tracks (default 10)
  /// [forceRefresh] - Bypass cache
  Future<List<Map<String, dynamic>>> fetchArtistTopTracks(
    String artistId, {
    String market = 'US',
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    try {
      final syncKey = 'artist_tracks_$artistId';

      if (!forceRefresh && _isCacheValid(syncKey, _ttlPlaylistTracks)) {
        final cached = _hiveService.getArtistTracksCache(artistId);
        if (cached.isNotEmpty) {
          print('[Sync] ✓ Artist tracks from cache');
          return cached;
        }
      }

      print('[Sync] ↓ Fetching artist top tracks from Spotify API...');
      final data = await _spotifyApi.getArtistTopTracks(
        artistId,
        market: market,
      );

      await _hiveService.cacheArtistTracks(artistId, data);
      await _updateSyncTime(syncKey);

      print('[Sync] ✓ Artist top tracks cached');
      return data;
    } catch (e) {
      print('[Sync] ✗ Error fetching artist top tracks: $e');
      final cached = _hiveService.getArtistTracksCache(artistId);
      if (cached.isNotEmpty) {
        print('[Sync] ▲ Using stale cached tracks');
        return cached;
      }
      rethrow;
    }
  }

  /// Fetch playlist details with smart caching
  ///
  /// [playlistId] - Spotify playlist ID
  /// [forceRefresh] - Bypass cache
  Future<Map<String, dynamic>> fetchPlaylistDetails(
    String playlistId, {
    bool forceRefresh = false,
  }) async {
    try {
      final syncKey = 'playlist_$playlistId';

      if (!forceRefresh && _isCacheValid(syncKey, _ttlPlaylistTracks)) {
        final cached = _hiveService.getPlaylistCache(playlistId);
        if (cached != null) {
          print('[Sync] ✓ Playlist from cache');
          return cached;
        }
      }

      print('[Sync] ↓ Fetching playlist from Spotify API...');
      final data = await _spotifyApi.getPlaylist(playlistId);

      await _hiveService.cachePlaylist(playlistId, data);
      await _updateSyncTime(syncKey);

      print('[Sync] ✓ Playlist cached');
      return data;
    } catch (e) {
      print('[Sync] ✗ Error fetching playlist: $e');
      final cached = _hiveService.getPlaylistCache(playlistId);
      if (cached != null) {
        print('[Sync] ▲ Using stale cached playlist');
        return cached;
      }
      rethrow;
    }
  }

  /// Search content (never cached - always fresh)
  /// Queries: track, artist, playlist, album names
  ///
  /// [query] - Search term
  /// [types] - What to search for (track, artist, playlist, album)
  /// [limit] - Max results per type
  Future<Map<String, dynamic>> search({
    required String query,
    List<String> types = const ['track', 'artist', 'playlist'],
    int limit = 20,
  }) async {
    try {
      print('[Sync] ↓ Searching Spotify for "$query"');
      final results =
          await _spotifyApi.search(query, type: types.join(','), limit: limit);
      print('[Sync] ✓ Search complete');
      return results;
    } catch (e) {
      print('[Sync] ✗ Search failed: $e');
      // Return empty results on error (don't cache failed searches)
      return {
        'tracks': {'items': []},
        'artists': {'items': []},
        'playlists': {'items': []},
      };
    }
  }

  /// Check if cache for a given key is still valid
  ///
  /// Returns true if cache exists and hasn't expired
  bool _isCacheValid(String syncKey, Duration ttl) {
    final lastSync = _hiveService.getLastSyncTime(syncKey);
    if (lastSync == null) return false;

    final lastSyncTime = DateTime.parse(lastSync);
    final isValid = DateTime.now().difference(lastSyncTime) < ttl;

    if (!isValid) {
      print('[Sync] ℹ Cache expired for "$syncKey" (TTL: ${ttl.inHours}h)');
    }

    return isValid;
  }

  /// Update sync timestamp for a cache key
  Future<void> _updateSyncTime(String syncKey) async {
    await _hiveService.updateLastSyncTime(
        syncKey, DateTime.now().toIso8601String());
  }

  /// Clear all caches (for testing/reset)
  Future<void> clearAllCaches() async {
    print('[Sync] 🧹 Clearing all caches...');
    await _hiveService.clearAllCaches();
    print('[Sync] ✓ Caches cleared');
  }

  /// Get cache statistics
  Map<String, String> getCacheStats() {
    return _hiveService.getCacheStats();
  }
}
