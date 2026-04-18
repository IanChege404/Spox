import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spotify_clone/data/model/artist.dart';
import '../firebase_options.dart';

/// Firebase Service for authentication and data synchronization
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  static const String _likedSongsCollection = 'liked_songs';
  static const String _legacyLikedSongsCollection = 'likedSongs';
  static const String _recentlyPlayedCollection = 'recently_played';
  static const String _legacyPlayHistoryCollection = 'playHistory';

  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  late FirebaseAnalytics _analytics;
  late FirebaseStorage _storage;
  late GoogleSignIn _googleSignIn;
  bool _isInitialized = false;

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  /// Check if Firebase has been fully initialized
  bool get isInitialized => _isInitialized;

  /// Initialize Firebase
  Future<void> initialize() async {
    try {
      // Check if Firebase is already initialized
      try {
        Firebase.app();
        print(
            '[FirebaseService] Firebase already initialized, reusing existing instance');
      } catch (e) {
        // Firebase not yet initialized, proceed with initialization
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        print('[FirebaseService] ✓ Firebase.initializeApp() completed');
      }

      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _analytics = FirebaseAnalytics.instance;
      _storage = FirebaseStorage.instance;
      _googleSignIn = GoogleSignIn();
      
      // Mark initialization as complete - critical for service_locator to know Firebase is ready
      _isInitialized = true;
      print('[FirebaseService] ✓ Firebase services initialized successfully');
    } catch (e) {
      print('[FirebaseService] ✗ Error in Firebase initialization: $e');
      rethrow;
    }
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Google sign-in cancelled');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      await _analytics.setUserId(id: userCredential.user?.uid);
      await _analytics.logLogin(loginMethod: 'google');

      // Create user document in Firestore if it doesn't exist
      await _createUserDocument(userCredential.user!);

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _analytics.setUserId(id: userCredential.user?.uid);
      await _analytics.logLogin(loginMethod: 'email');

      // Create user document if it doesn't exist
      await _createUserDocument(userCredential.user!);

      return userCredential;
    } catch (e) {
      print('Error signing in with email: $e');
      rethrow;
    }
  }

  /// Register with email and password
  Future<UserCredential> registerWithEmailPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _analytics.setUserId(id: userCredential.user?.uid);
      await _analytics.logSignUp(signUpMethod: 'email');

      // Update display name
      await userCredential.user!.updateDisplayName(displayName);

      // Create user document
      await _createUserDocument(userCredential.user!);

      return userCredential;
    } catch (e) {
      print('Error registering with email: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _analytics.setUserId();
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  /// Create or update user document in Firestore
  Future<void> _createUserDocument(User user) async {
    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      final doc = await userRef.get();

      if (!doc.exists) {
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? 'User',
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error creating user document: $e');
      rethrow;
    }
  }

  /// Add a liked song to Firestore
  Future<void> addLikedSong({
    required String spotifyId,
    required String title,
    required String artist,
    required String albumArt,
  }) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection(_likedSongsCollection)
          .doc(spotifyId)
          .set({
        'spotifyId': spotifyId,
        'title': title,
        'artist': artist,
        'albumArt': albumArt,
        'likedAt': FieldValue.serverTimestamp(),
      });

      // Mirror to legacy collection while the app migrates to the new schema.
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection(_legacyLikedSongsCollection)
          .doc(spotifyId)
          .set({
        'spotifyId': spotifyId,
        'title': title,
        'artist': artist,
        'albumArt': albumArt,
        'likedAt': FieldValue.serverTimestamp(),
      });

      await _analytics.logEvent(
        name: 'liked_song_added',
        parameters: {
          'spotify_id': spotifyId,
          'title': title,
          'artist': artist,
        },
      );
    } catch (e) {
      print('Error adding liked song: $e');
      rethrow;
    }
  }

  /// Remove a liked song from Firestore
  Future<void> removeLikedSong(String spotifyId) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection(_likedSongsCollection)
          .doc(spotifyId)
          .delete();

        await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection(_legacyLikedSongsCollection)
          .doc(spotifyId)
          .delete();

      await _analytics.logEvent(
        name: 'liked_song_removed',
        parameters: {
          'spotify_id': spotifyId,
        },
      );
    } catch (e) {
      print('Error removing liked song: $e');
      rethrow;
    }
  }

  /// Get stream of liked songs from Firestore
  Stream<List<Map<String, dynamic>>> getLikedSongsStream() {
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
      .collection(_likedSongsCollection)
        .orderBy('likedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Check if a song is liked
  Future<bool> isLiked(String spotifyId) async {
    try {
      if (currentUser == null) {
        return false;
      }

      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection(_likedSongsCollection)
          .doc(spotifyId)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error checking if song is liked: $e');
      return false;
    }
  }

  /// Sync liked songs from local Hive to Firestore
  Future<void> syncLikedSongsToFirebase(
    List<Map<String, dynamic>> likedSongs,
  ) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final batch = _firestore.batch();
      final userRef = _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection(_likedSongsCollection);

      for (final song in likedSongs) {
        batch.set(userRef.doc(song['spotifyId']), {
          'spotifyId': song['spotifyId'],
          'title': song['title'],
          'artist': song['artist'],
          'albumArt': song['albumArt'],
          'likedAt': FieldValue.serverTimestamp(),
        });

        batch.set(
          _firestore
              .collection('users')
              .doc(currentUser!.uid)
              .collection(_legacyLikedSongsCollection)
              .doc(song['spotifyId']),
          {
            'spotifyId': song['spotifyId'],
            'title': song['title'],
            'artist': song['artist'],
            'albumArt': song['albumArt'],
            'likedAt': FieldValue.serverTimestamp(),
          },
        );
      }

      await batch.commit();
    } catch (e) {
      print('Error syncing liked songs: $e');
      rethrow;
    }
  }

  /// Save selected artists to the user preferences/artists collection.
  Future<void> saveArtistPreferences(List<Artist> artists) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final preferencesRef = _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('preferences')
          .doc('artists')
          .collection('items');

      final batch = _firestore.batch();

      // Replace the collection so the latest onboarding choices win.
      final existing = await preferencesRef.get();
      for (final doc in existing.docs) {
        batch.delete(doc.reference);
      }

      for (final artist in artists) {
        final artistId = _slugify(artist.artistName ?? 'artist');
        batch.set(preferencesRef.doc(artistId), {
          'artistId': artistId,
          'artistName': artist.artistName,
          'artistImage': artist.artistImage,
          'selectedAt': FieldValue.serverTimestamp(),
          'source': 'onboarding',
        });
      }

      await batch.commit();

      // Keep a simple summary document for quick reads.
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('preferences')
          .doc('summary')
          .set({
        'selectedArtistCount': artists.length,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _analytics.logEvent(
        name: 'artist_preferences_saved',
        parameters: {'selected_count': artists.length},
      );
    } catch (e) {
      print('Error saving artist preferences: $e');
      rethrow;
    }
  }

  /// Load the user's selected artists from Firestore.
  Future<List<Map<String, dynamic>>> getArtistPreferences() async {
    try {
      if (currentUser == null) {
        return [];
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('preferences')
          .doc('artists')
          .collection('items')
          .orderBy('selectedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error loading artist preferences: $e');
      return [];
    }
  }

  /// Track a song play for analytics
  Future<void> recordSongPlay({
    required String spotifyId,
    required String title,
    required String artist,
    required Duration duration,
  }) async {
    try {
      if (currentUser == null) {
        return;
      }

      final playData = {
        'spotifyId': spotifyId,
        'title': title,
        'artist': artist,
        'duration': duration.inSeconds,
        'playedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('playHistory')
          .doc()
          .set(playData);

      // New schema-compliant recently played collection
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection(_recentlyPlayedCollection)
          .doc()
          .set({
        ...playData,
        'source': 'audio_player',
      });

        // Keep the legacy playHistory collection in sync during migration.
        await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection(_legacyPlayHistoryCollection)
          .doc()
          .set(playData);

      await _analytics.logEvent(
        name: 'song_played',
        parameters: {
          'spotify_id': spotifyId,
          'title': title,
          'artist': artist,
          'duration_seconds': duration.inSeconds,
        },
      );
    } catch (e) {
      print('Error recording song play: $e');
      // Don't rethrow - analytics failure shouldn't affect app functionality
    }
  }

  String _slugify(String input) {
    final slug = input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return slug.isEmpty ? 'artist' : slug;
  }

  /// Get user's play history
  Stream<List<Map<String, dynamic>>> getPlayHistoryStream({
    int limit = 100,
  }) {
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
      .collection(_recentlyPlayedCollection)
        .orderBy('playedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Create or update a user playlist in Firestore
  Future<void> upsertUserPlaylist({
    required String playlistId,
    required String name,
    String? description,
    String? imageUrl,
  }) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('playlists')
          .doc(playlistId)
          .set({
        'playlistId': playlistId,
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _analytics.logEvent(
        name: 'playlist_upserted',
        parameters: {
          'playlist_id': playlistId,
          'name': name,
        },
      );
    } catch (e) {
      print('Error upserting playlist: $e');
      rethrow;
    }
  }

  /// Remove a user playlist from Firestore
  Future<void> removeUserPlaylist(String playlistId) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('playlists')
          .doc(playlistId)
          .delete();

      await _analytics.logEvent(
        name: 'playlist_removed',
        parameters: {'playlist_id': playlistId},
      );
    } catch (e) {
      print('Error removing playlist: $e');
      rethrow;
    }
  }

  /// Stream user playlists from Firestore
  Stream<List<Map<String, dynamic>>> getUserPlaylistsStream() {
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('playlists')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Sync local playlists to Firestore in batch
  Future<void> syncUserPlaylistsToFirebase(
    List<Map<String, dynamic>> playlists,
  ) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final batch = _firestore.batch();
      final playlistsRef = _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('playlists');

      for (final playlist in playlists) {
        final playlistId = playlist['playlistId'] ?? playlist['id'];
        if (playlistId == null) continue;
        batch.set(playlistsRef.doc(playlistId.toString()), {
          ...playlist,
          'playlistId': playlistId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
      await _analytics.logEvent(
        name: 'playlists_synced',
        parameters: {'count': playlists.length},
      );
    } catch (e) {
      print('Error syncing playlists: $e');
      rethrow;
    }
  }

  /// Upload a local file to Firebase Storage and return public download URL
  Future<String> uploadTrackFile({
    required String localFilePath,
    required String fileName,
  }) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final ref = _storage
          .ref()
          .child('users')
          .child(currentUser!.uid)
          .child('tracks')
          .child(fileName);

        final task = await ref.putFile(File(localFilePath));

      final url = await task.ref.getDownloadURL();
      await _analytics.logEvent(
        name: 'track_uploaded',
        parameters: {'file_name': fileName},
      );
      return url;
    } catch (e) {
      print('Error uploading track file: $e');
      rethrow;
    }
  }

  /// Upload track/artwork bytes to Firebase Storage and return download URL
  Future<String> uploadTrackBytes({
    required List<int> bytes,
    required String fileName,
    String folder = 'uploads',
    String? contentType,
  }) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final ref = _storage
          .ref()
          .child('users')
          .child(currentUser!.uid)
          .child(folder)
          .child(fileName);

      final metadata = contentType != null
          ? SettableMetadata(contentType: contentType)
          : null;

      final task = await ref.putData(Uint8List.fromList(bytes), metadata);
      final url = await task.ref.getDownloadURL();

      await _analytics.logEvent(
        name: 'file_uploaded',
        parameters: {
          'folder': folder,
          'file_name': fileName,
        },
      );
      return url;
    } catch (e) {
      print('Error uploading file bytes: $e');
      rethrow;
    }
  }
}
