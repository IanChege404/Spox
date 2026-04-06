import 'package:spotify_clone/data/datasource/album_datasource.dart';
import 'package:spotify_clone/data/model/album.dart';
import 'package:spotify_clone/data/model/album_track.dart';
import 'package:spotify_clone/services/spotify_api_service.dart';

/// Remote album datasource that fetches albums from Spotify API
class SpotifyAlbumDatasource extends AlbumDatasource {
  final SpotifyApiService _apiService;

  SpotifyAlbumDatasource({required SpotifyApiService apiService})
      : _apiService = apiService;

  @override
  Future<Album> albumList(String singer) async {
    try {
      // Search for artist
      final searchResults = await _apiService.search(singer, type: 'artist');

      final artistsItems = searchResults['artists']['items'] as List? ?? [];
      if (artistsItems.isEmpty) {
        throw Exception('Artist "$singer" not found');
      }

      final artistData = artistsItems.first as Map<String, dynamic>;
      if (artistData.isEmpty) {
        throw Exception('No artist data found for "$singer"');
      }

      final artistId = artistData['id'] as String;
      final artistName = artistData['name'] as String? ?? singer;
      final artistImage = (artistData['images'] as List?)?.isNotEmpty == true
          ? artistData['images'][0]['url'] as String? ?? ''
          : '';

      // Get artist's top tracks
      final topTracks = await _apiService.getArtistTopTracks(
        artistId,
        market: 'US',
      );

      if (topTracks.isEmpty) {
        throw Exception('No tracks found for artist "$singer"');
      }

      // Convert to AlbumTrack model (limit to 20)
      final tracks = (topTracks as List).take(20).map((track) {
        final trackName = track['name'] as String? ?? 'Unknown Track';
        final artists = track['artists'] as List? ?? [];
        final artistNames = artists.isNotEmpty
            ? (artists.first['name'] as String? ?? 'Unknown Artist')
            : artistName;

        return AlbumTrack(trackName, artistNames);
      }).toList();

      // Create album with artist info as album
      return Album(
        artistImage.isNotEmpty ? artistImage : 'artist_placeholder.jpg',
        artistName,
        artistName,
        tracks,
        '2024',
        artistImage.isNotEmpty ? artistImage : 'artist_placeholder.jpg',
        [],
      );
    } catch (e) {
      throw Exception('Failed to fetch album for "$singer": $e');
    }
  }
}
