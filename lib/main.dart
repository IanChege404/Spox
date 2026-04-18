import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/DI/service_locator.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_bloc.dart';
import 'package:spotify_clone/bloc/auth/auth_bloc.dart';
import 'package:spotify_clone/bloc/cloud_sync/cloud_sync_bloc.dart';
import 'package:spotify_clone/bloc/download/download_bloc.dart';
import 'package:spotify_clone/bloc/equalizer/equalizer_bloc.dart';
import 'package:spotify_clone/bloc/guest/guest_access_cubit.dart';
import 'package:spotify_clone/bloc/history/history_bloc.dart';
import 'package:spotify_clone/bloc/home/home_bloc.dart';
import 'package:spotify_clone/bloc/liked_songs/liked_songs_bloc.dart';
import 'package:spotify_clone/bloc/liked_songs/liked_songs_event.dart';
import 'package:spotify_clone/bloc/lyrics/lyrics_bloc.dart';
import 'package:spotify_clone/bloc/queue/queue_bloc.dart';
import 'package:spotify_clone/bloc/search/search_bloc.dart';
import 'package:spotify_clone/bloc/stats/stats_bloc.dart';
import 'package:spotify_clone/bloc/theme/theme_bloc.dart';
import 'package:spotify_clone/bloc/theme/theme_event.dart';
import 'package:spotify_clone/bloc/theme/theme_state.dart';
import 'package:spotify_clone/core/config/env_config.dart';
import 'package:spotify_clone/services/audio_handler.dart';
import 'package:spotify_clone/services/firebase_service.dart';
import 'package:spotify_clone/services/hive_service.dart';
import 'package:spotify_clone/services/spotify_auth_service.dart';
import 'package:spotify_clone/core/theme/app_theme.dart';
import 'package:spotify_clone/ui/artist_preferences_screen.dart';
import 'package:spotify_clone/ui/home_screen.dart';
import 'package:spotify_clone/ui/splash_screen.dart';
import 'package:spotify_clone/ui/spotify_login_screen.dart';
import 'package:spotify_clone/widgets/mini_player_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment configuration from .env
  await EnvConfig.init();

  // Initialize Hive for persistence
  final hiveService = HiveService();
  try {
    await hiveService.init();
    print('[main] ✓ Hive initialization completed successfully');
  } catch (e) {
    print('[main] ✗ Critical error during Hive initialization: $e');
    // Attempt to recover by clearing app data and retrying once
    try {
      print('[main] Attempting recovery...');
      // Note: This will throw if recovery fails, causing app crash with clear error
      rethrow;
    } catch (recoveryError) {
      print('[main] ✗ Recovery failed: $recoveryError');
      rethrow; // Let the app crash with the error visible
    }
  }

  // Initialize Firebase for authentication and data synchronization
  final firebaseService = FirebaseService();
  try {
    await firebaseService.initialize();
    print('[main] ✓ Firebase initialization completed successfully');
  } catch (e) {
    print('[main] ✗ Error during Firebase initialization: $e');
    // Check if it's just a double-init error (Firebase already initialized by Android layer)
    if (e.toString().contains('already exists')) {
      print('[main] ℹ Firebase was auto-initialized by Android, continuing...');
    } else {
      // Don't block app startup if Firebase fails - some features will be limited
      print('[main] ⚠ App will continue with limited Firebase features');
    }
  }

  // Initialize service locator ONLY after Firebase is fully ready
  // This prevents race conditions where Firestore is accessed before Firebase initializes
  if (!firebaseService.isInitialized) {
    print(
        '[main] ⚠ WARNING: Firebase not fully initialized before Service Locator init');
  }
  initServiceLocator(hiveService);

  // Data loading moved to BLoCs using Spotify API
  // No hardcoded seed data - everything fetched from Spotify in real-time
  print('[main] ✓ Ready to load data from Spotify API via BLoCs');

  // Initialize AudioService for background playback and OS media controls
  // This may fail on emulators or due to AndroidManifest.xml configuration issues
  try {
    await AudioService.init(
      builder: () => locator<AppAudioHandler>(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.spotify_clone.channel.audio',
        androidNotificationChannelName: 'Spotify Clone Playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
    print('[main] ✓ AudioService initialization completed successfully');
  } catch (e) {
    print('[main] ✗ AudioService initialization failed: $e');
    if (e.toString().contains('AndroidManifest.xml')) {
      print(
          '[main] ℹ  Check android/app/src/main/AndroidManifest.xml configuration');
    }
    print('[main] ⚠ App will continue without background audio support');
    // Don't block app startup - app can still function without AudioService
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AudioPlayerBloc>(
          create: (context) => locator<AudioPlayerBloc>(),
        ),
        BlocProvider<QueueBloc>(
          create: (context) => locator<QueueBloc>(),
        ),
        BlocProvider<LikedSongsBloc>(
          create: (context) =>
              locator<LikedSongsBloc>()..add(const LoadLikedSongsEvent()),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => locator<AuthBloc>(),
        ),
        BlocProvider<CloudSyncBloc>(
          create: (context) => locator<CloudSyncBloc>(),
        ),
        BlocProvider<SearchBloc>(
          create: (context) => locator<SearchBloc>(),
        ),
        BlocProvider<HistoryBloc>(
          create: (context) => locator<HistoryBloc>(),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => locator<ThemeBloc>(),
        ),
        BlocProvider<LyricsBloc>(
          create: (context) => locator<LyricsBloc>(),
        ),
        BlocProvider<StatsBloc>(
          create: (context) => locator<StatsBloc>(),
        ),
        BlocProvider<EqualizerBloc>(
          create: (context) => locator<EqualizerBloc>(),
        ),
        BlocProvider<DownloadBloc>(
          create: (context) => locator<DownloadBloc>(),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => locator<HomeBloc>(),
        ),
        BlocProvider<GuestAccessCubit>(
          create: (context) => locator<GuestAccessCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isThemeChanged = themeState is ThemeChanged;
          final appThemeData =
              isThemeChanged ? themeState.themeData : AppTheme.darkTheme();
          final themeMode = isThemeChanged
              ? switch (themeState.themeMode) {
                  AppThemeMode.light => ThemeMode.light,
                  AppThemeMode.system => ThemeMode.system,
                  AppThemeMode.dark => ThemeMode.dark,
                }
              : ThemeMode.dark;

          return AnimatedTheme(
            data: appThemeData,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: MaterialApp(
              title: 'Spotify Clone',
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: themeMode,
              debugShowCheckedModeBanner: false,
              home: _buildInitialScreen(),
              routes: {
                '/home': (context) => MiniPlayerOverlay(
                      child: const HomeScreen(),
                    ),
                '/artist-preferences': (context) =>
                    const ArtistPreferencesScreen(),
                '/login': (context) => const SpotifyLoginScreen(),
              },
              // Handle deep links from Spotify OAuth redirect
              // This is triggered when the app is launched with a deep link
              // OR when the app is already running and receives a deep link (via Android foreground notification)
              onGenerateRoute: _handleDeepLink,
            ),
          );
        },
      ),
    );
  }

  /// Handle deep links from Spotify OAuth redirect (com.spotify.clone://callback?code=AUTH_CODE)
  /// This is called both at app startup (cold/warm start) and during runtime (hot start)
  static Route<dynamic>? _handleDeepLink(RouteSettings settings) {
    if (settings.name == null || !settings.name!.startsWith('/callback')) {
      return null; // Not a callback link, let default routing handle it
    }

    try {
      print('[main] ✓ Deep link received: ${settings.name}');
      final uri = Uri.parse(settings.name!);
      final code = uri.queryParameters['code'];
      final error = uri.queryParameters['error'];
      final state = uri.queryParameters['state'];

      // Handle OAuth errors from Spotify
      if (error != null) {
        final errorDesc =
            uri.queryParameters['error_description'] ?? 'Unknown error';
        print('[main] ✗ OAuth error from Spotify: $error - $errorDesc');
        // Show error to user by navigating to login with null code
        return MaterialPageRoute(
          builder: (context) => const SpotifyLoginScreen(redirectCode: null),
        );
      }

      // Validate PKCE state parameter (optional but recommended)
      if (state != null) {
        print(
            '[main] ℹ PKCE state parameter present: ${state.substring(0, 8)}...');
      }

      // Validate auth code
      if (code == null || code.trim().isEmpty) {
        print('[main] ✗ No authorization code found in callback URL');
        return MaterialPageRoute(
          builder: (context) => const SpotifyLoginScreen(redirectCode: null),
        );
      }

      print('[main] ✓ OAuth authorization code extracted successfully');
      print('[main] Code length: ${code.length} chars');

      // Navigate to login screen with the authorization code
      // The login screen will exchange the code for an access token
      return MaterialPageRoute(
        builder: (context) => SpotifyLoginScreen(redirectCode: code),
      );
    } catch (e) {
      print('[main] ✗ Error parsing deep link: $e');
      print('[main] Redirect URI: ${settings.name}');
      // On error, show login screen without code (user can retry)
      return MaterialPageRoute(
        builder: (context) => const SpotifyLoginScreen(redirectCode: null),
      );
    }
  }

  Widget _buildInitialScreen() {
    final authService = locator<SpotifyAuthService>();

    // Check if user is authenticated
    if (authService.isAuthenticated) {
      return MiniPlayerOverlay(
        child: const HomeScreen(),
      );
    }

    // Show splash first, then decide between login or home
    return const SplashScreen();
  }
}
