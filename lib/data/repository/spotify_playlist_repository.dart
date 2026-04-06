import 'package:spotify_clone/data/datasource/spotify_playlist_datasource.dart';
import 'package:spotify_clone/data/model/playlist.dart';
import 'package:spotify_clone/data/repository/playlist_repository.dart';

/// Remote playlist repository using Spotify API
/// Searches for and fetches real playlists from Spotify
class SpotifyPlaylistRepository extends PLaylistRepository {
  final SpotifyPlaylistDatasource _datasource;

  SpotifyPlaylistRepository({required SpotifyPlaylistDatasource datasource})
      : _datasource = datasource;

  @override
  Future<Playlist> getList(String mix) async {
    return await _datasource.trackList(mix);
  }
}
