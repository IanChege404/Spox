import 'package:spotify_clone/DI/service_locator.dart';
import 'package:spotify_clone/data/model/spotify_models.dart';
import 'package:spotify_clone/services/firestore_sync_service.dart';
import 'package:spotify_clone/services/spotify_api_service.dart';

/// Repository for Spotify API calls with Firestore caching
/// Uses Firestore for static data (playlists, artists)
/// Falls back to Spotify API for real-time data
class SpotifyRepository {
  final SpotifyApiService _apiService;
  late final FirestoreSyncService _syncService = locator.get();

  SpotifyRepository({required SpotifyApiService apiService})
      : _apiService = apiService;

  /// Get featured playlists from Firestore cache-first
  Future<List<SpotifyPlaylist>> getFeaturedPlaylists({
    int limit = 20,
  }) async {
    try {
      // Try Firestore first
      final playlists = await _syncService.syncPlaylists();
      if (playlists.isNotEmpty) {
        return playlists.take(limit).toList();
      }
    } catch (e) {
      print(
          '[SpotifyRepository] Firestore sync failed: $e, falling back to API');
    }

    // Fallback to Spotify API
    try {
      final playlists = await _apiService.getFeaturedPlaylists(limit: limit);
      return playlists.map((json) => SpotifyPlaylist.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch featured playlists: $e');
    }
  }

  /// Get user's playlists from Firestore cache-first
  Future<List<SpotifyPlaylist>> getUserPlaylists({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Try Firestore first (user playlists are cached)
      final playlists = await _syncService.syncPlaylists();
      if (playlists.isNotEmpty) {
        return playlists.skip(offset).take(limit).toList();
      }
    } catch (e) {
      print(
          '[SpotifyRepository] Firestore sync failed: $e, falling back to API');
    }

    // Fallback to Spotify API for actual user playlists
    try {
      final playlists =
          await _apiService.getUserPlaylists(limit: limit, offset: offset);
      return playlists.map((json) => SpotifyPlaylist.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch user playlists: $e');
    }
  }

  /// Get new releases
  Future<List<SpotifyPlaylist>> getNewReleases({
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.getNewReleases(limit: limit);
      final albums = (response['albums']?['items'] as List?) ?? [];

      return albums.map((album) {
        final albumMap = album as Map<String, dynamic>;
        final images = (albumMap['images'] as List?) ?? const [];
        final artists = (albumMap['artists'] as List?) ?? const [];

        return SpotifyPlaylist(
          id: albumMap['id'] ?? '',
          name: albumMap['name'] ?? 'Unknown',
          description: albumMap['album_type'] ?? 'album',
          imageUrl:
              images.isNotEmpty ? (images[0] as Map<String, dynamic>)['url'] : null,
          trackCount: albumMap['total_tracks'] ?? 0,
          ownerName: artists.isNotEmpty
              ? (artists[0] as Map<String, dynamic>)['name']
              : null,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch new releases: $e');
    }
  }

  /// Search for tracks, artists, albums, playlists
  Future<SpotifySearchResults> search(
    String query, {
    String type = 'track,artist,album,playlist',
    int limit = 20,
  }) async {
    try {
      final results = await _apiService.search(
        query,
        type: type,
        limit: limit,
      );
      return SpotifySearchResults.fromJson(results);
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  /// Get current user's profile
  Future<SpotifyUser> getCurrentUserProfile() async {
    try {
      final profile = await _apiService.getCurrentUserProfile();
      return SpotifyUser.fromJson(profile);
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// Get playlist details with tracks
  Future<SpotifyPlaylist> getPlaylist(String playlistId) async {
    try {
      final playlist = await _apiService.getPlaylist(playlistId);
      return SpotifyPlaylist.fromJson(playlist);
    } catch (e) {
      throw Exception('Failed to fetch playlist: $e');
    }
  }

  /// Get playlist tracks
  Future<List<SpotifyTrack>> getPlaylistTracks(
    String playlistId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final tracks = await _apiService.getPlaylistTracks(
        playlistId,
        limit: limit,
        offset: offset,
      );
      return tracks.map((json) => SpotifyTrack.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch playlist tracks: $e');
    }
  }

  /// Get track details
  Future<SpotifyTrack> getTrack(String trackId) async {
    try {
      final track = await _apiService.getTrack(trackId);
      return SpotifyTrack.fromJson(track);
    } catch (e) {
      throw Exception('Failed to fetch track: $e');
    }
  }

  /// Save track to library
  Future<void> saveTrack(String trackId) async {
    try {
      await _apiService.saveTrack(trackId);
    } catch (e) {
      throw Exception('Failed to save track: $e');
    }
  }

  /// Remove track from library
  Future<void> removeTrack(String trackId) async {
    try {
      await _apiService.removeTrack(trackId);
    } catch (e) {
      throw Exception('Failed to remove track: $e');
    }
  }

  /// Get user's saved tracks
  Future<List<SpotifyTrack>> getSavedTracks({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final tracks =
          await _apiService.getSavedTracks(limit: limit, offset: offset);
      return tracks.map((json) => SpotifyTrack.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch saved tracks: $e');
    }
  }

  /// Get artist details with Firestore fallback
  Future<SpotifyArtist> getArtist(String artistId) async {
    try {
      final artist = await _apiService.getArtist(artistId);
      return SpotifyArtist.fromJson(artist);
    } catch (e) {
      // Try Firestore cache
      try {
        final artists = await _syncService.syncArtists();
        for (final a in artists) {
          if (a.id == artistId) {
            return a;
          }
        }
      } catch (_) {}
      throw Exception('Failed to fetch artist: $e');
    }
  }

  /// Get artist's top tracks
  Future<List<SpotifyTrack>> getArtistTopTracks(
    String artistId, {
    String market = 'US',
  }) async {
    try {
      final tracks =
          await _apiService.getArtistTopTracks(artistId, market: market);
      return tracks.map((json) => SpotifyTrack.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch artist top tracks: $e');
    }
  }

  /// Get guest home page data - public content only
  /// Returns featured playlists, categories, and category playlists
  /// Works without authentication (public endpoints only)
  Future<GuestHomeData> getGuestHomeData({int limit = 20}) async {
    try {
      // Fetch all guest data in parallel
      final featuredPlaylistsFuture = getFeaturedPlaylists(limit: limit);
      final categoriesFuture = _apiService.getBrowseCategories(limit: 6);

      final featuredPlaylists = await featuredPlaylistsFuture;
      final categoriesJson = await categoriesFuture;
      final categories =
          categoriesJson.map((json) => BrowseCategory.fromJson(json)).toList();

      // Get playlists for first category if available
      List<SpotifyPlaylist> categoryPlaylists = [];
      if (categories.isNotEmpty) {
        try {
          final playlistsJson = await _apiService.getCategoryPlaylists(
            categories[0].id,
            limit: limit,
          );
          categoryPlaylists = playlistsJson
              .map((json) => SpotifyPlaylist.fromJson(json))
              .toList();
        } catch (e) {
          print('[Repository] Failed to fetch category playlists: $e');
        }
      }

      return GuestHomeData(
        featuredPlaylists: featuredPlaylists,
        browseCategories: categories,
        categoryPlaylists: categoryPlaylists,
      );
    } catch (e) {
      throw Exception('Failed to fetch guest home data: $e');
    }
  }

  /// Check if a section is restricted for guest users
  /// Returns true if the section requires authentication
  bool isRestrictedForGuest(String section) {
    const restrictedSections = {
      'liked_songs',
      'your_mixes',
      'recently_played',
      'your_library',
      'profile',
      'user_playlists',
    };
    return restrictedSections.contains(section);
  }
}
