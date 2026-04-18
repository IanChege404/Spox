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
  /// Featured playlists is a public endpoint - authentication is optional/unnecessary
  Future<List<Map<String, dynamic>>> getFeaturedPlaylists(
      {int limit = 20}) async {
    try {
      // Featured playlists is PUBLIC - don't require auth (works on free plan)
      // Token will be sent if available, but not required
      final response = await _httpClient.get(
        '$spotifyApiBaseUrl/browse/featured-playlists',
        queryParameters: {'limit': limit, 'country': 'US'},
      );

      if (response.statusCode == 200) {
        final items = response.data['playlists']['items'] as List;
        print(
            '[API] ✓ Fetched ${items.length} featured playlists from Spotify');
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 403) {
        print(
            '[API] 403 Forbidden - Premium subscription required, using mock playlists');
        return _getMockFeaturedPlaylists();
      } else {
        throw Exception(
            'Failed to fetch featured playlists: ${response.statusCode}');
      }
    } catch (e) {
      print(
          '[API] Error fetching featured playlists, falling back to mock data: $e');
      return _getMockFeaturedPlaylists();
    }
  }

  /// Mock featured playlists for fallback when API fails or requires Premium
  List<Map<String, dynamic>> _getMockFeaturedPlaylists() {
    return [
      {
        'id': 'mock_pop_hits_1',
        'name': 'Pop Hits',
        'description': 'Today\'s top pop tracks and trending songs',
        'images': [
          {
            'url': 'https://via.placeholder.com/300?text=Pop+Hits',
            'height': 300,
            'width': 300,
          }
        ],
        'tracks': {'total': 50},
        'owner': {'display_name': 'Spotify'}
      },
      {
        'id': 'mock_new_music_2',
        'name': 'New Music Daily',
        'description': 'A fresh mix of new releases from all genres',
        'images': [
          {
            'url': 'https://via.placeholder.com/300?text=New+Music',
            'height': 300,
            'width': 300,
          }
        ],
        'tracks': {'total': 75},
        'owner': {'display_name': 'Spotify'}
      },
      {
        'id': 'mock_chill_3',
        'name': 'Chill Vibes',
        'description': 'Relax and unwind with smooth, ambient tracks',
        'images': [
          {
            'url': 'https://via.placeholder.com/300?text=Chill+Vibes',
            'height': 300,
            'width': 300,
          }
        ],
        'tracks': {'total': 60},
        'owner': {'display_name': 'Spotify'}
      },
      {
        'id': 'mock_workout_4',
        'name': 'Workout Mix',
        'description': 'High-energy tracks to pump you up',
        'images': [
          {
            'url': 'https://via.placeholder.com/300?text=Workout',
            'height': 300,
            'width': 300,
          }
        ],
        'tracks': {'total': 55},
        'owner': {'display_name': 'Spotify'}
      },
    ];
  }

  /// Get browse categories (public endpoint)
  /// This is a PUBLIC endpoint - works for guests without authentication
  Future<List<Map<String, dynamic>>> getBrowseCategories(
      {int limit = 20, int offset = 0}) async {
    try {
      final response = await _httpClient.get(
        '$spotifyApiBaseUrl/browse/categories',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          'country': 'US',
        },
      );

      if (response.statusCode == 200) {
        final items = response.data['categories']['items'] as List;
        print('[API] ✓ Fetched ${items.length} browse categories from Spotify');
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 403) {
        print('[API] 403 Forbidden for categories, using mock data');
        return _getMockBrowseCategories();
      } else {
        throw Exception('Failed to fetch categories: ${response.statusCode}');
      }
    } catch (e) {
      print('[API] Error fetching categories, falling back to mock data: $e');
      return _getMockBrowseCategories();
    }
  }

  /// Mock browse categories for fallback
  List<Map<String, dynamic>> _getMockBrowseCategories() {
    return [
      {
        'id': 'pop',
        'name': 'Pop',
        'description': 'The latest pop hits',
        'icons': [
          {
            'url': 'https://via.placeholder.com/300?text=Pop',
            'height': 300,
            'width': 300
          }
        ]
      },
      {
        'id': 'rock',
        'name': 'Rock',
        'description': 'Rock music from all eras',
        'icons': [
          {
            'url': 'https://via.placeholder.com/300?text=Rock',
            'height': 300,
            'width': 300
          }
        ]
      },
      {
        'id': 'hiphop',
        'name': 'Hip-Hop',
        'description': 'The best of hip-hop culture',
        'icons': [
          {
            'url': 'https://via.placeholder.com/300?text=Hip-Hop',
            'height': 300,
            'width': 300
          }
        ]
      },
      {
        'id': 'latin',
        'name': 'Latin',
        'description': 'Latin hits and classics',
        'icons': [
          {
            'url': 'https://via.placeholder.com/300?text=Latin',
            'height': 300,
            'width': 300
          }
        ]
      },
    ];
  }

  /// Mock category playlists for fallback
  List<Map<String, dynamic>> _getMockCategoryPlaylists(String categoryId) {
    return [
      {
        'id': 'mock_cat_${categoryId}_1',
        'name': 'Top Charts',
        'description': 'The top songs in this category',
        'images': [
          {
            'url': 'https://via.placeholder.com/300?text=Top+Charts',
            'height': 300,
            'width': 300
          }
        ],
        'tracks': {'total': 50},
        'owner': {'display_name': 'Spotify'}
      },
      {
        'id': 'mock_cat_${categoryId}_2',
        'name': 'New Releases',
        'description': 'Latest releases in this category',
        'images': [
          {
            'url': 'https://via.placeholder.com/300?text=New+Releases',
            'height': 300,
            'width': 300
          }
        ],
        'tracks': {'total': 40},
        'owner': {'display_name': 'Spotify'}
      },
    ];
  }

  /// Search for tracks, artists, albums, or playlists
  /// Search is a public endpoint - authentication is optional
  Future<Map<String, dynamic>> search(
    String query, {
    String type =
        'track,artist,album,playlist', // Can be 'track', 'artist', 'album', 'playlist'
    int limit = 20,
  }) async {
    try {
      // Search is public - auth is optional
      await _authService.ensureValidToken(optional: true);
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
      } else if (response.statusCode == 403) {
        print('[API] 403 Search requires Premium, returning empty results');
        return {
          'tracks': {'items': []},
          'artists': {'items': []},
          'albums': {'items': []},
          'playlists': {'items': []}
        };
      } else {
        throw Exception('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      print('[API] Error searching: $e');
      // Return empty results on error for guest mode
      return {
        'tracks': {'items': []},
        'artists': {'items': []},
        'albums': {'items': []},
        'playlists': {'items': []}
      };
    }
  }

  /// Get album details with tracks
  /// Albums are public endpoints - authentication is optional
  Future<Map<String, dynamic>> getAlbum(String albumId) async {
    try {
      // Albums are public - auth is optional
      await _authService.ensureValidToken(optional: true);
      final response =
          await _httpClient.get('$spotifyApiBaseUrl/albums/$albumId');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else if (response.statusCode == 403) {
        print('[API] 403 Album requires Premium, using mock data');
        return _getMockAlbum(albumId);
      } else {
        throw Exception('Failed to fetch album: ${response.statusCode}');
      }
    } catch (e) {
      print('[API] Error fetching album, using mock data: $e');
      return _getMockAlbum(albumId);
    }
  }

  /// Get artist details
  /// Artists are public endpoints - authentication is optional
  Future<Map<String, dynamic>> getArtist(String artistId) async {
    try {
      // Artists are public - auth is optional
      await _authService.ensureValidToken(optional: true);
      final response =
          await _httpClient.get('$spotifyApiBaseUrl/artists/$artistId');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else if (response.statusCode == 403) {
        print('[API] 403 Artist requires Premium, using mock data');
        return _getMockArtist(artistId);
      } else {
        throw Exception('Failed to fetch artist: ${response.statusCode}');
      }
    } catch (e) {
      print('[API] Error fetching artist, using mock data: $e');
      return _getMockArtist(artistId);
    }
  }

  /// Get artist's top tracks
  /// Artist top tracks are public endpoints - authentication is optional
  Future<List<Map<String, dynamic>>> getArtistTopTracks(String artistId,
      {String market = 'US'}) async {
    try {
      // Artist top tracks are public - auth is optional
      await _authService.ensureValidToken(optional: true);
      final response = await _httpClient.get(
        '$spotifyApiBaseUrl/artists/$artistId/top-tracks',
        queryParameters: {'market': market},
      );

      if (response.statusCode == 200) {
        final tracks = response.data['tracks'] as List;
        return tracks.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 403) {
        print('[API] 403 Artist top tracks requires Premium, using mock data');
        return _getMockArtistTopTracks(artistId);
      } else {
        throw Exception(
            'Failed to fetch artist top tracks: ${response.statusCode}');
      }
    } catch (e) {
      print('[API] Error fetching artist top tracks, using mock data: $e');
      return _getMockArtistTopTracks(artistId);
    }
  }

  /// Get playlist details with tracks
  /// Public playlists are accessible without authentication
  Future<Map<String, dynamic>> getPlaylist(String playlistId) async {
    try {
      // Playlists are public - auth is optional
      await _authService.ensureValidToken(optional: true);
      final response =
          await _httpClient.get('$spotifyApiBaseUrl/playlists/$playlistId');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else if (response.statusCode == 403) {
        print('[API] 403 Playlist requires Premium, using mock data');
        return _getMockPlaylist(playlistId);
      } else {
        throw Exception('Failed to fetch playlist: ${response.statusCode}');
      }
    } catch (e) {
      print('[API] Error fetching playlist, using mock data: $e');
      return _getMockPlaylist(playlistId);
    }
  }

  /// Get playlist tracks with pagination
  /// Public playlists are accessible without authentication
  Future<List<Map<String, dynamic>>> getPlaylistTracks(
    String playlistId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      await _authService.ensureValidToken(optional: true);
      final response = await _httpClient.get(
        '$spotifyApiBaseUrl/playlists/$playlistId/tracks',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          'market': 'US',
        },
      );

      if (response.statusCode == 200) {
        final items = (response.data['items'] as List?) ?? [];
        return items
            .map((item) => (item as Map<String, dynamic>)['track'])
            .whereType<Map<String, dynamic>>()
            .toList();
      } else if (response.statusCode == 403) {
        print('[API] 403 Playlist tracks requires Premium, using mock data');
        return [
          _getMockTrack('track_${playlistId}_1'),
          _getMockTrack('track_${playlistId}_2'),
        ];
      } else {
        throw Exception(
            'Failed to fetch playlist tracks: ${response.statusCode}');
      }
    } catch (e) {
      print('[API] Error fetching playlist tracks, using mock data: $e');
      return [
        _getMockTrack('track_${playlistId}_1'),
        _getMockTrack('track_${playlistId}_2'),
      ];
    }
  }

  /// Get track details
  /// Tracks are public endpoints - authentication is optional
  Future<Map<String, dynamic>> getTrack(String trackId) async {
    try {
      // Tracks are public - auth is optional
      await _authService.ensureValidToken(optional: true);
      final response =
          await _httpClient.get('$spotifyApiBaseUrl/tracks/$trackId');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else if (response.statusCode == 403) {
        print('[API] 403 Track requires Premium, using mock data');
        return _getMockTrack(trackId);
      } else {
        throw Exception('Failed to fetch track: ${response.statusCode}');
      }
    } catch (e) {
      print('[API] Error fetching track, using mock data: $e');
      return _getMockTrack(trackId);
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
  /// Artist albums are public endpoints - authentication is optional
  Future<Map<String, dynamic>> getArtistAlbums(String artistId,
      {int limit = 20, int offset = 0}) async {
    try {
      // Artist albums are public - auth is optional
      await _authService.ensureValidToken(optional: true);
      final response = await _httpClient.get(
        '$spotifyApiBaseUrl/artists/$artistId/albums',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else if (response.statusCode == 403) {
        print('[API] 403 Artist albums requires Premium, using mock data');
        return _getMockArtistAlbums(artistId);
      } else {
        throw Exception(
            'Failed to fetch artist albums: ${response.statusCode}');
      }
    } catch (e) {
      print('[API] Error fetching artist albums, using mock data: $e');
      return _getMockArtistAlbums(artistId);
    }
  }

  /// Get new releases (albums and singles)
  /// Public endpoint - authentication is optional
  Future<Map<String, dynamic>> getNewReleases(
      {int limit = 20, int offset = 0}) async {
    try {
      await _authService.ensureValidToken(optional: true);
      final response = await _httpClient.get(
        '$spotifyApiBaseUrl/browse/new-releases',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else if (response.statusCode == 403) {
        print('[API] 403 - Using empty new releases');
        return {
          'albums': {'items': []}
        };
      } else {
        throw Exception('Failed to fetch new releases: ${response.statusCode}');
      }
    } catch (e) {
      print('[API] Error fetching new releases: $e');
      return {
        'albums': {'items': []}
      };
    }
  }

  /// Get recommendations based on seed tracks/artists/genres
  /// Public endpoint - authentication is optional
  Future<List<Map<String, dynamic>>> getRecommendations({
    List<String>? seedArtists,
    List<String>? seedGenres,
    List<String>? seedTracks,
    int limit = 20,
    String? market,
  }) async {
    try {
      await _authService.ensureValidToken(optional: true);

      // Need at least 1 seed (limit 5 total)
      final seeds = [...?seedArtists, ...?seedGenres, ...?seedTracks];
      if (seeds.isEmpty) {
        seedGenres = ['pop', 'rock', 'hip-hop']; // Default seeds
      } else if (seeds.length > 5) {
        throw Exception('Maximum 5 seeds allowed (artists + genres + tracks)');
      }

      final queryParams = <String, dynamic>{'limit': limit};
      if (seedArtists != null && seedArtists.isNotEmpty) {
        queryParams['seed_artists'] = seedArtists.join(',');
      }
      if (seedGenres != null && seedGenres.isNotEmpty) {
        queryParams['seed_genres'] = seedGenres.join(',');
      }
      if (seedTracks != null && seedTracks.isNotEmpty) {
        queryParams['seed_tracks'] = seedTracks.join(',');
      }
      if (market != null) {
        queryParams['market'] = market;
      }

      final response = await _httpClient.get(
        '$spotifyApiBaseUrl/recommendations',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final items = response.data['tracks'] as List;
        return items.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Failed to fetch recommendations: ${response.statusCode}');
      }
    } catch (e) {
      print('[API] Error fetching recommendations: $e');
      return [];
    }
  }

  /// Get available genre seeds for recommendations
  /// Public endpoint - authentication is optional
  Future<List<String>> getAvailableGenreSeeds() async {
    try {
      await _authService.ensureValidToken(optional: true);
      final response = await _httpClient.get(
        '$spotifyApiBaseUrl/recommendations/available-genre-seeds',
      );

      if (response.statusCode == 200) {
        final genres = response.data['genres'] as List;
        return genres.cast<String>();
      } else {
        throw Exception('Failed to fetch genre seeds: ${response.statusCode}');
      }
    } catch (e) {
      print('[API] Error fetching genre seeds: $e');
      // Return popular genres as fallback
      return [
        'pop',
        'rock',
        'hip-hop',
        'r-n-b',
        'indie',
        'electronic',
        'classical',
        'country'
      ];
    }
  }

  /// Get all browse categories
  /// Public endpoint - authentication is optional
  Future<List<Map<String, dynamic>>> getCategories(
      {int limit = 20, int offset = 0}) async {
    try {
      await _authService.ensureValidToken(optional: true);
      final response = await _httpClient.get(
        '$spotifyApiBaseUrl/browse/categories',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      if (response.statusCode == 200) {
        final items = response.data['categories']['items'] as List;
        return items.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch categories: ${response.statusCode}');
      }
    } catch (e) {
      print('[API] Error fetching categories: $e');
      return [];
    }
  }

  /// Get playlists for a specific category
  /// Public endpoint - authentication is optional
  Future<List<Map<String, dynamic>>> getCategoryPlaylists(
    String categoryId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      await _authService.ensureValidToken(optional: true);
      final response = await _httpClient.get(
        '$spotifyApiBaseUrl/browse/categories/$categoryId/playlists',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          'country': 'US',
        },
      );

      if (response.statusCode == 200) {
        final items = response.data['playlists']['items'] as List;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 403) {
        print('[API] 403 Forbidden for category playlists, using mock data');
        return _getMockCategoryPlaylists(categoryId);
      } else {
        throw Exception(
            'Failed to fetch category playlists: ${response.statusCode}');
      }
    } catch (e) {
      print(
          '[API] Error fetching category playlists, falling back to mock data: $e');
      return _getMockCategoryPlaylists(categoryId);
    }
  }

  // =========================================
  // Mock Data Generators (for free tier fallback)
  // =========================================

  /// Generate mock album data when API fails or requires Premium
  Map<String, dynamic> _getMockAlbum(String albumId) {
    return {
      'id': albumId,
      'name': 'Album (Preview Mode)',
      'artists': [
        {
          'id': 'artist_0',
          'name': 'Artist',
          'external_urls': {'spotify': 'https://open.spotify.com/artist/0'},
        }
      ],
      'release_date': '2024-01-01',
      'total_tracks': 12,
      'external_urls': {'spotify': 'https://open.spotify.com/album/$albumId'},
      'images': [
        {
          'url': 'https://via.placeholder.com/300?text=Album',
          'height': 300,
          'width': 300,
        }
      ],
      'tracks': {
        'items': [
          _getMockTrack('track_$albumId\_1'),
          _getMockTrack('track_$albumId\_2'),
        ]
      }
    };
  }

  /// Generate mock artist data when API fails or requires Premium
  Map<String, dynamic> _getMockArtist(String artistId) {
    return {
      'id': artistId,
      'name': 'Artist (Preview Mode)',
      'followers': {'total': 1000},
      'genres': ['pop', 'electronic'],
      'popularity': 65,
      'external_urls': {'spotify': 'https://open.spotify.com/artist/$artistId'},
      'images': [
        {
          'url': 'https://via.placeholder.com/300?text=Artist',
          'height': 300,
          'width': 300,
        }
      ],
    };
  }

  /// Generate mock artist top tracks when API fails or requires Premium
  List<Map<String, dynamic>> _getMockArtistTopTracks(String artistId) {
    return [
      _getMockTrack('track_${artistId}_top_1'),
      _getMockTrack('track_${artistId}_top_2'),
      _getMockTrack('track_${artistId}_top_3'),
    ];
  }

  /// Generate mock playlist data when API fails or requires Premium
  Map<String, dynamic> _getMockPlaylist(String playlistId) {
    return {
      'id': playlistId,
      'name': 'Playlist (Preview Mode)',
      'description': 'This is a preview playlist',
      'owner': {
        'display_name': 'Spotify',
        'external_urls': {'spotify': 'https://open.spotify.com/user/spotify'}
      },
      'tracks': {
        'total': 50,
        'items': [
          {'track': _getMockTrack('track_$playlistId\_1')},
          {'track': _getMockTrack('track_$playlistId\_2')},
        ]
      },
      'external_urls': {
        'spotify': 'https://open.spotify.com/playlist/$playlistId'
      },
      'images': [
        {
          'url': 'https://via.placeholder.com/300?text=Playlist',
          'height': 300,
          'width': 300,
        }
      ],
    };
  }

  /// Generate mock track data when API fails or requires Premium
  Map<String, dynamic> _getMockTrack(String trackId) {
    return {
      'id': trackId,
      'name': 'Track (Preview Mode)',
      'artists': [
        {
          'id': 'artist_0',
          'name': 'Artist',
          'external_urls': {'spotify': 'https://open.spotify.com/artist/0'}
        }
      ],
      'album': {
        'id': 'album_0',
        'name': 'Album',
        'images': [
          {
            'url': 'https://via.placeholder.com/300?text=Track',
            'height': 300,
            'width': 300,
          }
        ],
        'external_urls': {'spotify': 'https://open.spotify.com/album/album_0'}
      },
      'duration_ms': 180000,
      'explicit': false,
      'preview_url': null,
      'popular': 70,
      'external_urls': {'spotify': 'https://open.spotify.com/track/$trackId'},
      'is_playable': false,
    };
  }

  /// Generate mock artist albums when API fails or requires Premium
  Map<String, dynamic> _getMockArtistAlbums(String artistId) {
    return {
      'items': [
        _getMockAlbum('album_${artistId}_1'),
        _getMockAlbum('album_${artistId}_2'),
      ],
      'total': 2,
      'limit': 20,
      'offset': 0,
    };
  }
}
