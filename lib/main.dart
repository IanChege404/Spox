import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/DI/service_locator.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_bloc.dart';
import 'package:spotify_clone/bloc/history/history_bloc.dart';
import 'package:spotify_clone/bloc/liked_songs/liked_songs_bloc.dart';
import 'package:spotify_clone/bloc/lyrics/lyrics_bloc.dart';
import 'package:spotify_clone/bloc/queue/queue_bloc.dart';
import 'package:spotify_clone/bloc/search/search_bloc.dart';
import 'package:spotify_clone/bloc/stats/stats_bloc.dart';
import 'package:spotify_clone/bloc/theme/theme_bloc.dart';
import 'package:spotify_clone/core/config/env_config.dart';
import 'package:spotify_clone/services/audio_handler.dart';
import 'package:spotify_clone/services/hive_service.dart';
import 'package:spotify_clone/services/spotify_auth_service.dart';
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
  await hiveService.init();

  // Initialize service locator
  initServiceLocator(hiveService);

  // Initialize AudioService for background playback and OS media controls
  // Pre-initialize the handler so the builder can return it synchronously
  await AudioService.init(
    builder: () => locator<AppAudioHandler>(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.spotify_clone.channel.audio',
      androidNotificationChannelName: 'Spotify Clone Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

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
          create: (context) => locator<LikedSongsBloc>(),
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
      ],
      child: MaterialApp(
        title: 'Spotify Clone',
        theme: ThemeData(
          splashColor: Colors.transparent,
        ),
        debugShowCheckedModeBanner: false,
        home: _buildInitialScreen(),
        routes: {
          '/home': (context) => MiniPlayerOverlay(
                child: const HomeScreen(),
              ),
          '/login': (context) => const SpotifyLoginScreen(),
        },
        // Handle deep links from Spotify OAuth redirect
        onGenerateRoute: (settings) {
          if (settings.name?.startsWith('/callback') ?? false) {
            final uri = Uri.parse(settings.name!);
            final code = uri.queryParameters['code'];
            return MaterialPageRoute(
              builder: (context) => SpotifyLoginScreen(redirectCode: code),
            );
          }
          return null;
        },
      ),
    );
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
