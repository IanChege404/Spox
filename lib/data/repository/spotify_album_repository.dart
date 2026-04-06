import 'package:spotify_clone/data/datasource/spotify_album_datasource.dart';
import 'package:spotify_clone/data/model/album.dart';
import 'package:spotify_clone/data/repository/album_repository.dart';

/// Remote album repository using Spotify API
/// Fetches real album data and top tracks from Spotify
class SpotifyAlbumRepository extends AlbumRepository {
  final SpotifyAlbumDatasource _datasource;

  SpotifyAlbumRepository({required SpotifyAlbumDatasource datasource})
      : _datasource = datasource;

  @override
  Future<Album> albumList(String singer) async {
    return await _datasource.albumList(singer);
  }
}
