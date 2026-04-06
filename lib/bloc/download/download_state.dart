import 'package:equatable/equatable.dart';

enum DownloadStatus { notDownloaded, downloading, downloaded }

class DownloadedTrack extends Equatable {
  final String trackId;
  final String trackName;
  final String artist;
  final String? albumArt;
  final String? audioUrl;
  final DownloadStatus status;
  final double progress; // 0.0 to 1.0

  const DownloadedTrack({
    required this.trackId,
    required this.trackName,
    required this.artist,
    this.albumArt,
    this.audioUrl,
    required this.status,
    this.progress = 0.0,
  });

  DownloadedTrack copyWith({
    DownloadStatus? status,
    double? progress,
  }) {
    return DownloadedTrack(
      trackId: trackId,
      trackName: trackName,
      artist: artist,
      albumArt: albumArt,
      audioUrl: audioUrl,
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props =>
      [trackId, trackName, artist, status, progress];
}

abstract class DownloadState extends Equatable {
  const DownloadState();

  @override
  List<Object?> get props => [];
}

class DownloadInitial extends DownloadState {
  const DownloadInitial();
}

class DownloadsLoaded extends DownloadState {
  final Map<String, DownloadedTrack> tracks;

  const DownloadsLoaded(this.tracks);

  DownloadsLoaded copyWith({Map<String, DownloadedTrack>? tracks}) {
    return DownloadsLoaded(tracks ?? this.tracks);
  }

  List<DownloadedTrack> get downloadedTracks => tracks.values
      .where((t) => t.status == DownloadStatus.downloaded)
      .toList();

  List<DownloadedTrack> get inProgressTracks => tracks.values
      .where((t) => t.status == DownloadStatus.downloading)
      .toList();

  @override
  List<Object?> get props => [tracks];
}
