import 'package:spotify_clone/data/datasource/spotify_artist_datasource.dart';
import 'package:spotify_clone/data/model/artist.dart';
import 'package:spotify_clone/data/repository/artist_repository.dart';

/// Remote artist repository using Spotify API
/// Fetches real artist data from Spotify playlists
class SpotifyArtistRepository extends ArtistRepository {
  final SpotifyArtistDatasource _datasource;

  SpotifyArtistRepository({required SpotifyArtistDatasource datasource})
      : _datasource = datasource;

  @override
  Future<List<Artist>> artistList() async {
    return await _datasource.getArtistList();
  }
}
