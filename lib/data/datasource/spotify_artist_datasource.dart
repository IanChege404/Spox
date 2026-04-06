import 'package:spotify_clone/data/datasource/artist_datasource.dart';
import 'package:spotify_clone/data/model/artist.dart';
import 'package:spotify_clone/services/spotify_api_service.dart';

/// Remote artist datasource using Spotify API
class SpotifyArtistDatasource implements ArtistDatasource {
  final SpotifyApiService _spotifyApiService;

  SpotifyArtistDatasource({required SpotifyApiService spotifyApiService})
      : _spotifyApiService = spotifyApiService;

  @override
  Future<List<Artist>> getArtistList() async {
    try {
      // Get featured playlists and extract artists
      final playlists = await _spotifyApiService.getFeaturedPlaylists(limit: 10);
      
      final artists = <Artist>{};
      
      for (var playlist in playlists) {
        final playlistDetails = await _spotifyApiService.getPlaylist(playlist['id']);
        final items = playlistDetails['tracks']?['items'] as List?;
        
        if (items != null) {
          for (var item in items.take(3)) {
            final track = item['track'];
            final trackArtists = track?['artists'] as List?;
            
            if (trackArtists != null && trackArtists.isNotEmpty) {
              final artistData = trackArtists.first;
              artists.add(Artist(
                artistData['name'] ?? 'Unknown',
                artistData['images']?[0]?['url'] ?? 'images/artists/Post-Malone.jpg',
              ));
            }
          }
        }
      }
      
      return artists.toList().take(20).toList();
    } catch (e) {
      throw Exception('Failed to fetch artists: $e');
    }
  }
}
