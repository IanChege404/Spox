import 'package:spotify_clone/core/config/env_config.dart';
import 'package:spotify_clone/core/network/http_client.dart';
import 'package:spotify_clone/data/model/lyrics.dart';

/// Service to fetch time-synced lyrics from online sources
class LyricsService {
  final HttpClient _httpClient;

  LyricsService({required HttpClient httpClient}) : _httpClient = httpClient;

  /// Fetch lyrics from LRCLIB API
  /// Returns null if lyrics not found
  Future<Lyrics?> fetchLyrics({
    required String trackName,
    required String artistName,
  }) async {
    try {
      if (!EnvConfig.enableLyricsSync) {
        return null;
      }

      // Query LRCLIB API: https://lrclib.net/api/get?artist=...&track=...
      final response = await _httpClient.get(
        '${EnvConfig.lrclibApiUrl}/get',
        queryParameters: {
          'artist': artistName,
          'track': trackName,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // Check if we got lyrics back
        if (data['syncedLyrics'] != null &&
            data['syncedLyrics'].toString().isNotEmpty) {
          final lines = _parseLyrics(data['syncedLyrics'] as String);
          return Lyrics(
            trackName: trackName,
            artistName: artistName,
            lines: lines,
            isSynced: true,
          );
        } else if (data['plainLyrics'] != null &&
            data['plainLyrics'].toString().isNotEmpty) {
          // Fall back to plain lyrics if synced not available
          final lines = (data['plainLyrics'] as String)
              .split('\n')
              .map((line) => LyricLine(timestamp: Duration.zero, text: line))
              .toList();
          return Lyrics(
            trackName: trackName,
            artistName: artistName,
            lines: lines,
            isSynced: false,
          );
        }
      }

      return null;
    } catch (e) {
      print('Error fetching lyrics: $e');
      return null;
    }
  }

  /// Parse LRC format lyrics into LyricLine objects
  List<LyricLine> _parseLyrics(String lrcContent) {
    return lrcContent
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => LyricLine.fromLrc(line))
        .toList();
  }

  /// Search for lyrics by query (optional feature)
  Future<List<Lyrics>> searchLyrics(String query) async {
    try {
      // LRCLIB doesn't have a search endpoint, so this would require a different API
      // For now, return empty list
      return [];
    } catch (e) {
      print('Error searching lyrics: $e');
      return [];
    }
  }
}
