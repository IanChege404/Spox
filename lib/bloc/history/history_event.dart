import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load play history
class LoadPlayHistoryEvent extends HistoryEvent {
  final int limit;

  const LoadPlayHistoryEvent({this.limit = 50});

  @override
  List<Object?> get props => [limit];
}

/// Event to record a song play
class RecordPlayEvent extends HistoryEvent {
  final String trackName;
  final String artists;
  final int? duration; // Duration in seconds
  final String? albumImage; // Album artwork URL

  const RecordPlayEvent({
    required this.trackName,
    required this.artists,
    this.duration,
    this.albumImage,
  });

  @override
  List<Object?> get props => [trackName, artists, duration, albumImage];
}

/// Event to clear play history
class ClearPlayHistoryEvent extends HistoryEvent {
  const ClearPlayHistoryEvent();
}
