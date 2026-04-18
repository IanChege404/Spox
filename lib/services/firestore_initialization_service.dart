import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotify_clone/core/utils/firestore_seed_data.dart';

/// Firestore initialization service - Handles DB population on demand
/// Separates database initialization from app startup concerns
/// Can be called automatically or manually for testing/admin purposes
class FirestoreInitializationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize Firestore if collections are empty
  /// Safe to call multiple times - version check prevents unnecessary re-seeding
  ///
  /// Returns true if seeding was performed, false if data already exists
  static Future<bool> initializeIfNeeded() async {
    try {
      print('[FirestoreInit] Checking if Firestore needs initialization...');

      // Check if data already exists
      final exists = await _checkDataExists();

      if (!exists) {
        print('[FirestoreInit] ℹ Firestore is empty - starting seed...');
        await FirestoreSeedData.seedAllData();
        print('[FirestoreInit] ✓ Firestore initialization complete');
        return true;
      } else {
        print(
            '[FirestoreInit] ℹ Firestore already contains data - skipping seed');
        return false;
      }
    } catch (e) {
      print('[FirestoreInit] ✗ Error during initialization: $e');
      // Don't block app - data can be loaded from fallback sources (Hive cache, local data)
      return false;
    }
  }

  /// Force re-seed all data (dangerous - use only for testing/admin)
  /// Clears all existing collections and re-seeds from scratch
  ///
  /// WARNING: This will delete all user data! Use with caution.
  static Future<void> forceReSeed() async {
    try {
      print('[FirestoreInit] ⚠ Force re-seeding - clearing existing data...');
      await _clearAllCollections();
      print('[FirestoreInit] ℹ Collections cleared, starting fresh seed...');
      await FirestoreSeedData.seedAllData();
      print('[FirestoreInit] ✓ Force re-seed complete');
    } catch (e) {
      print('[FirestoreInit] ✗ Force re-seed failed: $e');
      rethrow;
    }
  }

  /// Check if Firestore has data by looking at metadata
  /// Uses version marker to detect if seeding has completed
  ///
  /// Returns true if collections contain data, false if empty
  static Future<bool> _checkDataExists() async {
    try {
      // Check metadata first (most reliable indicator of seeding status)
      final metadata =
          await _firestore.collection('_metadata').doc('seed_version').get();
      if (metadata.exists) {
        print('[FirestoreInit] ℹ Found seed_version metadata - data exists');
        return true;
      }

      // Fallback: check if playlists collection has any documents
      final playlistsSnapshot =
          await _firestore.collection('playlists').limit(1).get();
      final hasData = playlistsSnapshot.docs.isNotEmpty;

      if (hasData) {
        print('[FirestoreInit] ℹ Found playlists collection - data exists');
      }

      return hasData;
    } catch (e) {
      print('[FirestoreInit] ⚠ Warning: Could not check data: $e');
      // On error, assume data exists to avoid accidental re-seeding
      return true;
    }
  }

  /// Clear all app data collections (for testing/reset only)
  /// Deletes documents from: playlists, albums, artists, podcasts, _metadata
  ///
  /// WARNING: This operation cannot be undone!
  static Future<void> _clearAllCollections() async {
    try {
      final collections = [
        'playlists',
        'albums',
        'artists',
        'podcasts',
        '_metadata',
      ];

      for (final collection in collections) {
        print('[FirestoreInit] Clearing collection: $collection...');
        final docs = await _firestore.collection(collection).get();

        for (final doc in docs.docs) {
          await doc.reference.delete();
        }

        print(
            '[FirestoreInit]   ✓ Cleared $collection (${docs.docs.length} docs)');
      }

      print('[FirestoreInit] ✓ All collections cleared');
    } catch (e) {
      print('[FirestoreInit] ✗ Error clearing collections: $e');
      rethrow;
    }
  }

  /// Get initialization status - useful for debugging
  static Future<Map<String, dynamic>> getStatus() async {
    try {
      final exists = await _checkDataExists();
      final metadata =
          await _firestore.collection('_metadata').doc('seed_version').get();

      final version = metadata.data()?['seed_version'];
      final lastSeeded =
          (metadata.data()?['last_seeded'] as Timestamp?)?.toDate();

      return {
        'initialized': exists,
        'seed_version': version,
        'last_seeded': lastSeeded,
        'status': exists ? 'ready' : 'needs_initialization',
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'status': 'error',
      };
    }
  }
}
