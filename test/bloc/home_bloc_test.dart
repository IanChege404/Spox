import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotify_clone/bloc/home/home_bloc.dart';
import 'package:spotify_clone/data/model/spotify_models.dart';
import 'package:spotify_clone/data/repository/spotify_repository.dart';
import 'package:spotify_clone/services/spotify_auth_service.dart';
import 'package:spotify_clone/services/hive_service.dart';

class MockSpotifyRepository extends Mock implements SpotifyRepository {}

class MockSpotifyAuthService extends Mock implements SpotifyAuthService {}

class MockHiveService extends Mock implements HiveService {}

void main() {
  group('HomeBloc', () {
    late MockSpotifyRepository mockSpotifyRepository;
    late MockSpotifyAuthService mockSpotifyAuthService;
    late MockHiveService mockHiveService;
    late HomeBloc homeBloc;

    final mockFeaturedPlaylist = SpotifyPlaylist(
      id: '1',
      name: 'Featured Mix 1',
      description: 'Test described featured playlist',
      imageUrl: 'https://example.com/image.jpg',
      ownerName: 'Spotify',
      trackCount: 50,
    );

    final mockUserPlaylist = SpotifyPlaylist(
      id: '2',
      name: 'My Playlist',
      description: 'My personal playlist',
      imageUrl: 'https://example.com/image2.jpg',
      ownerName: 'User',
      trackCount: 25,
    );

    final mockUser = SpotifyUser(
      id: 'user123',
      displayName: 'Test User',
      email: 'test@example.com',
      imageUrl: 'https://example.com/profile.jpg',
      followers: 100,
    );

    setUp(() {
      mockSpotifyRepository = MockSpotifyRepository();
      mockSpotifyAuthService = MockSpotifyAuthService();
      mockHiveService = MockHiveService();
      when(() => mockSpotifyAuthService.isAuthenticated).thenReturn(true);
      when(() => mockHiveService.getSelectedArtists()).thenReturn([]);
      when(() => mockSpotifyRepository.getGuestHomeData(
            limit: any(named: 'limit'),
          )).thenAnswer(
        (_) async => GuestHomeData(
          featuredPlaylists: [],
          browseCategories: [],
          categoryPlaylists: [],
        ),
      );

      homeBloc = HomeBloc(
        spotifyRepository: mockSpotifyRepository,
        authService: mockSpotifyAuthService,
        hiveService: mockHiveService,
      );
    });

    tearDown(() {
      homeBloc.close();
    });

    test('initial state is HomeInitial', () {
      expect(homeBloc.state, isA<HomeInitial>());
    });

    // Happy path: Successfully load home data
    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeLoaded] when LoadHomeDataEvent is added successfully',
      build: () => homeBloc,
      act: (bloc) {
        when(() => mockSpotifyRepository.getFeaturedPlaylists(
                limit: any(named: 'limit')))
            .thenAnswer((_) async => [mockFeaturedPlaylist]);
        when(() => mockSpotifyRepository.getUserPlaylists(
                limit: any(named: 'limit')))
            .thenAnswer((_) async => [mockUserPlaylist]);
        when(() => mockSpotifyRepository.getCurrentUserProfile())
            .thenAnswer((_) async => mockUser);

        bloc.add(const LoadHomeDataEvent());
      },
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeLoaded>().having(
            (state) => state.featuredPlaylists, 'featuredPlaylists', [
          mockFeaturedPlaylist
        ]).having((state) => state.userPlaylists, 'userPlaylists', [
          mockUserPlaylist
        ]).having((state) => state.currentUser, 'currentUser', mockUser),
      ],
    );

    // Error scenario: API failure falls back to guest state
    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeLoadedGuest] when getFeaturedPlaylists fails',
      build: () => homeBloc,
      act: (bloc) {
        when(() => mockSpotifyRepository.getFeaturedPlaylists(
                limit: any(named: 'limit')))
            .thenThrow(
                Exception('API Error: Failed to fetch featured playlists'));

        bloc.add(const LoadHomeDataEvent());
      },
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeLoadedGuest>(),
      ],
    );

    // Error scenario: user playlists failure falls back to guest state
    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeLoadedGuest] when getUserPlaylists fails',
      build: () => homeBloc,
      act: (bloc) {
        when(() => mockSpotifyRepository.getCurrentUserProfile())
            .thenAnswer((_) async => mockUser);
        when(() => mockSpotifyRepository.getFeaturedPlaylists(
                limit: any(named: 'limit')))
            .thenAnswer((_) async => [mockFeaturedPlaylist]);
        when(() => mockSpotifyRepository.getUserPlaylists(
                limit: any(named: 'limit')))
            .thenThrow(Exception('Network timeout'));

        bloc.add(const LoadHomeDataEvent());
      },
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeLoadedGuest>(),
      ],
    );

    // Edge case: Empty playlists list
    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeLoaded] with empty playlists when repositories return empty',
      build: () => homeBloc,
      act: (bloc) {
        when(() => mockSpotifyRepository.getFeaturedPlaylists(
            limit: any(named: 'limit'))).thenAnswer((_) async => []);
        when(() => mockSpotifyRepository.getUserPlaylists(
            limit: any(named: 'limit'))).thenAnswer((_) async => []);
        when(() => mockSpotifyRepository.getCurrentUserProfile())
            .thenAnswer((_) async => mockUser);

        bloc.add(const LoadHomeDataEvent());
      },
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeLoaded>()
            .having((state) => state.featuredPlaylists.isEmpty,
                'empty featured', true)
            .having((state) => state.userPlaylists.isEmpty,
                'empty user playlists', true),
      ],
    );

    // Refresh functionality
    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeLoaded] when RefreshHomeDataEvent is added',
      build: () => homeBloc,
      act: (bloc) {
        when(() => mockSpotifyRepository.getFeaturedPlaylists(
                limit: any(named: 'limit')))
            .thenAnswer((_) async => [mockFeaturedPlaylist]);
        when(() => mockSpotifyRepository.getUserPlaylists(
                limit: any(named: 'limit')))
            .thenAnswer((_) async => [mockUserPlaylist]);
        when(() => mockSpotifyRepository.getCurrentUserProfile())
            .thenAnswer((_) async => mockUser);

        bloc.add(const RefreshHomeDataEvent());
      },
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeLoaded>(),
      ],
    );

    // Verify repositories are called with correct parameters
    blocTest<HomeBloc, HomeState>(
      'calls repositories with correct parameters',
      build: () => homeBloc,
      act: (bloc) {
        when(() => mockSpotifyRepository.getFeaturedPlaylists(
                limit: any(named: 'limit')))
            .thenAnswer((_) async => [mockFeaturedPlaylist]);
        when(() => mockSpotifyRepository.getUserPlaylists(
                limit: any(named: 'limit')))
            .thenAnswer((_) async => [mockUserPlaylist]);
        when(() => mockSpotifyRepository.getCurrentUserProfile())
            .thenAnswer((_) async => mockUser);

        bloc.add(const LoadHomeDataEvent());
      },
      verify: (bloc) {
        verify(() => mockSpotifyRepository.getFeaturedPlaylists(limit: 20))
            .called(1);
        verify(() => mockSpotifyRepository.getUserPlaylists(limit: 20))
            .called(1);
        verify(() => mockSpotifyRepository.getCurrentUserProfile()).called(1);
        verifyNever(
          () => mockSpotifyRepository.getGuestHomeData(
              limit: any(named: 'limit')),
        );
      },
    );
  });
}
