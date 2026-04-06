import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotify_clone/services/audio_player_service.dart';

/// Mock AudioPlayer for testing
class MockAudioPlayer extends Mock implements AudioPlayer {}

void main() {
  setUpAll(() {
    // Initialize Flutter binding before platform channels are used
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('AudioPlayerService', () {
    late AudioPlayerService audioPlayerService;
    late MockAudioPlayer mockAudioPlayer;

    setUp(() {
      mockAudioPlayer = MockAudioPlayer();

      // Setup default mock behaviors
      when(() => mockAudioPlayer.positionStream)
          .thenAnswer((_) => Stream<Duration>.empty());
      when(() => mockAudioPlayer.durationStream)
          .thenAnswer((_) => Stream<Duration>.empty());
      when(() => mockAudioPlayer.playerStateStream)
          .thenAnswer((_) => Stream<PlayerState>.empty());
      when(() => mockAudioPlayer.sequenceStateStream)
          .thenAnswer((_) => Stream<SequenceState?>.empty());

      when(() => mockAudioPlayer.playing).thenReturn(false);
      when(() => mockAudioPlayer.position).thenReturn(Duration.zero);
      when(() => mockAudioPlayer.duration)
          .thenReturn(const Duration(seconds: 180));

      // Inject the mock AudioPlayer into the service
      audioPlayerService = AudioPlayerService(audioPlayer: mockAudioPlayer);
    });

    group('Stream Getters', () {
      test('positionStream returns audio player position stream', () {
        // Act & Assert
        expect(audioPlayerService.positionStream, isNotNull);
      });

      test('durationStream returns audio player duration stream', () {
        // Act & Assert
        expect(audioPlayerService.durationStream, isNotNull);
      });

      test('playerStateStream returns audio player state stream', () {
        // Act & Assert
        expect(audioPlayerService.playerStateStream, isNotNull);
      });

      test('sequenceStateStream returns audio player sequence state stream',
          () {
        // Act & Assert
        expect(audioPlayerService.sequenceStateStream, isNotNull);
      });
    });

    group('State Getters', () {
      test('currentPosition returns current playback position', () {
        // Arrange
        const expectedPosition = Duration(seconds: 30);
        when(() => mockAudioPlayer.position).thenReturn(expectedPosition);

        // Act
        final position = audioPlayerService.currentPosition;

        // Assert
        expect(position, expectedPosition);
      });

      test('duration returns total track duration', () {
        // Arrange
        const expectedDuration = Duration(seconds: 200);
        when(() => mockAudioPlayer.duration).thenReturn(expectedDuration);

        // Act
        final duration = audioPlayerService.duration;

        // Assert
        expect(duration, expectedDuration);
      });

      test('isPlaying returns true when audio is playing', () {
        // Arrange
        when(() => mockAudioPlayer.playing).thenReturn(true);

        // Act
        final isPlaying = audioPlayerService.isPlaying;

        // Assert
        expect(isPlaying, true);
      });

      test('isPlaying returns false when audio is paused', () {
        // Arrange
        when(() => mockAudioPlayer.playing).thenReturn(false);

        // Act
        final isPlaying = audioPlayerService.isPlaying;

        // Assert
        expect(isPlaying, false);
      });
    });

    group('Playback Control', () {
      test('play() starts playback', () async {
        // Arrange
        when(() => mockAudioPlayer.play()).thenAnswer((_) async {});

        // Act
        await audioPlayerService.play();

        // Assert
        verify(() => mockAudioPlayer.play()).called(1);
      });

      test('pause() pauses playback', () async {
        // Arrange
        when(() => mockAudioPlayer.pause()).thenAnswer((_) async {});

        // Act
        await audioPlayerService.pause();

        // Assert
        verify(() => mockAudioPlayer.pause()).called(1);
      });

      test('stop() stops playback and resets position', () async {
        // Arrange
        when(() => mockAudioPlayer.stop()).thenAnswer((_) async {});

        // Act
        await audioPlayerService.stop();

        // Assert
        verify(() => mockAudioPlayer.stop()).called(1);
      });

      test('dispose() releases audio player resources', () async {
        // Arrange
        when(() => mockAudioPlayer.dispose()).thenAnswer((_) async {});

        // Act
        await audioPlayerService.dispose();

        // Assert
        verify(() => mockAudioPlayer.dispose()).called(1);
      });
    });

    group('Seeking & Position Control', () {
      test('seek() jumps to specified duration', () async {
        // Arrange
        const targetPosition = Duration(seconds: 90);
        when(() => mockAudioPlayer.seek(any())).thenAnswer((_) async {});

        // Act
        await audioPlayerService.seek(targetPosition);

        // Assert
        verify(() => mockAudioPlayer.seek(targetPosition)).called(1);
      });

      test('seek() with zero duration resets to start', () async {
        // Arrange
        when(() => mockAudioPlayer.seek(any())).thenAnswer((_) async {});

        // Act
        await audioPlayerService.seek(Duration.zero);

        // Assert
        verify(() => mockAudioPlayer.seek(Duration.zero)).called(1);
      });

      test('seek() handles position beyond duration gracefully', () async {
        // Arrange
        const beyondDuration = Duration(seconds: 9999);
        when(() => mockAudioPlayer.seek(any()))
            .thenAnswer((_) => Future.value());

        // Act
        await audioPlayerService.seek(beyondDuration);

        // Assert - Should attempt to seek even if beyond duration
        verify(() => mockAudioPlayer.seek(beyondDuration)).called(1);
      });
    });

    group('Playback Speed', () {
      test('setPlaybackSpeed() sets speed multiplier', () async {
        // Arrange
        when(() => mockAudioPlayer.setSpeed(any())).thenAnswer((_) async {});

        // Act
        await audioPlayerService.setSpeed(1.5);

        // Assert
        verify(() => mockAudioPlayer.setSpeed(1.5)).called(1);
      });

      test('setPlaybackSpeed() with 0.5 sets slow speed', () async {
        // Arrange
        when(() => mockAudioPlayer.setSpeed(any())).thenAnswer((_) async {});

        // Act
        await audioPlayerService.setSpeed(0.5);

        // Assert
        verify(() => mockAudioPlayer.setSpeed(0.5)).called(1);
      });

      test('setPlaybackSpeed() with 2.0 sets fast speed', () async {
        // Arrange
        when(() => mockAudioPlayer.setSpeed(any())).thenAnswer((_) async {});

        // Act
        await audioPlayerService.setSpeed(2.0);

        // Assert
        verify(() => mockAudioPlayer.setSpeed(2.0)).called(1);
      });
    });

    group('Error Handling', () {
      test('play() throws exception on audio load failure', () async {
        // Arrange
        when(() => mockAudioPlayer.play())
            .thenThrow(Exception('Cannot load audio'));

        // Act & Assert
        expect(
          audioPlayerService.play(),
          throwsA(isA<Exception>()),
        );
      });

      test('seek() with negative duration throws', () async {
        // Arrange
        const negativeDuration = Duration(seconds: -10);
        when(() => mockAudioPlayer.seek(any()))
            .thenThrow(Exception('Invalid seek position'));

        // Act & Assert
        expect(
          audioPlayerService.seek(negativeDuration),
          throwsA(isA<Exception>()),
        );
      });

      test('setPlaybackSpeed() with zero speed throws', () async {
        // Arrange
        when(() => mockAudioPlayer.setSpeed(0))
            .thenThrow(Exception('Speed must be > 0'));

        // Act & Assert
        expect(
          audioPlayerService.setSpeed(0),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Lifecycle', () {
      test('service can be created and disposed', () async {
        // Arrange
        when(() => mockAudioPlayer.dispose()).thenAnswer((_) async {});

        // Act
        await audioPlayerService.dispose();

        // Assert
        verify(() => mockAudioPlayer.dispose()).called(1);
      });

      test('multiple play/pause cycles work correctly', () async {
        // Arrange
        when(() => mockAudioPlayer.play()).thenAnswer((_) async {});
        when(() => mockAudioPlayer.pause()).thenAnswer((_) async {});

        // Act
        await audioPlayerService.play();
        await audioPlayerService.pause();
        await audioPlayerService.play();

        // Assert
        verify(() => mockAudioPlayer.play()).called(2);
        verify(() => mockAudioPlayer.pause()).called(1);
      });
    });
  });
}
