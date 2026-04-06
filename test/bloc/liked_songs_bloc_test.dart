import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotify_clone/bloc/liked_songs/liked_songs_bloc.dart';
import 'package:spotify_clone/bloc/liked_songs/liked_songs_event.dart';
import 'package:spotify_clone/bloc/liked_songs/liked_songs_state.dart';
import 'package:spotify_clone/data/model/album_track.dart';
import 'package:spotify_clone/services/hive_service.dart';

class MockHiveService extends Mock implements HiveService {}

class FakeAlbumTrack extends Fake implements AlbumTrack {
  @override
  final String trackName;

  @override
  final String singers;

  FakeAlbumTrack({this.trackName = 'Test Track', this.singers = 'Test Singer'});
}

void main() {
  group('LikedSongsBloc', () {
    late MockHiveService mockHiveService;
    late LikedSongsBloc likedSongsBloc;

    setUpAll(() {
      // Register fallback value for AlbumTrack
      registerFallbackValue(FakeAlbumTrack());
    });

    setUp(() {
      mockHiveService = MockHiveService();
      likedSongsBloc = LikedSongsBloc(hiveService: mockHiveService);
    });

    tearDown(() {
      likedSongsBloc.close();
    });

    test('initial state is LikedSongsInitial', () {
      expect(likedSongsBloc.state, isA<LikedSongsInitial>());
    });

    blocTest<LikedSongsBloc, LikedSongsState>(
      'emits Loading then Loaded with songs when LoadLikedSongsEvent is successful',
      build: () => likedSongsBloc,
      act: (bloc) {
        final mockSongs = [
          FakeAlbumTrack(trackName: 'Song 1', singers: 'Artist 1'),
          FakeAlbumTrack(trackName: 'Song 2', singers: 'Artist 2'),
        ];
        when(() => mockHiveService.getLikedSongs())
            .thenAnswer((_) async => mockSongs);
        bloc.add(LoadLikedSongsEvent());
      },
      expect: () => [
        isA<LikedSongsLoading>(),
        isA<LikedSongsLoaded>(),
      ],
    );

    blocTest<LikedSongsBloc, LikedSongsState>(
      'emits Empty when no liked songs are found',
      build: () => likedSongsBloc,
      act: (bloc) {
        when(() => mockHiveService.getLikedSongs()).thenAnswer((_) async => []);
        bloc.add(LoadLikedSongsEvent());
      },
      expect: () => [
        isA<LikedSongsLoading>(),
        isA<LikedSongsEmpty>(),
      ],
    );

    blocTest<LikedSongsBloc, LikedSongsState>(
      'emits Error when loading liked songs fails',
      build: () => likedSongsBloc,
      act: (bloc) {
        when(() => mockHiveService.getLikedSongs())
            .thenThrow(Exception('Failed to load'));
        bloc.add(LoadLikedSongsEvent());
      },
      expect: () => [
        isA<LikedSongsLoading>(),
        isA<LikedSongsError>(),
      ],
    );

    blocTest<LikedSongsBloc, LikedSongsState>(
      'adds song to liked songs when AddLikeEvent is dispatched',
      build: () => likedSongsBloc,
      seed: () => LikedSongsLoaded(
        likedSongs: [],
        likedSongKeys: {},
      ),
      act: (bloc) {
        final mockSong =
            FakeAlbumTrack(trackName: 'New Song', singers: 'New Artist');
        when(() => mockHiveService.saveLikedSong(any(), any()))
            .thenAnswer((_) async => Future.value());
        bloc.add(AddLikeEvent(song: mockSong, albumImage: 'test.jpg'));
      },
      expect: () => [
        isA<LikedSongsLoaded>(),
      ],
    );

    blocTest<LikedSongsBloc, LikedSongsState>(
      'removes song from liked songs when RemoveLikeEvent is dispatched',
      build: () => likedSongsBloc,
      seed: () => LikedSongsLoaded(
        likedSongs: [FakeAlbumTrack()],
        likedSongKeys: {'Test Track_Test Singer'},
      ),
      act: (bloc) {
        final mockSong = FakeAlbumTrack();
        when(() => mockHiveService.removeLikedSong(any()))
            .thenAnswer((_) async => Future.value());
        bloc.add(RemoveLikeEvent(song: mockSong));
      },
      expect: () => [
        isA<LikedSongsEmpty>(),
      ],
    );

    blocTest<LikedSongsBloc, LikedSongsState>(
      'clears all liked songs when ClearLikedSongsEvent is dispatched',
      build: () => likedSongsBloc,
      seed: () => LikedSongsLoaded(
        likedSongs: [FakeAlbumTrack()],
        likedSongKeys: {'Test Track_Test Singer'},
      ),
      act: (bloc) {
        when(() => mockHiveService.clearAll())
            .thenAnswer((_) async => Future.value());
        bloc.add(ClearLikedSongsEvent());
      },
      expect: () => [
        isA<LikedSongsEmpty>(),
      ],
    );
  });
}
