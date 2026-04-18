import 'package:spotify_clone/DI/service_locator.dart';
import 'package:spotify_clone/data/model/podcast.dart';
import 'package:spotify_clone/services/firestore_sync_service.dart';

abstract class PodcastRepository {
  Future<List<Podcast>> getPodcastList();
}

class PodcastLocalRepository extends PodcastRepository {
  late final FirestoreSyncService _syncService = locator.get();

  @override
  Future<List<Podcast>> getPodcastList() async {
    try {
      final firebasePodcasts = await _syncService.syncPodcasts();
      return firebasePodcasts
          .map((podcast) => Podcast(
                podcast.image,
                podcast.name,
              ))
          .toList();
    } catch (e) {
      print('[PodcastRepository] Firestore sync failed: $e');
      return [];
    }
  }
}
