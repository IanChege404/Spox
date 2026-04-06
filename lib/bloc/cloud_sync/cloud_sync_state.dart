import 'package:equatable/equatable.dart';

abstract class CloudSyncState extends Equatable {
  const CloudSyncState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CloudSyncInitial extends CloudSyncState {
  const CloudSyncInitial();
}

/// Syncing is in progress
class CloudSyncLoading extends CloudSyncState {
  const CloudSyncLoading();
}

/// Successfully synced
class CloudSyncSuccess extends CloudSyncState {
  final List<Map<String, dynamic>> likedSongs;

  const CloudSyncSuccess(this.likedSongs);

  @override
  List<Object?> get props => [likedSongs];
}

/// Sync error occurred
class CloudSyncError extends CloudSyncState {
  final String message;

  const CloudSyncError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Sync operation completed
class CloudSyncCompleted extends CloudSyncState {
  const CloudSyncCompleted();
}
