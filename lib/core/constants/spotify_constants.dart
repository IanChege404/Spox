import 'package:spotify_clone/core/config/env_config.dart';

/// Spotify API configuration constants (loaded from .env)
late String spotifyClientId = EnvConfig.spotifyClientId;
late String spotifyClientSecret = EnvConfig.spotifyClientSecret;
late String spotifyRedirectUrl = EnvConfig.spotifyRedirectUrl;
late String spotifyAuthUrl = '${EnvConfig.authBaseUrl}/authorize';
late String spotifyTokenUrl = '${EnvConfig.authBaseUrl}/api/token';
late String spotifyApiBaseUrl = EnvConfig.apiBaseUrl;

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
