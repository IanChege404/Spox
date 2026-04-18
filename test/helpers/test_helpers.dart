import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_bloc.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_state.dart';
import 'package:spotify_clone/bloc/download/download_bloc.dart';
import 'package:spotify_clone/bloc/download/download_state.dart';
import 'package:spotify_clone/bloc/equalizer/equalizer_bloc.dart';
import 'package:spotify_clone/bloc/equalizer/equalizer_state.dart';
import 'package:spotify_clone/bloc/history/history_bloc.dart';
import 'package:spotify_clone/bloc/home/home_bloc.dart';
import 'package:spotify_clone/bloc/liked_songs/liked_songs_bloc.dart';
import 'package:spotify_clone/bloc/lyrics/lyrics_bloc.dart';
import 'package:spotify_clone/bloc/queue/queue_bloc.dart';
import 'package:spotify_clone/bloc/search/search_bloc.dart';
import 'package:spotify_clone/bloc/stats/stats_bloc.dart';
import 'package:spotify_clone/bloc/theme/theme_bloc.dart';
import 'package:spotify_clone/services/spotify_auth_service.dart';
import '../fixtures/mock_blocs.dart';
import '../fixtures/mock_services.dart';

/// Set up GetIt with all required mock BLoCs and services for testing
void setupMockGetIt() {
  final getIt = GetIt.instance;

  // Clear any existing registrations
  getIt.reset();
  getIt.allowReassignment = true;

  // Register mock services
  final mockSpotifyAuthService = MockSpotifyAuthService();
  when(() => mockSpotifyAuthService.isAuthenticated).thenReturn(false);
  getIt.registerSingleton<SpotifyAuthService>(mockSpotifyAuthService);

  // Create all mock BLoCs
  final mockAudioPlayerBloc = MockAudioPlayerBloc();
  final mockQueueBloc = MockQueueBloc();
  final mockLikedSongsBloc = MockLikedSongsBloc();
  final mockSearchBloc = MockSearchBloc();
  final mockHistoryBloc = MockHistoryBloc();
  final mockThemeBloc = MockThemeBloc();
  final mockLyricsBloc = MockLyricsBloc();
  final mockStatsBloc = MockStatsBloc();
  final mockEqualizerBloc = MockEqualizerBloc();
  final mockDownloadBloc = MockDownloadBloc();
  final mockHomeBloc = MockHomeBloc();

  // Setup stream and state behaviors for all BLoCs
  _setupAudioPlayerBlocMocks(mockAudioPlayerBloc);
  _setupQueueBlocMocks(mockQueueBloc);
  _setupLikedSongsBlocMocks(mockLikedSongsBloc);
  _setupSearchBlocMocks(mockSearchBloc);
  _setupHistoryBlocMocks(mockHistoryBloc);
  _setupThemeBlocMocks(mockThemeBloc);
  _setupLyricsBlocMocks(mockLyricsBloc);
  _setupStatsBlocMocks(mockStatsBloc);
  _setupEqualizerBlocMocks(mockEqualizerBloc);
  _setupDownloadBlocMocks(mockDownloadBloc);
  _setupHomeBlocMocks(mockHomeBloc);

  // Register all BLoCs in GetIt
  getIt.registerSingleton<AudioPlayerBloc>(mockAudioPlayerBloc);
  getIt.registerSingleton<QueueBloc>(mockQueueBloc);
  getIt.registerSingleton<LikedSongsBloc>(mockLikedSongsBloc);
  getIt.registerSingleton<SearchBloc>(mockSearchBloc);
  getIt.registerSingleton<HistoryBloc>(mockHistoryBloc);
  getIt.registerSingleton<ThemeBloc>(mockThemeBloc);
  getIt.registerSingleton<LyricsBloc>(mockLyricsBloc);
  getIt.registerSingleton<StatsBloc>(mockStatsBloc);
  getIt.registerSingleton<EqualizerBloc>(mockEqualizerBloc);
  getIt.registerSingleton<DownloadBloc>(mockDownloadBloc);
  getIt.registerSingleton<HomeBloc>(mockHomeBloc);
}

void _setupAudioPlayerBlocMocks(MockAudioPlayerBloc mock) {
  when(() => mock.stream).thenAnswer((_) => const Stream.empty());
  when(() => mock.state).thenReturn(AudioPlayerInitial());
  when(() => mock.close()).thenAnswer((_) async => Future.value());
}

void _setupQueueBlocMocks(MockQueueBloc mock) {
  when(() => mock.stream).thenAnswer((_) => const Stream.empty());
  when(() => mock.close()).thenAnswer((_) async => Future.value());
}

void _setupLikedSongsBlocMocks(MockLikedSongsBloc mock) {
  when(() => mock.stream).thenAnswer((_) => const Stream.empty());
  when(() => mock.close()).thenAnswer((_) async => Future.value());
}

void _setupSearchBlocMocks(MockSearchBloc mock) {
  when(() => mock.stream).thenAnswer((_) => const Stream.empty());
  when(() => mock.close()).thenAnswer((_) async => Future.value());
}

void _setupHistoryBlocMocks(MockHistoryBloc mock) {
  when(() => mock.stream).thenAnswer((_) => const Stream.empty());
  when(() => mock.close()).thenAnswer((_) async => Future.value());
}

void _setupThemeBlocMocks(MockThemeBloc mock) {
  when(() => mock.stream).thenAnswer((_) => const Stream.empty());
  when(() => mock.close()).thenAnswer((_) async => Future.value());
}

void _setupLyricsBlocMocks(MockLyricsBloc mock) {
  when(() => mock.stream).thenAnswer((_) => const Stream.empty());
  when(() => mock.close()).thenAnswer((_) async => Future.value());
}

void _setupStatsBlocMocks(MockStatsBloc mock) {
  when(() => mock.stream).thenAnswer((_) => const Stream.empty());
  when(() => mock.close()).thenAnswer((_) async => Future.value());
}

void _setupEqualizerBlocMocks(MockEqualizerBloc mock) {
  when(() => mock.stream).thenAnswer((_) => const Stream.empty());
  when(() => mock.state).thenReturn(const EqualizerInitial());
  when(() => mock.close()).thenAnswer((_) async => Future.value());
}

void _setupDownloadBlocMocks(MockDownloadBloc mock) {
  when(() => mock.stream).thenAnswer((_) => const Stream.empty());
  when(() => mock.state).thenReturn(const DownloadInitial());
  when(() => mock.close()).thenAnswer((_) async => Future.value());
}

void _setupHomeBlocMocks(MockHomeBloc mock) {
  when(() => mock.stream).thenAnswer((_) => const Stream.empty());
  when(() => mock.state).thenReturn(HomeInitial());
  when(() => mock.close()).thenAnswer((_) async => Future.value());
}

/// Cleanup GetIt after tests
void tearDownMockGetIt() {
  GetIt.instance.reset();
}
