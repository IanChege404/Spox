import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotify_clone/bloc/download/download_bloc.dart';
import 'package:spotify_clone/bloc/download/download_event.dart';
import 'package:spotify_clone/bloc/download/download_state.dart';
import 'package:spotify_clone/services/hive_service.dart';

class MockHiveService extends Mock implements HiveService {}

void main() {
  group('DownloadBloc', () {
    late DownloadBloc downloadBloc;
    late MockHiveService mockHiveService;

    setUp(() {
      mockHiveService = MockHiveService();
      when(() => mockHiveService.getDownloadedTracks()).thenReturn({});
      when(() => mockHiveService.saveDownloadedTrack(any()))
          .thenAnswer((_) async {});
      when(() => mockHiveService.removeDownloadedTrack(any()))
          .thenAnswer((_) async {});

      downloadBloc = DownloadBloc(hiveService: mockHiveService);
    });

    tearDown(() {
      downloadBloc.close();
    });

    test('initial state is DownloadInitial', () {
      expect(downloadBloc.state, isA<DownloadInitial>());
    });

    blocTest<DownloadBloc, DownloadState>(
      'LoadDownloadsEvent emits DownloadsLoaded with empty tracks',
      build: () => downloadBloc,
      act: (bloc) => bloc.add(const LoadDownloadsEvent()),
      expect: () => [
        isA<DownloadsLoaded>().having(
          (s) => s.tracks.isEmpty,
          'tracks empty',
          true,
        ),
      ],
    );

    blocTest<DownloadBloc, DownloadState>(
      'StartDownloadEvent adds track in downloading state',
      build: () => downloadBloc,
      seed: () => const DownloadsLoaded({}),
      act: (bloc) => bloc.add(const StartDownloadEvent(
        trackId: 'abc123',
        trackName: 'Test Track',
        artist: 'Test Artist',
        albumArt: 'https://example.com/art.jpg',
        audioUrl: 'https://example.com/audio.mp3',
      )),
      expect: () => [
        isA<DownloadsLoaded>().having(
          (s) => s.tracks['abc123']?.status,
          'status',
          DownloadStatus.downloading,
        ),
      ],
    );

    blocTest<DownloadBloc, DownloadState>(
      'StartDownloadEvent is idempotent for existing track',
      build: () => downloadBloc,
      seed: () => DownloadsLoaded({
        'abc123': const DownloadedTrack(
          trackId: 'abc123',
          trackName: 'Test Track',
          artist: 'Test Artist',
          status: DownloadStatus.downloading,
        ),
      }),
      act: (bloc) => bloc.add(const StartDownloadEvent(
        trackId: 'abc123',
        trackName: 'Test Track',
        artist: 'Test Artist',
      )),
      // No new states emitted because track already exists
      expect: () => [],
    );

    blocTest<DownloadBloc, DownloadState>(
      'UpdateDownloadProgressEvent updates track progress',
      build: () => downloadBloc,
      seed: () => DownloadsLoaded({
        'abc123': const DownloadedTrack(
          trackId: 'abc123',
          trackName: 'Test Track',
          artist: 'Test Artist',
          status: DownloadStatus.downloading,
          progress: 0.0,
        ),
      }),
      act: (bloc) => bloc.add(const UpdateDownloadProgressEvent(
        trackId: 'abc123',
        progress: 0.5,
      )),
      expect: () => [
        isA<DownloadsLoaded>().having(
          (s) => s.tracks['abc123']?.progress,
          'progress',
          0.5,
        ),
      ],
    );

    blocTest<DownloadBloc, DownloadState>(
      'CompleteDownloadEvent marks track as downloaded',
      build: () => downloadBloc,
      seed: () => DownloadsLoaded({
        'abc123': const DownloadedTrack(
          trackId: 'abc123',
          trackName: 'Test Track',
          artist: 'Test Artist',
          status: DownloadStatus.downloading,
          progress: 0.9,
        ),
      }),
      act: (bloc) => bloc.add(const CompleteDownloadEvent('abc123')),
      expect: () => [
        isA<DownloadsLoaded>().having(
          (s) => s.tracks['abc123']?.status,
          'status',
          DownloadStatus.downloaded,
        ),
      ],
    );

    blocTest<DownloadBloc, DownloadState>(
      'RemoveDownloadEvent removes track from list',
      build: () => downloadBloc,
      seed: () => DownloadsLoaded({
        'abc123': const DownloadedTrack(
          trackId: 'abc123',
          trackName: 'Test Track',
          artist: 'Test Artist',
          status: DownloadStatus.downloaded,
        ),
        'def456': const DownloadedTrack(
          trackId: 'def456',
          trackName: 'Another Track',
          artist: 'Another Artist',
          status: DownloadStatus.downloaded,
        ),
      }),
      act: (bloc) => bloc.add(const RemoveDownloadEvent('abc123')),
      expect: () => [
        isA<DownloadsLoaded>().having(
          (s) => s.tracks.containsKey('abc123'),
          'track removed',
          false,
        ),
      ],
    );

    test('DownloadsLoaded.downloadedTracks returns only downloaded tracks', () {
      final state = DownloadsLoaded({
        'a': const DownloadedTrack(
          trackId: 'a',
          trackName: 'Track A',
          artist: 'Artist A',
          status: DownloadStatus.downloaded,
        ),
        'b': const DownloadedTrack(
          trackId: 'b',
          trackName: 'Track B',
          artist: 'Artist B',
          status: DownloadStatus.downloading,
        ),
      });
      expect(state.downloadedTracks.length, 1);
      expect(state.downloadedTracks.first.trackId, 'a');
    });

    test('DownloadsLoaded.inProgressTracks returns only downloading tracks', () {
      final state = DownloadsLoaded({
        'a': const DownloadedTrack(
          trackId: 'a',
          trackName: 'Track A',
          artist: 'Artist A',
          status: DownloadStatus.downloaded,
        ),
        'b': const DownloadedTrack(
          trackId: 'b',
          trackName: 'Track B',
          artist: 'Artist B',
          status: DownloadStatus.downloading,
        ),
      });
      expect(state.inProgressTracks.length, 1);
      expect(state.inProgressTracks.first.trackId, 'b');
    });
  });
}
