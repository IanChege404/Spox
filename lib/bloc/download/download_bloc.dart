import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/bloc/download/download_event.dart';
import 'package:spotify_clone/bloc/download/download_state.dart';
import 'package:spotify_clone/services/hive_service.dart';

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final Map<String, Timer> _downloadTimers = {};
  final HiveService _hiveService;

  DownloadBloc({required HiveService hiveService})
      : _hiveService = hiveService,
        super(const DownloadInitial()) {
    on<LoadDownloadsEvent>(_onLoad);
    on<StartDownloadEvent>(_onStartDownload);
    on<UpdateDownloadProgressEvent>(_onUpdateProgress);
    on<CompleteDownloadEvent>(_onComplete);
    on<RemoveDownloadEvent>(_onRemove);
  }

  Future<void> _onLoad(
      LoadDownloadsEvent event, Emitter<DownloadState> emit) async {
    final stored = _hiveService.getDownloadedTracks();
    final tracks = <String, DownloadedTrack>{};

    for (final entry in stored.entries) {
      final data = entry.value;
      final statusRaw = data['status'] as String? ?? 'notDownloaded';
      final status = DownloadStatus.values.firstWhere(
        (s) => s.name == statusRaw,
        orElse: () => DownloadStatus.notDownloaded,
      );

      tracks[entry.key] = DownloadedTrack(
        trackId: data['trackId'] as String? ?? entry.key,
        trackName: data['trackName'] as String? ?? 'Unknown',
        artist: data['artist'] as String? ?? 'Unknown',
        albumArt: data['albumArt'] as String?,
        audioUrl: data['audioUrl'] as String?,
        status: status,
        progress: (data['progress'] as num?)?.toDouble() ?? 0.0,
      );
    }

    emit(DownloadsLoaded(tracks));
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
    await _persistTrack(newTrack);

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
    await _persistTrack(updated);
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
    await _persistTrack(updated);
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
    await _hiveService.removeDownloadedTrack(event.trackId);
  }

  Future<void> _persistTrack(DownloadedTrack track) async {
    await _hiveService.saveDownloadedTrack({
      'trackId': track.trackId,
      'trackName': track.trackName,
      'artist': track.artist,
      'albumArt': track.albumArt,
      'audioUrl': track.audioUrl,
      'status': track.status.name,
      'progress': track.progress,
      'updatedAt': DateTime.now().toIso8601String(),
    });
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
