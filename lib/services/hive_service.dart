import 'package:hive_flutter/hive_flutter.dart';
import 'package:spotify_clone/data/model/album_track.dart';

/// Hive service for local data persistence
class HiveService {
  static const String likedSongsBox = 'liked_songs';
  static const String playHistoryBox = 'play_history';
  static const String appSettingsBox = 'app_settings';
  static const String userPreferencesBox = 'user_preferences';

  late Box<Map> _likedSongsBox;
  late Box<Map> _playHistoryBox;
  late Box<Map> _appSettingsBox;
  late Box<Map> _userPreferencesBox;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Constructor for testing with injected boxes
  HiveService({
    Box<Map>? likedSongsBox,
    Box<Map>? playHistoryBox,
    Box<Map>? appSettingsBox,
    Box<Map>? userPreferencesBox,
  }) {
    if (likedSongsBox != null) {
      _likedSongsBox = likedSongsBox;
      _initialized = true;
    }
    if (playHistoryBox != null) {
      _playHistoryBox = playHistoryBox;
      _initialized = true;
    }
    if (appSettingsBox != null) {
      _appSettingsBox = appSettingsBox;
      _initialized = true;
    }
    if (userPreferencesBox != null) {
      _userPreferencesBox = userPreferencesBox;
      _initialized = true;
    }
  }

  /// Initialize Hive and open all boxes
  Future<void> init() async {
    if (_initialized) return;

    try {
      await Hive.initFlutter();

      // Open boxes with JSON storage
      _likedSongsBox = await Hive.openBox<Map>(likedSongsBox);
      _playHistoryBox = await Hive.openBox<Map>(playHistoryBox);
      _appSettingsBox = await Hive.openBox<Map>(appSettingsBox);
      _userPreferencesBox = await Hive.openBox<Map>(userPreferencesBox);

      _initialized = true;
      print('Hive initialized successfully');
    } catch (e) {
      print('Error initializing Hive: $e');
      rethrow;
    }
  }

  /// Save a liked song
  Future<void> saveLikedSong(AlbumTrack song, String albumImage) async {
    try {
      final key = '${song.trackName}_${song.singers}';
      await _likedSongsBox.put(key, {
        'trackName': song.trackName,
        'singers': song.singers,
        'albumImage': albumImage,
        'savedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving liked song: $e');
      rethrow;
    }
  }

  /// Remove a liked song
  Future<void> removeLikedSong(AlbumTrack song) async {
    try {
      final key = '${song.trackName}_${song.singers}';
      await _likedSongsBox.delete(key);
    } catch (e) {
      print('Error removing liked song: $e');
      rethrow;
    }
  }

  /// Get all liked songs
  Future<List<AlbumTrack>> getLikedSongs() async {
    try {
      final songs = <AlbumTrack>[];
      for (var value in _likedSongsBox.values) {
        songs.add(AlbumTrack(value['trackName'], value['singers']));
      }
      return songs;
    } catch (e) {
      print('Error fetching liked songs: $e');
      return [];
    }
  }

  /// Check if a song is liked
  Future<bool> isLiked(AlbumTrack song) async {
    try {
      final key = '${song.trackName}_${song.singers}';
      return _likedSongsBox.containsKey(key);
    } catch (e) {
      print('Error checking if liked: $e');
      return false;
    }
  }

  /// Save play history entry with enhanced metadata
  ///
  /// [song] - The track details
  /// [duration] - Duration of the track in seconds (for stats calculation)
  /// [albumImage] - Album artwork URL (for display in stats)
  Future<void> recordPlay(
    AlbumTrack song, {
    int? duration,
    String? albumImage,
  }) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      await _playHistoryBox.put(timestamp, {
        'trackName': song.trackName,
        'singers': song.singers,
        'playedAt': timestamp,
        'duration': duration, // in seconds
        'albumImage': albumImage, // for display
      });
    } catch (e) {
      print('Error recording play: $e');
      rethrow;
    }
  }

  /// Get play history
  Future<List<Map>> getPlayHistory({int limit = 50}) async {
    try {
      return _playHistoryBox.values.toList().reversed.take(limit).toList();
    } catch (e) {
      print('Error fetching play history: $e');
      return [];
    }
  }

  /// Save app setting
  Future<void> saveSetting(String key, dynamic value) async {
    try {
      await _appSettingsBox.put(key, {'key': key, 'value': value});
    } catch (e) {
      print('Error saving setting: $e');
      rethrow;
    }
  }

  /// Get app setting
  dynamic getSetting(String key, [dynamic defaultValue]) {
    try {
      final value = _appSettingsBox.get(key);
      return value?['value'] ?? defaultValue;
    } catch (e) {
      print('Error getting setting: $e');
      return defaultValue;
    }
  }

  /// Save user preference
  Future<void> savePreference(String key, dynamic value) async {
    try {
      await _userPreferencesBox.put(key, {'key': key, 'value': value});
    } catch (e) {
      print('Error saving preference: $e');
      rethrow;
    }
  }

  /// Get user preference
  dynamic getPreference(String key, [dynamic defaultValue]) {
    try {
      final value = _userPreferencesBox.get(key);
      return value?['value'] ?? defaultValue;
    } catch (e) {
      print('Error getting preference: $e');
      return defaultValue;
    }
  }

  /// Clear all data
  Future<void> clearAll() async {
    try {
      await _likedSongsBox.clear();
      await _playHistoryBox.clear();
      await _appSettingsBox.clear();
      await _userPreferencesBox.clear();
    } catch (e) {
      print('Error clearing all data: $e');
      rethrow;
    }
  }

  /// Close all boxes
  Future<void> close() async {
    try {
      await Hive.close();
      _initialized = false;
    } catch (e) {
      print('Error closing Hive: $e');
    }
  }
}
