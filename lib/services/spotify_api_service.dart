import 'package:spotify_clone/core/constants/spotify_constants.dart';
import 'package:spotify_clone/core/network/http_client.dart';
import 'package:spotify_clone/services/spotify_auth_service.dart';

class SpotifyApiService {
  final HttpClient _httpClient;
  final SpotifyAuthService _authService;

  SpotifyApiService({
    required HttpClient httpClient,
    required SpotifyAuthService authService,
  })  : _httpClient = httpClient,
        _authService = authService;

  /// Get current user's profile
  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    try {
      await _authService.ensureValidToken();
      final response = await _httpClient.get('$spotifyApiBaseUrl/me');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch user profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

  /// Get user's playlists
  Future<List<Map<String, dynamic>>> getUserPlaylists(
      {int limit = 20, int offset = 0}) async {
    try {
      await _authService.ensureValidToken();
      final response = await _httpClient.get(
        '$spotifyApiBaseUrl/me/playlists',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      if (response.statusCode == 200) {
        final items = response.data['items'] as List;
        return items.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch playlists: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching playlists: $e');
    }
  }

  /// Get featured playlists (for home screen)
  Future<List<Map<String, dynamic>>> getFeaturedPlaylists(
      {int limit = 20}) async {
    try {
      await _authService.ensureValidToken();
      final response = await _httpClient.get(
        '$spotifyApiBaseUrl/browse/featured-playlists',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final items = response.data['playlists']['items'] as List;
        return items.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Failed to fetch featured playlists: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching featured playlists: $e');
    }
  }

  /// Search for tracks, artists, albums, or playlists
  Future<Map<String, dynamic>> search(
    String query, {
    String type =
        'track,artist,album,playlist', // Can be 'track', 'artist', 'album', 'playlist'
    int limit = 20,
  }) async {
    try {
      await _authService.ensureValidToken();
      final response = await _httpClient.get(
        '$spotifyApiBaseUrl/search',
        queryParameters: {
          'q': query,
          'type': type,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching: $e');
    }
  }

  /// Get album details with tracks
  Future<Map<String, dynamic>> getAlbum(String albumId) async {
    try {
      await _authService.ensureValidToken();
      final response =
          await _httpClient.get('$spotifyApiBaseUrl/albums/$albumId');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch album: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching album: $e');
    }
  }

  /// Get artist details
  Future<Map<String, dynamic>> getArtist(String artistId) async {
    try {
      await _authService.ensureValidToken();
      final response =
          await _httpClient.get('$spotifyApiBaseUrl/artists/$artistId');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch artist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching artist: $e');
    }
  }

  /// Get artist's top tracks
  Future<List<Map<String, dynamic>>> getArtistTopTracks(String artistId,
      {String market = 'US'}) async {
    try {
      await _authService.ensureValidToken();
      final response = await _httpClient.get(
        '$spotifyApiBaseUrl/artists/$artistId/top-tracks',
        queryParameters: {'market': market},
      );

      if (response.statusCode == 200) {
        final tracks = response.data['tracks'] as List;
        return tracks.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Failed to fetch artist top tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching artist top tracks: $e');
    }
  }

  /// Get playlist details with tracks
  Future<Map<String, dynamic>> getPlaylist(String playlistId) async {
    try {
      await _authService.ensureValidToken();
      final response =
          await _httpClient.get('$spotifyApiBaseUrl/playlists/$playlistId');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch playlist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching playlist: $e');
    }
  }

  /// Get track details
  Future<Map<String, dynamic>> getTrack(String trackId) async {
    try {
      await _authService.ensureValidToken();
      final response =
          await _httpClient.get('$spotifyApiBaseUrl/tracks/$trackId');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch track: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching track: $e');
    }
  }

  /// Add track to user's library
  Future<void> saveTrack(String trackId) async {
    try {
      await _authService.ensureValidToken();
      final response = await _httpClient.put(
        '$spotifyApiBaseUrl/me/tracks',
        data: {
          'ids': [trackId]
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save track: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saving track: $e');
    }
  }

  /// Remove track from user's library
  Future<void> removeTrack(String trackId) async {
    try {
      await _authService.ensureValidToken();
      final response = await _httpClient.delete(
        '$spotifyApiBaseUrl/me/tracks',
        queryParameters: {'ids': trackId},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to remove track: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error removing track: $e');
    }
  }

  /// Get user's saved tracks
  Future<List<Map<String, dynamic>>> getSavedTracks(
      {int limit = 20, int offset = 0}) async {
    try {
      await _authService.ensureValidToken();
      final response = await _httpClient.get(
        '$spotifyApiBaseUrl/me/tracks',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      if (response.statusCode == 200) {
        final items = response.data['items'] as List;
        return items.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch saved tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching saved tracks: $e');
    }
  }

  /// Get artist's albums
  Future<Map<String, dynamic>> getArtistAlbums(String artistId,
      {int limit = 20, int offset = 0}) async {
    try {
      await _authService.ensureValidToken();
      final response = await _httpClient.get(
        '$spotifyApiBaseUrl/artists/$artistId/albums',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to fetch artist albums: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching artist albums: $e');
    }
  }
}
