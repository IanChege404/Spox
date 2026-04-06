import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotify_clone/data/model/album_track.dart';
import 'package:spotify_clone/services/hive_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Mock Hive Box for testing
class MockBox<T> extends Mock implements Box<T> {}

void main() {
  group('HiveService', () {
    late HiveService hiveService;
    late MockBox<Map> mockLikedSongsBox;
    late MockBox<Map> mockPlayHistoryBox;
    late MockBox<Map> mockAppSettingsBox;
    late MockBox<Map> mockUserPreferencesBox;

    setUp(() {
      mockLikedSongsBox = MockBox<Map>();
      mockPlayHistoryBox = MockBox<Map>();
      mockAppSettingsBox = MockBox<Map>();
      mockUserPreferencesBox = MockBox<Map>();

      hiveService = HiveService(
        likedSongsBox: mockLikedSongsBox,
        playHistoryBox: mockPlayHistoryBox,
        appSettingsBox: mockAppSettingsBox,
        userPreferencesBox: mockUserPreferencesBox,
      );
    });

    group('Liked Songs Operations', () {
      test('saveLikedSong stores song with all metadata', () async {
        // Arrange
        final track = AlbumTrack('Test Song', 'Test Artist');
        const albumImage = 'https://example.com/album.jpg';

        when(() => mockLikedSongsBox.put(any(), any()))
            .thenAnswer((_) => Future.value());

        // Act
        await hiveService.saveLikedSong(track, albumImage);

        // Assert
        verify(() => mockLikedSongsBox.put(
              'Test Song_Test Artist',
              any(
                that: isA<Map>()
                    .having((m) => m['trackName'], 'trackName', 'Test Song')
                    .having((m) => m['singers'], 'singers', 'Test Artist')
                    .having((m) => m['albumImage'], 'albumImage', albumImage),
              ),
            )).called(1);
      });

      test('removeLikedSong deletes song by key', () async {
        // Arrange
        final track = AlbumTrack('Test Song', 'Test Artist');

        when(() => mockLikedSongsBox.delete(any()))
            .thenAnswer((_) => Future.value());

        // Act
        await hiveService.removeLikedSong(track);

        // Assert
        verify(() => mockLikedSongsBox.delete('Test Song_Test Artist'))
            .called(1);
      });

      test('isLiked returns true when song exists', () async {
        // Arrange
        final track = AlbumTrack('Test Song', 'Test Artist');
        const key = 'Test Song_Test Artist';

        when(() => mockLikedSongsBox.containsKey(any())).thenReturn(true);

        // Act
        final result = await hiveService.isLiked(track);

        // Assert
        expect(result, true);
        verify(() => mockLikedSongsBox.containsKey(key)).called(1);
      });

      test('isLiked returns false when song does not exist', () async {
        // Arrange
        final track = AlbumTrack('Unknown Song', 'Unknown Artist');

        when(() => mockLikedSongsBox.containsKey(any())).thenReturn(false);

        // Act
        final result = await hiveService.isLiked(track);

        // Assert
        expect(result, false);
      });

      test('getLikedSongs returns all saved songs', () async {
        // Arrange
        final mockSongData = {
          'trackName': 'Song 1',
          'singers': 'Artist 1',
          'albumImage': 'image1.jpg',
          'savedAt': DateTime.now().toIso8601String(),
        };

        when(() => mockLikedSongsBox.values).thenReturn([mockSongData]);

        // Act
        final songs = await hiveService.getLikedSongs();

        // Assert
        expect(songs, isNotEmpty);
        expect(songs.first.trackName, 'Song 1');
        expect(songs.first.singers, 'Artist 1');
      });

      test('getLikedSongs returns empty list on error', () async {
        // Arrange
        when(() => mockLikedSongsBox.values)
            .thenThrow(Exception('Storage error'));

        // Act
        final songs = await hiveService.getLikedSongs();

        // Assert
        expect(songs, isEmpty);
      });

      test('clearAll removes all data', () async {
        // Arrange
        when(() => mockLikedSongsBox.clear())
            .thenAnswer((_) => Future.value(0));
        when(() => mockPlayHistoryBox.clear())
            .thenAnswer((_) => Future.value(0));
        when(() => mockAppSettingsBox.clear())
            .thenAnswer((_) => Future.value(0));
        when(() => mockUserPreferencesBox.clear())
            .thenAnswer((_) => Future.value(0));

        // Act
        await hiveService.clearAll();

        // Assert
        verify(() => mockLikedSongsBox.clear()).called(1);
        verify(() => mockPlayHistoryBox.clear()).called(1);
        verify(() => mockAppSettingsBox.clear()).called(1);
        verify(() => mockUserPreferencesBox.clear()).called(1);
      });
    });

    group('Play History Operations', () {
      test('recordPlay stores track with timestamp', () async {
        // Arrange
        final track = AlbumTrack('Track 1', 'Artist 1');

        when(() => mockPlayHistoryBox.put(any(), any()))
            .thenAnswer((_) => Future.value());

        // Act
        await hiveService.recordPlay(track);

        // Assert
        verify(() => mockPlayHistoryBox.put(any(), any())).called(1);
      });

      test('recordPlay stores track with duration and albumImage', () async {
        // Arrange
        final track = AlbumTrack('Track 1', 'Artist 1');
        const duration = 240; // 4 minutes
        const albumImage = 'https://example.com/album.jpg';

        when(() => mockPlayHistoryBox.put(any(), any()))
            .thenAnswer((_) => Future.value());

        // Act
        await hiveService.recordPlay(
          track,
          duration: duration,
          albumImage: albumImage,
        );

        // Assert
        verify(() => mockPlayHistoryBox.put(any(), any())).called(1);
      });

      test('getPlayHistory returns played tracks', () async {
        // Arrange
        final mockHistoryData = {
          'trackName': 'Played Song',
          'singers': 'Artist',
          'playedAt': DateTime.now().toIso8601String(),
          'duration': 240,
          'albumImage': 'https://example.com/album.jpg',
        };

        when(() => mockPlayHistoryBox.values).thenReturn([mockHistoryData]);

        // Act
        final history = await hiveService.getPlayHistory();

        // Assert
        expect(history, isNotEmpty);
      });

      test('getPlayHistory returns empty list on error', () async {
        // Arrange
        when(() => mockPlayHistoryBox.values)
            .thenThrow(Exception('Storage error'));

        // Act
        final history = await hiveService.getPlayHistory();

        // Assert
        expect(history, isEmpty);
      });
    });

    group('App Settings Operations', () {
      test('saveSetting stores key-value pair', () async {
        // Arrange
        when(() => mockAppSettingsBox.put(any(), any()))
            .thenAnswer((_) => Future.value());

        // Act
        await hiveService.saveSetting('theme', 'dark');

        // Assert
        verify(() => mockAppSettingsBox
            .put('theme', {'key': 'theme', 'value': 'dark'})).called(1);
      });

      test('getSetting retrieves value by key', () {
        // Arrange
        when(() => mockAppSettingsBox.get(any()))
            .thenReturn({'key': 'theme', 'value': 'dark'});

        // Act
        final value = hiveService.getSetting('theme');

        // Assert
        expect(value, 'dark');
      });

      test('getSetting returns default when key not found', () {
        // Arrange
        when(() => mockAppSettingsBox.get(any())).thenReturn(null);

        // Act
        final value = hiveService.getSetting('nonexistent', 'light');

        // Assert
        expect(value, 'light');
      });

      test('getSetting with key found returns correct value', () {
        // Arrange
        when(() => mockAppSettingsBox.get(any()))
            .thenReturn({'key': 'theme', 'value': 'dark'});

        // Act
        final value = hiveService.getSetting('theme');

        // Assert
        expect(value, 'dark');
      });
    });

    group('Edge Cases', () {
      test('saveLikedSong with empty album image', () async {
        // Arrange
        final track = AlbumTrack('Song', 'Artist');

        when(() => mockLikedSongsBox.put(any(), any()))
            .thenAnswer((_) => Future.value());

        // Act
        await hiveService.saveLikedSong(track, '');

        // Assert - Should not throw and store empty string
        verify(() => mockLikedSongsBox.put(any(), any())).called(1);
      });

      test('saveLikedSong handles special characters in names', () async {
        // Arrange
        final track = AlbumTrack('Song "Special" & Chars', 'Artist/Name');

        when(() => mockLikedSongsBox.put(any(), any()))
            .thenAnswer((_) => Future.value());

        // Act
        await hiveService.saveLikedSong(track, 'image.jpg');

        // Assert
        verify(() => mockLikedSongsBox.put(any(), any())).called(1);
      });

      test('getLikedSongs handles empty values gracefully', () async {
        // Arrange
        when(() => mockLikedSongsBox.values).thenReturn([]);

        // Act
        final songs = await hiveService.getLikedSongs();

        // Assert
        expect(songs, isEmpty);
      });
    });
  });
}
