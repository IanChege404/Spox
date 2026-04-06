# Architecture

## Overview

Spox is a Flutter Spotify clone built with the **BLoC (Business Logic Component)** pattern and **clean architecture** principles. The codebase is separated into distinct layers — Presentation, Data, Services, and Core — to maximise testability and maintainability.

## Folder Structure

```
lib/
├── bloc/           # BLoC event/state/bloc classes (one subfolder per feature)
├── constants/      # App-wide constants (colours, strings, dimensions)
├── core/           # Cross-cutting concerns: errors, config, network, utils
├── data/           # Repositories, data-sources, and data models
├── DI/             # Dependency injection (service_locator.dart)
├── services/       # External service wrappers (audio, Hive, Spotify API, Firebase)
├── ui/             # Full-screen widgets (one file per screen)
└── widgets/        # Reusable, stateless/stateful UI components
```

## Layer Descriptions

### Presentation (UI + BLoC)

- **`lib/ui/`** — Screen-level widgets. Each screen reads state from a BLoC via `BlocBuilder` / `BlocListener` and dispatches events via `context.read<Bloc>().add(...)`.
- **`lib/bloc/`** — Feature BLoCs that receive events, execute business logic (delegating to services/repositories), and emit new states. No direct dependency on Flutter widgets.
- **`lib/widgets/`** — Shared, reusable UI components with no business logic.

### Data (Repositories, Datasources, Models)

- **`lib/data/`** — Contains repository interfaces and implementations, remote/local data-source classes, and plain Dart model classes (e.g., `AlbumTrack`, `SpotifyTrack`). Repositories abstract the origin of data (network vs. local cache) from the rest of the app.

### Services (Audio, Hive, Spotify API, Firebase)

- **`lib/services/`** — Wrappers around external packages and APIs:
  - `AudioService` — just_audio playback, queue management
  - `HiveService` — Hive local persistence (liked songs, history, settings)
  - `SpotifyApiService` — Spotify Web API calls (search, playlists, new releases)
  - `FirebaseService` — Firebase Auth / Analytics integration

### Core (Errors, Config, Network, Utils)

- **`lib/core/`** — Shared infrastructure with no dependency on Flutter UI:
  - `errors/` — Typed exception hierarchy (`AppException` and subclasses)
  - `config/` — Environment configuration (API base URLs, keys loaded from `.env`)
  - `network/` — HTTP client setup, interceptors, connectivity checks
  - `utils/` — Pure helper functions (formatters, extensions)

### DI (Dependency Injection)

- **`lib/DI/service_locator.dart`** — Uses `get_it` to register and resolve all singletons and factories (services, repositories, BLoCs).

## Key BLoCs

| BLoC | Responsibility |
|---|---|
| `AudioPlayerBloc` | Playback control, progress tracking, sleep timer |
| `QueueBloc` | Track queue management (add, remove, reorder, shuffle) |
| `LikedSongsBloc` | Like/unlike tracks, persist to Hive |
| `SearchBloc` | Real-time Spotify search with debounce |
| `HistoryBloc` | Play history retrieval and display |
| `ThemeBloc` | Dark/light mode toggling, persisted preference |
| `LyricsBloc` | Fetch and sync lyrics for the current track |
| `StatsBloc` | Aggregate listening statistics from play history |
| `HomeBloc` | Fetch featured playlists and new releases |
| `EqualizerBloc` | 5-band EQ state, preset management, Hive persistence |
| `DownloadBloc` | Simulated download progress and offline track management |

## State Management Flow

```
User Action
    │
    ▼
UI Widget dispatches Event
    │
    ▼
BLoC receives Event → calls Service / Repository
    │
    ▼
Service / Repository returns data or throws AppException
    │
    ▼
BLoC emits new State
    │
    ▼
BlocBuilder rebuilds UI
```

## Data Flow

```
UI → BLoC Event → BLoC → State → UI rebuild
```

BLoCs never import widgets. Services never import BLoCs. Repositories never import services directly — they depend on data-source interfaces, keeping each layer independently testable.

## Dependencies

Key packages used:

| Package | Purpose |
|---|---|
| `flutter_bloc` | BLoC pattern implementation |
| `equatable` | Value equality for states/events |
| `just_audio` | Audio playback engine |
| `hive_flutter` | Lightweight local key-value persistence |
| `get_it` | Service locator / dependency injection |
| `http` / `dio` | HTTP client for Spotify API |
| `firebase_core` | Firebase integration |

## Testing Approach

- **Unit tests** — BLoC logic tested in isolation with mocked services using `mocktail` or `mockito`. Located in `test/bloc/`.
- **Widget tests** — Individual screens and widgets tested with `flutter_test`. Located in `test/ui/`.
- **Integration tests** — Full app flows tested end-to-end. Located in `integration_test/`.
- CI enforces `dart format`, `flutter analyze`, and `flutter test` on every pull request.
