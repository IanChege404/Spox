# Spox — Flutter Spotify Clone

[![Flutter CI/CD](https://github.com/IanChege404/Spox/actions/workflows/flutter.yml/badge.svg)](https://github.com/IanChege404/Spox/actions/workflows/flutter.yml)
[![codecov](https://codecov.io/gh/IanChege404/Spox/graph/badge.svg)](https://codecov.io/gh/IanChege404/Spox)
[![Test Coverage](https://img.shields.io/badge/coverage-22.8%25-orange)](coverage/lcov.info)
[![Tests](https://img.shields.io/badge/tests-passing-brightgreen)](test/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A production-grade Flutter Spotify clone built as a portfolio project demonstrating clean architecture, BLoC state management, Spotify Web API integration, and professional testing practices.

---

## ✨ Features

| Feature | Details |
|---|---|
| **Home Screen** | Browse featured playlists & new releases via Spotify Web API |
| **Search** | Real-time Spotify search across tracks, artists, albums & playlists |
| **Track View** | Now-playing screen with album art, lyrics sync, sleep timer, share |
| **Equalizer** | 5-band EQ with presets (Flat, Bass Boost, Treble Boost, Vocal, Electronic) persisted in Hive |
| **Offline/Downloads** | Simulated download manager with progress tracking |
| **Barcode Scanner** | Upgraded mobile scanner — parses Spotify URIs, torch button |
| **Stats** | Listening statistics — top tracks, artists, total minutes |
| **Auth** | Spotify OAuth 2.0 PKCE flow with token refresh |
| **Audio** | just_audio + audio_service (background playback, OS media controls) |
| **Lyrics** | Synced lyrics via LRCLIB API |
| **Theme** | Dark/Light theme toggle, persisted via Hive |
| **Firebase** | Authentication + Cloud Firestore sync (optional) |

---

## 🏗️ Architecture

```
lib/
├── DI/                   # Dependency injection (get_it service locator)
├── bloc/                 # BLoC state management (13 BLoCs)
│   ├── audio_player/
│   ├── equalizer/        # NEW — 5-band EQ + presets
│   ├── download/         # NEW — offline download simulation
│   └── ...
├── core/
│   ├── errors/           # AppException hierarchy
│   ├── config/           # EnvConfig (.env loading)
│   └── network/          # HttpClient (Dio)
├── data/
│   ├── datasource/       # Local & Spotify API datasources
│   ├── model/            # Data models
│   └── repository/       # Repository pattern
├── services/             # Audio, Hive, Spotify API, Firebase
├── ui/                   # 35+ screens
└── widgets/              # Reusable UI components
```

See [ARCHITECTURE.md](ARCHITECTURE.md) for a full architecture description.

---

## 🎯 Free Tier Status (Portfolio Mode)

This project is optimized to work with **free tier services** for portfolio/demo purposes:

### ✅ What Works on Free Tier

- **Spotify Development Mode** (free, 25 users max):
  - Search API (unlimited calls)
  - Browse playlists & categories
  - 30-second audio previews (via Spotify Web API)
  - User authentication (OAuth 2.0 PKCE)
  - Playlist/album/artist metadata

- **Firebase Spark Plan** (free, unlimited users):
  - Firestore database (50k reads/day, 20k writes/day)
  - Authentication (Google Sign-In, email)
  - 1GB storage for user data

### ⚠️ Limitations (Premium/Extended Quota Required)

| Feature | Free Tier | What You Get |
|---|---|---|
| Full track streaming | ❌ Premium SDK required | 30-sec previews ✓ |
| User profiles API | ❌ Premium subscription required | Fallback mock data ✓ |
| Some album/artist details | ❌ Premium subscription required | Fallback mock data ✓ |
| Beyond 25 users | ❌ Requires Extended Quota | Use mock data for demo ✓ |
| Server-side functions | ❌ No Cloud Functions on Spark | Not needed for PKCE auth ✓ |

**Current Implementation:**
- All 403 (Forbidden) errors gracefully fall back to mock data
- App functions 100% on free tier—just with placeholder content instead of live Spotify data
- Perfect for showcasing UI, state management, and architecture

See [SPOTIFY_SETUP.md](SPOTIFY_SETUP.md) for setup details and quota information.

---

## 🚀 Getting Started

### Prerequisites

- Flutter 3.13.0+
- Android Studio / VS Code
- A [Spotify Developer](https://developer.spotify.com/dashboard) account

### Setup

```bash
# 1. Clone the repo
git clone https://github.com/IanChege404/Spox.git
cd Spox

# 2. Install dependencies
flutter pub get

# 3. Configure environment
cp .env.example .env
# Edit .env and fill in your Spotify API credentials

# 4. Run the app
flutter run
```

See [SPOTIFY_SETUP.md](SPOTIFY_SETUP.md) for detailed Spotify API configuration.

---

## 🧪 Testing

### Run Unit Tests

```bash
flutter test
```

### Run with Coverage

```bash
flutter test --coverage
```

### Run Integration Tests

```bash
flutter test integration_test/app_test.dart
```

### Test Structure

| Layer | Files | Description |
|---|---|---|
| `test/bloc/` | 11 test files | BLoC unit tests (AudioPlayer, Home, Equalizer, Download, …) |
| `test/services/` | 3 test files | Service unit tests |
| `test/data/` | 1 test file | Repository tests |
| `test/widget/` | 2 test files | Widget smoke tests (dashboard tabs, scanner URI parsing) |
| `integration_test/` | 1 test file | End-to-end integration test |

---

## 📦 Key Dependencies

| Category | Packages |
|---|---|
| State Management | `bloc`, `flutter_bloc`, `equatable` |
| DI | `get_it` |
| Audio | `just_audio`, `audio_service` |
| Network | `dio` |
| Persistence | `hive`, `hive_flutter` |
| Scanner | `mobile_scanner` |
| Share | `screenshot`, `share_plus` |
| Charts | `fl_chart` |
| Firebase | `firebase_core`, `firebase_auth`, `cloud_firestore` |

---

## 📄 Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) — Architecture overview
- [CHANGELOG.md](CHANGELOG.md) — Version history
- [CONTRIBUTING.md](CONTRIBUTING.md) — Contribution guide
- [SPOTIFY_SETUP.md](SPOTIFY_SETUP.md) — Spotify API setup
- [TESTING.md](TESTING.md) — Testing guide
- [docs/DEMO.md](docs/DEMO.md) — Demo & screenshots

---

## 📜 License

MIT License — see [LICENSE](LICENSE) for details.


## Overview 
This is an enormous spotify application ui that has been written with dart. Supports `4 albums`, `4 playlists`, `An snippet of track screen with a dynamic video and animation to the lyrics section`,` with all the sign up section pages and choosing artists and podcasts` and Even an `scanner to scan spotify barcodes`. The local data has been implemented in a way that works with bloc state management to keep the project clean and maintainable.  

## Features 
 - **Main Activity** : The ui is just like Spotify application. Lists playlists, musics, albums and more.
 - **Song Detail** : One song has a detail with a video, singer, album name and lyrics.
 - **Album Detail** : 4 albums has been implemented in the application with bloc state management wich each of the songs and even the album could be routed to share screen with their own unique album name and singer.
 - **Playlist Detail** : 4 playlists has been implemented with a massive datasource working in the background with bloc and each contains 15 songs with singer and song name.
 - **Scanner** : As an additional feature an scanner has been handled and added to the ui to make the project even more near to reality.
 - **Other Features** : user can route to setting, library and profile screen.


## Project Structure 
The project follows bloc architecture for the separation of layers to keep everything clean:

 - BLoC : To handle the logic and send different states for the unique event being received.
 - Data : To handle 3 important layers when working with local data :
    - Model : which is the entity of the app.
    - DataSource : To keep a list of local data (works just like usecases).
    - Repositoy : To get data from datasource and handle whether an error occurred or the list has been taken (similar to adapter layer).
 - UI : Infrastructure layer that is aware of the bloc and can send certain events to it.


## Dependancies 
  - auto_size_text (for the dynamic text size)
  - animations (for switching smothly beetween pages)
  - flutter_barcode_scanner (for scanner)
  - video_player (to handle background video of track screen)


## Project Setup 
To run the application do the following :

 1. Clone the repository or download it.
 2. Open the project in Android Studio / VScode.
 3. Create your environment file by copying `.env.example` to `.env` and filling the required values.
 4. Build and run the app on an Android emulator or physical device by your choice.
## Testing

This project includes comprehensive unit tests for core business logic (BLoCs, services, repositories).

**Run all tests:**
```bash
flutter test
```

**Run tests with coverage:**
```bash
flutter test --coverage
```

**Coverage Goals:**
- **Overall:** ≥40% (baseline for production)
- **BLoCs:** ≥80% (business logic)
- **Services:** ≥70% (data layers)

For detailed testing guidelines, see [TESTING.md](TESTING.md).

**Test Statistics:**
- 179 test cases across 13 test files
- BLoC tests: 100+ (AudioPlayer, Search, Home, Queue, Auth, LikedSongs, Lyrics, Stats, Theme)
- Service tests: 50+ (HiveService, AudioPlayerService, SpotifyAuthService)
- Repository tests: 25+ (SpotifyRepository)

CI/CD automatically runs tests on every push and PR.