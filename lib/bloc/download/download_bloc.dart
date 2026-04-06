import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/bloc/download/download_event.dart';
import 'package:spotify_clone/bloc/download/download_state.dart';

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final Map<String, Timer> _downloadTimers = {};

  DownloadBloc() : super(const DownloadInitial()) {
    on<LoadDownloadsEvent>(_onLoad);
    on<StartDownloadEvent>(_onStartDownload);
    on<UpdateDownloadProgressEvent>(_onUpdateProgress);
    on<CompleteDownloadEvent>(_onComplete);
    on<RemoveDownloadEvent>(_onRemove);
  }

  Future<void> _onLoad(
      LoadDownloadsEvent event, Emitter<DownloadState> emit) async {
    emit(const DownloadsLoaded({}));
  }

  Future<void> _onStartDownload(
      StartDownloadEvent event, Emitter<DownloadState> emit) async {
    final current = state is DownloadsLoaded
        ? state as DownloadsLoaded
        : const DownloadsLoaded({});

    if (current.tracks.containsKey(event.trackId)) return;

    final newTrack = DownloadedTrack(
      trackId: event.trackId,
      trackName: event.trackName,
      artist: event.artist,
      albumArt: event.albumArt,
      audioUrl: event.audioUrl,
      status: DownloadStatus.downloading,
      progress: 0.0,
    );

    final newTracks = Map<String, DownloadedTrack>.from(current.tracks)
      ..[event.trackId] = newTrack;

    emit(DownloadsLoaded(newTracks));

    // Simulate download progress over ~3 seconds
    double progress = 0.0;
    _downloadTimers[event.trackId]?.cancel();
    _downloadTimers[event.trackId] = Timer.periodic(
      const Duration(milliseconds: 150),
      (timer) {
        progress = (progress + 0.05).clamp(0.0, 1.0);
        add(UpdateDownloadProgressEvent(
            trackId: event.trackId, progress: progress));
        if (progress >= 1.0) {
          timer.cancel();
          _downloadTimers.remove(event.trackId);
          add(CompleteDownloadEvent(event.trackId));
        }
      },
    );
  }

  Future<void> _onUpdateProgress(
      UpdateDownloadProgressEvent event,
      Emitter<DownloadState> emit) async {
    if (state is! DownloadsLoaded) return;
    final current = state as DownloadsLoaded;
    final track = current.tracks[event.trackId];
    if (track == null) return;

    final updated =
        track.copyWith(progress: event.progress);
    final newTracks =
        Map<String, DownloadedTrack>.from(current.tracks)
          ..[event.trackId] = updated;
    emit(DownloadsLoaded(newTracks));
  }

  Future<void> _onComplete(
      CompleteDownloadEvent event, Emitter<DownloadState> emit) async {
    if (state is! DownloadsLoaded) return;
    final current = state as DownloadsLoaded;
    final track = current.tracks[event.trackId];
    if (track == null) return;

    final updated = track.copyWith(
        status: DownloadStatus.downloaded, progress: 1.0);
    final newTracks =
        Map<String, DownloadedTrack>.from(current.tracks)
          ..[event.trackId] = updated;
    emit(DownloadsLoaded(newTracks));
  }

  Future<void> _onRemove(
      RemoveDownloadEvent event, Emitter<DownloadState> emit) async {
    if (state is! DownloadsLoaded) return;
    final current = state as DownloadsLoaded;
    _downloadTimers[event.trackId]?.cancel();
    _downloadTimers.remove(event.trackId);

    final newTracks =
        Map<String, DownloadedTrack>.from(current.tracks)
          ..remove(event.trackId);
    emit(DownloadsLoaded(newTracks));
  }

  @override
  Future<void> close() {
    for (final timer in _downloadTimers.values) {
      timer.cancel();
    }
    _downloadTimers.clear();
    return super.close();
  }
}
