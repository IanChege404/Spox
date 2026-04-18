import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotify_clone/data/model/spotify_models.dart';
import 'package:spotify_clone/data/model/podcast.dart';

/// Firestore data source for static app data
/// Handles fetching playlists, artists, podcasts, and home screen configuration
class FirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreDataSource(this._firestore, {FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  // ============================================================================
  // PLAYLISTS
  // ============================================================================

  /// Fetch all playlists from Firestore
  /// Collection: playlists/
  /// Returns empty list if user is not authenticated (Firestore rules require auth)
  Future<List<SpotifyPlaylist>> fetchPlaylists() async {
    try {
      // Check if user is authenticated - Firestore security rules typically require this
      if (_auth.currentUser == null) {
        print(
            '[FirestoreDataSource] User not authenticated - skipping Firestore fetch for playlists');
        return [];
      }

      final snapshot = await _firestore.collection('playlists').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SpotifyPlaylist(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          imageUrl: data['coverUrl'] ?? '',
          trackCount: data['trackCount'] ?? 0,
          ownerName: data['ownerName'] ?? 'Spotify',
        );
      }).toList();
    } catch (e) {
      print('Error fetching playlists from Firestore: $e');
      rethrow;
    }
  }

  /// Fetch a single playlist with its tracks
  Future<List<SpotifyTrack>> fetchPlaylistTracks(String playlistId) async {
    try {
      // Check if user is authenticated before attempting Firestore read
      if (_auth.currentUser == null) {
        print(
            '[FirestoreDataSource] User not authenticated - skipping Firestore fetch for playlist tracks');
        return [];
      }

      final snapshot = await _firestore
          .collection('playlists')
          .doc(playlistId)
          .collection('tracks')
          .orderBy('position')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Parse artists list from Firestore
        final artistsList = (data['artists'] as List? ?? [])
            .map((a) => a is Map
                ? SpotifyArtist.fromJson(a as Map<String, dynamic>)
                : null)
            .whereType<SpotifyArtist>()
            .toList();

        return SpotifyTrack(
          id: data['spotifyId'] ?? '',
          name: data['trackName'] ?? '',
          artists: artistsList,
          imageUrl: data['albumArt'] ?? '',
          durationMs: data['durationMs'] ?? 0,
          previewUrl: data['previewUrl'],
          popularity: data['popularity'] ?? 0,
        );
      }).toList();
    } catch (e) {
      print('Error fetching playlist tracks from Firestore: $e');
      rethrow;
    }
  }

  // ============================================================================
  // ARTISTS
  // ============================================================================

  /// Fetch all artists from Firestore
  /// Collection: artists/
  /// Returns empty list if user is not authenticated
  Future<List<SpotifyArtist>> fetchArtists() async {
    try {
      // Check if user is authenticated before attempting Firestore read
      if (_auth.currentUser == null) {
        print(
            '[FirestoreDataSource] User not authenticated - skipping Firestore fetch for artists');
        return [];
      }

      final snapshot = await _firestore.collection('artists').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SpotifyArtist(
          id: doc.id,
          name: data['name'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          genres: List<String>.from(data['genres'] ?? []),
          followers: data['followers'] ?? 0,
          popularity: data['popularity'] ?? 0,
        );
      }).toList();
    } catch (e) {
      print('Error fetching artists from Firestore: $e');
      rethrow;
    }
  }

  // ============================================================================
  // PODCASTS
  // ============================================================================

  /// Fetch all podcasts from Firestore
  /// Collection: podcasts/
  /// Returns empty list if user is not authenticated
  Future<List<Podcast>> fetchPodcasts() async {
    try {
      // Check if user is authenticated before attempting Firestore read
      if (_auth.currentUser == null) {
        print(
            '[FirestoreDataSource] User not authenticated - skipping Firestore fetch for podcasts');
        return [];
      }

      final snapshot = await _firestore.collection('podcasts').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Podcast(
          data['coverUrl'] ?? '',
          data['name'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error fetching podcasts from Firestore: $e');
      rethrow;
    }
  }

  // ============================================================================
  // HOME SCREEN CONFIGURATION
  // ============================================================================

  /// Fetch home screen section configuration
  /// Collection: config/homeScreenSections
  Future<Map<String, dynamic>> fetchHomeScreenConfig() async {
    try {
      final doc =
          await _firestore.collection('config').doc('homeScreenSections').get();
      if (!doc.exists) {
        return _getDefaultHomeConfig();
      }
      return doc.data() ?? _getDefaultHomeConfig();
    } catch (e) {
      print('Error fetching home screen config: $e');
      return _getDefaultHomeConfig();
    }
  }

  /// Default home screen configuration (fallback)
  Map<String, dynamic> _getDefaultHomeConfig() {
    return {
      'topMixes': [
        {'title': '2010s Mix', 'playlistId': '2010s'},
        {'title': 'Chill Mix', 'playlistId': 'chill'},
        {'title': 'Upbeat Mix', 'playlistId': 'upbeat'},
        {'title': 'Drake Mix', 'playlistId': 'drake-mix'},
      ],
      'recentPlays': [
        'american-dream',
        'utopia',
        'liked-songs',
      ],
    };
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Check if a specific collection exists and has data
  Future<bool> collectionHasData(String collectionName) async {
    try {
      final snapshot =
          await _firestore.collection(collectionName).limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get collection metadata (count, lastUpdated)
  Future<Map<String, dynamic>> getCollectionMetadata(
      String collectionName) async {
    try {
      final doc =
          await _firestore.collection('metadata').doc(collectionName).get();
      if (!doc.exists) {
        return {
          'count': 0,
          'lastUpdated': DateTime.now().toIso8601String(),
        };
      }
      return doc.data() ?? {};
    } catch (e) {
      return {};
    }
  }
}
