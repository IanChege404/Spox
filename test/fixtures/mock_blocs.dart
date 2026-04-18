import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
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
import 'package:spotify_clone/bloc/liked_songs/liked_songs_bloc.dart';
import 'package:spotify_clone/bloc/lyrics/lyrics_bloc.dart';
import 'package:spotify_clone/bloc/queue/queue_bloc.dart';
import 'package:spotify_clone/bloc/search/search_bloc.dart';
import 'package:spotify_clone/bloc/stats/stats_bloc.dart';
import 'package:spotify_clone/bloc/stats/stats_event.dart';
import 'package:spotify_clone/bloc/stats/stats_state.dart';
import 'package:spotify_clone/bloc/theme/theme_bloc.dart';
import 'package:spotify_clone/bloc/home/home_bloc.dart';

// AudioPlayerBloc Mock
class MockAudioPlayerBloc extends MockBloc<AudioPlayerEvent, AudioPlayerState>
    implements AudioPlayerBloc {}

// QueueBloc Mock
class MockQueueBloc extends Mock implements QueueBloc {}

// LikedSongsBloc Mock
class MockLikedSongsBloc extends Mock implements LikedSongsBloc {}

// SearchBloc Mock
class MockSearchBloc extends Mock implements SearchBloc {}

// HistoryBloc Mock
class MockHistoryBloc extends Mock implements HistoryBloc {}

// ThemeBloc Mock
class MockThemeBloc extends Mock implements ThemeBloc {}

// LyricsBloc Mock
class MockLyricsBloc extends Mock implements LyricsBloc {}

// StatsBloc Mock
class MockStatsBloc extends MockBloc<StatsEvent, StatsState>
    implements StatsBloc {}

// EqualizerBloc Mock
class MockEqualizerBloc extends MockBloc<EqualizerEvent, EqualizerState>
    implements EqualizerBloc {}

// DownloadBloc Mock
class MockDownloadBloc extends MockBloc<DownloadEvent, DownloadState>
    implements DownloadBloc {}

// HomeBloc Mock
class MockHomeBloc extends Mock implements HomeBloc {}
