import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration loaded from .env file
class EnvConfig {
  static late final String spotifyClientId;
  static late final String spotifyClientSecret;
  static late final String spotifyRedirectUrl;
  static late final String apiBaseUrl;
  static late final String authBaseUrl;
  static late final bool enableOfflineMode;
  static late final bool enableLyricsSync;
  static late final bool enableStatsPage;
  static late final bool enableEqualizer;
  static late final bool analyticsEnabled;
  static late final bool crashReportingEnabled;
  static late final String lrclibApiUrl;

  /// Initialize environment variables from .env file
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');

    spotifyClientId =
        dotenv.env['SPOTIFY_CLIENT_ID'] ?? 'YOUR_SPOTIFY_CLIENT_ID';
    spotifyClientSecret =
        dotenv.env['SPOTIFY_CLIENT_SECRET'] ?? 'YOUR_SPOTIFY_CLIENT_SECRET';
    spotifyRedirectUrl =
        dotenv.env['SPOTIFY_REDIRECT_URL'] ?? 'com.spotify.clone://callback';
    apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.spotify.com/v1';
    authBaseUrl = dotenv.env['AUTH_BASE_URL'] ?? 'https://accounts.spotify.com';
    enableOfflineMode = dotenv.env['ENABLE_OFFLINE_MODE'] == 'true';
    enableLyricsSync =
        dotenv.env['ENABLE_LYRICS_SYNC'] != 'false'; // Default true
    enableStatsPage =
        dotenv.env['ENABLE_STATS_PAGE'] != 'false'; // Default true
    enableEqualizer = dotenv.env['ENABLE_EQUALIZER'] != 'false'; // Default true
    analyticsEnabled = dotenv.env['ANALYTICS_ENABLED'] == 'true';
    crashReportingEnabled = dotenv.env['CRASH_REPORTING_ENABLED'] == 'true';
    lrclibApiUrl = dotenv.env['LRCLIB_API_URL'] ?? 'https://lrclib.net/api';
  }

  /// Check if credentials are properly configured
  static bool isConfigured() {
    return spotifyClientId != 'YOUR_SPOTIFY_CLIENT_ID' &&
        spotifyClientSecret != 'YOUR_SPOTIFY_CLIENT_SECRET';
  }
}
