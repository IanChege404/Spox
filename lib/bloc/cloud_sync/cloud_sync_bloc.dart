import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:spotify_clone/bloc/cloud_sync/cloud_sync_event.dart';
import 'package:spotify_clone/bloc/cloud_sync/cloud_sync_state.dart';
import 'package:spotify_clone/services/firebase_service.dart';

class CloudSyncBloc extends Bloc<CloudSyncEvent, CloudSyncState> {
  final FirebaseService _firebaseService;
  late StreamSubscription<List<Map<String, dynamic>>> _likedSongsSubscription;

  CloudSyncBloc({required FirebaseService firebaseService})
      : _firebaseService = firebaseService,
        super(const CloudSyncInitial()) {
    on<SyncLikedSongsEvent>(_onSyncLikedSongs);
    on<LoadLikedSongsEvent>(_onLoadLikedSongs);
    on<AddLikedSongEvent>(_onAddLikedSong);
    on<RemoveLikedSongEvent>(_onRemoveLikedSong);
  }

  /// Sync liked songs from local to Firebase
  FutureOr<void> _onSyncLikedSongs(
    SyncLikedSongsEvent event,
    Emitter<CloudSyncState> emit,
  ) async {
    try {
      emit(const CloudSyncLoading());

      await _firebaseService.syncLikedSongsToFirebase(event.likedSongs);

      emit(CloudSyncSuccess(event.likedSongs));
      emit(const CloudSyncCompleted());
    } catch (e) {
      emit(CloudSyncError('Failed to sync liked songs: ${e.toString()}'));
    }
  }

  /// Load liked songs from Firebase
  FutureOr<void> _onLoadLikedSongs(
    LoadLikedSongsEvent event,
    Emitter<CloudSyncState> emit,
  ) {
    try {
      emit(const CloudSyncLoading());

      // Listen to Firestore stream
      _likedSongsSubscription = _firebaseService.getLikedSongsStream().listen(
        (likedSongs) {
          emit(CloudSyncSuccess(likedSongs));
        },
        onError: (e) {
          emit(CloudSyncError('Failed to load liked songs: ${e.toString()}'));
        },
      );
    } catch (e) {
      emit(CloudSyncError('Failed to load liked songs: ${e.toString()}'));
    }
  }

  /// Add a single liked song
  FutureOr<void> _onAddLikedSong(
    AddLikedSongEvent event,
    Emitter<CloudSyncState> emit,
  ) async {
    try {
      emit(const CloudSyncLoading());

      await _firebaseService.addLikedSong(
        spotifyId: event.spotifyId,
        title: event.title,
        artist: event.artist,
        albumArt: event.albumArt,
      );

      emit(const CloudSyncCompleted());
    } catch (e) {
      emit(CloudSyncError('Failed to add liked song: ${e.toString()}'));
    }
  }

  /// Remove a liked song
  FutureOr<void> _onRemoveLikedSong(
    RemoveLikedSongEvent event,
    Emitter<CloudSyncState> emit,
  ) async {
    try {
      emit(const CloudSyncLoading());

      await _firebaseService.removeLikedSong(event.spotifyId);

      emit(const CloudSyncCompleted());
    } catch (e) {
      emit(CloudSyncError('Failed to remove liked song: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() async {
    await _likedSongsSubscription.cancel();
    return super.close();
  }
}
