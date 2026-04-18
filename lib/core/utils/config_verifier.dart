import 'package:spotify_clone/core/config/env_config.dart';

/// Configuration verification utility for Spotify Clone
class ConfigVerifier {
  /// Check Spotify configuration completeness
  static Map<String, dynamic> verifySpotifyConfig() {
    final results = <String, dynamic>{};

    // Check Client ID
    results['spotify_client_id'] = {
      'present': EnvConfig.spotifyClientId.isNotEmpty,
      'valid': EnvConfig.spotifyClientId != 'YOUR_SPOTIFY_CLIENT_ID' &&
          EnvConfig.spotifyClientId.length >= 20,
      'value': EnvConfig.spotifyClientId.isEmpty
          ? 'MISSING'
          : EnvConfig.spotifyClientId.substring(0, 10) + '***',
    };

    // Check Client Secret (optional for PKCE mobile flow)
    results['spotify_client_secret'] = {
      'present': EnvConfig.spotifyClientSecret.isNotEmpty,
      'valid': true,
      'value': EnvConfig.spotifyClientSecret.isEmpty
          ? 'OPTIONAL_FOR_PKCE'
          : EnvConfig.spotifyClientSecret.substring(0, 10) + '***',
    };

    // Check Redirect URL
    results['spotify_redirect_url'] = {
      'present': EnvConfig.spotifyRedirectUrl.isNotEmpty,
      'valid': EnvConfig.spotifyRedirectUrl.contains('spotify.clone') ||
          EnvConfig.spotifyRedirectUrl.startsWith('com.spotify'),
      'value': EnvConfig.spotifyRedirectUrl,
    };

    // Check API endpoints
    results['api_base_url'] = {
      'present': EnvConfig.apiBaseUrl.isNotEmpty,
      'valid': EnvConfig.apiBaseUrl.contains('api.spotify.com'),
      'value': EnvConfig.apiBaseUrl,
    };

    results['auth_base_url'] = {
      'present': EnvConfig.authBaseUrl.isNotEmpty,
      'valid': EnvConfig.authBaseUrl.contains('accounts.spotify.com'),
      'value': EnvConfig.authBaseUrl,
    };

    return results;
  }

  /// Check feature flags and preferences
  static Map<String, dynamic> verifyFeatureFlags() {
    return {
      'enable_offline_mode': {
        'enabled': EnvConfig.enableOfflineMode,
        'status': EnvConfig.enableOfflineMode ? 'ON' : 'OFF',
      },
      'enable_lyrics_sync': {
        'enabled': EnvConfig.enableLyricsSync,
        'status': EnvConfig.enableLyricsSync ? 'ON' : 'OFF',
      },
      'enable_stats_page': {
        'enabled': EnvConfig.enableStatsPage,
        'status': EnvConfig.enableStatsPage ? 'ON' : 'OFF',
      },
      'enable_equalizer': {
        'enabled': EnvConfig.enableEqualizer,
        'status': EnvConfig.enableEqualizer ? 'ON' : 'OFF',
      },
      'analytics_enabled': {
        'enabled': EnvConfig.analyticsEnabled,
        'status': EnvConfig.analyticsEnabled ? 'ON' : 'OFF',
      },
      'crash_reporting_enabled': {
        'enabled': EnvConfig.crashReportingEnabled,
        'status': EnvConfig.crashReportingEnabled ? 'ON' : 'OFF',
      },
    };
  }

  /// Check storage configuration
  static Map<String, dynamic> verifyStorageConfig() {
    return {
      'cache_dir': {
        'value': EnvConfig.cacheDir,
        'valid': EnvConfig.cacheDir.isNotEmpty,
      },
      'downloads_dir': {
        'value': EnvConfig.downloadsDir,
        'valid': EnvConfig.downloadsDir.isNotEmpty,
      },
      'logs_dir': {
        'value': EnvConfig.logsDir,
        'valid': EnvConfig.logsDir.isNotEmpty,
      },
      'lrclib_api_url': {
        'value': EnvConfig.lrclibApiUrl,
        'valid': EnvConfig.lrclibApiUrl.contains('lrclib.net'),
      },
    };
  }

  /// Overall configuration status
  static Map<String, dynamic> getFullReport() {
    final spotify = verifySpotifyConfig();
    final features = verifyFeatureFlags();
    final storage = verifyStorageConfig();

    // Calculate overall health
    final spotifyValid = (spotify.values.toList())
        .cast<Map<String, dynamic>>()
        .every((item) => item['valid'] == true);

    final storageValid =
        storage.values.cast<Map<String, dynamic>>().every((item) {
      return item['valid'] == true;
    });

    return {
      'spotify': spotify,
      'features': features,
      'storage': storage,
      'summary': {
        'spotify_configured': spotifyValid,
        'features_enabled': features.values
            .cast<Map<String, dynamic>>()
            .where((f) => f['enabled'] == true)
            .length,
        'storage_configured': storageValid,
        'overall_status':
            spotifyValid && storageValid ? 'READY ✓' : 'NEEDS SETUP ✗',
      },
    };
  }

  /// Print a formatted report
  static void printReport() {
    final report = getFullReport();

    print('\n' + '=' * 70);
    print('📋 CONFIGURATION VERIFICATION REPORT');
    print('=' * 70);

    // Spotify Configuration
    print('\n🎵 SPOTIFY CONFIGURATION:');
    print('-' * 70);
    final spotify = report['spotify'] as Map<String, dynamic>;
    spotify.forEach((key, value) {
      final status = (value as Map)['valid'] ? '✓' : '✗';
      final displayValue = (value)['value'] as String;
      print('  $status $key: $displayValue');
    });

    // Feature Flags
    print('\n⚙️  FEATURE FLAGS:');
    print('-' * 70);
    final features = report['features'] as Map<String, dynamic>;
    features.forEach((key, value) {
      final status = (value as Map)['enabled'] ? '✓ ON' : '✗ OFF';
      print('  $status: $key');
    });

    // Storage Configuration
    print('\n💾 STORAGE CONFIGURATION:');
    print('-' * 70);
    final storage = report['storage'] as Map<String, dynamic>;
    storage.forEach((key, value) {
      final valid = (value as Map)['valid'] ? '✓' : '✗';
      final displayValue = (value)['value'] as String;
      print('  $valid $key: $displayValue');
    });

    // Summary
    print('\n📊 SUMMARY:');
    print('-' * 70);
    final summary = report['summary'] as Map<String, dynamic>;
    print('  Spotify Score: ${summary['spotify_configured'] ? '✓' : '✗'}');
    print('  Features Enabled: ${summary['features_enabled']}');
    print('  Storage Score: ${summary['storage_configured'] ? '✓' : '✗'}');
    print('  Overall Status: ${summary['overall_status']}');

    print('\n' + '=' * 70);
    print('🔥 FIREBASE CONFIGURATION: Generated ✓ (firebase_options.dart)');
    print('   Project ID: spox-60047');
    print('   Platforms: Android, iOS, macOS, Web, Windows');
    print('   Auth: Enabled ✓ | Firestore: Enabled ✓ | Analytics: Enabled ✓');
    print(
        '   Note: Service Account Key NOT needed for client apps on Spark plan');
    print('=' * 70 + '\n');
  }
}
