import 'package:get_it/get_it.dart';
import 'package:spotify_clone/bloc/audio_player/audio_player_bloc.dart';
import 'package:spotify_clone/bloc/download/download_bloc.dart';
import 'package:spotify_clone/bloc/equalizer/equalizer_bloc.dart';
import 'package:spotify_clone/bloc/history/history_bloc.dart';
import 'package:spotify_clone/bloc/home/home_bloc.dart';
import 'package:spotify_clone/bloc/liked_songs/liked_songs_bloc.dart';
import 'package:spotify_clone/bloc/lyrics/lyrics_bloc.dart';
import 'package:spotify_clone/bloc/queue/queue_bloc.dart';
import 'package:spotify_clone/bloc/search/search_bloc.dart';
import 'package:spotify_clone/bloc/stats/stats_bloc.dart';
import 'package:spotify_clone/bloc/theme/theme_bloc.dart';
import 'package:spotify_clone/core/network/http_client.dart';
import 'package:spotify_clone/data/datasource/album_datasource.dart';
import 'package:spotify_clone/data/datasource/artist_datasource.dart';
import 'package:spotify_clone/data/datasource/playlist_datasource.dart';
import 'package:spotify_clone/data/datasource/podcast_datasource.dart';
import 'package:spotify_clone/data/datasource/spotify_album_datasource.dart';
import 'package:spotify_clone/data/datasource/spotify_artist_datasource.dart';
import 'package:spotify_clone/data/datasource/spotify_playlist_datasource.dart';
import 'package:spotify_clone/data/repository/album_repository.dart';
import 'package:spotify_clone/data/repository/artist_repository.dart';
import 'package:spotify_clone/data/repository/playlist_repository.dart';
import 'package:spotify_clone/data/repository/podcast_repository.dart';
import 'package:spotify_clone/data/repository/spotify_album_repository.dart';
import 'package:spotify_clone/data/repository/spotify_artist_repository.dart';
import 'package:spotify_clone/data/repository/spotify_playlist_repository.dart';
import 'package:spotify_clone/data/repository/spotify_repository.dart';
import 'package:spotify_clone/services/audio_handler.dart';
import 'package:spotify_clone/services/audio_player_service.dart';
import 'package:spotify_clone/services/hive_service.dart';
import 'package:spotify_clone/services/lyrics_service.dart';
import 'package:spotify_clone/services/spotify_api_service.dart';
import 'package:spotify_clone/services/spotify_auth_service.dart';
import 'package:spotify_clone/services/stats_service.dart';

var locator = GetIt.instance;

void initServiceLocator(HiveService hiveService) {
  // Network
  locator.registerSingleton<HttpClient>(HttpClient());

  // Spotify Services
  locator.registerSingleton<SpotifyAuthService>(
    SpotifyAuthService(httpClient: locator<HttpClient>()),
  );
  locator.registerSingleton<SpotifyApiService>(
    SpotifyApiService(
      httpClient: locator<HttpClient>(),
      authService: locator<SpotifyAuthService>(),
    ),
  );

  // Spotify API & Repository
  locator.registerSingleton<SpotifyRepository>(
    SpotifyRepository(apiService: locator<SpotifyApiService>()),
  );

  // Persistence
  locator.registerSingleton<HiveService>(hiveService);

  // Audio Player
  locator.registerSingleton<AudioPlayerService>(AudioPlayerService());
  locator.registerSingleton<AppAudioHandler>(
    AppAudioHandler(locator<AudioPlayerService>()),
  );

  // History Management (must be before AudioPlayerBloc for dependency injection)
  locator.registerSingleton<HistoryBloc>(
    HistoryBloc(hiveService: locator<HiveService>()),
  );

  // Audio Player BLoC with History integration
  locator.registerSingleton<AudioPlayerBloc>(
    AudioPlayerBloc(
      audioPlayerService: locator<AudioPlayerService>(),
      historyBloc: locator<HistoryBloc>(),
    ),
  );

  // Queue Management
  locator.registerSingleton<QueueBloc>(QueueBloc());

  // Liked Songs Management
  locator.registerSingleton<LikedSongsBloc>(
    LikedSongsBloc(hiveService: locator<HiveService>()),
  );

  // Search Management
  locator.registerSingleton<SearchBloc>(
    SearchBloc(spotifyApiService: locator<SpotifyApiService>()),
  );

  // Home Management
  locator.registerSingleton<HomeBloc>(
    HomeBloc(spotifyRepository: locator<SpotifyRepository>()),
  );

  // Theme Management
  locator.registerSingleton<ThemeBloc>(
    ThemeBloc(hiveService: locator<HiveService>()),
  );

  // Lyrics Service & BLoC (Phase 6.2)
  locator.registerSingleton<LyricsService>(
    LyricsService(httpClient: locator<HttpClient>()),
  );
  locator.registerSingleton<LyricsBloc>(
    LyricsBloc(lyricsService: locator<LyricsService>()),
  );

  // Stats Service & BLoC (Phase 6.3)
  locator.registerSingleton<StatsService>(
    StatsService(hiveService: locator<HiveService>()),
  );
  locator.registerSingleton<StatsBloc>(
    StatsBloc(statsService: locator<StatsService>()),
  );

  // Equalizer BLoC (Phase 6+ - Equalizer UI)
  locator.registerSingleton<EqualizerBloc>(
    EqualizerBloc(hiveService: locator<HiveService>()),
  );

  // Download BLoC (Phase 6+ - Offline/Download Mode)
  locator.registerSingleton<DownloadBloc>(DownloadBloc());

  // Datasources — Using Spotify API instead of local hardcoded data (Phase 2.1)
  // This switches from hardcoded Drake album to live Spotify API data
  locator.registerSingleton<AlbumDatasource>(
    SpotifyAlbumDatasource(apiService: locator<SpotifyApiService>()),
  );
  locator.registerSingleton<ArtistDatasource>(
    SpotifyArtistDatasource(spotifyApiService: locator<SpotifyApiService>()),
  );
  locator.registerSingleton<PlaylistDatasource>(
    SpotifyPlaylistDatasource(apiService: locator<SpotifyApiService>()),
  );
  locator.registerSingleton<PodcastDatasource>(PodcastLocalDatasource());

  // Repositories — Using Spotify API versions (Phase 2.1)
  locator.registerSingleton<AlbumRepository>(
    SpotifyAlbumRepository(
      datasource:
          SpotifyAlbumDatasource(apiService: locator<SpotifyApiService>()),
    ),
  );
  locator.registerSingleton<ArtistRepository>(
    SpotifyArtistRepository(
      datasource: SpotifyArtistDatasource(
          spotifyApiService: locator<SpotifyApiService>()),
    ),
  );
  locator.registerSingleton<PLaylistRepository>(
    SpotifyPlaylistRepository(
      datasource:
          SpotifyPlaylistDatasource(apiService: locator<SpotifyApiService>()),
    ),
  );
  locator.registerSingleton<PodcastRepository>(PodcastLocalRepository());
}
