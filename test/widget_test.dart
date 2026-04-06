// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_bloc.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_state.dart';
import 'package:spotify_clone/bloc/history/history_bloc.dart';
import 'package:spotify_clone/bloc/liked_songs/liked_songs_bloc.dart';
import 'package:spotify_clone/bloc/lyrics/lyrics_bloc.dart';
import 'package:spotify_clone/bloc/queue/queue_bloc.dart';
import 'package:spotify_clone/bloc/search/search_bloc.dart';
import 'package:spotify_clone/bloc/stats/stats_bloc.dart';
import 'package:spotify_clone/bloc/theme/theme_bloc.dart';
import 'package:spotify_clone/main.dart';
import 'package:spotify_clone/services/spotify_auth_service.dart';

// Mock BLoCs
class MockAudioPlayerBloc extends Mock implements AudioPlayerBloc {}

class MockQueueBloc extends Mock implements QueueBloc {}

class MockLikedSongsBloc extends Mock implements LikedSongsBloc {}

class MockSearchBloc extends Mock implements SearchBloc {}

class MockHistoryBloc extends Mock implements HistoryBloc {}

class MockThemeBloc extends Mock implements ThemeBloc {}

class MockLyricsBloc extends Mock implements LyricsBloc {}

class MockStatsBloc extends Mock implements StatsBloc {}

// Mock Services
class MockSpotifyAuthService extends Mock implements SpotifyAuthService {}

void main() {
  final getIt = GetIt.instance;

  setUp(() {
    // Clear any existing registrations to ensure a clean slate for every test
    getIt.reset();
    getIt.allowReassignment = true;

    // Create mock Services
    final mockSpotifyAuthService = MockSpotifyAuthService();

    // Mock SpotifyAuthService behaviors
    when(() => mockSpotifyAuthService.isAuthenticated).thenReturn(false);

    // Register mock Services
    getIt.registerSingleton<SpotifyAuthService>(mockSpotifyAuthService);

    // Create mock BLoCs
    final mockAudioPlayerBloc = MockAudioPlayerBloc();
    final mockQueueBloc = MockQueueBloc();
    final mockLikedSongsBloc = MockLikedSongsBloc();
    final mockSearchBloc = MockSearchBloc();
    final mockHistoryBloc = MockHistoryBloc();
    final mockThemeBloc = MockThemeBloc();
    final mockLyricsBloc = MockLyricsBloc();
    final mockStatsBloc = MockStatsBloc();

    // Mock stream behaviors for BLoCs that need them
    when(() => mockAudioPlayerBloc.stream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockAudioPlayerBloc.state).thenReturn(AudioPlayerInitial());
    when(() => mockAudioPlayerBloc.close())
        .thenAnswer((_) async => Future.value());

    when(() => mockQueueBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockQueueBloc.close()).thenAnswer((_) async => Future.value());

    when(() => mockLikedSongsBloc.stream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockLikedSongsBloc.close())
        .thenAnswer((_) async => Future.value());

    when(() => mockSearchBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSearchBloc.close()).thenAnswer((_) async => Future.value());

    when(() => mockHistoryBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockHistoryBloc.close()).thenAnswer((_) async => Future.value());

    when(() => mockThemeBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockThemeBloc.close()).thenAnswer((_) async => Future.value());

    when(() => mockLyricsBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockLyricsBloc.close()).thenAnswer((_) async => Future.value());

    when(() => mockStatsBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockStatsBloc.close()).thenAnswer((_) async => Future.value());

    // Register mock BLoCs
    getIt.registerSingleton<AudioPlayerBloc>(mockAudioPlayerBloc);
    getIt.registerSingleton<QueueBloc>(mockQueueBloc);
    getIt.registerSingleton<LikedSongsBloc>(mockLikedSongsBloc);
    getIt.registerSingleton<SearchBloc>(mockSearchBloc);
    getIt.registerSingleton<HistoryBloc>(mockHistoryBloc);
    getIt.registerSingleton<ThemeBloc>(mockThemeBloc);
    getIt.registerSingleton<LyricsBloc>(mockLyricsBloc);
    getIt.registerSingleton<StatsBloc>(mockStatsBloc);
  });

  tearDown(() {
    getIt.reset();
  });

  testWidgets('App builds without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds without throwing errors
    expect(find.byType(MyApp), findsOneWidget);
  });
}
