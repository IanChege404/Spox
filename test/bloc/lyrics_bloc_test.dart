import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotify_clone/bloc/lyrics/lyrics_bloc.dart';
import 'package:spotify_clone/bloc/lyrics/lyrics_event.dart';
import 'package:spotify_clone/bloc/lyrics/lyrics_state.dart';
import 'package:spotify_clone/data/model/lyrics.dart';
import 'package:spotify_clone/services/lyrics_service.dart';

class MockLyricsService extends Mock implements LyricsService {}

void main() {
  group('LyricsBloc', () {
    late MockLyricsService mockLyricsService;
    late LyricsBloc lyricsBloc;

    final mockLyrics = Lyrics(
      trackName: 'Test Song',
      artistName: 'Test Artist',
      lines: [
        LyricLine(
          text: 'Verse 1',
          timestamp: Duration.zero,
        ),
        LyricLine(
          text: 'Chorus',
          timestamp: const Duration(milliseconds: 30000),
        ),
        LyricLine(
          text: 'Verse 2',
          timestamp: const Duration(milliseconds: 60000),
        ),
      ],
    );

    setUp(() {
      mockLyricsService = MockLyricsService();
      lyricsBloc = LyricsBloc(lyricsService: mockLyricsService);
    });

    tearDown(() {
      lyricsBloc.close();
    });

    test('initial state is LyricsInitial', () {
      expect(lyricsBloc.state, isA<LyricsInitial>());
    });

    // Happy path: Successfully fetch lyrics
    blocTest<LyricsBloc, LyricsState>(
      'emits [LyricsLoading, LyricsLoaded] when lyrics are found',
      build: () => lyricsBloc,
      act: (bloc) {
        when(() => mockLyricsService.fetchLyrics(
              trackName: any(named: 'trackName'),
              artistName: any(named: 'artistName'),
            )).thenAnswer((_) async => mockLyrics);

        bloc.add(const FetchLyricsEvent(
          trackName: 'Test Song',
          artistName: 'Test Artist',
        ));
      },
      expect: () => [
        isA<LyricsLoading>(),
        isA<LyricsLoaded>()
            .having((state) => state.lyrics.trackName, 'track name',
                'Test Song')
            .having((state) => state.lyrics.lines.length, 'lines count', 3)
            .having((state) => state.currentLine?.text, 'first line',
                'Verse 1'),
      ],
    );

    // Error scenario: Lyrics not found
    blocTest<LyricsBloc, LyricsState>(
      'emits [LyricsLoading, LyricsNotFound] when lyrics are not found',
      build: () => lyricsBloc,
      act: (bloc) {
        when(() => mockLyricsService.fetchLyrics(
              trackName: any(named: 'trackName'),
              artistName: any(named: 'artistName'),
            )).thenAnswer((_) async => null);

        bloc.add(const FetchLyricsEvent(
          trackName: 'Unknown Song',
          artistName: 'Unknown Artist',
        ));
      },
      expect: () => [
        isA<LyricsLoading>(),
        isA<LyricsNotFound>()
            .having((state) => state.trackName, 'track name', 'Unknown Song'),
      ],
    );

    // Error scenario: Network or API failure
    blocTest<LyricsBloc, LyricsState>(
      'emits [LyricsLoading, LyricsError] when fetching lyrics fails',
      build: () => lyricsBloc,
      act: (bloc) {
        when(() => mockLyricsService.fetchLyrics(
              trackName: any(named: 'trackName'),
              artistName: any(named: 'artistName'),
            )).thenThrow(Exception('Network error'));

        bloc.add(const FetchLyricsEvent(
          trackName: 'Test Song',
          artistName: 'Test Artist',
        ));
      },
      expect: () => [
        isA<LyricsLoading>(),
        isA<LyricsError>().having((state) => state.message, 'message',
            contains('Failed to fetch lyrics')),
      ],
    );

    // Update lyrics position (auto-scroll)
    blocTest<LyricsBloc, LyricsState>(
      'emits LyricsLoaded with updated position when UpdateLyricsPositionEvent is added',
      build: () => lyricsBloc,
      seed: () => LyricsLoaded(
        lyrics: mockLyrics,
        currentPosition: Duration.zero,
        currentLine: mockLyrics.lines.first,
      ),
      act: (bloc) {
        bloc.add(const UpdateLyricsPositionEvent(Duration(seconds: 35)));
      },
      expect: () => [
        isA<LyricsLoaded>()
            .having((state) => state.currentPosition, 'current position',
                const Duration(seconds: 35))
            .having((state) => state.currentLine?.text, 'current line',
                'Chorus'), // Should match the line at 30s
      ],
    );

    // Clear lyrics
    blocTest<LyricsBloc, LyricsState>(
      'emits LyricsInitial when ClearLyricsEvent is added',
      build: () => lyricsBloc,
      seed: () => LyricsLoaded(
        lyrics: mockLyrics,
        currentPosition: Duration.zero,
        currentLine: mockLyrics.lines.first,
      ),
      act: (bloc) {
        bloc.add(const ClearLyricsEvent());
      },
      expect: () => [
        isA<LyricsInitial>(),
      ],
    );

    // Verify service method calls
    blocTest<LyricsBloc, LyricsState>(
      'calls lyricsService.fetchLyrics with correct parameters',
      build: () => lyricsBloc,
      act: (bloc) {
        when(() => mockLyricsService.fetchLyrics(
              trackName: any(named: 'trackName'),
              artistName: any(named: 'artistName'),
            )).thenAnswer((_) async => mockLyrics);

        bloc.add(const FetchLyricsEvent(
          trackName: 'Song Title',
          artistName: 'Artist Name',
        ));
      },
      verify: (bloc) {
        verify(() => mockLyricsService.fetchLyrics(
              trackName: 'Song Title',
              artistName: 'Artist Name',
            )).called(1);
      },
    );

    // Edge case: Empty lyrics lines
    blocTest<LyricsBloc, LyricsState>(
      'handles lyrics with no lines gracefully',
      build: () => lyricsBloc,
      act: (bloc) {
        final emptyLyrics = Lyrics(
          trackName: 'No Lyrics Song',
          artistName: 'Test Artist',
          lines: [],
        );

        when(() => mockLyricsService.fetchLyrics(
              trackName: any(named: 'trackName'),
              artistName: any(named: 'artistName'),
            )).thenAnswer((_) async => emptyLyrics);

        bloc.add(const FetchLyricsEvent(
          trackName: 'No Lyrics Song',
          artistName: 'Test Artist',
        ));
      },
      expect: () => [
        isA<LyricsLoading>(),
        isA<LyricsLoaded>()
            .having((state) => state.lyrics.lines.isEmpty, 'empty lines', true)
            .having((state) => state.currentLine, 'current line', null),
      ],
    );
  });
}
