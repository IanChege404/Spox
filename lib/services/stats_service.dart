import 'package:spotify_clone/data/model/user_stats.dart';
import 'package:spotify_clone/services/hive_service.dart';

/// Service to calculate and generate user statistics
class StatsService {
  final HiveService _hiveService;

  StatsService({required HiveService hiveService}) : _hiveService = hiveService;

  /// Calculate statistics for a given period
  Future<UserStats?> calculateStats(StatsPeriod period) async {
    try {
      // Get play history
      final playHistory =
          await _hiveService.getPlayHistory(limit: -1); // All entries

      if (playHistory.isEmpty) {
        return null;
      }

      // Parse and filter by period
      final now = DateTime.now();
      final cutoffDate = now.subtract(period.duration);
      final filteredHistory = playHistory
          .where((entry) {
            final playedAt = _parseDateTime(entry['playedAt']);
            return playedAt.isAfter(cutoffDate);
          })
          .toList()
          .cast<Map<String, dynamic>>();

      if (filteredHistory.isEmpty) {
        return null;
      }

      // Calculate metrics
      final totalMinutes = _calculateTotalMinutes(filteredHistory);
      final topTracks = _getTopTracks(filteredHistory);
      final topArtists = _getTopArtists(filteredHistory);
      final topAlbums = _getTopAlbums(filteredHistory);
      final topArtist =
          topArtists.isNotEmpty ? topArtists.first.name : 'Unknown';

      return UserStats(
        totalMinutesListened: totalMinutes,
        topArtist: topArtist,
        topTracks: topTracks,
        topArtists: topArtists,
        topAlbums: topAlbums,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      print('Error calculating stats: $e');
      return null;
    }
  }

  /// Calculate total minutes listened
  int _calculateTotalMinutes(List<Map<String, dynamic>> history) {
    int totalSeconds = 0;
    for (final entry in history) {
      final duration = entry['duration'] as int? ?? 0;
      totalSeconds += duration;
    }
    return (totalSeconds / 60).round();
  }

  /// Get top 5 tracks
  List<StatTrack> _getTopTracks(List<Map<String, dynamic>> history) {
    final trackMap =
        <String, (int count, int totalMinutes, String artist, String? art)>{};

    for (final entry in history) {
      final name = entry['trackName'] as String? ?? 'Unknown';
      final artist = entry['singers'] as String? ?? 'Unknown';
      final duration = entry['duration'] as int? ?? 0;
      final art = entry['albumImage'] as String?;
      final key = '$name|$artist';

      if (trackMap.containsKey(key)) {
        final (count, minutes, _, _) = trackMap[key]!;
        trackMap[key] = (count + 1, minutes + (duration ~/ 60), artist, art);
      } else {
        trackMap[key] = (1, duration ~/ 60, artist, art);
      }
    }

    // Sort by play count and convert
    final sorted = trackMap.entries
        .map((e) => (
              key: e.key,
              count: e.value.$1,
              minutes: e.value.$2,
              artist: e.value.$3,
              art: e.value.$4
            ))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return sorted.take(5).map((item) {
      final parts = item.key.split('|');
      return StatTrack(
        trackName: parts[0],
        artistName: item.artist,
        playCount: item.count,
        totalMinutesListened: item.minutes,
        albumArt: item.art,
      );
    }).toList();
  }

  /// Get top 5 artists
  List<StatArtist> _getTopArtists(List<Map<String, dynamic>> history) {
    final artistMap = <String, (int count, int minutes)>{};

    for (final entry in history) {
      final artists = entry['singers'] as String? ?? 'Unknown';
      final duration = entry['duration'] as int? ?? 0;

      // Split multiple artists
      for (final artist in artists.split(',')) {
        final trimmed = artist.trim();
        if (artistMap.containsKey(trimmed)) {
          final (count, minutes) = artistMap[trimmed]!;
          artistMap[trimmed] = (count + 1, minutes + (duration ~/ 60));
        } else {
          artistMap[trimmed] = (1, duration ~/ 60);
        }
      }
    }

    // Sort by play count and convert
    final sorted = artistMap.entries
        .map((e) => (name: e.key, count: e.value.$1, minutes: e.value.$2))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return sorted.take(5).map((item) {
      return StatArtist(
        name: item.name,
        playCount: item.count,
        totalMinutesListened: item.minutes,
      );
    }).toList();
  }

  /// Get top 5 albums
  List<StatAlbum> _getTopAlbums(List<Map<String, dynamic>> history) {
    final albumMap = <String, (int count, String artist, String? art)>{};

    for (final entry in history) {
      // Albums aren't tracked in basic history, use track grouping as proxy
      final trackName = entry['trackName'] as String? ?? 'Unknown';
      final artist = entry['singers'] as String? ?? 'Unknown';
      final art = entry['albumImage'] as String?;

      if (albumMap.containsKey(trackName)) {
        final (count, _, _) = albumMap[trackName]!;
        albumMap[trackName] = (count + 1, artist, art);
      } else {
        albumMap[trackName] = (1, artist, art);
      }
    }

    // Sort by play count and convert
    final sorted = albumMap.entries
        .map((e) => (
              name: e.key,
              count: e.value.$1,
              artist: e.value.$2,
              art: e.value.$3
            ))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return sorted.take(5).map((item) {
      return StatAlbum(
        name: item.name,
        artistName: item.artist,
        playCount: item.count,
        albumArt: item.art,
      );
    }).toList();
  }

  /// Parse play history datetime
  DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}
