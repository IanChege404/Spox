import 'package:hive_flutter/hive_flutter.dart';
import 'package:spotify_clone/data/model/album_track.dart';
import 'package:spotify_clone/data/model/spotify_models.dart';
import 'package:spotify_clone/data/model/podcast.dart';

/// Hive service for local data persistence
class HiveService {
  static const String likedSongsBox = 'liked_songs';
  static const String playHistoryBox = 'play_history';
  static const String appSettingsBox = 'app_settings';
  static const String userPreferencesBox = 'user_preferences';
  static const String selectedArtistsKey = 'selected_artists';
  static const String artistPreferencesCompleteKey =
      'artist_preferences_complete';
  static const String recentSearchesKey = 'recent_searches';
  static const String guestSessionBox = 'guest_session';
  static const String downloadsHistoryBox = 'downloads_history';

  // Cache boxes for Firestore sync
  static const String playlistsCacheBox = 'playlists_cache';
  static const String playlistTracksCacheBox = 'playlist_tracks_cache';
  static const String artistsCacheBox = 'artists_cache';
  static const String podcastsCacheBox = 'podcasts_cache';
  static const String homeScreenConfigCacheBox = 'home_screen_config_cache';
  static const String lastSyncBox = 'last_sync_times';

  late Box<Map> _likedSongsBox;
  late Box<Map> _playHistoryBox;
  late Box<Map> _appSettingsBox;
  late Box<Map> _userPreferencesBox;
  late Box<Map> _downloadsHistoryBox;

  // Cache boxes
  late Box<Map> _playlistsCacheBox;
  late Box<Map> _playlistTracksCacheBox;
  late Box<Map> _artistsCacheBox;
  late Box<Map> _podcastsCacheBox;
  late Box<Map> _homeScreenConfigCacheBox;
  late Box<String> _lastSyncBox;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Constructor for testing with injected boxes
  HiveService({
    Box<Map>? likedSongsBox,
    Box<Map>? playHistoryBox,
    Box<Map>? appSettingsBox,
    Box<Map>? userPreferencesBox,
  }) {
    if (likedSongsBox != null) {
      _likedSongsBox = likedSongsBox;
      _initialized = true;
    }
    if (playHistoryBox != null) {
      _playHistoryBox = playHistoryBox;
      _initialized = true;
    }
    if (appSettingsBox != null) {
      _appSettingsBox = appSettingsBox;
      _initialized = true;
    }
    if (userPreferencesBox != null) {
      _userPreferencesBox = userPreferencesBox;
      _initialized = true;
    }
  }

  /// Initialize Hive and open all boxes
  Future<void> init() async {
    if (_initialized) return;

    try {
      await Hive.initFlutter();

      // Open boxes with JSON storage - check if already open first
      _likedSongsBox = Hive.isBoxOpen(likedSongsBox)
          ? Hive.box<Map>(likedSongsBox)
          : await Hive.openBox<Map>(likedSongsBox);

      _playHistoryBox = Hive.isBoxOpen(playHistoryBox)
          ? Hive.box<Map>(playHistoryBox)
          : await Hive.openBox<Map>(playHistoryBox);

      _appSettingsBox = Hive.isBoxOpen(appSettingsBox)
          ? Hive.box<Map>(appSettingsBox)
          : await Hive.openBox<Map>(appSettingsBox);

      _userPreferencesBox = Hive.isBoxOpen(userPreferencesBox)
          ? Hive.box<Map>(userPreferencesBox)
          : await Hive.openBox<Map>(userPreferencesBox);

      _downloadsHistoryBox = Hive.isBoxOpen(downloadsHistoryBox)
          ? Hive.box<Map>(downloadsHistoryBox)
          : await Hive.openBox<Map>(downloadsHistoryBox);

      // Open cache boxes
      _playlistsCacheBox = Hive.isBoxOpen(playlistsCacheBox)
          ? Hive.box<Map>(playlistsCacheBox)
          : await Hive.openBox<Map>(playlistsCacheBox);

      _playlistTracksCacheBox = Hive.isBoxOpen(playlistTracksCacheBox)
          ? Hive.box<Map>(playlistTracksCacheBox)
          : await Hive.openBox<Map>(playlistTracksCacheBox);

      _artistsCacheBox = Hive.isBoxOpen(artistsCacheBox)
          ? Hive.box<Map>(artistsCacheBox)
          : await Hive.openBox<Map>(artistsCacheBox);

      _podcastsCacheBox = Hive.isBoxOpen(podcastsCacheBox)
          ? Hive.box<Map>(podcastsCacheBox)
          : await Hive.openBox<Map>(podcastsCacheBox);

      _homeScreenConfigCacheBox = Hive.isBoxOpen(homeScreenConfigCacheBox)
          ? Hive.box<Map>(homeScreenConfigCacheBox)
          : await Hive.openBox<Map>(homeScreenConfigCacheBox);

      _lastSyncBox = Hive.isBoxOpen(lastSyncBox)
          ? Hive.box<String>(lastSyncBox)
          : await Hive.openBox<String>(lastSyncBox);

      _initialized = true;
      print(
          '[HiveService] ✓ Hive initialized successfully with all boxes opened');
    } catch (e) {
      print('[HiveService] ✗ Error initializing Hive: $e');
      _initialized = false; // Ensure flag is reset on failure
      rethrow;
    }
  }

  /// Save a liked song
  Future<void> saveLikedSong(AlbumTrack song, String albumImage) async {
    try {
      final key = '${song.trackName}_${song.singers}';
      await _likedSongsBox.put(key, {
        'trackName': song.trackName,
        'singers': song.singers,
        'albumImage': albumImage,
        'audioUrl': song.audioUrl,
        'savedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving liked song: $e');
      rethrow;
    }
  }

  /// Remove a liked song
  Future<void> removeLikedSong(AlbumTrack song) async {
    try {
      final key = '${song.trackName}_${song.singers}';
      await _likedSongsBox.delete(key);
    } catch (e) {
      print('Error removing liked song: $e');
      rethrow;
    }
  }

  /// Get all liked songs
  Future<List<AlbumTrack>> getLikedSongs() async {
    try {
      final songs = <AlbumTrack>[];
      for (var value in _likedSongsBox.values) {
        songs.add(
          AlbumTrack(
            value['trackName'],
            value['singers'],
            audioUrl: value['audioUrl'],
            albumImage: value['albumImage'],
            likedAt: value['savedAt'] != null
                ? DateTime.tryParse(value['savedAt'])
                : null,
          ),
        );
      }
      return songs;
    } catch (e) {
      print('Error fetching liked songs: $e');
      return [];
    }
  }

  /// Get liked songs as raw map list (for cloud sync payloads)
  Future<List<Map<String, dynamic>>> getLikedSongsRaw() async {
    try {
      return _likedSongsBox.values
          .map((value) => value.cast<String, dynamic>())
          .toList();
    } catch (e) {
      print('Error fetching raw liked songs: $e');
      return [];
    }
  }

  /// Check if a song is liked
  Future<bool> isLiked(AlbumTrack song) async {
    try {
      final key = '${song.trackName}_${song.singers}';
      return _likedSongsBox.containsKey(key);
    } catch (e) {
      print('Error checking if liked: $e');
      return false;
    }
  }

  /// Clear all liked songs
  Future<void> clearLikedSongs() async {
    try {
      await _likedSongsBox.clear();
    } catch (e) {
      print('Error clearing liked songs: $e');
      rethrow;
    }
  }

  /// Save play history entry with enhanced metadata
  ///
  /// [song] - The track details
  /// [duration] - Duration of the track in seconds (for stats calculation)
  /// [albumImage] - Album artwork URL (for display in stats)
  Future<void> recordPlay(
    AlbumTrack song, {
    int? duration,
    String? albumImage,
  }) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      await _playHistoryBox.put(timestamp, {
        'trackName': song.trackName,
        'singers': song.singers,
        'playedAt': timestamp,
        'duration': duration, // in seconds
        'albumImage': albumImage, // for display
      });
    } catch (e) {
      print('Error recording play: $e');
      rethrow;
    }
  }

  /// Get play history
  Future<List<Map>> getPlayHistory({int limit = 50}) async {
    try {
      return _playHistoryBox.values.toList().reversed.take(limit).toList();
    } catch (e) {
      print('Error fetching play history: $e');
      return [];
    }
  }

  /// Clear play history entries
  Future<void> clearPlayHistory() async {
    try {
      await _playHistoryBox.clear();
    } catch (e) {
      print('Error clearing play history: $e');
      rethrow;
    }
  }

  /// Save app setting
  Future<void> saveSetting(String key, dynamic value) async {
    try {
      await _appSettingsBox.put(key, {'key': key, 'value': value});
    } catch (e) {
      print('Error saving setting: $e');
      rethrow;
    }
  }

  Future<void> saveRecentSearch(String query, {int maxItems = 12}) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return;

    try {
      final existing = getRecentSearches();
      final updated = <String>[normalized];

      for (final item in existing) {
        if (item.toLowerCase() != normalized.toLowerCase()) {
          updated.add(item);
        }
        if (updated.length >= maxItems) break;
      }

      await _appSettingsBox.put(recentSearchesKey, {
        'items': updated,
      });
    } catch (e) {
      print('Error saving recent search: $e');
    }
  }

  List<String> getRecentSearches({int maxItems = 12}) {
    try {
      final saved = _appSettingsBox.get(recentSearchesKey);
      if (saved == null) return [];

      final items = saved['items'] as List?;
      if (items == null) return [];

      return items
          .map((item) => item?.toString() ?? '')
          .where((item) => item.trim().isNotEmpty)
          .take(maxItems)
          .toList();
    } catch (e) {
      print('Error fetching recent searches: $e');
      return [];
    }
  }

  Future<void> removeRecentSearch(String query) async {
    try {
      final updated = getRecentSearches()
          .where((item) => item.toLowerCase() != query.toLowerCase())
          .toList();

      await _appSettingsBox.put(recentSearchesKey, {
        'items': updated,
      });
    } catch (e) {
      print('Error removing recent search: $e');
    }
  }

  Future<void> clearRecentSearches() async {
    try {
      await _appSettingsBox.delete(recentSearchesKey);
    } catch (e) {
      print('Error clearing recent searches: $e');
    }
  }

  /// Get app setting
  dynamic getSetting(String key, [dynamic defaultValue]) {
    try {
      final value = _appSettingsBox.get(key);
      return value?['value'] ?? defaultValue;
    } catch (e) {
      print('Error getting setting: $e');
      return defaultValue;
    }
  }

  /// Save user preference
  Future<void> savePreference(String key, dynamic value) async {
    try {
      await _userPreferencesBox.put(key, {'key': key, 'value': value});
    } catch (e) {
      print('Error saving preference: $e');
      rethrow;
    }
  }

  /// Get user preference
  dynamic getPreference(String key, [dynamic defaultValue]) {
    try {
      final value = _userPreferencesBox.get(key);
      return value?['value'] ?? defaultValue;
    } catch (e) {
      print('Error getting preference: $e');
      return defaultValue;
    }
  }

  /// Persist selected onboarding artists locally.
  Future<void> saveSelectedArtists(List<Map<String, dynamic>> artists) async {
    try {
      await savePreference(selectedArtistsKey, artists);
      await savePreference(artistPreferencesCompleteKey, true);
    } catch (e) {
      print('Error saving selected artists: $e');
      rethrow;
    }
  }

  /// Load selected onboarding artists locally.
  List<Map<String, dynamic>> getSelectedArtists() {
    try {
      final artists =
          getPreference(selectedArtistsKey, <Map<String, dynamic>>[]);
      return (artists as List?)?.cast<Map<String, dynamic>>() ??
          <Map<String, dynamic>>[];
    } catch (e) {
      print('Error getting selected artists: $e');
      return [];
    }
  }

  /// Check whether the user has completed artist onboarding.
  bool hasCompletedArtistPreferences() {
    try {
      return getPreference(artistPreferencesCompleteKey, false) == true;
    } catch (e) {
      return false;
    }
  }

  /// Clear all data
  Future<void> clearAll() async {
    try {
      await _likedSongsBox.clear();
      await _playHistoryBox.clear();
      await _appSettingsBox.clear();
      await _userPreferencesBox.clear();
      if (Hive.isBoxOpen(downloadsHistoryBox)) {
        await Hive.box<Map>(downloadsHistoryBox).clear();
      }
      await clearAllCaches();
    } catch (e) {
      print('Error clearing all data: $e');
      rethrow;
    }
  }

  // ============================================================================
  // FIRESTORE CACHE METHODS
  // ============================================================================

  /// Get last sync box (for tracking cache timestamps)
  Box<String> getLastSyncBox() {
    return _lastSyncBox;
  }

  /// Cache playlists from Firestore
  Future<void> cachePlaylists(List<SpotifyPlaylist> playlists) async {
    try {
      await _playlistsCacheBox.clear();
      for (var playlist in playlists) {
        await _playlistsCacheBox.put(playlist.id, {
          'id': playlist.id,
          'name': playlist.name,
          'description': playlist.description,
          'imageUrl': playlist.imageUrl,
          'trackCount': playlist.trackCount,
          'ownerName': playlist.ownerName,
        });
      }
      print('[Cache] Cached ${playlists.length} playlists');
    } catch (e) {
      print('Error caching playlists: $e');
      rethrow;
    }
  }

  /// Get cached playlists
  List<SpotifyPlaylist> getCachedPlaylists() {
    try {
      return _playlistsCacheBox.values.map((data) {
        return SpotifyPlaylist(
          id: data['id'],
          name: data['name'],
          description: data['description'],
          imageUrl: data['imageUrl'],
          trackCount: data['trackCount'],
          ownerName: data['ownerName'],
        );
      }).toList();
    } catch (e) {
      print('Error retrieving cached playlists: $e');
      return [];
    }
  }

  /// Cache playlist tracks
  Future<void> cachePlaylistTracks(
      String playlistId, List<SpotifyTrack> tracks) async {
    try {
      final key = 'playlist_${playlistId}_tracks';
      await _playlistTracksCacheBox.put(key, {
        'playlistId': playlistId,
        'tracks': tracks
            .map((t) => {
                  'id': t.id,
                  'name': t.name,
                  'artists': t.artists.map((a) => a.id).toList(),
                  'imageUrl': t.imageUrl,
                  'durationMs': t.durationMs,
                  'previewUrl': t.previewUrl,
                  'popularity': t.popularity,
                })
            .toList(),
      });
      print('[Cache] Cached ${tracks.length} tracks for playlist $playlistId');
    } catch (e) {
      print('Error caching playlist tracks: $e');
      rethrow;
    }
  }

  /// Get cached playlist tracks
  List<SpotifyTrack> getCachedPlaylistTracks(String playlistId) {
    try {
      final key = 'playlist_${playlistId}_tracks';
      final data = _playlistTracksCacheBox.get(key);
      if (data == null) return [];

      final tracks = (data['tracks'] as List?)?.cast<Map>() ?? [];
      return tracks
          .map((t) => SpotifyTrack(
                id: t['id'],
                name: t['name'],
                artists: [],
                imageUrl: t['imageUrl'],
                durationMs: t['durationMs'],
                previewUrl: t['previewUrl'],
                popularity: t['popularity'],
              ))
          .toList();
    } catch (e) {
      print('Error retrieving cached playlist tracks: $e');
      return [];
    }
  }

  /// Cache artists from Firestore
  Future<void> cacheArtists(List<SpotifyArtist> artists) async {
    try {
      await _artistsCacheBox.clear();
      for (var artist in artists) {
        await _artistsCacheBox.put(artist.id, {
          'id': artist.id,
          'name': artist.name,
          'imageUrl': artist.imageUrl,
          'genres': artist.genres,
          'followers': artist.followers,
          'popularity': artist.popularity,
        });
      }
      print('[Cache] Cached ${artists.length} artists');
    } catch (e) {
      print('Error caching artists: $e');
      rethrow;
    }
  }

  /// Get cached artists
  List<SpotifyArtist> getCachedArtists() {
    try {
      return _artistsCacheBox.values.map((data) {
        return SpotifyArtist(
          id: data['id'],
          name: data['name'],
          imageUrl: data['imageUrl'],
          genres: (data['genres'] as List?)?.cast<String>() ?? [],
          followers: data['followers'],
          popularity: data['popularity'],
        );
      }).toList();
    } catch (e) {
      print('Error retrieving cached artists: $e');
      return [];
    }
  }

  /// Cache podcasts from Firestore
  Future<void> cachePodcasts(List<Podcast> podcasts) async {
    try {
      await _podcastsCacheBox.clear();
      for (var podcast in podcasts) {
        await _podcastsCacheBox.put(podcast.name, {
          'name': podcast.name,
          'image': podcast.image,
        });
      }
      print('[Cache] Cached ${podcasts.length} podcasts');
    } catch (e) {
      print('Error caching podcasts: $e');
      rethrow;
    }
  }

  /// Get cached podcasts
  List<Podcast> getCachedPodcasts() {
    try {
      return _podcastsCacheBox.values.map((data) {
        return Podcast(
          data['image'] ?? '',
          data['name'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error retrieving cached podcasts: $e');
      return [];
    }
  }

  /// Cache home screen configuration
  Future<void> cacheHomeScreenConfig(Map<String, dynamic> config) async {
    try {
      await _homeScreenConfigCacheBox.clear();
      await _homeScreenConfigCacheBox.put('config', config);
      print('[Cache] Cached home screen configuration');
    } catch (e) {
      print('Error caching home screen config: $e');
      rethrow;
    }
  }

  /// Get cached home screen configuration
  Map<String, dynamic> getCachedHomeScreenConfig() {
    try {
      final data = _homeScreenConfigCacheBox.get('config');
      return (data?.cast<String, dynamic>()) ?? {};
    } catch (e) {
      print('Error retrieving cached home screen config: $e');
      return {};
    }
  }

  /// Clear all caches (but keep user data)
  Future<void> clearAllCaches() async {
    try {
      if (Hive.isBoxOpen(playlistsCacheBox)) {
        await Hive.box<Map>(playlistsCacheBox).clear();
      }
      if (Hive.isBoxOpen(playlistTracksCacheBox)) {
        await Hive.box<Map>(playlistTracksCacheBox).clear();
      }
      if (Hive.isBoxOpen(artistsCacheBox)) {
        await Hive.box<Map>(artistsCacheBox).clear();
      }
      if (Hive.isBoxOpen(podcastsCacheBox)) {
        await Hive.box<Map>(podcastsCacheBox).clear();
      }
      if (Hive.isBoxOpen(homeScreenConfigCacheBox)) {
        await Hive.box<Map>(homeScreenConfigCacheBox).clear();
      }
      if (Hive.isBoxOpen(lastSyncBox)) {
        await Hive.box<String>(lastSyncBox).clear();
      }
      print('[Cache] All caches cleared');
    } catch (e) {
      print('Error clearing caches: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Downloads History
  // ─────────────────────────────────────────────────────────────

  /// Save or update a downloaded track state
  Future<void> saveDownloadedTrack(Map<String, dynamic> trackData) async {
    try {
      final trackId = trackData['trackId'] as String?;
      if (trackId == null || trackId.isEmpty) return;

      final box = Hive.isBoxOpen(downloadsHistoryBox)
          ? Hive.box<Map>(downloadsHistoryBox)
          : _downloadsHistoryBox;

      await box.put(trackId, trackData);
    } catch (e) {
      print('Error saving downloaded track: $e');
      rethrow;
    }
  }

  /// Remove a downloaded track by id
  Future<void> removeDownloadedTrack(String trackId) async {
    try {
      final box = Hive.isBoxOpen(downloadsHistoryBox)
          ? Hive.box<Map>(downloadsHistoryBox)
          : _downloadsHistoryBox;
      await box.delete(trackId);
    } catch (e) {
      print('Error removing downloaded track: $e');
      rethrow;
    }
  }

  /// Load all downloaded track states
  Map<String, Map<String, dynamic>> getDownloadedTracks() {
    try {
      final box = Hive.isBoxOpen(downloadsHistoryBox)
          ? Hive.box<Map>(downloadsHistoryBox)
          : _downloadsHistoryBox;

      final result = <String, Map<String, dynamic>>{};
      for (final key in box.keys) {
        final value = box.get(key);
        if (key is String && value != null) {
          result[key] = value.cast<String, dynamic>();
        }
      }
      return result;
    } catch (e) {
      print('Error loading downloaded tracks: $e');
      return {};
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Featured Playlists Cache
  // ─────────────────────────────────────────────────────────────

  /// Cache featured playlists
  Future<void> cacheFeaturedPlaylists(
    List<Map<String, dynamic>> playlists, {
    int limit = 20,
  }) async {
    try {
      const cacheKey = 'featured_playlists';
      await _playlistsCacheBox.put(cacheKey, {
        'items': playlists,
        'limit': limit,
      });
      print('[Cache] Featured playlists cached (${playlists.length} items)');
    } catch (e) {
      print('Error caching featured playlists: $e');
    }
  }

  /// Get cached featured playlists
  List<Map<String, dynamic>> getFeaturedPlaylistsCache({int limit = 20}) {
    try {
      const cacheKey = 'featured_playlists';
      final cached = _playlistsCacheBox.get(cacheKey);
      final items = (cached?['items'] as List?)?.cast<Map>() ?? [];
      return items
          .map((item) => item.cast<String, dynamic>())
          .take(limit)
          .toList();
    } catch (e) {
      print('Error retrieving cached featured playlists: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  // New Releases Cache
  // ─────────────────────────────────────────────────────────────

  /// Cache new releases
  Future<void> cacheNewReleases(Map<String, dynamic> releases) async {
    try {
      await _homeScreenConfigCacheBox.put('new_releases', releases);
      print('[Cache] New releases cached');
    } catch (e) {
      print('Error caching new releases: $e');
    }
  }

  /// Get cached new releases
  Map<String, dynamic>? getNewReleasesCache() {
    try {
      return _homeScreenConfigCacheBox
          .get('new_releases')
          ?.cast<String, dynamic>();
    } catch (e) {
      print('Error retrieving cached new releases: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Trending Tracks Cache
  // ─────────────────────────────────────────────────────────────

  /// Cache trending tracks
  Future<void> cacheTrendingTracks(List<Map<String, dynamic>> tracks) async {
    try {
      await _homeScreenConfigCacheBox.put('trending_tracks', {
        'items': tracks,
      });
      print('[Cache] Trending tracks cached (${tracks.length} items)');
    } catch (e) {
      print('Error caching trending tracks: $e');
    }
  }

  /// Get cached trending tracks
  List<Map<String, dynamic>> getTrendingTracksCache() {
    try {
      final cached = _homeScreenConfigCacheBox.get('trending_tracks');
      final items = (cached?['items'] as List?)?.cast<Map>() ?? [];
      return items.map((item) => item.cast<String, dynamic>()).toList();
    } catch (e) {
      print('Error retrieving cached trending tracks: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Artist Cache
  // ─────────────────────────────────────────────────────────────

  /// Cache artist details
  Future<void> cacheArtist(
    String artistId,
    Map<String, dynamic> artistData,
  ) async {
    try {
      await _artistsCacheBox.put(artistId, artistData);
      print('[Cache] Artist "$artistId" cached');
    } catch (e) {
      print('Error caching artist: $e');
    }
  }

  /// Get cached artist details
  Map<String, dynamic>? getArtistCache(String artistId) {
    try {
      return _artistsCacheBox.get(artistId)?.cast<String, dynamic>();
    } catch (e) {
      print('Error retrieving cached artist: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Artist Tracks Cache
  // ─────────────────────────────────────────────────────────────

  /// Cache artist's top tracks
  Future<void> cacheArtistTracks(
    String artistId,
    List<Map<String, dynamic>> tracks,
  ) async {
    try {
      final cacheKey = 'artist_tracks_$artistId';
      await _playlistTracksCacheBox.put(cacheKey, {
        'items': tracks,
      });
      print('[Cache] Artist tracks cached (${tracks.length} tracks)');
    } catch (e) {
      print('Error caching artist tracks: $e');
    }
  }

  /// Get cached artist tracks
  List<Map<String, dynamic>> getArtistTracksCache(String artistId) {
    try {
      final cacheKey = 'artist_tracks_$artistId';
      final cached = _playlistTracksCacheBox.get(cacheKey);
      final items = (cached?['items'] as List?)?.cast<Map>() ?? [];
      return items.map((item) => item.cast<String, dynamic>()).toList();
    } catch (e) {
      print('Error retrieving cached artist tracks: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Playlist Cache
  // ─────────────────────────────────────────────────────────────

  /// Cache playlist details
  Future<void> cachePlaylist(
    String playlistId,
    Map<String, dynamic> playlistData,
  ) async {
    try {
      await _playlistsCacheBox.put(playlistId, playlistData);
      print('[Cache] Playlist "$playlistId" cached');
    } catch (e) {
      print('Error caching playlist: $e');
    }
  }

  /// Get cached playlist details
  Map<String, dynamic>? getPlaylistCache(String playlistId) {
    try {
      return _playlistsCacheBox.get(playlistId)?.cast<String, dynamic>();
    } catch (e) {
      print('Error retrieving cached playlist: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Sync Timestamp Tracking
  // ─────────────────────────────────────────────────────────────

  /// Update last sync time for a cache key
  Future<void> updateLastSyncTime(String syncKey, String timestamp) async {
    try {
      await _lastSyncBox.put(syncKey, timestamp);
    } catch (e) {
      print('Error updating sync time: $e');
    }
  }

  /// Get last sync time for a cache key
  String? getLastSyncTime(String syncKey) {
    try {
      return _lastSyncBox.get(syncKey);
    } catch (e) {
      print('Error retrieving sync time: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Cache Statistics
  // ─────────────────────────────────────────────────────────────

  /// Get cache statistics
  Map<String, String> getCacheStats() {
    try {
      return {
        'featured_playlists': _playlistsCacheBox.length.toString(),
        'playlists': _playlistsCacheBox.length.toString(),
        'artists': _artistsCacheBox.length.toString(),
        'playlist_tracks': _playlistTracksCacheBox.length.toString(),
        'podcasts': _podcastsCacheBox.length.toString(),
        'sync_entries': _lastSyncBox.length.toString(),
      };
    } catch (e) {
      print('Error getting cache stats: $e');
      return {};
    }
  }

  /// Save guest mode flag to persist across app restarts
  Future<void> saveGuestMode(bool isGuest) async {
    try {
      await _appSettingsBox.put(
        'is_guest_mode',
        {'value': isGuest, 'timestamp': DateTime.now().toIso8601String()},
      );
      print('[HiveService] ✓ Guest mode saved: $isGuest');
    } catch (e) {
      print('[HiveService] ✗ Error saving guest mode: $e');
    }
  }

  /// Check if guest mode should be active (persisted from previous session)
  bool isGuestModePersisted() {
    try {
      final data = _appSettingsBox.get('is_guest_mode', defaultValue: {});
      if (data == null || data.isEmpty) {
        return false;
      }
      return data['value'] as bool? ?? false;
    } catch (e) {
      print('[HiveService] ✗ Error checking guest mode: $e');
      return false;
    }
  }

  /// Clear guest mode flag
  Future<void> clearGuestMode() async {
    try {
      await _appSettingsBox.delete('is_guest_mode');
      print('[HiveService] ✓ Guest mode cleared');
    } catch (e) {
      print('[HiveService] ✗ Error clearing guest mode: $e');
    }
  }

  /// Get guest session data (visit count, timestamp, etc.)
  Map<String, dynamic> getGuestSessionData() {
    try {
      final data = _appSettingsBox.get('guest_session_data', defaultValue: {});
      if (data == null || data.isEmpty) {
        return {
          'is_guest': isGuestModePersisted(),
          'created_at': DateTime.now().toIso8601String(),
          'visit_count': 1,
        };
      }
      return {
        'is_guest': isGuestModePersisted(),
        'created_at': data['created_at'] ?? DateTime.now().toIso8601String(),
        'visit_count': (data['visit_count'] ?? 0) + 1,
      };
    } catch (e) {
      print('[HiveService] ✗ Error getting guest session data: $e');
      return {};
    }
  }

  /// Save guest session data
  Future<void> saveGuestSessionData(Map<String, dynamic> data) async {
    try {
      await _appSettingsBox.put('guest_session_data', data);
      print('[HiveService] ✓ Guest session data saved');
    } catch (e) {
      print('[HiveService] ✗ Error saving guest session data: $e');
    }
  }

  /// Close all boxes
  Future<void> close() async {
    try {
      await Hive.close();
      _initialized = false;
    } catch (e) {
      print('Error closing Hive: $e');
    }
  }
}
