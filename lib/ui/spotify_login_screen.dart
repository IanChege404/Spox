import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spotify_clone/DI/service_locator.dart';
import 'package:spotify_clone/constants/constants.dart';
import 'package:spotify_clone/services/spotify_auth_service.dart';
import 'package:spotify_clone/services/hive_service.dart';

/// Spotify OAuth Login Screen
///
/// Handles authentication with Spotify via OAuth 2.0 PKCE flow.
/// After successful authentication, user is redirected to home screen.
class SpotifyLoginScreen extends StatefulWidget {
  final String? redirectCode;

  const SpotifyLoginScreen({
    super.key,
    this.redirectCode,
  });

  @override
  State<SpotifyLoginScreen> createState() => _SpotifyLoginScreenState();
}

class _SpotifyLoginScreenState extends State<SpotifyLoginScreen> {
  late final SpotifyAuthService _authService;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _authService = locator<SpotifyAuthService>();

    // If we have a redirect code (from deep link), exchange it for token
    if (widget.redirectCode != null && widget.redirectCode!.isNotEmpty) {
      _exchangeCodeForToken(widget.redirectCode!);
    }
  }

  /// Exchange authorization code for access token
  Future<void> _exchangeCodeForToken(String authCode) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('[Login] Exchanging authorization code for access token...');
      await _authService.exchangeCodeForToken(authCode);

      if (mounted && _authService.isAuthenticated) {
        print('[Login] ✓ Authentication successful, navigating to home...');
        // Clear guest mode when user authenticates
        final hiveService = locator<HiveService>();
        await hiveService.clearGuestMode();
        // Navigate to artist onboarding first if preferences haven't been set
        if (mounted) {
          final targetRoute = hiveService.hasCompletedArtistPreferences()
              ? '/home'
              : '/artist-preferences';
          Navigator.of(context).pushReplacementNamed(targetRoute);
        }
      } else {
        throw Exception('Authentication failed - token not set');
      }
    } catch (e) {
      print('[Login] ✗ Token exchange error: $e');
      setState(() {
        _errorMessage = 'Failed to complete authentication:\n\n'
            '${e.toString().replaceFirst('Exception: ', '')}\n\n'
            'Please try again.';
        _isLoading = false;
      });
    }
  }

  /// Initiate Spotify OAuth flow via flutter_appauth
  /// Uses in-app browser for seamless PKCE-based authentication
  Future<void> _startSpotifyLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('[Login] Starting Spotify OAuth flow via flutter_appauth...');

      // Use flutter_appauth for in-app browser authentication
      final success = await _authService.startOAuthFlow();

      if (mounted) {
        if (success && _authService.isAuthenticated) {
          print('[Login] ✓ Authentication successful, navigating to home...');
          // Clear guest mode when user authenticates
          final hiveService = locator<HiveService>();
          await hiveService.clearGuestMode();
          // Navigate to artist onboarding first if preferences haven't been set
          if (mounted) {
            final targetRoute = hiveService.hasCompletedArtistPreferences()
                ? '/home'
                : '/artist-preferences';
            Navigator.of(context).pushReplacementNamed(targetRoute);
          }
        } else {
          print('[Login] ⚠ OAuth flow was cancelled by user');
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('[Login] ✗ OAuth flow error: $e');
      setState(() {
        _errorMessage = 'Authentication failed:\n\n'
            '${e.toString().replaceFirst('Exception: ', '')}\n\n'
            'Please try again.';
        _isLoading = false;
      });
    }
  }

  /// Continue as guest - enable guest mode and navigate to home
  Future<void> _continueAsGuest() async {
    try {
      final authService = locator<SpotifyAuthService>();
      final hiveService = locator<HiveService>();

      // Enable guest mode
      await authService.enableGuestMode();
      await hiveService.saveGuestMode(true);

      print('[Login] ✓ Guest mode enabled, navigating to home');

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      print('[Login] ✗ Error continuing as guest: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// Debug-only shortcut to bypass Spotify OAuth during development.
  Future<void> _skipLoginForDevelopment() async {
    if (!kDebugMode) return;
    await _continueAsGuest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.blackColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Spotify Logo / Title
                Image.asset(
                  'assets/icon/icon.png',
                  width: 100,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: MyColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.music_note,
                        size: 50,
                        color: Colors.black,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // Title
                Text(
                  'Spotify Clone',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Subtitle
                Text(
                  'Sign in with your Spotify account to access\nmillions of songs',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[400],
                      ),
                ),
                const SizedBox(height: 40),

                // Login Button
                if (!_isLoading && _errorMessage == null)
                  Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _startSpotifyLogin,
                        icon: Image.asset(
                          'assets/icon/icon.png',
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.music_note, size: 24);
                          },
                        ),
                        label: const Text('Login with Spotify'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.primaryColor,
                          foregroundColor: MyColors.blackColor,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Continue as Guest button
                      OutlinedButton(
                        onPressed: _continueAsGuest,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: MyColors.primaryColor, width: 2),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Continue as Guest',
                          style: TextStyle(
                            color: MyColors.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Note: For development testing, use scripts/get-test-token.js to obtain a valid token
                      // and then manually test by setting it via debug commands, not hardcoded in UI
                    ],
                  )
                else if (_isLoading)
                  // Loading state
                  Column(
                    children: [
                      const CircularProgressIndicator(
                        color: MyColors.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Authenticating...',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),

                // DEBUG: Test login button (dev mode only)
                if (kDebugMode && !_isLoading && _errorMessage == null)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _skipLoginForDevelopment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          '🔧 Dev: Skip Login',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),

                // Error state
                if (_errorMessage != null)
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red, width: 1),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Login Failed',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.red[300],
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _errorMessage = null;
                            _isLoading = false;
                          });
                          _startSpotifyLogin();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.primaryColor,
                          foregroundColor: MyColors.blackColor,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 40),

                // Info box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[800]!, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ℹ️ First Time Setup?',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Make sure you have configured your Spotify API credentials in the .env file. See SPOTIFY_SETUP.md for detailed instructions.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[400],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
