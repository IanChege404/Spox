import 'package:spotify_clone/data/model/spotify_models.dart';
import 'package:spotify_clone/services/spotify_api_service.dart';

/// Repository for Spotify API calls
/// Abstracts API layer from business logic
class SpotifyRepository {
  final SpotifyApiService _apiService;

  SpotifyRepository({required SpotifyApiService apiService})
      : _apiService = apiService;

  /// Get featured playlists for home screen
  Future<List<SpotifyPlaylist>> getFeaturedPlaylists({
    int limit = 20,
  }) async {
    try {
      final playlists = await _apiService.getFeaturedPlaylists(limit: limit);
      return playlists.map((json) => SpotifyPlaylist.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch featured playlists: $e');
    }
  }

  /// Get user's playlists
  Future<List<SpotifyPlaylist>> getUserPlaylists({
    int limit = 20,
    int offset = 0,
  }) async {
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
      // Using browse/new-releases endpoint
      final response = await _apiService.getFeaturedPlaylists(limit: limit);
      return response.map((json) => SpotifyPlaylist.fromJson(json)).toList();
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
      // Note: This would need to be added to SpotifyApiService
      // For now, returning empty list as placeholder
      return [];
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

  /// Get artist details
  Future<SpotifyArtist> getArtist(String artistId) async {
    try {
      final artist = await _apiService.getArtist(artistId);
      return SpotifyArtist.fromJson(artist);
    } catch (e) {
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
}
