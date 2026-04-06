import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_clone/ui/scan_spotify_code.dart';

void main() {
  group('parseSpotifyUri', () {
    test('parses spotify:track:ID URIs', () {
      const uri = 'spotify:track:4cOdK2wGLETKBW3PvgPWqT';
      final result = parseSpotifyUri(uri);
      expect(result, '4cOdK2wGLETKBW3PvgPWqT');
    });

    test('parses spotify:album:ID URIs', () {
      const uri = 'spotify:album:1NAmidJlEaVgA3MpcPFYGq';
      final result = parseSpotifyUri(uri);
      expect(result, '1NAmidJlEaVgA3MpcPFYGq');
    });

    test('parses spotify:playlist:ID URIs', () {
      const uri = 'spotify:playlist:37i9dQZF1DXcBWIGoYBM5M';
      final result = parseSpotifyUri(uri);
      expect(result, '37i9dQZF1DXcBWIGoYBM5M');
    });

    test('parses open.spotify.com track URLs', () {
      const url = 'https://open.spotify.com/track/4cOdK2wGLETKBW3PvgPWqT';
      final result = parseSpotifyUri(url);
      expect(result, '4cOdK2wGLETKBW3PvgPWqT');
    });

    test('parses open.spotify.com album URLs', () {
      const url = 'https://open.spotify.com/album/1NAmidJlEaVgA3MpcPFYGq';
      final result = parseSpotifyUri(url);
      expect(result, '1NAmidJlEaVgA3MpcPFYGq');
    });

    test('parses open.spotify.com playlist URLs', () {
      const url =
          'https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M';
      final result = parseSpotifyUri(url);
      expect(result, '37i9dQZF1DXcBWIGoYBM5M');
    });

    test('returns null for non-Spotify URLs', () {
      const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
      final result = parseSpotifyUri(url);
      expect(result, isNull);
    });

    test('returns null for random text', () {
      const text = 'hello world';
      final result = parseSpotifyUri(text);
      expect(result, isNull);
    });

    test('returns null for empty string', () {
      final result = parseSpotifyUri('');
      expect(result, isNull);
    });

    test('handles spotify URI with extra parts gracefully', () {
      // Too short — only 'spotify:track' with no ID
      const uri = 'spotify:track';
      final result = parseSpotifyUri(uri);
      // 2 parts → not 3 → returns null
      expect(result, isNull);
    });
  });
}
