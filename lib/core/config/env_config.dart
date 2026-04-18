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
  static late final String cacheDir;
  static late final String downloadsDir;
  static late final String logsDir;
  static late final String firebaseApiKeyWeb;
  static late final String firebaseApiKeyAndroid;
  static late final String firebaseApiKeyIos;
  static late final String firebaseAppIdWeb;
  static late final String firebaseAppIdAndroid;
  static late final String firebaseAppIdIos;
  static late final String firebaseMessagingSenderId;
  static late final String firebaseProjectId;
  static late final String firebaseAuthDomain;
  static late final String firebaseStorageBucket;
  static late final String firebaseMeasurementIdWeb;
  static late final String firebaseMeasurementIdWindows;
  static late final String firebaseIosBundleId;

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
    cacheDir = dotenv.env['CACHE_DIR'] ?? '.cache';
    downloadsDir = dotenv.env['DOWNLOADS_DIR'] ?? 'downloads';
    logsDir = dotenv.env['LOGS_DIR'] ?? 'logs';
    firebaseApiKeyWeb =
        dotenv.env['FIREBASE_API_KEY_WEB'] ?? 'YOUR_FIREBASE_API_KEY_WEB';
    firebaseApiKeyAndroid = dotenv.env['FIREBASE_API_KEY_ANDROID'] ??
        'YOUR_FIREBASE_API_KEY_ANDROID';
    firebaseApiKeyIos =
        dotenv.env['FIREBASE_API_KEY_IOS'] ?? 'YOUR_FIREBASE_API_KEY_IOS';
    firebaseAppIdWeb =
        dotenv.env['FIREBASE_APP_ID_WEB'] ?? 'YOUR_FIREBASE_APP_ID_WEB';
    firebaseAppIdAndroid =
        dotenv.env['FIREBASE_APP_ID_ANDROID'] ?? 'YOUR_FIREBASE_APP_ID_ANDROID';
    firebaseAppIdIos =
        dotenv.env['FIREBASE_APP_ID_IOS'] ?? 'YOUR_FIREBASE_APP_ID_IOS';
    firebaseMessagingSenderId = dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ??
        'YOUR_MESSAGING_SENDER_ID';
    firebaseProjectId =
        dotenv.env['FIREBASE_PROJECT_ID'] ?? 'YOUR_FIREBASE_PROJECT_ID';
    firebaseAuthDomain =
        dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? 'YOUR_FIREBASE_AUTH_DOMAIN';
    firebaseStorageBucket =
        dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? 'YOUR_FIREBASE_STORAGE_BUCKET';
    firebaseMeasurementIdWeb =
        dotenv.env['FIREBASE_MEASUREMENT_ID_WEB'] ?? 'YOUR_MEASUREMENT_ID_WEB';
    firebaseMeasurementIdWindows =
        dotenv.env['FIREBASE_MEASUREMENT_ID_WINDOWS'] ??
            'YOUR_MEASUREMENT_ID_WINDOWS';
    firebaseIosBundleId =
        dotenv.env['FIREBASE_IOS_BUNDLE_ID'] ?? 'com.example.spotifyClone';
  }

  /// Check if credentials are properly configured
  static bool isConfigured() {
    return spotifyClientId != 'YOUR_SPOTIFY_CLIENT_ID';
  }
}
