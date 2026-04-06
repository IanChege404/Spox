import 'package:flutter/material.dart';
import 'package:spotify_clone/DI/service_locator.dart';
import 'package:spotify_clone/constants/constants.dart';
import 'package:spotify_clone/services/spotify_auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
      await _authService.exchangeCodeForToken(authCode);

      if (mounted && _authService.isAuthenticated) {
        // Navigate to home screen
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Authentication failed: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Initiate Spotify OAuth flow
  Future<void> _startSpotifyLogin() async {
    try {
      final authUrl = _authService.generateAuthorizationUrl();
      if (await canLaunchUrl(Uri.parse(authUrl))) {
        await launchUrl(
          Uri.parse(authUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        setState(() {
          _errorMessage = 'Could not launch Spotify login';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error starting login: $e';
      });
    }
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
                  'images/icon/ic_launcher.png',
                  width: 100,
                  height: 100,
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
                  ElevatedButton.icon(
                    onPressed: _startSpotifyLogin,
                    icon: Image.asset(
                      'images/icon/ic_launcher.png',
                      width: 24,
                      height: 24,
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
                  )
                else if (_errorMessage != null)
                  // Error state
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
