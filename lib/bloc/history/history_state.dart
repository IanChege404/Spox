import 'package:equatable/equatable.dart';

/// Represents a play history entry
class HistoryEntry extends Equatable {
  final String trackName;
  final String artists;
  final DateTime playedAt;

  const HistoryEntry({
    required this.trackName,
    required this.artists,
    required this.playedAt,
  });

  @override
  List<Object?> get props => [trackName, artists, playedAt];
}

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

/// Initial state - history not yet loaded
class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

/// Loading state - fetching history
class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

/// Loaded state - history available
class HistoryLoaded extends HistoryState {
  final List<HistoryEntry> entries;

  const HistoryLoaded(this.entries);

  @override
  List<Object?> get props => [entries];

  /// Check if history is empty
  bool get isEmpty => entries.isEmpty;

  /// Get most recently played track
  HistoryEntry? get mostRecent => entries.isNotEmpty ? entries.first : null;

  /// Get play count for a specific track
  int getPlayCount(String trackName) {
    return entries.where((e) => e.trackName == trackName).length;
  }

  /// Copy with modified entries
  HistoryLoaded copyWith({List<HistoryEntry>? entries}) {
    return HistoryLoaded(entries ?? this.entries);
  }
}

/// Empty state - no history
class HistoryEmpty extends HistoryState {
  const HistoryEmpty();
}

/// Error state - loading failed
class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
