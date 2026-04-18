import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spotify_clone/DI/service_locator.dart';
import 'package:spotify_clone/constants/constants.dart';
import 'package:spotify_clone/services/spotify_auth_service.dart';
import 'package:spotify_clone/services/hive_service.dart';
import 'package:spotify_clone/ui/home_screen.dart';
import 'package:spotify_clone/ui/spotify_login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(
      const Duration(seconds: 3),
      () {
        if (mounted) {
          _navigateToNextScreen();
        }
      },
    );
  }

  void _navigateToNextScreen() {
    final authService = locator<SpotifyAuthService>();
    final hiveService = locator<HiveService>();

    Widget nextScreen;

    // Check if authenticated
    if (authService.isAuthenticated) {
      nextScreen = const HomeScreen();
      print('[SplashScreen] ✓ User authenticated, navigating to home');
    }
    // Check if guest mode is persisted from previous session
    else if (hiveService.isGuestModePersisted()) {
      nextScreen = const HomeScreen();
      print(
          '[SplashScreen] ✓ Guest session persisted, navigating to home as guest');
    }
    // Otherwise show login screen with Continue as Guest option
    else {
      nextScreen = const SpotifyLoginScreen();
      print('[SplashScreen] User not authenticated, showing login screen');
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  void dispose() {
    _navigationTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.blackColor,
      body: Center(
        child: SizedBox(
          height: 200,
          width: 200,
          child: Image.asset(
            'assets/icon/icon.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback if image not found
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.music_note,
                  size: 100,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
