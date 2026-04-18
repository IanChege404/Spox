import 'package:spotify_clone/DI/service_locator.dart';
import 'package:spotify_clone/data/datasource/spotify_playlist_datasource.dart';
import 'package:spotify_clone/data/model/playlist.dart';
import 'package:spotify_clone/data/model/playlist_track.dart';
import 'package:spotify_clone/data/model/spotify_models.dart';
import 'package:spotify_clone/data/repository/playlist_repository.dart';
import 'package:spotify_clone/services/firestore_sync_service.dart';

/// Remote playlist repository using Firestore with fallback to Spotify API
/// Fetches playlists from Firestore and caches them locally
class SpotifyPlaylistRepository extends PLaylistRepository {
  final SpotifyPlaylistDatasource _datasource;
  late final FirestoreSyncService _syncService = locator.get();

  SpotifyPlaylistRepository({required SpotifyPlaylistDatasource datasource})
      : _datasource = datasource;

  @override
  Future<Playlist> getList(String mix) async {
    try {
      // Try to get from Firestore first (with cache)
      final spotifyPlaylists = await _syncService.syncPlaylists();

      // Find playlist matching the mix parameter
      SpotifyPlaylist? matchingPlaylist;
      for (final p in spotifyPlaylists) {
        if (p.name.toLowerCase().contains(mix.toLowerCase())) {
          matchingPlaylist = p;
          break;
        }
      }
      matchingPlaylist ??=
          spotifyPlaylists.isNotEmpty ? spotifyPlaylists.first : null;

      if (matchingPlaylist != null) {
        return _convertToLocalPlaylist(matchingPlaylist);
      }
    } catch (e) {
      print(
          '[PlaylistRepository] Firestore sync failed: $e, falling back to Spotify API');
    }

    // Fallback to Spotify API
    return await _datasource.trackList(mix);
  }

  /// Convert SpotifyPlaylist to local Playlist model
  Playlist _convertToLocalPlaylist(dynamic spotifyPlaylist) {
    // Extract track items if available
    final tracksList = <PLaylistTrack>[];

    // For now, create a simple playlist with the basic info
    // In a real scenario, you'd fetch the full track list from Firestore
    final time = spotifyPlaylist.trackCount?.toString() ?? '0';

    return Playlist(time, tracksList);
  }
}
