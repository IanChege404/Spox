import 'package:dio/dio.dart';

class _RetryRequest {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;

  _RetryRequest(this.requestOptions, this.handler);
}

typedef TokenRefreshCallback = Future<bool> Function();

class HttpClient {
  final Dio _dio = Dio();
  String? _accessToken;
  bool _isRefreshing = false;
  final List<_RetryRequest> _retryQueue = [];
  TokenRefreshCallback? _onTokenExpired;

  HttpClient() {
    // Configure Dio with defaults
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.responseType = ResponseType.json;

    // Add comprehensive interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth header with access token
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized with automatic token refresh
          if (error.response?.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;

            // Queue this request for retry after token refresh
            _retryQueue.add(_RetryRequest(error.requestOptions, handler));

            // Trigger token refresh via callback
            if (_onTokenExpired != null) {
              try {
                final success = await _onTokenExpired!();
                if (success) {
                  print('[HttpClient] Token refreshed successfully, retrying queued requests');
                  await processRetryQueue();
                  return;
                } else {
                  print('[HttpClient] Token refresh failed');
                  rejectRetryQueue(error);
                  _isRefreshing = false;
                  return handler.next(error);
                }
              } catch (e) {
                print('[HttpClient] Error during token refresh: $e');
                rejectRetryQueue(error);
                _isRefreshing = false;
                return handler.next(error);
              }
            }

            // No refresh callback registered, pass error through
            _isRefreshing = false;
            _retryQueue.clear();
            return handler.next(error);
          }

          // Log errors for debugging
          _logError(error);
          return handler.next(error);
        },
        onResponse: (response, handler) {
          // Reset retry queue on successful response
          if (_isRefreshing && _retryQueue.isEmpty) {
            _isRefreshing = false;
          }
          return handler.next(response);
        },
      ),
    );
  }

  /// Register a callback to refresh token when 401 occurs
  void registerTokenRefreshCallback(TokenRefreshCallback callback) {
    _onTokenExpired = callback;
  }

  /// Set the access token for authenticated requests
  void setAccessToken(String token) {
    _accessToken = token;
  }

  /// Clear the access token (for logout)
  void clearAccessToken() {
    _accessToken = null;
  }

  /// Log errors for debugging (Phase 5 - will integrate with analytics)
  void _logError(DioException error) {
    print('=== HTTP ERROR ===');
    print('Status: ${error.response?.statusCode}');
    print('Message: ${error.message}');
    print('URL: ${error.requestOptions.path}');
    if (error.response?.data != null) {
      print('Response: ${error.response?.data}');
    }
  }

  /// Process retry queue after token refresh succeeds
  Future<void> processRetryQueue() async {
    if (_retryQueue.isEmpty) {
      return;
    }

    print(
        '[HttpClient] Processing ${_retryQueue.length} queued requests after token refresh');
    final queue = List.from(_retryQueue);
    _retryQueue.clear();
    _isRefreshing = false;

    for (final request in queue) {
      try {
        // Retry the queued request with the new token
        final response = await _dio.request(
          request.requestOptions.path,
          data: request.requestOptions.data,
          queryParameters: request.requestOptions.queryParameters,
          options: Options(
            method: request.requestOptions.method,
            headers: request.requestOptions.headers,
          ),
        );
        request.handler.resolve(response);
      } catch (e) {
        request.handler.reject(DioException(
          requestOptions: request.requestOptions,
          error: e,
          type: DioExceptionType.unknown,
        ));
      }
    }
  }

  /// Reject all queued retry requests with an error
  void rejectRetryQueue(DioException error) {
    if (_retryQueue.isEmpty) {
      return;
    }

    print(
        '[HttpClient] Rejecting ${_retryQueue.length} queued requests due to token refresh failure');
    for (final request in _retryQueue) {
      request.handler.reject(error);
    }
    _retryQueue.clear();
    _isRefreshing = false;
  }

  /// GET request
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      return await _dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// POST request
  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      return await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// PUT request
  Future<Response> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      return await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE request
  Future<Response> delete(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      return await _dio.delete(
        url,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
    } catch (e) {
      rethrow;
    }
  }
}
