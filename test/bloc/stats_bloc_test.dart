import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotify_clone/bloc/stats/stats_bloc.dart';
import 'package:spotify_clone/bloc/stats/stats_event.dart';
import 'package:spotify_clone/bloc/stats/stats_state.dart';
import 'package:spotify_clone/data/model/user_stats.dart';
import 'package:spotify_clone/services/stats_service.dart';

class MockStatsService extends Mock implements StatsService {}

void main() {
  setUpAll(() {
    registerFallbackValue(StatsPeriod.week);
  });

  group('StatsBloc', () {
    late MockStatsService mockStatsService;
    late StatsBloc statsBloc;

    final mockStats = UserStats(
      totalMinutesListened: 1200,
      topArtist: 'Drake',
      topTracks: [
        StatTrack(
          trackName: 'Track 1',
          artistName: 'Artist 1',
          playCount: 5,
          totalMinutesListened: 300,
        ),
        StatTrack(
          trackName: 'Track 2',
          artistName: 'Artist 2',
          playCount: 4,
          totalMinutesListened: 280,
        ),
        StatTrack(
          trackName: 'Track 3',
          artistName: 'Artist 3',
          playCount: 3,
          totalMinutesListened: 240,
        ),
      ],
      topArtists: [
        StatArtist(
          name: 'Artist 1',
          playCount: 12,
          totalMinutesListened: 350,
        ),
        StatArtist(
          name: 'Artist 2',
          playCount: 10,
          totalMinutesListened: 300,
        ),
      ],
      topAlbums: [],
      generatedAt: DateTime.now(),
    );

    setUp(() {
      mockStatsService = MockStatsService();
      statsBloc = StatsBloc(statsService: mockStatsService);
    });

    tearDown(() {
      statsBloc.close();
    });

    test('initial state is StatsInitial', () {
      expect(statsBloc.state, isA<StatsInitial>());
    });

    // Happy path: Successfully generate stats
    blocTest<StatsBloc, StatsState>(
      'emits [StatsLoading, StatsLoaded] when GenerateStatsEvent succeeds',
      build: () => statsBloc,
      act: (bloc) {
        when(() => mockStatsService.calculateStats(any()))
            .thenAnswer((_) async => mockStats);

        bloc.add(GenerateStatsEvent(StatsPeriod.week));
      },
      expect: () => [
        isA<StatsLoading>()
            .having((state) => state.period, 'period', StatsPeriod.week),
        isA<StatsLoaded>()
            .having((state) => state.stats.topTracks.length, 'top tracks', 3)
            .having((state) => state.period, 'period', StatsPeriod.week),
      ],
    );

    // Error scenario: No stats data
    blocTest<StatsBloc, StatsState>(
      'emits [StatsLoading, StatsEmpty] when no stats are available',
      build: () => statsBloc,
      act: (bloc) {
        when(() => mockStatsService.calculateStats(any()))
            .thenAnswer((_) async => null);

        bloc.add(GenerateStatsEvent(StatsPeriod.month));
      },
      expect: () => [
        isA<StatsLoading>(),
        isA<StatsEmpty>(),
      ],
    );

    // Error scenario: Stats calculation fails
    blocTest<StatsBloc, StatsState>(
      'emits [StatsLoading, StatsError] when stats calculation fails',
      build: () => statsBloc,
      act: (bloc) {
        when(() => mockStatsService.calculateStats(any()))
            .thenThrow(Exception('Database error'));

        bloc.add(GenerateStatsEvent(StatsPeriod.week));
      },
      expect: () => [
        isA<StatsLoading>(),
        isA<StatsError>().having((state) => state.message, 'message',
            contains('Failed to generate stats')),
      ],
    );

    // Change period to month
    blocTest<StatsBloc, StatsState>(
      'emits [StatsLoading, StatsLoaded] when ChangePeriodEvent is added',
      build: () => statsBloc,
      act: (bloc) {
        final monthStats = UserStats(
          totalMinutesListened: 1200,
          topArtist: 'Drake',
          topTracks: mockStats.topTracks,
          topArtists: mockStats.topArtists,
          topAlbums: [],
          generatedAt: DateTime.now(),
        );
        when(() => mockStatsService.calculateStats(any()))
            .thenAnswer((_) async => monthStats);

        bloc.add(ChangePeriodEvent(StatsPeriod.month));
      },
      expect: () => [
        isA<StatsLoading>()
            .having((state) => state.period, 'period', StatsPeriod.month),
        isA<StatsLoaded>()
            .having((state) => state.period, 'period', StatsPeriod.month),
      ],
    );

    // Change period to year
    blocTest<StatsBloc, StatsState>(
      'correctly changes period to allTime when requested',
      build: () => statsBloc,
      act: (bloc) {
        final yearStats = UserStats(
          totalMinutesListened: 1200,
          topArtist: 'Drake',
          topTracks: mockStats.topTracks,
          topArtists: mockStats.topArtists,
          topAlbums: [],
          generatedAt: DateTime.now(),
        );
        when(() => mockStatsService.calculateStats(any()))
            .thenAnswer((_) async => yearStats);

        bloc.add(ChangePeriodEvent(StatsPeriod.allTime));
      },
      expect: () => [
        isA<StatsLoading>()
            .having((state) => state.period, 'period', StatsPeriod.allTime),
        isA<StatsLoaded>()
            .having((state) => state.period, 'period', StatsPeriod.allTime),
      ],
    );

    // Verify service call with correct period
    blocTest<StatsBloc, StatsState>(
      'calls statsService.calculateStats with correct period',
      build: () => statsBloc,
      act: (bloc) {
        when(() => mockStatsService.calculateStats(any()))
            .thenAnswer((_) async => mockStats);

        bloc.add(GenerateStatsEvent(StatsPeriod.week));
      },
      verify: (bloc) {
        verify(() => mockStatsService.calculateStats(StatsPeriod.week))
            .called(1);
      },
    );

    // Edge case: Empty top tracks
    blocTest<StatsBloc, StatsState>(
      'handles stats with empty top tracks gracefully',
      build: () => statsBloc,
      act: (bloc) {
        final emptyStats = UserStats(
          totalMinutesListened: 1200,
          topArtist: 'Drake',
          topTracks: [],
          topArtists: mockStats.topArtists,
          topAlbums: [],
          generatedAt: DateTime.now(),
        );

        when(() => mockStatsService.calculateStats(any()))
            .thenAnswer((_) async => emptyStats);

        bloc.add(GenerateStatsEvent(StatsPeriod.week));
      },
      expect: () => [
        isA<StatsLoading>(),
        isA<StatsLoaded>().having(
            (state) => state.stats.topTracks.isEmpty, 'empty tracks', true),
      ],
    );
  });
}
