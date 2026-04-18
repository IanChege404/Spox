import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spotify_clone/core/constants/spotify_constants.dart';
import 'package:spotify_clone/core/network/http_client.dart';

class SpotifyAuthService {
  final HttpClient _httpClient;
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? _accessToken;
  String? _refreshToken;
  DateTime? _expiresAt;
  String? _codeVerifier;
  bool _isTestMode = false;
  bool _isGuestMode = false;

  // Secure storage keys
  static const String _accessTokenKey = 'spotify_access_token';
  static const String _refreshTokenKey = 'spotify_refresh_token';
  static const String _expiresAtKey = 'spotify_expires_at';

  SpotifyAuthService({required HttpClient httpClient})
      : _httpClient = httpClient {
    _initializeTokens();
  }

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isAuthenticated =>
      _accessToken != null && (_expiresAt?.isAfter(DateTime.now()) ?? false);
  bool get isTestMode => _isTestMode;
  bool get isGuestMode => _isGuestMode;

  /// Backwards-compatible PKCE authorization URL generator.
  /// Kept for tests and manual fallback flows.
  String generateAuthorizationUrl() {
    _codeVerifier = _generateRandomString(96);

    final bytes = utf8.encode(_codeVerifier!);
    final digest = sha256.convert(bytes);
    final codeChallenge = base64Url.encode(digest.bytes).replaceAll('=', '');

    final params = {
      'client_id': spotifyClientId,
      'response_type': 'code',
      'redirect_uri': spotifyRedirectUrl,
      'scope': spotifyScopes.replaceAll('\n', ' ').trim(),
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
    };

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final authUrl = '$spotifyAuthUrl?$queryString';
    print('[Auth] ✓ OAuth Authorization URL generated (PKCE fallback)');
    return authUrl;
  }

  /// Initialize tokens from secure storage on service creation
  Future<void> _initializeTokens() async {
    try {
      _accessToken = await _secureStorage.read(key: _accessTokenKey);
      _refreshToken = await _secureStorage.read(key: _refreshTokenKey);

      final expiresAtStr = await _secureStorage.read(key: _expiresAtKey);
      if (expiresAtStr != null) {
        _expiresAt = DateTime.parse(expiresAtStr);
      }

      if (_accessToken != null) {
        _httpClient.setAccessToken(_accessToken!);
        print('[Auth] ✓ Restored access token from secure storage');
      }
    } catch (e) {
      print('[Auth] ⚠ Error initializing tokens from storage: $e');
    }
  }

  /// Start Spotify OAuth 2.0 PKCE flow via flutter_appauth
  /// This handles the full OAuth dance securely without exposing credentials
  Future<bool> startOAuthFlow() async {
    try {
      print(
          '[Auth] Starting Spotify OAuth 2.0 PKCE flow via flutter_appauth...');

      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          spotifyClientId,
          spotifyRedirectUrl,
          discoveryUrl:
              'https://accounts.spotify.com/.well-known/openid-configuration',
          scopes: spotifyScopes.split('\n').map((s) => s.trim()).toList(),
          promptValues: ['login'],
          additionalParameters: {
            'show_dialog': 'true',
          },
        ),
      );

      if (result == null) {
        print('[Auth] ⚠ OAuth flow cancelled by user');
        return false;
      }

      // Successfully obtained tokens via appauth
      _accessToken = result.accessToken;
      _refreshToken = result.refreshToken;

      if (result.accessTokenExpirationDateTime != null) {
        _expiresAt = result.accessTokenExpirationDateTime;
      } else {
        // Fallback: assume 1 hour expiry
        _expiresAt = DateTime.now().add(const Duration(hours: 1));
      }

      // Persist tokens to secure storage
      await _secureStorage.write(
        key: _accessTokenKey,
        value: _accessToken,
      );
      if (_refreshToken != null) {
        await _secureStorage.write(
          key: _refreshTokenKey,
          value: _refreshToken,
        );
      }
      await _secureStorage.write(
        key: _expiresAtKey,
        value: _expiresAt!.toIso8601String(),
      );

      _httpClient.setAccessToken(_accessToken!);

      print(
          '[Auth] ✓ OAuth flow successful, tokens persisted to secure storage');
      print('[Auth] ✓ Access token expires at: $_expiresAt');
      return true;
    } catch (e) {
      print('[Auth] ✗ OAuth flow error: $e');
      return false;
    }
  }

  /// Exchange authorization code for access token (used for deep link callbacks)
  /// Falls back to manual PKCE exchange if flutter_appauth handling fails
  Future<void> exchangeCodeForToken(String authCode) async {
    try {
      print('[Auth] Manual code exchange for deep link callback...');

      // Build PKCE parameters (use default verifier if not set)
      String codeVerifier = _codeVerifier ?? _generateRandomString(96);

      final response = await _httpClient.post(
        spotifyTokenUrl,
        data: {
          'grant_type': 'authorization_code',
          'code': authCode,
          'redirect_uri': spotifyRedirectUrl,
          'client_id': spotifyClientId,
          'code_verifier': codeVerifier, // PKCE security
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _accessToken = data['access_token'];
        _refreshToken = data['refresh_token'];
        final expiresIn = data['expires_in'] ?? 3600;
        _expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

        // Persist to secure storage
        await _secureStorage.write(
          key: _accessTokenKey,
          value: _accessToken!,
        );
        if (_refreshToken != null) {
          await _secureStorage.write(
            key: _refreshTokenKey,
            value: _refreshToken!,
          );
        }
        await _secureStorage.write(
          key: _expiresAtKey,
          value: _expiresAt!.toIso8601String(),
        );

        _httpClient.setAccessToken(_accessToken!);
        print(
            '[Auth] ✓ Successfully obtained access token via code exchange (expires in ${expiresIn}s)');
      } else {
        throw Exception(
            'Failed to exchange code for token: ${response.statusCode}');
      }
    } catch (e) {
      print('[Auth] ✗ Error exchanging code: $e');
      throw Exception('Error exchanging code: $e');
    }
  }

  /// Generate code verifier for PKCE (only used as fallback)
  String _generateRandomString(int length) {
    const charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.write(charset[random.nextInt(charset.length)]);
    }
    return buffer.toString();
  }

  /// Refresh access token using refresh token
  Future<void> refreshAccessToken() async {
    if (_refreshToken == null) {
      throw Exception('No refresh token available - user must re-authenticate');
    }

    try {
      print('[Auth] Refreshing access token using refresh token...');

      final response = await _httpClient.post(
        spotifyTokenUrl,
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': _refreshToken,
          'client_id': spotifyClientId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _accessToken = data['access_token'];
        final expiresIn = data['expires_in'] ?? 3600;
        _expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

        // Update secure storage with new access token
        await _secureStorage.write(
          key: _accessTokenKey,
          value: _accessToken!,
        );
        await _secureStorage.write(
          key: _expiresAtKey,
          value: _expiresAt!.toIso8601String(),
        );

        // Update refresh token if provided
        if (data['refresh_token'] != null) {
          _refreshToken = data['refresh_token'];
          await _secureStorage.write(
            key: _refreshTokenKey,
            value: _refreshToken!,
          );
        }

        _httpClient.setAccessToken(_accessToken!);
        print('[Auth] ✓ Access token refreshed successfully');

        // Process queued requests
        await _httpClient.processRetryQueue();
      } else {
        throw Exception('Failed to refresh token: ${response.statusCode}');
      }
    } catch (e) {
      print('[Auth] ✗ Token refresh failed: $e');
      throw Exception('Error refreshing token: $e');
    }
  }

  /// Logout and clear all tokens
  Future<void> logout() async {
    try {
      // Clear from secure storage
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _expiresAtKey);

      // Clear from memory
      _accessToken = null;
      _refreshToken = null;
      _expiresAt = null;
      _isTestMode = false;
      _isGuestMode = false;

      _httpClient.clearAccessToken();
      print('[Auth] ✓ Logged out - all tokens cleared');
    } catch (e) {
      print('[Auth] ⚠ Error during logout: $e');
    }
  }

  /// DEBUG ONLY: Enable test mode with a valid access token for development
  void enableTestMode(String validAccessToken) {
    _isTestMode = true;
    _accessToken = validAccessToken;
    _refreshToken = null; // No refresh in test mode
    _expiresAt = DateTime.now().add(const Duration(hours: 1));
    _httpClient.setAccessToken(_accessToken!);
    print('[Auth] ✓ Test mode enabled with valid access token');
  }

  /// DEBUG ONLY: Disable test mode
  void disableTestMode() {
    _isTestMode = false;
    _accessToken = null;
    _refreshToken = null;
    _expiresAt = null;
    _httpClient.clearAccessToken();
    print('[Auth] Test mode disabled');
  }

  /// Enable guest mode (no authentication required)
  Future<void> enableGuestMode() async {
    _isGuestMode = true;
    _accessToken = null;
    _refreshToken = null;
    _expiresAt = null;
    _httpClient.clearAccessToken();
    print('[Auth] ✓ Guest mode enabled - accessing public endpoints only');
  }

  /// Disable guest mode
  Future<void> disableGuestMode() async {
    _isGuestMode = false;
    print('[Auth] Guest mode disabled');
  }

  /// Attach token refresh callback to HttpClient for automatic 401 retry
  void attachToHttpClient(HttpClient httpClient) {
    httpClient.registerTokenRefreshCallback(_handleTokenRefresh);
    print('[Auth] ✓ Token refresh callback registered with HttpClient');
  }

  /// Internal callback for HttpClient to handle 401 errors
  Future<bool> _handleTokenRefresh() async {
    try {
      if (_refreshToken != null && !_isTestMode && !_isGuestMode) {
        await refreshAccessToken();
        return true;
      } else if (_isTestMode) {
        print('[Auth] Test mode: skipping retry on 401');
        return false;
      } else if (_isGuestMode) {
        print('[Auth] Guest mode: skipping retry on 401');
        return false;
      }
      return false;
    } catch (e) {
      print('[Auth] ✗ Failed to refresh token in error handler: $e');
      return false;
    }
  }

  /// Proactive token refresh before expiry
  Future<void> proactiveTokenRefresh() async {
    if (isAuthenticated && _expiresAt != null) {
      final timeUntilExpiry = _expiresAt!.difference(DateTime.now());

      if (timeUntilExpiry.inMinutes < 5) {
        print(
            '[Auth] Token expiring soon (${timeUntilExpiry.inSeconds}s), refreshing proactively...');
        try {
          if (_refreshToken != null && !_isTestMode && !_isGuestMode) {
            await refreshAccessToken();
            print('[Auth] ✓ Proactive token refresh successful');
          }
        } catch (e) {
          print('[Auth] ⚠ Proactive refresh failed: $e');
        }
      }
    }
  }

  /// Ensure valid token before API call
  Future<void> ensureValidToken({bool optional = false}) async {
    if (!isAuthenticated) {
      if (optional) {
        print('[Auth] Continuing without auth (public endpoint)');
        return;
      }
      if (_refreshToken != null) {
        await refreshAccessToken();
      } else {
        throw Exception('Not authenticated - user must log in');
      }
    }
  }
}
