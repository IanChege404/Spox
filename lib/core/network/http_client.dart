import 'package:dio/dio.dart';

class _RetryRequest {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;

  _RetryRequest(this.requestOptions, this.handler);
}

class HttpClient {
  final Dio _dio = Dio();
  String? _accessToken;
  bool _isRefreshing = false;
  final List<_RetryRequest> _retryQueue = [];

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
        onError: (error, handler) {
          // Handle 401 Unauthorized with token refresh (Phase 2A)
          if (error.response?.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;
            
            // Queue this request for retry after token refresh
            _retryQueue.add(_RetryRequest(error.requestOptions, handler));
            
            // Trigger token refresh (caller's responsibility to implement)
            return handler.next(error);
          }
          
          // Log errors for debugging
          _logError(error);
          return handler.next(error);
        },
        onResponse: (response, handler) {
          // Reset retry queue on successful response
          if (_isRefreshing) {
            _isRefreshing = false;
            _retryQueue.clear();
          }
          return handler.next(response);
        },
      ),
    );
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
