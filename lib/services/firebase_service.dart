import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';

/// Firebase Service for authentication and data synchronization
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  late GoogleSignIn _googleSignIn;

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  /// Initialize Firebase
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _googleSignIn = GoogleSignIn();
    } catch (e) {
      print('Error initializing Firebase: $e');
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
          .collection('likedSongs')
          .doc(spotifyId)
          .set({
        'spotifyId': spotifyId,
        'title': title,
        'artist': artist,
        'albumArt': albumArt,
        'likedAt': FieldValue.serverTimestamp(),
      });
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
          .collection('likedSongs')
          .doc(spotifyId)
          .delete();
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
        .collection('likedSongs')
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
          .collection('likedSongs')
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
          .collection('likedSongs');

      for (final song in likedSongs) {
        batch.set(userRef.doc(song['spotifyId']), {
          'spotifyId': song['spotifyId'],
          'title': song['title'],
          'artist': song['artist'],
          'albumArt': song['albumArt'],
          'likedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error syncing liked songs: $e');
      rethrow;
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

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('playHistory')
          .doc()
          .set({
        'spotifyId': spotifyId,
        'title': title,
        'artist': artist,
        'duration': duration.inSeconds,
        'playedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error recording song play: $e');
      // Don't rethrow - analytics failure shouldn't affect app functionality
    }
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
        .collection('playHistory')
        .orderBy('playedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
}
