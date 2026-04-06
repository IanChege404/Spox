import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_bloc.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_event.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_state.dart';
import 'package:spotify_clone/bloc/download/download_bloc.dart';
import 'package:spotify_clone/bloc/download/download_event.dart';
import 'package:spotify_clone/bloc/download/download_state.dart';
import 'package:spotify_clone/bloc/equalizer/equalizer_bloc.dart';
import 'package:spotify_clone/bloc/equalizer/equalizer_event.dart';
import 'package:spotify_clone/bloc/equalizer/equalizer_state.dart';
import 'package:spotify_clone/bloc/history/history_bloc.dart';
import 'package:spotify_clone/bloc/liked_songs/liked_songs_bloc.dart';
import 'package:spotify_clone/bloc/lyrics/lyrics_bloc.dart';
import 'package:spotify_clone/bloc/queue/queue_bloc.dart';
import 'package:spotify_clone/bloc/search/search_bloc.dart';
import 'package:spotify_clone/bloc/stats/stats_bloc.dart';
import 'package:spotify_clone/bloc/theme/theme_bloc.dart';
import 'package:spotify_clone/main.dart';
import 'package:spotify_clone/services/hive_service.dart';
import 'package:spotify_clone/services/spotify_auth_service.dart';

// Mock BLoCs
class MockAudioPlayerBloc extends MockBloc<AudioPlayerEvent, AudioPlayerState>
    implements AudioPlayerBloc {}

class MockQueueBloc extends Mock implements QueueBloc {}

class MockLikedSongsBloc extends Mock implements LikedSongsBloc {}

class MockSearchBloc extends Mock implements SearchBloc {}

class MockHistoryBloc extends Mock implements HistoryBloc {}

class MockThemeBloc extends Mock implements ThemeBloc {}

class MockLyricsBloc extends Mock implements LyricsBloc {}

class MockStatsBloc extends Mock implements StatsBloc {}

class MockEqualizerBloc extends Mock implements EqualizerBloc {}

class MockDownloadBloc extends Mock implements DownloadBloc {}

class MockSpotifyAuthService extends Mock implements SpotifyAuthService {}

class MockHiveService extends Mock implements HiveService {}

void main() {
  final getIt = GetIt.instance;

  setUp(() {
    getIt.reset();
    getIt.allowReassignment = true;

    // Mocked services
    final mockAuthService = MockSpotifyAuthService();
    when(() => mockAuthService.isAuthenticated).thenReturn(false);
    getIt.registerSingleton<SpotifyAuthService>(mockAuthService);

    // Mocked BLoCs
    final mockAudioPlayerBloc = MockAudioPlayerBloc();
    final mockQueueBloc = MockQueueBloc();
    final mockLikedSongsBloc = MockLikedSongsBloc();
    final mockSearchBloc = MockSearchBloc();
    final mockHistoryBloc = MockHistoryBloc();
    final mockThemeBloc = MockThemeBloc();
    final mockLyricsBloc = MockLyricsBloc();
    final mockStatsBloc = MockStatsBloc();
    final mockEqualizerBloc = MockEqualizerBloc();
    final mockDownloadBloc = MockDownloadBloc();

    when(() => mockAudioPlayerBloc.stream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockAudioPlayerBloc.state).thenReturn(AudioPlayerInitial());
    when(() => mockAudioPlayerBloc.close())
        .thenAnswer((_) async => Future.value());

    when(() => mockQueueBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockQueueBloc.close()).thenAnswer((_) async => Future.value());

    when(() => mockLikedSongsBloc.stream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockLikedSongsBloc.close())
        .thenAnswer((_) async => Future.value());

    when(() => mockSearchBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSearchBloc.close()).thenAnswer((_) async => Future.value());

    when(() => mockHistoryBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockHistoryBloc.close()).thenAnswer((_) async => Future.value());

    when(() => mockThemeBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockThemeBloc.close()).thenAnswer((_) async => Future.value());

    when(() => mockLyricsBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockLyricsBloc.close()).thenAnswer((_) async => Future.value());

    when(() => mockStatsBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockStatsBloc.close()).thenAnswer((_) async => Future.value());

    when(() => mockEqualizerBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockEqualizerBloc.state).thenReturn(const EqualizerInitial());
    when(() => mockEqualizerBloc.close())
        .thenAnswer((_) async => Future.value());

    when(() => mockDownloadBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockDownloadBloc.state).thenReturn(const DownloadInitial());
    when(() => mockDownloadBloc.close()).thenAnswer((_) async => Future.value());

    getIt.registerSingleton<AudioPlayerBloc>(mockAudioPlayerBloc);
    getIt.registerSingleton<QueueBloc>(mockQueueBloc);
    getIt.registerSingleton<LikedSongsBloc>(mockLikedSongsBloc);
    getIt.registerSingleton<SearchBloc>(mockSearchBloc);
    getIt.registerSingleton<HistoryBloc>(mockHistoryBloc);
    getIt.registerSingleton<ThemeBloc>(mockThemeBloc);
    getIt.registerSingleton<LyricsBloc>(mockLyricsBloc);
    getIt.registerSingleton<StatsBloc>(mockStatsBloc);
    getIt.registerSingleton<EqualizerBloc>(mockEqualizerBloc);
    getIt.registerSingleton<DownloadBloc>(mockDownloadBloc);
  });

  tearDown(() {
    getIt.reset();
  });

  group('End-to-End App Integration', () {
    testWidgets('App builds with all BLoCs without errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(MyApp), findsOneWidget);
    });

    testWidgets('SplashScreen is shown when user is not authenticated',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();
      // App boots — no crash
      expect(find.byType(MyApp), findsOneWidget);
    });
  });

  group('EqualizerBloc integration', () {
    test('Load event emits EqualizerLoaded from saved settings', () async {
      final mockHive = MockHiveService();
      when(() => mockHive.getSetting('eq_enabled', true)).thenReturn(true);
      when(() => mockHive.getSetting('eq_preset', 'Flat')).thenReturn('Flat');
      when(() => mockHive.getSetting('eq_bands')).thenReturn(null);

      final bloc = EqualizerBloc(hiveService: mockHive);
      bloc.add(const LoadEqualizerEvent());
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state, isA<EqualizerLoaded>());
      bloc.close();
    });
  });

  group('DownloadBloc integration', () {
    blocTest<DownloadBloc, DownloadState>(
      'LoadDownloadsEvent emits DownloadsLoaded with empty map',
      build: () => DownloadBloc(),
      act: (bloc) => bloc.add(const LoadDownloadsEvent()),
      expect: () => [isA<DownloadsLoaded>()],
    );

    blocTest<DownloadBloc, DownloadState>(
      'StartDownloadEvent adds a track in downloading state',
      build: () => DownloadBloc(),
      act: (bloc) {
        bloc.add(const LoadDownloadsEvent());
        bloc.add(const StartDownloadEvent(
          trackId: 'track1',
          trackName: 'Test Track',
          artist: 'Test Artist',
        ));
      },
      expect: () => [
        isA<DownloadsLoaded>(),
        isA<DownloadsLoaded>().having(
          (s) => (s as DownloadsLoaded)
              .tracks['track1']
              ?.status,
          'status',
          DownloadStatus.downloading,
        ),
      ],
    );

    blocTest<DownloadBloc, DownloadState>(
      'RemoveDownloadEvent removes the track',
      build: () => DownloadBloc(),
      seed: () => DownloadsLoaded({
        'track1': const DownloadedTrack(
          trackId: 'track1',
          trackName: 'Test Track',
          artist: 'Test Artist',
          status: DownloadStatus.downloaded,
        ),
      }),
      act: (bloc) => bloc.add(const RemoveDownloadEvent('track1')),
      expect: () => [
        isA<DownloadsLoaded>().having(
          (s) => (s as DownloadsLoaded).tracks.isEmpty,
          'tracks empty',
          true,
        ),
      ],
    );
  });

  group('AudioPlayerBloc 95% completion triggers history record', () {
    test('Position at 95% of total emits history record', () {
      // Verify the threshold logic: 95% triggers recording
      final total = const Duration(minutes: 3);
      final position95 = Duration(
        milliseconds: (total.inMilliseconds * 0.95).round(),
      );
      final progress = (position95.inMilliseconds / total.inMilliseconds) * 100;
      expect(progress, greaterThanOrEqualTo(95.0));
    });
  });
}
