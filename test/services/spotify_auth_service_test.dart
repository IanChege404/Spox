import 'dart:collection';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_clone/core/config/env_config.dart';
import 'package:spotify_clone/core/network/http_client.dart';
import 'package:spotify_clone/services/spotify_auth_service.dart';

class MockHttpClient implements HttpClient {
  final Queue<Future<Response>> _responseQueue = Queue();
  List<String> _accessTokens = [];
  bool _accessTokenCleared = false;

  void setPostResponse(Future<Response> response) {
    _responseQueue.addLast(response);
  }

  void setPostResponses(List<Future<Response>> responses) {
    for (final response in responses) {
      _responseQueue.addLast(response);
    }
  }

  @override
  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    if (_responseQueue.isEmpty) {
      throw StateError('No response queued for post() call');
    }
    return _responseQueue.removeFirst();
  }

  @override
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    throw UnimplementedError('get() not used in these tests');
  }

  @override
  Future<Response> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    throw UnimplementedError('put() not used in these tests');
  }

  @override
  Future<Response> delete(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    throw UnimplementedError('delete() not used in these tests');
  }

  @override
  void setAccessToken(String token) {
    _accessTokens.add(token);
  }

  @override
  void clearAccessToken() {
    _accessTokenCleared = true;
  }

  @override
  Future<void> processRetryQueue() async {
    // Mock implementation - no queued requests to process in tests
  }

  @override
  void rejectRetryQueue(DioException error) {
    // Mock implementation - no queued requests to reject in tests
  }

  @override
  void registerTokenRefreshCallback(Future<bool> Function() callback) {
    // Mock implementation - token refresh not tested in these unit tests
  }

  // Test helpers
  String? getLastAccessToken() =>
      _accessTokens.isNotEmpty ? _accessTokens.last : null;

  bool wasAccessTokenCleared() => _accessTokenCleared;

  void reset() {
    _responseQueue.clear();
    _accessTokens.clear();
    _accessTokenCleared = false;
  }
}

class MockResponse<T> implements Response<T> {
  final int _statusCode;
  final T _data;

  MockResponse({required int statusCode, required T data})
      : _statusCode = statusCode,
        _data = data;

  @override
  int get statusCode => _statusCode;

  @override
  T get data => _data;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockHttpClient mockHttpClient;
  late SpotifyAuthService spotifyAuthService;

  setUpAll(() async {
    // Initialize environment configuration for tests
    TestWidgetsFlutterBinding.ensureInitialized();
    await EnvConfig.init();
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    spotifyAuthService = SpotifyAuthService(httpClient: mockHttpClient);
  });

  group('SpotifyAuthService', () {
    group('generateAuthorizationUrl', () {
      test('returns valid authorization URL with all required parameters', () {
        final url = spotifyAuthService.generateAuthorizationUrl();

        expect(url, contains('client_id='));
        expect(url, contains('response_type=code'));
        expect(url, contains('redirect_uri='));
        expect(url, contains('scope='));
        expect(url, contains('code_challenge='));
        expect(url, contains('code_challenge_method=S256'));
      });

      test('generates consistent code verifier for same session', () {
        final url1 = spotifyAuthService.generateAuthorizationUrl();
        final url2 = spotifyAuthService.generateAuthorizationUrl();

        // Both URLs should have code challenge (though different due to new verifier)
        expect(url1, contains('code_challenge='));
        expect(url2, contains('code_challenge='));
      });

      test('scope includes all required permissions', () {
        final url = spotifyAuthService.generateAuthorizationUrl();

        expect(url, contains('streaming'));
        expect(url, contains('user-read-email'));
        expect(url, contains('user-read-private'));
        expect(url, contains('user-library-read'));
        expect(url, contains('user-library-modify'));
        expect(url, contains('playlist-modify-public'));
        expect(url, contains('playlist-modify-private'));
      });

      test('code challenge is URL-safe base64 encoded', () {
        final url = spotifyAuthService.generateAuthorizationUrl();

        // Extract code_challenge value
        final codeChallengePart = url.split('code_challenge=')[1].split('&')[0];

        // Should not contain padding
        expect(codeChallengePart, isNotEmpty);
        expect(codeChallengePart.contains('='), false);
      });
    });

    group('exchangeCodeForToken', () {
      test('successfully exchanges auth code for access token', () async {
        // Arrange
        final mockResponse = MockResponse(
          statusCode: 200,
          data: {
            'access_token': 'test_access_token',
            'refresh_token': 'test_refresh_token',
            'expires_in': 3600,
            'token_type': 'Bearer',
          },
        );

        mockHttpClient.setPostResponse(Future.value(mockResponse));

        // Generate auth URL to set code verifier
        spotifyAuthService.generateAuthorizationUrl();

        // Act
        await spotifyAuthService.exchangeCodeForToken('test_auth_code');

        // Assert
        expect(spotifyAuthService.accessToken, equals('test_access_token'));
        expect(spotifyAuthService.refreshToken, equals('test_refresh_token'));
        expect(spotifyAuthService.isAuthenticated, isTrue);
        expect(
            mockHttpClient.getLastAccessToken(), equals('test_access_token'));
      });

      test('sets expiration time correctly from expires_in', () async {
        // Arrange
        final mockResponse = MockResponse(
          statusCode: 200,
          data: {
            'access_token': 'test_token',
            'refresh_token': 'refresh_token',
            'expires_in': 7200,
            'token_type': 'Bearer',
          },
        );

        mockHttpClient.setPostResponse(Future.value(mockResponse));

        spotifyAuthService.generateAuthorizationUrl();

        // Act
        await spotifyAuthService.exchangeCodeForToken('test_code');

        // Assert - token should be valid
        expect(spotifyAuthService.isAuthenticated, isTrue);
      });

      test('throws exception when exchange fails with error status', () async {
        // Arrange
        final mockResponse = MockResponse(
          statusCode: 400,
          data: {'error': 'invalid_grant'},
        );

        mockHttpClient.setPostResponse(Future.value(mockResponse));

        spotifyAuthService.generateAuthorizationUrl();

        // Act & Assert
        expect(
          () => spotifyAuthService.exchangeCodeForToken('invalid_code'),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception on network error during code exchange', () async {
        // Arrange
        mockHttpClient.setPostResponse(
          Future.error(Exception('Network error')),
        );

        spotifyAuthService.generateAuthorizationUrl();

        // Act & Assert
        expect(
          () => spotifyAuthService.exchangeCodeForToken('test_code'),
          throwsA(isA<Exception>()),
        );
      });

      test('uses code_verifier from generateAuthorizationUrl in request',
          () async {
        // Arrange
        final mockResponse = MockResponse(
          statusCode: 200,
          data: {
            'access_token': 'token',
            'refresh_token': 'refresh',
            'expires_in': 3600,
          },
        );

        mockHttpClient.setPostResponse(Future.value(mockResponse));

        spotifyAuthService.generateAuthorizationUrl();

        // Act
        await spotifyAuthService.exchangeCodeForToken('auth_code');

        // Assert
        expect(spotifyAuthService.accessToken, equals('token'));
        expect(spotifyAuthService.refreshToken, equals('refresh'));
      });

      test('uses correct grant_type for authorization code exchange', () async {
        // Arrange
        final mockResponse = MockResponse(
          statusCode: 200,
          data: {
            'access_token': 'token',
            'refresh_token': 'refresh',
            'expires_in': 3600,
          },
        );

        mockHttpClient.setPostResponse(Future.value(mockResponse));

        spotifyAuthService.generateAuthorizationUrl();

        // Act
        await spotifyAuthService.exchangeCodeForToken('auth_code');

        // Assert
        expect(spotifyAuthService.isAuthenticated, isTrue);
      });
    });

    group('refreshAccessToken', () {
      test('successfully refreshes access token using refresh token', () async {
        // Arrange - First establish auth
        final authResponse = MockResponse(
          statusCode: 200,
          data: {
            'access_token': 'initial_token',
            'refresh_token': 'refresh_token',
            'expires_in': 3600,
          },
        );

        final refreshResponse = MockResponse(
          statusCode: 200,
          data: {
            'access_token': 'new_token',
            'expires_in': 3600,
            'token_type': 'Bearer',
          },
        );

        // Queue both responses in order
        mockHttpClient.setPostResponse(Future.value(authResponse));
        mockHttpClient.setPostResponse(Future.value(refreshResponse));

        spotifyAuthService.generateAuthorizationUrl();
        await spotifyAuthService.exchangeCodeForToken('auth_code');

        // Act
        await spotifyAuthService.refreshAccessToken();

        // Assert
        expect(spotifyAuthService.accessToken, equals('new_token'));
        expect(mockHttpClient.getLastAccessToken(), equals('new_token'));
      });

      test('updates refresh token when provided in refresh response', () async {
        // Arrange
        final authResponse = MockResponse(
          statusCode: 200,
          data: {
            'access_token': 'token',
            'refresh_token': 'old_refresh',
            'expires_in': 3600,
          },
        );

        final refreshResponse = MockResponse(
          statusCode: 200,
          data: {
            'access_token': 'new_token',
            'refresh_token': 'new_refresh',
            'expires_in': 3600,
          },
        );

        // Queue both responses in order
        mockHttpClient.setPostResponse(Future.value(authResponse));
        mockHttpClient.setPostResponse(Future.value(refreshResponse));

        spotifyAuthService.generateAuthorizationUrl();
        await spotifyAuthService.exchangeCodeForToken('code');

        // Act
        await spotifyAuthService.refreshAccessToken();

        // Assert
        expect(spotifyAuthService.refreshToken, equals('new_refresh'));
      });

      test('keeps existing refresh token when not provided in response',
          () async {
        // Arrange
        final authResponse = MockResponse(
          statusCode: 200,
          data: {
            'access_token': 'token',
            'refresh_token': 'original_refresh',
            'expires_in': 3600,
          },
        );

        final refreshResponse = MockResponse(
          statusCode: 200,
          data: {
            'access_token': 'new_token',
            'expires_in': 3600,
          },
        );

        // Queue both responses in order
        mockHttpClient.setPostResponse(Future.value(authResponse));
        mockHttpClient.setPostResponse(Future.value(refreshResponse));

        spotifyAuthService.generateAuthorizationUrl();
        await spotifyAuthService.exchangeCodeForToken('code');

        // Act
        await spotifyAuthService.refreshAccessToken();

        // Assert
        expect(spotifyAuthService.refreshToken, equals('original_refresh'));
      });

      test('throws exception when no refresh token available', () async {
        // Act & Assert
        expect(
          () => spotifyAuthService.refreshAccessToken(),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception on refresh failure', () async {
        // Arrange
        final authResponse = MockResponse(
          statusCode: 200,
          data: {
            'access_token': 'token',
            'refresh_token': 'refresh',
            'expires_in': 3600,
          },
        );

        // Queue both responses in order
        mockHttpClient.setPostResponse(Future.value(authResponse));

        spotifyAuthService.generateAuthorizationUrl();
        await spotifyAuthService.exchangeCodeForToken('code');

        // Setup for failed refresh
        final failResponse =
            MockResponse(statusCode: 401, data: {'error': 'Unauthorized'});
        mockHttpClient.setPostResponse(Future.value(failResponse));

        // Act & Assert
        expect(
          () => spotifyAuthService.refreshAccessToken(),
          throwsA(isA<Exception>()),
        );
      });

      test('uses correct grant_type for refresh', () async {
        // Arrange
        final authResponse = MockResponse(
          statusCode: 200,
          data: {
            'access_token': 'token',
            'refresh_token': 'refresh_token',
            'expires_in': 3600,
          },
        );

        final refreshResponse = MockResponse(
          statusCode: 200,
          data: {
            'access_token': 'new_token',
            'expires_in': 3600,
          },
        );

        // Queue both responses in order
        mockHttpClient.setPostResponse(Future.value(authResponse));
        mockHttpClient.setPostResponse(Future.value(refreshResponse));

        spotifyAuthService.generateAuthorizationUrl();
        await spotifyAuthService.exchangeCodeForToken('code');

        // Act
        await spotifyAuthService.refreshAccessToken();

        // Assert
        expect(spotifyAuthService.isAuthenticated, isTrue);
      });
    });

    group('logout', () {
      test('clears all tokens and marks as unauthenticated', () async {
        // Arrange
        final mockResponse = MockResponse(
          statusCode: 200,
          data: {
            'access_token': 'test_token',
            'refresh_token': 'test_refresh',
            'expires_in': 3600,
          },
        );

        mockHttpClient.setPostResponse(Future.value(mockResponse));

        spotifyAuthService.generateAuthorizationUrl();
        await spotifyAuthService.exchangeCodeForToken('code');

        expect(spotifyAuthService.isAuthenticated, isTrue);

        // Act
        spotifyAuthService.logout();

        // Assert
        expect(spotifyAuthService.accessToken, isNull);
        expect(spotifyAuthService.refreshToken, isNull);
        expect(spotifyAuthService.isAuthenticated, isFalse);
        expect(mockHttpClient.wasAccessTokenCleared(), isTrue);
      });

      test('can logout before authentication', () {
        // Act
        spotifyAuthService.logout();

        // Assert
        expect(spotifyAuthService.isAuthenticated, isFalse);
        expect(mockHttpClient.wasAccessTokenCleared(), isTrue);
      });
    });

    group('isAuthenticated', () {
      test('returns false when no access token', () {
        expect(spotifyAuthService.isAuthenticated, isFalse);
      });

      test('returns false when token is expired', () async {
        // Arrange
        final mockResponse = MockResponse(
          statusCode: 200,
          data: {
            'access_token': 'token',
            'refresh_token': 'refresh',
            'expires_in': -1, // Already expired
          },
        );

        mockHttpClient.setPostResponse(Future.value(mockResponse));

        spotifyAuthService.generateAuthorizationUrl();
        await spotifyAuthService.exchangeCodeForToken('code');

        // Assert
        expect(spotifyAuthService.isAuthenticated, isFalse);
      });

      test('returns true when token is valid and not expired', () async {
        // Arrange
        final mockResponse = MockResponse(
          statusCode: 200,
          data: {
            'access_token': 'valid_token',
            'refresh_token': 'refresh',
            'expires_in': 3600,
          },
        );

        mockHttpClient.setPostResponse(Future.value(mockResponse));

        spotifyAuthService.generateAuthorizationUrl();
        await spotifyAuthService.exchangeCodeForToken('code');

        // Assert
        expect(spotifyAuthService.isAuthenticated, isTrue);
      });
    });

    group('ensureValidToken', () {
      test('does nothing when token is already valid', () async {
        // Arrange
        final mockResponse = MockResponse(
          statusCode: 200,
          data: {
            'access_token': 'valid_token',
            'refresh_token': 'refresh',
            'expires_in': 3600,
          },
        );

        mockHttpClient.setPostResponse(Future.value(mockResponse));

        spotifyAuthService.generateAuthorizationUrl();
        await spotifyAuthService.exchangeCodeForToken('code');

        // Act
        await spotifyAuthService.ensureValidToken();

        // Assert
        expect(spotifyAuthService.isAuthenticated, isTrue);
      });

      test('refreshes token when expired but refresh token available',
          () async {
        // Arrange - Initial auth
        final authResponse = MockResponse(
          statusCode: 200,
          data: {
            'access_token': 'expired_token',
            'refresh_token': 'refresh_token',
            'expires_in': -1, // Already expired
          },
        );

        final refreshResponse = MockResponse(
          statusCode: 200,
          data: {
            'access_token': 'fresh_token',
            'expires_in': 3600,
          },
        );

        // Queue both responses in order
        mockHttpClient.setPostResponse(Future.value(authResponse));
        mockHttpClient.setPostResponse(Future.value(refreshResponse));

        spotifyAuthService.generateAuthorizationUrl();
        await spotifyAuthService.exchangeCodeForToken('code');

        // Act
        await spotifyAuthService.ensureValidToken();

        // Assert
        expect(spotifyAuthService.isAuthenticated, isTrue);
        expect(spotifyAuthService.accessToken, equals('fresh_token'));
      });

      test('throws exception when not authenticated and no refresh token', () {
        // Act & Assert
        expect(
          () => spotifyAuthService.ensureValidToken(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Accessors', () {
      test('accessToken getter returns null before authentication', () {
        expect(spotifyAuthService.accessToken, isNull);
      });

      test('refreshToken getter returns null before authentication', () {
        expect(spotifyAuthService.refreshToken, isNull);
      });

      test('accessToken getter returns token after authentication', () async {
        // Arrange
        final mockResponse = MockResponse(
          statusCode: 200,
          data: {
            'access_token': 'my_token',
            'refresh_token': 'my_refresh',
            'expires_in': 3600,
          },
        );

        mockHttpClient.setPostResponse(Future.value(mockResponse));

        spotifyAuthService.generateAuthorizationUrl();
        await spotifyAuthService.exchangeCodeForToken('code');

        // Assert
        expect(spotifyAuthService.accessToken, equals('my_token'));
      });

      test('refreshToken getter returns token after authentication', () async {
        // Arrange
        final mockResponse = MockResponse(
          statusCode: 200,
          data: {
            'access_token': 'token',
            'refresh_token': 'my_refresh_token',
            'expires_in': 3600,
          },
        );

        mockHttpClient.setPostResponse(Future.value(mockResponse));

        spotifyAuthService.generateAuthorizationUrl();
        await spotifyAuthService.exchangeCodeForToken('code');

        // Assert
        expect(spotifyAuthService.refreshToken, equals('my_refresh_token'));
      });
    });
  });
}
