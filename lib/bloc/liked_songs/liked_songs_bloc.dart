import 'package:bloc/bloc.dart';
import 'package:spotify_clone/bloc/liked_songs/liked_songs_event.dart';
import 'package:spotify_clone/bloc/liked_songs/liked_songs_state.dart';
import 'package:spotify_clone/data/model/album_track.dart';
import 'package:spotify_clone/services/hive_service.dart';

class LikedSongsBloc extends Bloc<LikedSongsEvent, LikedSongsState> {
  final HiveService _hiveService;

  LikedSongsBloc({required HiveService hiveService})
      : _hiveService = hiveService,
        super(const LikedSongsInitial()) {
    on<LoadLikedSongsEvent>(_onLoadLikedSongs);
    on<AddLikeEvent>(_onAddLike);
    on<RemoveLikeEvent>(_onRemoveLike);
    on<ToggleLikeEvent>(_onToggleLike);
    on<ClearLikedSongsEvent>(_onClearLikedSongs);
  }

  Future<void> _onLoadLikedSongs(
    LoadLikedSongsEvent event,
    Emitter<LikedSongsState> emit,
  ) async {
    emit(const LikedSongsLoading());
    try {
      final likedSongs = await _hiveService.getLikedSongs();

      if (likedSongs.isEmpty) {
        emit(const LikedSongsEmpty());
      } else {
        // Create a set of keys for quick lookup
        final likedSongKeys = <String>{};
        for (var song in likedSongs) {
          likedSongKeys.add('${song.trackName}_${song.singers}');
        }

        emit(LikedSongsLoaded(
          likedSongs: likedSongs,
          likedSongKeys: likedSongKeys,
        ));
      }
    } catch (e) {
      emit(LikedSongsError('Failed to load liked songs: $e'));
    }
  }

  Future<void> _onAddLike(
    AddLikeEvent event,
    Emitter<LikedSongsState> emit,
  ) async {
    try {
      await _hiveService.saveLikedSong(event.song, event.albumImage);

      final currentState = state;
      if (currentState is LikedSongsLoaded) {
        final updatedSongs = List<AlbumTrack>.from(currentState.likedSongs);
        updatedSongs.add(event.song);

        final updatedKeys = Set<String>.from(currentState.likedSongKeys);
        updatedKeys.add('${event.song.trackName}_${event.song.singers}');

        emit(currentState.copyWith(
          likedSongs: updatedSongs,
          likedSongKeys: updatedKeys,
        ));
      } else {
        // If not loaded yet, reload
        add(const LoadLikedSongsEvent());
      }
    } catch (e) {
      emit(LikedSongsError('Failed to like song: $e'));
    }
  }

  Future<void> _onRemoveLike(
    RemoveLikeEvent event,
    Emitter<LikedSongsState> emit,
  ) async {
    try {
      await _hiveService.removeLikedSong(event.song);

      final currentState = state;
      if (currentState is LikedSongsLoaded) {
        final updatedSongs = List<AlbumTrack>.from(currentState.likedSongs);
        updatedSongs.removeWhere(
          (s) =>
              s.trackName == event.song.trackName &&
              s.singers == event.song.singers,
        );

        final updatedKeys = Set<String>.from(currentState.likedSongKeys);
        updatedKeys.remove('${event.song.trackName}_${event.song.singers}');

        if (updatedSongs.isEmpty) {
          emit(const LikedSongsEmpty());
        } else {
          emit(currentState.copyWith(
            likedSongs: updatedSongs,
            likedSongKeys: updatedKeys,
          ));
        }
      }
    } catch (e) {
      emit(LikedSongsError('Failed to unlike song: $e'));
    }
  }

  Future<void> _onToggleLike(
    ToggleLikeEvent event,
    Emitter<LikedSongsState> emit,
  ) async {
    try {
      final isLiked = await _hiveService.isLiked(event.song);

      if (isLiked) {
        add(RemoveLikeEvent(song: event.song));
      } else {
        add(AddLikeEvent(song: event.song, albumImage: event.albumImage));
      }
    } catch (e) {
      emit(LikedSongsError('Failed to toggle like: $e'));
    }
  }

  Future<void> _onClearLikedSongs(
    ClearLikedSongsEvent event,
    Emitter<LikedSongsState> emit,
  ) async {
    try {
      // Would need to implement clear in HiveService
      emit(const LikedSongsEmpty());
    } catch (e) {
      emit(LikedSongsError('Failed to clear liked songs: $e'));
    }
  }
}
