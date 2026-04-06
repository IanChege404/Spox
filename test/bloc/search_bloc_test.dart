import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotify_clone/bloc/search/search_bloc.dart';
import 'package:spotify_clone/bloc/search/search_event.dart';
import 'package:spotify_clone/bloc/search/search_state.dart';
import 'package:spotify_clone/services/spotify_api_service.dart';

class MockSpotifyApiService extends Mock implements SpotifyApiService {}

void main() {
  group('SearchBloc', () {
    late MockSpotifyApiService mockSpotifyApiService;
    late SearchBloc searchBloc;

    setUp(() {
      mockSpotifyApiService = MockSpotifyApiService();
      searchBloc = SearchBloc(spotifyApiService: mockSpotifyApiService);
    });

    tearDown(() {
      searchBloc.close();
    });

    test('initial state is SearchInitial', () {
      expect(searchBloc.state, isA<SearchInitial>());
    });

    blocTest<SearchBloc, SearchState>(
      'emits Initial when SearchQueryEvent is empty',
      build: () => searchBloc,
      act: (bloc) => bloc.add(const SearchQueryEvent('')),
      expect: () => [
        isA<SearchInitial>(),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits Loading then Loaded when search succeeds',
      build: () => searchBloc,
      act: (bloc) {
        when(() => mockSpotifyApiService.search(
              any(),
              type: any(named: 'type'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => {
              'tracks': {
                'items': [
                  {
                    'name': 'Test Song',
                    'artists': [
                      {'name': 'Test Artist'}
                    ]
                  }
                ]
              },
              'artists': {'items': []},
              'albums': {'items': []},
              'playlists': {'items': []}
            });
        bloc.add(const SearchQueryEvent('test'));
      },
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchLoaded>(),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits Empty when search returns no results',
      build: () => searchBloc,
      act: (bloc) {
        when(() => mockSpotifyApiService.search(
              any(),
              type: any(named: 'type'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => {
              'tracks': {'items': []},
              'artists': {'items': []},
              'albums': {'items': []},
              'playlists': {'items': []}
            });
        bloc.add(const SearchQueryEvent('nonexistent'));
      },
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchEmpty>(),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits Error when search throws exception',
      build: () => searchBloc,
      act: (bloc) {
        when(() => mockSpotifyApiService.search(
              any(),
              type: any(named: 'type'),
              limit: any(named: 'limit'),
            )).thenThrow(Exception('API Error'));
        bloc.add(const SearchQueryEvent('test'));
      },
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchError>(),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits Initial when SearchClearEvent is dispatched',
      build: () => searchBloc,
      seed: () => SearchLoaded(
        songs: [],
        artists: [],
        albums: [],
        playlists: [],
        query: 'test',
      ),
      act: (bloc) => bloc.add(const SearchClearEvent()),
      expect: () => [
        isA<SearchInitial>(),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'debounces multiple rapid search queries',
      build: () => searchBloc,
      act: (bloc) {
        when(() => mockSpotifyApiService.search(
              any(),
              type: any(named: 'type'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => {
              'tracks': {'items': []},
              'artists': {'items': []},
              'albums': {'items': []},
              'playlists': {'items': []}
            });

        // Send multiple rapid queries
        bloc.add(const SearchQueryEvent('t'));
        bloc.add(const SearchQueryEvent('te'));
        bloc.add(const SearchQueryEvent('tes'));
        bloc.add(const SearchQueryEvent('test'));
      },
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchEmpty>(),
      ],
      verify: (bloc) {
        // Verify API was called only once (last query only)
        verify(() => mockSpotifyApiService.search(
              'test',
              type: any(named: 'type'),
              limit: any(named: 'limit'),
            )).called(1);
      },
    );

    blocTest<SearchBloc, SearchState>(
      'handles search with mixed result types',
      build: () => searchBloc,
      act: (bloc) {
        when(() => mockSpotifyApiService.search(
              any(),
              type: any(named: 'type'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => {
              'tracks': {
                'items': [
                  {
                    'name': 'Track 1',
                    'artists': [
                      {'name': 'Artist 1'}
                    ]
                  }
                ]
              },
              'artists': {
                'items': [
                  {'name': 'Artist A'}
                ]
              },
              'albums': {
                'items': [
                  {'name': 'Album 1'}
                ]
              },
              'playlists': {'items': []}
            });
        bloc.add(const SearchQueryEvent('mixed'));
      },
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchLoaded>(),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'handles search query with whitespace',
      build: () => searchBloc,
      act: (bloc) {
        when(() => mockSpotifyApiService.search(
              any(),
              type: any(named: 'type'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => {
              'tracks': {'items': []},
              'artists': {'items': []},
              'albums': {'items': []},
              'playlists': {'items': []}
            });
        bloc.add(const SearchQueryEvent('  test query  '));
      },
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchEmpty>(),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'recovers from error with new search',
      build: () => searchBloc,
      seed: () => SearchError('Previous error'),
      act: (bloc) {
        when(() => mockSpotifyApiService.search(
              any(),
              type: any(named: 'type'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => {
              'tracks': {
                'items': [
                  {
                    'name': 'Recovery Song',
                    'artists': [
                      {'name': 'Recovery Artist'}
                    ]
                  }
                ]
              },
              'artists': {'items': []},
              'albums': {'items': []},
              'playlists': {'items': []}
            });
        bloc.add(const SearchQueryEvent('recovery'));
      },
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchLoaded>(),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits Initial when clearing search from Error state',
      build: () => searchBloc,
      seed: () => SearchError('API Error'),
      act: (bloc) => bloc.add(const SearchClearEvent()),
      expect: () => [
        isA<SearchInitial>(),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'ignores SearchQueryEvent with null query',
      build: () => searchBloc,
      act: (bloc) {
        when(() => mockSpotifyApiService.search(
              any(),
              type: any(named: 'type'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => {
              'tracks': {'items': []},
              'artists': {'items': []},
              'albums': {'items': []},
              'playlists': {'items': []}
            });
        bloc.add(const SearchQueryEvent(''));
      },
      expect: () => [
        isA<SearchInitial>(),
      ],
      verify: (bloc) {
        // API should not be called for empty query
        verifyNever(() => mockSpotifyApiService.search(
              any(),
              type: any(named: 'type'),
              limit: any(named: 'limit'),
            ));
      },
    );

    blocTest<SearchBloc, SearchState>(
      'maintains search state across multiple queries',
      build: () => searchBloc,
      act: (bloc) {
        when(() => mockSpotifyApiService.search(
              'test1',
              type: any(named: 'type'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => {
              'tracks': {
                'items': [
                  {
                    'name': 'Test Song 1',
                    'artists': [
                      {'name': 'Test Artist 1'}
                    ]
                  }
                ]
              },
              'artists': {'items': []},
              'albums': {'items': []},
              'playlists': {'items': []}
            });

        when(() => mockSpotifyApiService.search(
              'test2',
              type: any(named: 'type'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => {
              'tracks': {
                'items': [
                  {
                    'name': 'Test Song 2',
                    'artists': [
                      {'name': 'Test Artist 2'}
                    ]
                  }
                ]
              },
              'artists': {'items': []},
              'albums': {'items': []},
              'playlists': {'items': []}
            });

        bloc.add(const SearchQueryEvent('test1'));
      },
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchLoaded>(),
      ],
    );
  });
}

