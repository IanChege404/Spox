import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotify_clone/data/model/spotify_models.dart';
import 'package:spotify_clone/data/repository/spotify_repository.dart';
import 'package:spotify_clone/services/spotify_api_service.dart';

/// Mock Spotify API Service for testing
class MockSpotifyApiService extends Mock implements SpotifyApiService {}

void main() {
  group('SpotifyRepository', () {
    late MockSpotifyApiService mockApiService;
    late SpotifyRepository repository;

    // Mock data
    final mockFeaturedPlaylistJson = {
      'id': 'featured_1',
      'name': 'Featured Mix',
      'description': 'A featured Spotify mix',
      'images': [
        {'url': 'https://example.com/image.jpg'}
      ],
      'owner': {'display_name': 'Spotify'},
      'tracks': {'total': 50},
    };

    final mockUserJson = {
      'id': 'user123',
      'display_name': 'Test User',
      'email': 'test@example.com',
      'images': [
        {'url': 'https://example.com/profile.jpg'}
      ],
      'followers': {'total': 100},
    };

    final mockSearchResults = {
      'tracks': {
        'items': [
          {
            'id': 'track1',
            'name': 'Test Track',
            'artists': [
              {'name': 'Test Artist'}
            ],
            'duration_ms': 180000,
            'preview_url': 'https://example.com/preview.mp3',
          }
        ]
      },
      'artists': {'items': []},
      'albums': {'items': []},
      'playlists': {'items': []},
    };

    setUp(() {
      mockApiService = MockSpotifyApiService();
      repository = SpotifyRepository(apiService: mockApiService);
    });

    group('Featured Playlists', () {
      test('getFeaturedPlaylists returns list of SpotifyPlaylist objects',
          () async {
        // Arrange
        when(() =>
                mockApiService.getFeaturedPlaylists(limit: any(named: 'limit')))
            .thenAnswer((_) async => [mockFeaturedPlaylistJson]);

        // Act
        final result = await repository.getFeaturedPlaylists(limit: 20);

        // Assert
        expect(result, isNotEmpty);
        expect(result.first, isA<SpotifyPlaylist>());
        expect(result.first.name, 'Featured Mix');
        verify(() => mockApiService.getFeaturedPlaylists(limit: 20)).called(1);
      });

      test('getFeaturedPlaylists returns empty list when no playlists found',
          () async {
        // Arrange
        when(() =>
                mockApiService.getFeaturedPlaylists(limit: any(named: 'limit')))
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getFeaturedPlaylists();

        // Assert
        expect(result, isEmpty);
      });

      test('getFeaturedPlaylists throws exception on API error', () async {
        // Arrange
        when(() =>
                mockApiService.getFeaturedPlaylists(limit: any(named: 'limit')))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.getFeaturedPlaylists(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('User Playlists', () {
      test('getUserPlaylists returns user playlists with pagination', () async {
        // Arrange
        when(() => mockApiService.getUserPlaylists(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async => [mockFeaturedPlaylistJson]);

        // Act
        final result = await repository.getUserPlaylists(limit: 20, offset: 0);

        // Assert
        expect(result, isNotEmpty);
        verify(() => mockApiService.getUserPlaylists(limit: 20, offset: 0))
            .called(1);
      });

      test('getUserPlaylists handles offset correctly', () async {
        // Arrange
        when(() => mockApiService.getUserPlaylists(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async => []);

        // Act
        await repository.getUserPlaylists(limit: 10, offset: 50);

        // Assert
        verify(() => mockApiService.getUserPlaylists(limit: 10, offset: 50))
            .called(1);
      });
    });

    group('User Profile', () {
      test('getCurrentUserProfile returns SpotifyUser with profile information',
          () async {
        // Arrange
        when(() => mockApiService.getCurrentUserProfile())
            .thenAnswer((_) async => mockUserJson);

        // Act
        final result = await repository.getCurrentUserProfile();

        // Assert
        expect(result, isA<SpotifyUser>());
        expect(result.displayName, 'Test User');
        expect(result.email, 'test@example.com');
        verify(() => mockApiService.getCurrentUserProfile()).called(1);
      });

      test('getCurrentUserProfile throws on authentication failure', () async {
        // Arrange
        when(() => mockApiService.getCurrentUserProfile())
            .thenThrow(Exception('Unauthorized: Invalid token'));

        // Act & Assert
        expect(
          () => repository.getCurrentUserProfile(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Search', () {
      test('search returns SpotifySearchResults with all result types',
          () async {
        // Arrange
        when(() => mockApiService.search(
              any(),
              type: any(named: 'type'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => mockSearchResults);

        // Act
        final result = await repository.search('test');

        // Assert
        expect(result, isA<SpotifySearchResults>());
        expect(result.tracks, isNotEmpty);
      });

      test('search with specific type filters results', () async {
        // Arrange
        when(() => mockApiService.search(
              any(),
              type: any(named: 'type'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => mockSearchResults);

        // Act
        await repository.search('test', type: 'track');

        // Assert
        verify(() => mockApiService.search('test', type: 'track', limit: 20))
            .called(1);
      });

      test('search with empty query throws', () async {
        // Arrange
        when(() => mockApiService.search(
              any(),
              type: any(named: 'type'),
              limit: any(named: 'limit'),
            )).thenThrow(Exception('Query cannot be empty'));

        // Act & Assert
        expect(
          () => repository.search(''),
          throwsA(isA<Exception>()),
        );
      });

      test('search with limit parameter', () async {
        // Arrange
        when(() => mockApiService.search(
              any(),
              type: any(named: 'type'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => mockSearchResults);

        // Act
        await repository.search('test', limit: 50);

        // Assert
        verify(() => mockApiService.search(
              'test',
              type: 'track,artist,album,playlist',
              limit: 50,
            )).called(1);
      });

      test('search throws on network error', () async {
        // Arrange
        when(() => mockApiService.search(
              any(),
              type: any(named: 'type'),
              limit: any(named: 'limit'),
            )).thenThrow(Exception('Connection timeout'));

        // Act & Assert
        expect(
          () => repository.search('test'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('New Releases', () {
      test('getNewReleases returns list of new albums', () async {
        // Arrange
        when(() => mockApiService.getNewReleases(limit: any(named: 'limit')))
            .thenAnswer((_) async => {
                  'albums': {
                    'items': [
                      {
                        'id': 'album_1',
                        'name': 'New Album',
                        'album_type': 'album',
                        'images': [
                          {'url': 'https://example.com/album.jpg'}
                        ],
                        'artists': [
                          {'name': 'Test Artist'}
                        ],
                        'total_tracks': 12,
                      }
                    ]
                  }
                });

        // Act
        final result = await repository.getNewReleases(limit: 20);

        // Assert
        expect(result, isNotEmpty);
        verify(() => mockApiService.getNewReleases(limit: 20)).called(1);
      });
    });

    group('Error Handling', () {
      test('getFeaturedPlaylists wraps API errors with context', () async {
        // Arrange
        when(() =>
                mockApiService.getFeaturedPlaylists(limit: any(named: 'limit')))
            .thenThrow(Exception('401 Unauthorized'));

        // Act & Assert
        expect(
          () => repository.getFeaturedPlaylists(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to fetch featured playlists'),
            ),
          ),
        );
      });

      test('getUserPlaylists wraps API errors', () async {
        // Arrange
        when(() => mockApiService.getUserPlaylists(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenThrow(Exception('Rate limited'));

        // Act & Assert
        expect(
          () => repository.getUserPlaylists(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Data Transformation', () {
      test('getFeaturedPlaylists correctly transforms JSON to model', () async {
        // Arrange
        when(() =>
                mockApiService.getFeaturedPlaylists(limit: any(named: 'limit')))
            .thenAnswer((_) async => [mockFeaturedPlaylistJson]);

        // Act
        final result = await repository.getFeaturedPlaylists();

        // Assert
        final playlist = result.first;
        expect(playlist.id, 'featured_1');
        expect(playlist.name, 'Featured Mix');
        expect(playlist.description, 'A featured Spotify mix');
        expect(playlist.trackCount, 50);
      });

      test('search correctly transforms search results', () async {
        // Arrange
        when(() => mockApiService.search(
              any(),
              type: any(named: 'type'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => mockSearchResults);

        // Act
        final result = await repository.search('test');

        // Assert
        expect(result.tracks, isNotEmpty);
        expect(result.artists, isEmpty);
      });
    });
  });
}
