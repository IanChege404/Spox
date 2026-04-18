import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_bloc.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_event.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_state.dart';
import 'package:spotify_clone/bloc/download/download_bloc.dart';
import 'package:spotify_clone/bloc/download/download_event.dart';
import 'package:spotify_clone/bloc/download/download_state.dart';
import 'package:spotify_clone/bloc/equalizer/equalizer_bloc.dart';
import 'package:spotify_clone/bloc/equalizer/equalizer_event.dart';
import 'package:spotify_clone/bloc/equalizer/equalizer_state.dart';
import 'package:spotify_clone/bloc/history/history_bloc.dart';
import 'package:spotify_clone/bloc/home/home_bloc.dart';
import 'package:spotify_clone/bloc/liked_songs/liked_songs_bloc.dart';
import 'package:spotify_clone/bloc/lyrics/lyrics_bloc.dart';
import 'package:spotify_clone/bloc/queue/queue_bloc.dart';
import 'package:spotify_clone/bloc/search/search_bloc.dart';
import 'package:spotify_clone/bloc/stats/stats_bloc.dart';
import 'package:spotify_clone/bloc/stats/stats_event.dart';
import 'package:spotify_clone/bloc/stats/stats_state.dart';
import 'package:spotify_clone/bloc/theme/theme_bloc.dart';
import 'package:spotify_clone/ui/dashboard_screen.dart';

// Mock BLoCs
class MockAudioPlayerBloc extends MockBloc<AudioPlayerEvent, AudioPlayerState>
    implements AudioPlayerBloc {}

class MockQueueBloc extends Mock implements QueueBloc {}

class MockLikedSongsBloc extends Mock implements LikedSongsBloc {}

class MockSearchBloc extends Mock implements SearchBloc {}

class MockHistoryBloc extends Mock implements HistoryBloc {}

class MockThemeBloc extends Mock implements ThemeBloc {}

class MockLyricsBloc extends Mock implements LyricsBloc {}

class MockStatsBloc extends MockBloc<StatsEvent, StatsState>
    implements StatsBloc {}

class MockEqualizerBloc extends MockBloc<EqualizerEvent, EqualizerState>
    implements EqualizerBloc {}

class MockDownloadBloc extends MockBloc<DownloadEvent, DownloadState>
    implements DownloadBloc {}

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

Widget _buildTestApp({
  required MockAudioPlayerBloc audioPlayerBloc,
  required MockStatsBloc statsBloc,
  required MockEqualizerBloc equalizerBloc,
  required MockDownloadBloc downloadBloc,
  required MockQueueBloc queueBloc,
  required MockLikedSongsBloc likedSongsBloc,
  required MockSearchBloc searchBloc,
  required MockHistoryBloc historyBloc,
  required MockThemeBloc themeBloc,
  required MockLyricsBloc lyricsBloc,
  required MockHomeBloc homeBloc,
}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<AudioPlayerBloc>.value(value: audioPlayerBloc),
      BlocProvider<QueueBloc>.value(value: queueBloc),
      BlocProvider<LikedSongsBloc>.value(value: likedSongsBloc),
      BlocProvider<SearchBloc>.value(value: searchBloc),
      BlocProvider<HistoryBloc>.value(value: historyBloc),
      BlocProvider<ThemeBloc>.value(value: themeBloc),
      BlocProvider<LyricsBloc>.value(value: lyricsBloc),
      BlocProvider<StatsBloc>.value(value: statsBloc),
      BlocProvider<EqualizerBloc>.value(value: equalizerBloc),
      BlocProvider<DownloadBloc>.value(value: downloadBloc),
      BlocProvider<HomeBloc>.value(value: homeBloc),
    ],
    child: MaterialApp(
      home: const DashBoardScreen(),
    ),
  );
}

void main() {
  late MockAudioPlayerBloc audioPlayerBloc;
  late MockStatsBloc statsBloc;
  late MockEqualizerBloc equalizerBloc;
  late MockDownloadBloc downloadBloc;
  late MockQueueBloc queueBloc;
  late MockLikedSongsBloc likedSongsBloc;
  late MockSearchBloc searchBloc;
  late MockHistoryBloc historyBloc;
  late MockThemeBloc themeBloc;
  late MockLyricsBloc lyricsBloc;
  late MockHomeBloc homeBloc;

  setUp(() {
    audioPlayerBloc = MockAudioPlayerBloc();
    statsBloc = MockStatsBloc();
    equalizerBloc = MockEqualizerBloc();
    downloadBloc = MockDownloadBloc();
    queueBloc = MockQueueBloc();
    likedSongsBloc = MockLikedSongsBloc();
    searchBloc = MockSearchBloc();
    historyBloc = MockHistoryBloc();
    themeBloc = MockThemeBloc();
    lyricsBloc = MockLyricsBloc();
    homeBloc = MockHomeBloc();

    // Configure stream/state defaults
    when(() => audioPlayerBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => audioPlayerBloc.state).thenReturn(AudioPlayerInitial());

    when(() => statsBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => statsBloc.state).thenReturn(StatsInitial());

    when(() => equalizerBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => equalizerBloc.state).thenReturn(const EqualizerInitial());

    when(() => downloadBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => downloadBloc.state).thenReturn(const DownloadInitial());

    when(() => queueBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => likedSongsBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => searchBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => historyBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => themeBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => lyricsBloc.stream).thenAnswer((_) => const Stream.empty());

    when(() => homeBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => homeBloc.state).thenReturn(HomeInitial());
  });

  group('DashboardScreen tab navigation', () {
    testWidgets('renders without exceptions', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        audioPlayerBloc: audioPlayerBloc,
        statsBloc: statsBloc,
        equalizerBloc: equalizerBloc,
        downloadBloc: downloadBloc,
        queueBloc: queueBloc,
        likedSongsBloc: likedSongsBloc,
        searchBloc: searchBloc,
        historyBloc: historyBloc,
        themeBloc: themeBloc,
        lyricsBloc: lyricsBloc,
        homeBloc: homeBloc,
      ));

      expect(find.byType(DashBoardScreen), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('shows 6 navigation items', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        audioPlayerBloc: audioPlayerBloc,
        statsBloc: statsBloc,
        equalizerBloc: equalizerBloc,
        downloadBloc: downloadBloc,
        queueBloc: queueBloc,
        likedSongsBloc: likedSongsBloc,
        searchBloc: searchBloc,
        historyBloc: historyBloc,
        themeBloc: themeBloc,
        lyricsBloc: lyricsBloc,
        homeBloc: homeBloc,
      ));

      // Home, Search, Library, Stats, EQ, Offline
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('Stats'), findsOneWidget);
      expect(find.text('EQ'), findsOneWidget);
      expect(find.text('Offline'), findsOneWidget);
    });

    testWidgets('tapping EQ tab does not throw', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        audioPlayerBloc: audioPlayerBloc,
        statsBloc: statsBloc,
        equalizerBloc: equalizerBloc,
        downloadBloc: downloadBloc,
        queueBloc: queueBloc,
        likedSongsBloc: likedSongsBloc,
        searchBloc: searchBloc,
        historyBloc: historyBloc,
        themeBloc: themeBloc,
        lyricsBloc: lyricsBloc,
        homeBloc: homeBloc,
      ));

      await tester.tap(find.text('EQ'));
      await tester.pump();
      // No exceptions thrown
      expect(find.byType(DashBoardScreen), findsOneWidget);
    });

    testWidgets('tapping Offline tab does not throw', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        audioPlayerBloc: audioPlayerBloc,
        statsBloc: statsBloc,
        equalizerBloc: equalizerBloc,
        downloadBloc: downloadBloc,
        queueBloc: queueBloc,
        likedSongsBloc: likedSongsBloc,
        searchBloc: searchBloc,
        historyBloc: historyBloc,
        themeBloc: themeBloc,
        lyricsBloc: lyricsBloc,
        homeBloc: homeBloc,
      ));

      await tester.tap(find.text('Offline'));
      await tester.pump();
      // No exceptions thrown
      expect(find.byType(DashBoardScreen), findsOneWidget);
    });
  });
}
