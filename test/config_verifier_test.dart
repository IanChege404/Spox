import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_clone/core/config/env_config.dart';
import 'package:spotify_clone/core/utils/config_verifier.dart';

void main() {
  group('ConfigVerifier', () {
    setUpAll(() async {
      // Initialize env config before tests
      await EnvConfig.init();
    });

    test('Spotify configuration should be present', () {
      final report = ConfigVerifier.verifySpotifyConfig();

      expect(report.containsKey('spotify_client_id'), true);
      expect(report.containsKey('spotify_client_secret'), true);
      expect(report.containsKey('spotify_redirect_url'), true);
      expect(report.containsKey('api_base_url'), true);
      expect(report.containsKey('auth_base_url'), true);
    });

    test('Spotify Client ID should be configured', () {
      final report = ConfigVerifier.verifySpotifyConfig();
      final clientId = report['spotify_client_id'] as Map<String, dynamic>;

      expect(clientId['present'], true);
      expect(clientId.containsKey('valid'), true);
      expect(clientId.containsKey('value'), true);
    });

    test('Spotify Client Secret should be configured', () {
      final report = ConfigVerifier.verifySpotifyConfig();
      final clientSecret =
          report['spotify_client_secret'] as Map<String, dynamic>;

      expect(clientSecret['present'], true);
      expect(clientSecret.containsKey('valid'), true);
      expect(clientSecret.containsKey('value'), true);
    });

    test('API endpoints should be valid', () {
      final report = ConfigVerifier.verifySpotifyConfig();

      final apiBaseUrl = report['api_base_url'] as Map<String, dynamic>;
      final authBaseUrl = report['auth_base_url'] as Map<String, dynamic>;

      expect(apiBaseUrl['valid'], true);
      expect(authBaseUrl['valid'], true);
      expect((apiBaseUrl['value'] as String).contains('api.spotify.com'),
          true);
      expect((authBaseUrl['value'] as String).contains('accounts.spotify.com'),
          true);
    });

    test('Storage paths should be configured', () {
      final report = ConfigVerifier.verifyStorageConfig();

      expect(report.containsKey('cache_dir'), true);
      expect(report.containsKey('downloads_dir'), true);
      expect(report.containsKey('logs_dir'), true);
      expect(report.containsKey('lrclib_api_url'), true);

      // Verify all have values
      report.forEach((key, config) {
        final cfg = config as Map<String, dynamic>;
        expect((cfg['value'] as String).isNotEmpty, true);
      });
    });

    test('Feature flags should load successfully', () {
      final flags = ConfigVerifier.verifyFeatureFlags();

      expect(flags.length, greaterThan(0));
      expect(flags.containsKey('enable_offline_mode'), true);
      expect(flags.containsKey('enable_lyrics_sync'), true);
      expect(flags.containsKey('enable_stats_page'), true);
      expect(flags.containsKey('enable_equalizer'), true);
      expect(flags.containsKey('analytics_enabled'), true);
      expect(flags.containsKey('crash_reporting_enabled'), true);

      // Verify each flag has status
      flags.forEach((key, flag) {
        final f = flag as Map<String, dynamic>;
        expect(f.containsKey('enabled'), true);
        expect(f.containsKey('status'), true);
      });
    });

    test('Overall report should be generated with summary', () {
      final report = ConfigVerifier.getFullReport();

      expect(report.containsKey('spotify'), true);
      expect(report.containsKey('features'), true);
      expect(report.containsKey('storage'), true);
      expect(report.containsKey('summary'), true);

      final summary = report['summary'] as Map<String, dynamic>;
      expect(summary.containsKey('spotify_configured'), true);
      expect(summary.containsKey('features_enabled'), true);
      expect(summary.containsKey('storage_configured'), true);
      expect(summary.containsKey('overall_status'), true);
    });

    test('Report should indicate if app is ready', () {
      final report = ConfigVerifier.getFullReport();
      final summary = report['summary'] as Map<String, dynamic>;
      final status = summary['overall_status'] as String;

      expect(
        status == 'READY ✓' || status == 'NEEDS SETUP ✗',
        true,
        reason: 'Status should be either READY or NEEDS SETUP',
      );
    });

    test('ConfigVerifier should not throw when printing report', () {
      expect(() {
        ConfigVerifier.printReport();
      }, returnsNormally);
    });

    test('EnvConfig should be initialized correctly', () {
      expect(EnvConfig.spotifyClientId.isNotEmpty, true);
      expect(EnvConfig.spotifyClientSecret.isNotEmpty, true);
      expect(EnvConfig.spotifyRedirectUrl.isNotEmpty, true);
      expect(EnvConfig.apiBaseUrl.isNotEmpty, true);
      expect(EnvConfig.authBaseUrl.isNotEmpty, true);
      expect(EnvConfig.cacheDir.isNotEmpty, true);
      expect(EnvConfig.downloadsDir.isNotEmpty, true);
      expect(EnvConfig.logsDir.isNotEmpty, true);
    });

    test('EnvConfig isConfigured should return correct status', () {
      final configured = EnvConfig.isConfigured();
      expect(configured, isA<bool>());
    });
  });
}
