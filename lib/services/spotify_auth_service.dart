import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:spotify_clone/core/constants/spotify_constants.dart';
import 'package:spotify_clone/core/network/http_client.dart';

class SpotifyAuthService {
  final HttpClient _httpClient;
  String? _accessToken;
  String? _refreshToken;
  DateTime? _expiresAt;
  String? _codeVerifier;

  SpotifyAuthService({required HttpClient httpClient})
      : _httpClient = httpClient;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isAuthenticated =>
      _accessToken != null && (_expiresAt?.isAfter(DateTime.now()) ?? false);

  /// Generate code verifier and challenge for PKCE flow
  /// Returns the authorization URL to open in browser
  String generateAuthorizationUrl() {
    // Generate random code verifier (43-128 characters)
    _codeVerifier = _generateRandomString(128);

    // Generate code challenge from verifier
    final bytes = utf8.encode(_codeVerifier!);
    final digest = sha256.convert(bytes);
    final codeChallenge = base64Url.encode(digest.bytes).replaceAll('=', '');

    final params = {
      'client_id': spotifyClientId,
      'response_type': 'code',
      'redirect_uri': spotifyRedirectUrl,
      'scope': 'streaming user-read-email user-read-private '
          'user-library-read user-library-modify '
          'playlist-modify-public playlist-modify-private',
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
    };

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$spotifyAuthUrl?$queryString';
  }

  /// Exchange authorization code for access token
  Future<void> exchangeCodeForToken(String authCode) async {
    try {
      final response = await _httpClient.post(
        spotifyTokenUrl,
        data: {
          'grant_type': 'authorization_code',
          'code': authCode,
          'redirect_uri': spotifyRedirectUrl,
          'client_id': spotifyClientId,
          'code_verifier': _codeVerifier,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _accessToken = data['access_token'];
        _refreshToken = data['refresh_token'];
        final expiresIn = data['expires_in'] ?? 3600;
        _expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
        _httpClient.setAccessToken(_accessToken!);
      } else {
        throw Exception(
            'Failed to exchange code for token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error exchanging code: $e');
    }
  }

  /// Refresh access token using refresh token
  Future<void> refreshAccessToken() async {
    if (_refreshToken == null) {
      throw Exception('No refresh token available');
    }

    try {
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
        _httpClient.setAccessToken(_accessToken!);

        // Update refresh token if provided
        if (data['refresh_token'] != null) {
          _refreshToken = data['refresh_token'];
        }
      } else {
        throw Exception('Failed to refresh token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error refreshing token: $e');
    }
  }

  /// Logout and clear tokens
  void logout() {
    _accessToken = null;
    _refreshToken = null;
    _expiresAt = null;
    _httpClient.clearAccessToken();
  }

  /// Check if token needs refresh and refresh if necessary
  Future<void> ensureValidToken() async {
    if (!isAuthenticated) {
      if (_refreshToken != null) {
        await refreshAccessToken();
      } else {
        throw Exception('Not authenticated');
      }
    }
  }

  /// Generate random string for code verifier
  String _generateRandomString(int length) {
    const charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = DateTime.now().millisecondsSinceEpoch;
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.write(charset[(random + i) % charset.length]);
    }
    return buffer.toString();
  }
}
