import 'package:spotify_clone/data/datasource/playlist_datasource.dart';
import 'package:spotify_clone/data/model/playlist.dart';
import 'package:spotify_clone/data/model/playlist_track.dart';
import 'package:spotify_clone/services/spotify_api_service.dart';

/// Remote playlist datasource that fetches playlists from Spotify API
class SpotifyPlaylistDatasource extends PlaylistDatasource {
  final SpotifyApiService _apiService;

  SpotifyPlaylistDatasource({required SpotifyApiService apiService})
      : _apiService = apiService;

  @override
  Future<Playlist> trackList(String mix) async {
    try {
      // Search for playlist
      final searchResults = await _apiService.search(mix, type: 'playlist');
      
      final playlistItems = searchResults['playlists']['items'] as List? ?? [];
      if (playlistItems.isEmpty) {
        // If not found, fetch featured playlists as fallback
        final featured = await _apiService.getFeaturedPlaylists(limit: 50);
        if (featured.isEmpty) {
          throw Exception('Playlist "$mix" not found');
        }
        return _buildPlaylistFromData(featured.first);
      }

      return _buildPlaylistFromData(playlistItems.first as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch playlist "$mix": $e');
    }
  }

  /// Fetch featured playlists for home screen
  Future<List<Playlist>> getFeaturedPlaylists() async {
    try {
      final featured = await _apiService.getFeaturedPlaylists(limit: 20);
      
      if (featured.isEmpty) {
        throw Exception('No featured playlists found');
      }

      return featured.map((p) => _buildPlaylistFromData(p)).toList();
    } catch (e) {
      throw Exception('Failed to fetch featured playlists: $e');
    }
  }

  /// Build Playlist model from Spotify API response
  Playlist _buildPlaylistFromData(Map<String, dynamic> playlistData) {
    final tracks = playlistData['tracks'] as Map? ?? {};
    final trackItems = tracks['items'] as List? ?? [];

    // Convert to PLaylistTrack model (take first 20)
    final playlistTracks = trackItems.take(20).map((trackItem) {
      final track = trackItem is Map ? trackItem['track'] as Map? : null;
      
      if (track == null) {
        return PLaylistTrack('', 'Unknown', 'Unknown');
      }

      final trackName = track['name'] as String? ?? 'Unknown Track';
      
      // Extract album images safely
      final album = track['album'] as Map<String, dynamic>?;
      final images = album?['images'] as List?;
      final imageUrl = (images?.isNotEmpty ?? false)
          ? (((images!.first as Map?)?['url']) as String? ?? '')
          : '';
      
      final artistList = track['artists'] as List<dynamic>? ?? [];
      final artistName = artistList.isNotEmpty
          ? (((artistList.first as Map<String, dynamic>?)?['name']) as String? ?? 'Unknown Artist')
          : 'Unknown Artist';

      return PLaylistTrack(imageUrl, artistName, trackName);
    }).toList();

    // Calculate total duration
    final totalTracks = tracks['total'] as int? ?? playlistTracks.length;
    final durationMinutes = (totalTracks * 3.5).toInt(); // ~3.5 min per track average
    final duration = '${durationMinutes ~/ 60}h ${durationMinutes % 60}m';

    return Playlist(
      duration,
      playlistTracks,
    );
  }
}
