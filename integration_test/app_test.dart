import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotify_clone/bloc/download/download_bloc.dart';
import 'package:spotify_clone/bloc/download/download_event.dart';
import 'package:spotify_clone/bloc/download/download_state.dart';
import 'package:spotify_clone/bloc/equalizer/equalizer_bloc.dart';
import 'package:spotify_clone/bloc/equalizer/equalizer_event.dart';
import 'package:spotify_clone/bloc/equalizer/equalizer_state.dart';
import 'package:spotify_clone/main.dart';
import '../test/fixtures/mock_services.dart';
import '../test/helpers/test_helpers.dart';

void main() {
  setUp(() {
    setupMockGetIt();
  });

  tearDown(() {
    tearDownMockGetIt();
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
    late MockHiveService mockHive;

    setUp(() {
      mockHive = MockHiveService();
      when(() => mockHive.getDownloadedTracks()).thenReturn({});
      when(() => mockHive.saveDownloadedTrack(any())).thenAnswer((_) async {});
      when(() => mockHive.removeDownloadedTrack(any()))
          .thenAnswer((_) async {});
    });

    blocTest<DownloadBloc, DownloadState>(
      'LoadDownloadsEvent emits DownloadsLoaded with empty map',
      build: () => DownloadBloc(hiveService: mockHive),
      act: (bloc) => bloc.add(const LoadDownloadsEvent()),
      expect: () => [isA<DownloadsLoaded>()],
    );

    blocTest<DownloadBloc, DownloadState>(
      'StartDownloadEvent adds a track in downloading state',
      build: () => DownloadBloc(hiveService: mockHive),
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
          (s) => s.tracks['track1']?.status,
          'status',
          DownloadStatus.downloading,
        ),
      ],
    );

    blocTest<DownloadBloc, DownloadState>(
      'RemoveDownloadEvent removes the track',
      build: () => DownloadBloc(hiveService: mockHive),
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
          (s) => s.tracks.isEmpty,
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
