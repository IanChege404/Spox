# Changelog

All notable changes to Spox will be documented in this file.

## [1.5.0] - 2026-04-06

### Phase 6 - Equalizer, Offline mode, Scanner upgrade, Share, Integration tests

- 5-band audio equalizer with presets (Flat, Bass Boost, Treble Boost, Vocal, Electronic) persisted via Hive
- Offline/Download screen with simulated download progress management
- EqualizerBloc and DownloadBloc with full event/state coverage
- Share functionality for tracks
- Barcode/QR scanner upgrade
- Integration test suite

## [1.4.0] - 2025-06-01

### Phase 5 - Testing, CI/CD, error handling

- Comprehensive unit and widget tests
- CI/CD pipeline via GitHub Actions
- Structured error handling with typed AppException hierarchy
- `flutter analyze` and `dart format` enforced in CI

## [1.3.0] - 2024-12-01

### Phase 4 - Lyrics, Stats, History

- Synced lyrics display on the Track View screen
- Listening statistics: top tracks, top artists, total listening time
- Play history persistence via Hive
- LyricsBloc, StatsBloc, HistoryBloc added

## [1.2.0] - 2024-09-01

### Phase 3 - Audio playback, Hive persistence

- Audio playback using just_audio with queue management
- Hive local storage for liked songs and play history
- AudioPlayerBloc and QueueBloc
- Sleep timer support

## [1.1.0] - 2024-06-01

### Phase 2 - Spotify API integration

- Spotify Web API integration (OAuth2 PKCE)
- Real-time search for tracks, artists, albums, playlists
- Featured playlists and new releases on the Home screen
- SearchBloc, HomeBloc added

## [1.0.0] - 2024-01-01

### Initial release - core UI, local data

- Core application scaffold with BLoC pattern and clean architecture
- Home, Search, Track View screens with local/mock data
- Theme support (dark mode)
- Basic navigation
