import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotify_clone/data/datasource/firestore_datasource.dart';
import 'package:spotify_clone/data/model/spotify_models.dart';
import 'package:spotify_clone/data/model/podcast.dart';
import 'package:spotify_clone/services/firestore_sync_service.dart';
import 'package:spotify_clone/services/hive_service.dart';

/// Mock classes
class MockFirestoreDataSource extends Mock implements FirestoreDataSource {}

class MockHiveService extends Mock implements HiveService {
  final playlistCache = <SpotifyPlaylist>[];
  final artistsCache = <SpotifyArtist>[];
  final podcastsCache = <Podcast>[];
  final homeConfigCache = <String, dynamic>{};
  final lastSyncBox = <String, String>{};

  @override
  Future<void> cachePlaylists(List<SpotifyPlaylist> playlists) async {
    playlistCache.clear();
    playlistCache.addAll(playlists);
  }

  @override
  List<SpotifyPlaylist> getCachedPlaylists() {
    return playlistCache;
  }

  @override
  Future<void> cacheArtists(List<SpotifyArtist> artists) async {
    artistsCache.clear();
    artistsCache.addAll(artists);
  }

  @override
  List<SpotifyArtist> getCachedArtists() {
    return artistsCache;
  }

  @override
  Future<void> cachePodcasts(List<Podcast> podcasts) async {
    podcastsCache.clear();
    podcastsCache.addAll(podcasts);
  }

  @override
  List<Podcast> getCachedPodcasts() {
    return podcastsCache;
  }

  @override
  Future<void> cacheHomeScreenConfig(Map<String, dynamic> config) async {
    homeConfigCache.clear();
    homeConfigCache.addAll(config);
  }

  @override
  Map<String, dynamic> getCachedHomeScreenConfig() {
    return homeConfigCache;
  }

  @override
  Box<String> getLastSyncBox() {
    return MockBox();
  }
}

class MockBox extends Mock implements Box<String> {
  final Map<dynamic, String> _storage = {};

  @override
  Future<void> put(dynamic key, String value) async {
    _storage[key] = value;
  }

  @override
  String? get(dynamic key, {String? defaultValue}) {
    return _storage[key] ?? defaultValue;
  }

  @override
  Future<int> clear() async {
    final count = _storage.length;
    _storage.clear();
    return count;
  }
}

/// Fake classes for mocktail fallback values
class FakeSpotifyPlaylist extends Fake implements SpotifyPlaylist {}

class FakeSpotifyArtist extends Fake implements SpotifyArtist {}

class FakePodcast extends Fake implements Podcast {}

void main() {
  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(FakeSpotifyPlaylist());
    registerFallbackValue(FakeSpotifyArtist());
    registerFallbackValue(FakePodcast());
  });

  group('FirestoreSyncService', () {
    late MockFirestoreDataSource mockFirestoreDataSource;
    late MockHiveService mockHiveService;
    late FirestoreSyncService syncService;

    // Sample data
    late List<SpotifyPlaylist> samplePlaylists;
    late List<SpotifyArtist> sampleArtists;
    late List<Podcast> samplePodcasts;

    setUp(() {
      mockFirestoreDataSource = MockFirestoreDataSource();
      mockHiveService = MockHiveService();
      syncService = FirestoreSyncService(
        mockFirestoreDataSource,
        mockHiveService,
      );

      // Setup sample data
      samplePlaylists = [
        SpotifyPlaylist(
          id: '2010s',
          name: '2010s Mix',
          description: 'Hits from the 2010s',
          imageUrl: 'https://example.com/2010s.jpg',
          trackCount: 15,
          ownerName: 'Spotify',
        ),
        SpotifyPlaylist(
          id: 'chill',
          name: 'Chill Mix',
          description: 'Relaxing tracks',
          imageUrl: 'https://example.com/chill.jpg',
          trackCount: 14,
          ownerName: 'Spotify',
        ),
      ];

      sampleArtists = [
        SpotifyArtist(
          id: 'drake',
          name: 'Drake',
          imageUrl: 'https://example.com/drake.jpg',
          genres: ['hip-hop', 'rap'],
          followers: 69000000,
          popularity: 94,
        ),
        SpotifyArtist(
          id: 'taylor-swift',
          name: 'Taylor Swift',
          imageUrl: 'https://example.com/taylor.jpg',
          genres: ['pop'],
          followers: 92000000,
          popularity: 96,
        ),
      ];

      samplePodcasts = [
        Podcast('https://example.com/jre.jpg', 'The Joe Rogan Experience'),
      ];
    });

    group('syncPlaylists', () {
      test('should fetch playlists from Firestore and cache them', () async {
        when(() => mockFirestoreDataSource.fetchPlaylists())
            .thenAnswer((_) => Future.value(samplePlaylists));

        final result = await syncService.syncPlaylists();

        expect(result, equals(samplePlaylists));
        expect(result.length, 2);
        verify(() => mockFirestoreDataSource.fetchPlaylists()).called(1);
      });

      test('should return cached playlists if cache is valid', () async {
        // Setup cache
        await mockHiveService.cachePlaylists(samplePlaylists);
        mockHiveService
            .getLastSyncBox()
            .put('playlists_lastSync', DateTime.now().toIso8601String());

        when(() => mockFirestoreDataSource.fetchPlaylists())
            .thenAnswer((_) => Future.value([]));

        final result = await syncService.syncPlaylists(); // No force refresh

        expect(result, equals(samplePlaylists));
        // Should use cache, not fetch from Firestore
        verifyNever(() => mockFirestoreDataSource.fetchPlaylists());
      });

      test('should force refresh if forceRefresh is true', () async {
        await mockHiveService.cachePlaylists(samplePlaylists);
        mockHiveService
            .getLastSyncBox()
            .put('playlists_lastSync', DateTime.now().toIso8601String());

        when(() => mockFirestoreDataSource.fetchPlaylists())
            .thenAnswer((_) => Future.value(samplePlaylists));

        final result = await syncService.syncPlaylists(forceRefresh: true);

        expect(result, equals(samplePlaylists));
        verify(() => mockFirestoreDataSource.fetchPlaylists()).called(1);
      });

      test('should fallback to cache on Firestore error', () async {
        await mockHiveService.cachePlaylists(samplePlaylists);

        when(() => mockFirestoreDataSource.fetchPlaylists())
            .thenThrow(Exception('Network error'));

        final result = await syncService.syncPlaylists(forceRefresh: true);

        expect(result, equals(samplePlaylists));
      });

      test('should return empty list if no cache and Firestore fails',
          () async {
        when(() => mockFirestoreDataSource.fetchPlaylists())
            .thenThrow(Exception('Network error'));

        final result = await syncService.syncPlaylists(forceRefresh: true);

        expect(result, isEmpty);
      });
    });

    group('syncArtists', () {
      test('should fetch artists from Firestore and cache them', () async {
        when(() => mockFirestoreDataSource.fetchArtists())
            .thenAnswer((_) => Future.value(sampleArtists));

        final result = await syncService.syncArtists();

        expect(result, equals(sampleArtists));
        expect(result.length, 2);
        verify(() => mockFirestoreDataSource.fetchArtists()).called(1);
      });

      test('should return cached artists', () async {
        await mockHiveService.cacheArtists(sampleArtists);
        mockHiveService
            .getLastSyncBox()
            .put('artists_lastSync', DateTime.now().toIso8601String());

        when(() => mockFirestoreDataSource.fetchArtists()).thenAnswer(
            (_) => Future.value([])); // Should not be called if cache is valid

        final result = await syncService.syncArtists();

        expect(result, equals(sampleArtists));
        verifyNever(() => mockFirestoreDataSource.fetchArtists());
      });
    });

    group('syncPodcasts', () {
      test('should fetch podcasts from Firestore and cache them', () async {
        when(() => mockFirestoreDataSource.fetchPodcasts())
            .thenAnswer((_) => Future.value(samplePodcasts));

        final result = await syncService.syncPodcasts();

        expect(result, equals(samplePodcasts));
        verify(() => mockFirestoreDataSource.fetchPodcasts()).called(1);
      });
    });

    group('syncAllData', () {
      test('should sync all collections', () async {
        when(() => mockFirestoreDataSource.fetchPlaylists())
            .thenAnswer((_) => Future.value(samplePlaylists));
        when(() => mockFirestoreDataSource.fetchArtists())
            .thenAnswer((_) => Future.value(sampleArtists));
        when(() => mockFirestoreDataSource.fetchPodcasts())
            .thenAnswer((_) => Future.value(samplePodcasts));
        when(() => mockFirestoreDataSource.fetchHomeScreenConfig())
            .thenAnswer((_) => Future.value({'topMixes': []}));

        final result = await syncService.syncAllData();

        expect(result.containsKey('playlists'), true);
        expect(result.containsKey('artists'), true);
        expect(result.containsKey('podcasts'), true);
        expect(result.containsKey('homeScreenConfig'), true);

        verify(() => mockFirestoreDataSource.fetchPlaylists()).called(1);
        verify(() => mockFirestoreDataSource.fetchArtists()).called(1);
        verify(() => mockFirestoreDataSource.fetchPodcasts()).called(1);
      });
    });

    group('getCacheStatus', () {
      test('should return cache status for all collections', () async {
        await mockHiveService.cachePlaylists(samplePlaylists);
        await mockHiveService.cacheArtists(sampleArtists);

        mockHiveService
            .getLastSyncBox()
            .put('playlists_lastSync', DateTime.now().toIso8601String());
        mockHiveService
            .getLastSyncBox()
            .put('artists_lastSync', DateTime.now().toIso8601String());

        final status = await syncService.getCacheStatus();

        expect(status.containsKey('playlists'), true);
        expect(status['playlists']['count'], 2);
        expect(status['artists']['count'], 2);
      });
    });

    group('clearAllCaches', () {
      test('should clear all caches', () async {
        await mockHiveService.cachePlaylists(samplePlaylists);
        await mockHiveService.cacheArtists(sampleArtists);

        await syncService.clearAllCaches();

        expect(mockHiveService.getCachedPlaylists(), isEmpty);
        expect(mockHiveService.getCachedArtists(), isEmpty);
      });
    });
  });
}
