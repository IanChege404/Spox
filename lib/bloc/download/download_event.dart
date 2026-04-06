import 'package:equatable/equatable.dart';

abstract class DownloadEvent extends Equatable {
  const DownloadEvent();

  @override
  List<Object?> get props => [];
}

/// Load all downloads from local storage
class LoadDownloadsEvent extends DownloadEvent {
  const LoadDownloadsEvent();
}

/// Start downloading a track (simulated)
class StartDownloadEvent extends DownloadEvent {
  final String trackId;
  final String trackName;
  final String artist;
  final String? albumArt;
  final String? audioUrl;

  const StartDownloadEvent({
    required this.trackId,
    required this.trackName,
    required this.artist,
    this.albumArt,
    this.audioUrl,
  });

  @override
  List<Object?> get props => [trackId, trackName, artist];
}

/// Update download progress (0.0 to 1.0)
class UpdateDownloadProgressEvent extends DownloadEvent {
  final String trackId;
  final double progress;

  const UpdateDownloadProgressEvent({
    required this.trackId,
    required this.progress,
  });

  @override
  List<Object?> get props => [trackId, progress];
}

/// Mark download as complete
class CompleteDownloadEvent extends DownloadEvent {
  final String trackId;
  const CompleteDownloadEvent(this.trackId);

  @override
  List<Object?> get props => [trackId];
}

/// Remove a downloaded track
class RemoveDownloadEvent extends DownloadEvent {
  final String trackId;
  const RemoveDownloadEvent(this.trackId);

  @override
  List<Object?> get props => [trackId];
}
