import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_bloc.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_event.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_state.dart';
import 'package:spotify_clone/services/audio_player_service.dart';

class MockAudioPlayerService extends Mock implements AudioPlayerService {}

void main() {
  setUpAll(() {
    // Register fallback value for Duration
    registerFallbackValue(Duration.zero);
  });

  group('AudioPlayerBloc', () {
    late MockAudioPlayerService mockAudioPlayerService;
    late AudioPlayerBloc audioPlayerBloc;

    setUp(() {
      mockAudioPlayerService = MockAudioPlayerService();

      // Mock all required streams with empty streams
      when(() => mockAudioPlayerService.positionStream)
          .thenAnswer((_) => Stream<Duration?>.empty());
      when(() => mockAudioPlayerService.durationStream)
          .thenAnswer((_) => Stream<Duration?>.empty());
      when(() => mockAudioPlayerService.playerStateStream)
          .thenAnswer((_) => Stream<PlayerState>.empty());
      when(() => mockAudioPlayerService.sequenceStateStream)
          .thenAnswer((_) => Stream<SequenceState?>.empty());
      when(() => mockAudioPlayerService.dispose())
          .thenAnswer((_) async => Future.value());

      audioPlayerBloc = AudioPlayerBloc(
        audioPlayerService: mockAudioPlayerService,
      );
    });

    tearDown(() {
      audioPlayerBloc.close();
    });

    test('initial state is AudioPlayerInitial', () {
      expect(audioPlayerBloc.state, isA<AudioPlayerInitial>());
    });

    blocTest<AudioPlayerBloc, AudioPlayerState>(
      'emits Loading then Playing when PlaySongEvent is added',
      build: () => audioPlayerBloc,
      act: (bloc) {
        when(() => mockAudioPlayerService.playSingle(any()))
            .thenAnswer((_) async => Future.value());
        bloc.add(PlaySongEvent(
          audioUrl: 'https://example.com/song.mp3',
          songTitle: 'Test Song',
          artist: 'Test Artist',
          albumArt: 'https://example.com/art.jpg',
        ));
      },
      expect: () => [
        isA<AudioLoading>(),
        isA<AudioPlaying>(),
      ],
    );

    blocTest<AudioPlayerBloc, AudioPlayerState>(
      'emits Paused when PauseSongEvent is added from Playing state',
      build: () => audioPlayerBloc,
      seed: () => AudioPlaying(
        songTitle: 'Test Song',
        artist: 'Test Artist',
        albumArt: 'https://example.com/art.jpg',
        current: Duration.zero,
        total: const Duration(seconds: 180),
      ),
      act: (bloc) {
        when(() => mockAudioPlayerService.pause())
            .thenAnswer((_) async => Future.value());
        bloc.add(PauseSongEvent());
      },
      expect: () => [
        isA<AudioPaused>(),
      ],
    );

    blocTest<AudioPlayerBloc, AudioPlayerState>(
      'emits Playing when ResumeSongEvent is added from Paused state',
      build: () => audioPlayerBloc,
      seed: () => AudioPaused(
        songTitle: 'Test Song',
        artist: 'Test Artist',
        albumArt: 'https://example.com/art.jpg',
        current: const Duration(seconds: 30),
        total: const Duration(seconds: 180),
      ),
      act: (bloc) {
        when(() => mockAudioPlayerService.play())
            .thenAnswer((_) async => Future.value());
        bloc.add(ResumeSongEvent());
      },
      expect: () => [
        isA<AudioPlaying>(),
      ],
    );

    blocTest<AudioPlayerBloc, AudioPlayerState>(
      'emits AudioError when PlaySongEvent throws exception',
      build: () => audioPlayerBloc,
      act: (bloc) {
        when(() => mockAudioPlayerService.playSingle(any()))
            .thenThrow(Exception('Playback failed'));
        bloc.add(PlaySongEvent(
          audioUrl: 'https://example.com/song.mp3',
          songTitle: 'Test Song',
          artist: 'Test Artist',
          albumArt: 'https://example.com/art.jpg',
        ));
      },
      expect: () => [
        isA<AudioLoading>(),
        isA<AudioError>(),
      ],
    );

    blocTest<AudioPlayerBloc, AudioPlayerState>(
      'handles SeekToEvent correctly',
      build: () => audioPlayerBloc,
      seed: () => AudioPlaying(
        songTitle: 'Test Song',
        artist: 'Test Artist',
        albumArt: 'https://example.com/art.jpg',
        current: const Duration(seconds: 30),
        total: const Duration(seconds: 180),
      ),
      act: (bloc) {
        when(() => mockAudioPlayerService.seek(any()))
            .thenAnswer((_) async => Future.value());
        bloc.add(SeekToEvent(const Duration(seconds: 60)));
      },
      expect: () => [
        isA<AudioPlaying>(),
      ],
    );

    blocTest<AudioPlayerBloc, AudioPlayerState>(
      'emits appropriate state when StopSongEvent is added',
      build: () => audioPlayerBloc,
      seed: () => AudioPlaying(
        songTitle: 'Test Song',
        artist: 'Test Artist',
        albumArt: 'https://example.com/art.jpg',
        current: const Duration(seconds: 30),
        total: const Duration(seconds: 180),
      ),
      act: (bloc) {
        when(() => mockAudioPlayerService.stop())
            .thenAnswer((_) async => Future.value());
        bloc.add(StopSongEvent());
      },
      expect: () => [
        isA<AudioStopped>(),
      ],
    );

    blocTest<AudioPlayerBloc, AudioPlayerState>(
      'handles SkipNextEvent when queue is available',
      build: () => audioPlayerBloc,
      seed: () => AudioPlaying(
        songTitle: 'Song 1',
        artist: 'Artist 1',
        albumArt: 'https://example.com/art1.jpg',
        current: Duration.zero,
        total: const Duration(seconds: 180),
      ),
      act: (bloc) {
        when(() => mockAudioPlayerService.skipToNext())
            .thenAnswer((_) async {});
        bloc.add(SkipNextEvent());
      },
      expect: () => [],
    );

    blocTest<AudioPlayerBloc, AudioPlayerState>(
      'handles SkipPreviousEvent when queue is available',
      build: () => audioPlayerBloc,
      seed: () => AudioPlaying(
        songTitle: 'Song 2',
        artist: 'Artist 2',
        albumArt: 'https://example.com/art2.jpg',
        current: const Duration(seconds: 30),
        total: const Duration(seconds: 180),
      ),
      act: (bloc) {
        when(() => mockAudioPlayerService.skipToPrevious())
            .thenAnswer((_) async {});
        bloc.add(SkipPreviousEvent());
      },
      expect: () => [],
    );

    blocTest<AudioPlayerBloc, AudioPlayerState>(
      'handles SetPlaybackSpeedEvent',
      build: () => audioPlayerBloc,
      seed: () => AudioPlaying(
        songTitle: 'Test Song',
        artist: 'Test Artist',
        albumArt: 'https://example.com/art.jpg',
        current: const Duration(seconds: 30),
        total: const Duration(seconds: 180),
      ),
      act: (bloc) {
        when(() => mockAudioPlayerService.setSpeed(1.5))
            .thenAnswer((_) async {});
        bloc.add(SetPlaybackSpeedEvent(1.5));
      },
      expect: () => [],
    );

    blocTest<AudioPlayerBloc, AudioPlayerState>(
      'sets sleep timer when SetSleepTimerEvent is added',
      build: () => audioPlayerBloc,
      seed: () => AudioPlaying(
        songTitle: 'Test Song',
        artist: 'Test Artist',
        albumArt: 'https://example.com/art.jpg',
        current: Duration.zero,
        total: const Duration(seconds: 180),
      ),
      act: (bloc) {
        bloc.add(SetSleepTimerEvent(const Duration(minutes: 15)));
      },
      expect: () => [
        isA<SleepTimerActive>(),
      ],
    );

    blocTest<AudioPlayerBloc, AudioPlayerState>(
      'cancels sleep timer when CancelSleepTimerEvent is added',
      build: () => audioPlayerBloc,
      seed: () => SleepTimerActive(
        remainingTime: const Duration(minutes: 10),
        totalDuration: const Duration(minutes: 15),
      ),
      act: (bloc) {
        bloc.add(CancelSleepTimerEvent());
      },
      expect: () => [
        isA<SleepTimerCancelled>(),
      ],
    );

    blocTest<AudioPlayerBloc, AudioPlayerState>(
      'updates sleep timer countdown with SleepTimerTickEvent',
      build: () => audioPlayerBloc,
      seed: () => SleepTimerActive(
        remainingTime: const Duration(minutes: 5),
        totalDuration: const Duration(minutes: 10),
      ),
      act: (bloc) {
        bloc.add(SleepTimerTickEvent(const Duration(minutes: 4)));
      },
      expect: () => [
        isA<SleepTimerActive>(),
      ],
    );

    blocTest<AudioPlayerBloc, AudioPlayerState>(
      'handles SetLoopModeEvent to change repeat mode',
      build: () => audioPlayerBloc,
      seed: () => AudioPlaying(
        songTitle: 'Test Song',
        artist: 'Test Artist',
        albumArt: 'https://example.com/art.jpg',
        current: Duration.zero,
        total: const Duration(seconds: 180),
      ),
      act: (bloc) {
        when(() => mockAudioPlayerService.setLoopMode(1))
            .thenAnswer((_) async {});
        bloc.add(SetLoopModeEvent(1)); // Set to all repeat
      },
      expect: () => [],
    );

    blocTest<AudioPlayerBloc, AudioPlayerState>(
      'handles SetShuffleModeEvent',
      build: () => audioPlayerBloc,
      seed: () => AudioPlaying(
        songTitle: 'Test Song',
        artist: 'Test Artist',
        albumArt: 'https://example.com/art.jpg',
        current: Duration.zero,
        total: const Duration(seconds: 180),
      ),
      act: (bloc) {
        when(() => mockAudioPlayerService.setShuffle(true))
            .thenAnswer((_) async {});
        bloc.add(SetShuffleModeEvent(true));
      },
      expect: () => [],
    );

    blocTest<AudioPlayerBloc, AudioPlayerState>(
      'emits AudioError when SeekToEvent fails',
      build: () => audioPlayerBloc,
      seed: () => AudioPlaying(
        songTitle: 'Test Song',
        artist: 'Test Artist',
        albumArt: 'https://example.com/art.jpg',
        current: const Duration(seconds: 30),
        total: const Duration(seconds: 180),
      ),
      act: (bloc) {
        when(() => mockAudioPlayerService.seek(any()))
            .thenThrow(Exception('Seek failed'));
        bloc.add(SeekToEvent(const Duration(seconds: 60)));
      },
      expect: () => [
        isA<AudioError>(),
      ],
    );

    blocTest<AudioPlayerBloc, AudioPlayerState>(
      'handles PositionUpdateEvent for UI synchronization',
      build: () => audioPlayerBloc,
      seed: () => AudioPlaying(
        songTitle: 'Test Song',
        artist: 'Test Artist',
        albumArt: 'https://example.com/art.jpg',
        current: const Duration(seconds: 30),
        total: const Duration(seconds: 180),
      ),
      act: (bloc) {
        bloc.add(PositionUpdateEvent(const Duration(seconds: 45)));
      },
      expect: () => [
        isA<AudioPlaying>(),
      ],
    );
  });
}

