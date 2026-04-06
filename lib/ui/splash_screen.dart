import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spotify_clone/DI/service_locator.dart';
import 'package:spotify_clone/constants/constants.dart';
import 'package:spotify_clone/services/spotify_auth_service.dart';
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

    Widget nextScreen;

    // If authenticated, go to home
    if (authService.isAuthenticated) {
      nextScreen = const HomeScreen();
    } else {
      // Otherwise show login screen
      nextScreen = const SpotifyLoginScreen();
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
        child: Image.asset(
          'images/splah_logo.png',
          height: 200,
          width: 200,
        ),
      ),
    );
  }
}
