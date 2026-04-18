import 'package:spotify_clone/DI/service_locator.dart';
import 'package:spotify_clone/data/datasource/spotify_artist_datasource.dart';
import 'package:spotify_clone/data/model/artist.dart';
import 'package:spotify_clone/data/repository/artist_repository.dart';
import 'package:spotify_clone/services/firestore_sync_service.dart';

/// Remote artist repository using Firestore with fallback to Spotify API
/// Fetches artists from Firestore cache-first approach
class SpotifyArtistRepository extends ArtistRepository {
  final SpotifyArtistDatasource _datasource;
  late final FirestoreSyncService _syncService = locator.get();

  SpotifyArtistRepository({required SpotifyArtistDatasource datasource})
      : _datasource = datasource;

  @override
  Future<List<Artist>> artistList() async {
    try {
      // Try to get from Firestore first (with cache)
      final spotifyArtists = await _syncService.syncArtists();
      
      if (spotifyArtists.isNotEmpty) {
        return spotifyArtists
            .map((artist) => Artist(
                  artist.name,
                  artist.imageUrl,
                ))
            .toList();
      }
    } catch (e) {
      print('[ArtistRepository] Firestore sync failed: $e, falling back to Spotify API');
    }

    // Fallback to Spotify API
    return await _datasource.getArtistList();
  }
}
