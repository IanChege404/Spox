import 'package:spotify_clone/core/config/env_config.dart';

/// Spotify API configuration constants (loaded from .env)
late String spotifyClientId = EnvConfig.spotifyClientId;
late String spotifyClientSecret = EnvConfig.spotifyClientSecret;
late String spotifyRedirectUrl = EnvConfig.spotifyRedirectUrl;
late String spotifyAuthUrl = '${EnvConfig.authBaseUrl}/authorize';
late String spotifyTokenUrl = '${EnvConfig.authBaseUrl}/api/token';
late String spotifyApiBaseUrl = EnvConfig.apiBaseUrl;

/// Storage directories (loaded from .env)
late String cacheDir = EnvConfig.cacheDir;
late String downloadsDir = EnvConfig.downloadsDir;
late String logsDir = EnvConfig.logsDir;

/// Feature flags (loaded from .env)
late bool enableOfflineMode = EnvConfig.enableOfflineMode;
late bool enableLyricsSync = EnvConfig.enableLyricsSync;
late bool enableStatsPage = EnvConfig.enableStatsPage;
late bool enableEqualizer = EnvConfig.enableEqualizer;

/// Analytics configuration (loaded from .env)
late bool analyticsEnabled = EnvConfig.analyticsEnabled;
late bool crashReportingEnabled = EnvConfig.crashReportingEnabled;

/// Third-party API endpoints (loaded from .env)
late String lrclibApiUrl = EnvConfig.lrclibApiUrl;

/// OAuth scopes required by the app
const String spotifyScopes = '''
user-read-private
user-read-email
playlist-read-private
playlist-read-collaborative
user-library-read
user-library-modify
user-read-playback-state
user-modify-playback-state
streaming
''';

/// Guest mode restrictions - sections that require authentication
const List<String> guestRestrictedSections = [
  'liked_songs',
  'your_mixes',
  'recently_played',
  'your_library',
  'profile',
  'user_playlists',
];

/// Guest mode messages for restricted sections
const Map<String, String> guestSectionMessages = {
  'liked_songs': 'Keep your favorite tracks in one place',
  'your_mixes': 'Get AI-curated mixes based on your taste',
  'recently_played': 'See what you\'ve been listening to',
  'your_library': 'Manage all your saved content',
  'profile': 'View and edit your profile',
  'user_playlists': 'Access your personal playlists',
};

/// Public endpoints accessible by guests
const List<String> guestPublicEndpoints = [
  '/browse/featured-playlists',
  '/browse/categories',
  '/browse/categories/{id}/playlists',
  '/search',
  '/albums',
  '/artists',
  '/tracks',
];
