# 🎧 Spotify Clone — Improvement Roadmap
> A portfolio-grade upgrade plan for [Mohammad-Nikmard/Spotify-Clone](https://github.com/Mohammad-Nikmard/Spotify-Clone)
> Built with Flutter · Dart · BLoC State Management

---

## 📌 Overview

This document outlines a structured, phased roadmap of improvements for the Spotify Clone Flutter project. The goal is to transform it from a polished UI demo into a **production-quality, portfolio-worthy mobile application** that demonstrates real engineering depth — not just surface-level design.

Each improvement is categorized by phase, priority, and estimated complexity so you can plan your time effectively.

---

## 🗺️ Roadmap Phases

| Phase | Focus | Goal |
|-------|-------|------|
| **Phase 1** | Core Functionality | Make it a real music app |
| **Phase 2** | Data & Persistence | Real data, real storage |
| **Phase 3** | UI/UX Polish | Feels like the real Spotify |
| **Phase 4** | Missing Features | Parity with Spotify's core experience |
| **Phase 5** | Code Quality | Production-grade codebase |
| **Phase 6** | Wow Factor | Stand-out portfolio extras |

---

## Phase 1 — Core Functionality 🎵
> *Priority: HIGH · Do this first. Everything else depends on it.*

### 1.1 — Fully Functional Audio Player

**Current State:** The app is UI-only. There is no real audio playback.

**The Problem:** A music app that doesn't play music is a prototype, not a portfolio piece. Recruiters and reviewers will open the app expecting sound.

**Recommended Solution:** Integrate the [`just_audio`](https://pub.dev/packages/just_audio) package — it is the gold standard for audio in Flutter.

**Implementation Steps:**
1. Add `just_audio` and `audio_service` to `pubspec.yaml`
2. Create an `AudioPlayerService` class that wraps `just_audio`
3. Connect it to your existing BLoC — create an `AudioPlayerBloc` with states: `AudioLoading`, `AudioPlaying`, `AudioPaused`, `AudioCompleted`, `AudioError`
4. Wire up the play/pause, seek bar, skip forward/backward buttons in the UI to dispatch BLoC events
5. Preload the next track silently to eliminate buffering gaps

```dart
// Example BLoC event structure
abstract class AudioPlayerEvent {}
class PlaySong extends AudioPlayerEvent { final Song song; }
class PauseSong extends AudioPlayerEvent {}
class SeekTo extends AudioPlayerEvent { final Duration position; }
class SkipNext extends AudioPlayerEvent {}
class SkipPrevious extends AudioPlayerEvent {}
```

**Why it matters for your portfolio:** Shows you understand async operations, streams, and state management — all critical Flutter skills.

---

### 1.2 — Background Playback

**Current State:** Not implemented.

**The Problem:** Music stopping when you lock your phone or switch apps is a dealbreaker for any music app.

**Recommended Solution:** Use the [`audio_service`](https://pub.dev/packages/audio_service) package alongside `just_audio`. It hooks into the OS media controls on both Android and iOS.

**Implementation Steps:**
1. Wrap your audio logic in an `AudioHandler` that extends `BaseAudioHandler`
2. Implement `play()`, `pause()`, `stop()`, `seek()`, and `skipToNext()` methods
3. Register the handler in `main.dart` using `AudioService.init()`
4. Show a persistent media notification with album art, song name, and controls on Android
5. Hook into Control Center / Lock Screen on iOS automatically

**Expected Result:** Music keeps playing with OS-level media controls shown on the lock screen — just like real Spotify.

---

### 1.3 — Queue Management

**Current State:** No queue system exists.

**Recommended Improvements:**
- Display a "Up Next" queue that shows upcoming songs in order
- Allow users to drag-and-drop songs to reorder the queue using `ReorderableListView`
- Add "Add to Queue" button on each song card
- Implement shuffle mode that randomizes queue order without repeating songs
- Implement repeat modes: Repeat Off → Repeat All → Repeat One

**BLoC State to Add:**
```dart
class QueueState {
  final List<Song> queue;
  final int currentIndex;
  final ShuffleMode shuffleMode;
  final RepeatMode repeatMode;
}
```

---

## Phase 2 — Data & Persistence 🗄️
> *Priority: HIGH · Transforms the app from static to dynamic.*

### 2.1 — Spotify Web API Integration

**Current State:** All data is hardcoded locally — 4 albums, 4 playlists, fixed songs.

**The Problem:** Hardcoded data means the app never changes. Real apps consume real data.

**Recommended Solution:** Integrate the [Spotify Web API](https://developer.spotify.com/documentation/web-api) for live data.

**Implementation Steps:**
1. Register your app at [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Implement **OAuth 2.0 PKCE flow** for authentication (no client secret needed on mobile)
3. Use the [`spotify_sdk`](https://pub.dev/packages/spotify_sdk) Flutter package or make raw HTTP calls using `dio`
4. Create a `SpotifyRepository` that abstracts all API calls
5. Replace local BLoC data sources with API-powered repositories

**Key API Endpoints to use:**
- `GET /me` — logged-in user's profile
- `GET /me/playlists` — user's own playlists
- `GET /browse/featured-playlists` — featured playlists for Home screen
- `GET /search` — power the search feature
- `GET /tracks/{id}` — song details and 30-second preview URL

> ⚠️ **Note:** Full track streaming requires a Spotify Premium account and the Spotify SDK. For portfolio purposes, use the **30-second preview URLs** provided free in the API — they are perfect for demos.

---

### 2.2 — Local Database with Hive or Isar

**Current State:** No persistence. Liked songs, recent plays, and settings reset every session.

**Recommended Solution:** Use [`Isar`](https://pub.dev/packages/isar) — it is fast, Flutter-native, and works offline. Alternatively, use `hive_flutter` for simplicity.

**Data to Persist:**
- Liked/favourited songs
- Recently played songs and albums
- User's playlists (if not using Spotify API)
- App settings (theme preference, audio quality)
- Download history

**Implementation:**
```dart
@collection
class LikedSong {
  Id id = Isar.autoIncrement;
  late String spotifyId;
  late String title;
  late String artist;
  late String albumArt;
  late DateTime likedAt;
}
```

---

### 2.3 — Firebase Integration (Optional but impressive)

**Why add it:** Firebase auth + Firestore shows backend integration skills — extremely valuable for your portfolio.

**What to implement:**
- **Firebase Auth** — Google Sign-In and email/password
- **Firestore** — sync liked songs and playlists across devices
- **Firebase Storage** — if you allow users to upload their own tracks
- **Firebase Analytics** — track which songs are played most (shows product thinking)

---

## Phase 3 — UI/UX Polish ✨
> *Priority: MEDIUM · Makes it feel premium.*

### 3.1 — Persistent Mini Player

**Current State:** No mini player exists between screens.

**The Problem:** When you navigate away from the song detail screen, the playback UI disappears entirely.

**Recommended Solution:** Add a persistent mini player at the bottom of the screen (above the nav bar) that shows on all screens while a song is playing.

**Implementation:**
- Use a `Stack` widget at the root of your app to overlay the mini player
- Animate it sliding up when playback starts using `AnimatedSlide`
- Tapping it should expand to the full player screen
- Use a `GestureDetector` with a vertical drag to dismiss or expand

```dart
// Root scaffold structure
Scaffold(
  body: Stack(
    children: [
      MainNavigationContent(),
      Positioned(
        bottom: 60, // above nav bar
        child: MiniPlayerWidget(), // listens to AudioPlayerBloc
      ),
    ],
  ),
  bottomNavigationBar: BottomNavBar(),
)
```

---

### 3.2 — Dynamic Color Theming

**Current State:** Static dark theme throughout the app.

**Recommended Improvement:** Extract the dominant color from the currently playing song's album art and use it to tint the player screen background — exactly like real Spotify.

**How to implement:**
1. Use the [`palette_generator`](https://pub.dev/packages/palette_generator) package
2. When a song loads, extract the dominant and vibrant colors from the album art
3. Animate the background gradient of the player screen to transition to those colors using `AnimatedContainer`

```dart
Future<Color> getDominantColor(String imageUrl) async {
  final paletteGenerator = await PaletteGenerator.fromImageProvider(
    NetworkImage(imageUrl),
  );
  return paletteGenerator.dominantColor?.color ?? Colors.grey[900]!;
}
```

**Impact:** This single feature makes the app feel dramatically more premium and is always a showstopper in portfolio demos.

---

### 3.3 — Skeleton Loading Screens

**Current State:** Likely shows a plain spinner or blank screen while data loads.

**Recommended Solution:** Replace all loading states with skeleton shimmer screens using [`shimmer`](https://pub.dev/packages/shimmer) package.

Every screen (Home, Album Detail, Playlist Detail) should have a matching skeleton layout that shows the exact shape of the content before it loads. This is standard in production apps and signals professional UI thinking.

---

### 3.4 — Smoother Animations & Transitions

**Specific improvements:**
- **Hero animations** between the song card and the full player screen (album art should fly smoothly)
- **Page transitions** using custom `PageRouteBuilder` with slide + fade instead of default push
- **Staggered list animations** — songs in a playlist should animate in one by one on screen load using `flutter_animate`
- **Like button animation** — heart should burst with a particle effect when tapped, using a `Lottie` animation

**Packages to use:**
- [`flutter_animate`](https://pub.dev/packages/flutter_animate) — declarative animations
- [`lottie`](https://pub.dev/packages/lottie) — for the heart animation and other micro-interactions

---

### 3.5 — Dark / Light Theme Toggle

**Why:** Shows you understand Flutter theming deeply. Also practically useful.

**Implementation:**
- Define both `ThemeData` instances in a central `AppTheme` class
- Use a `ThemeBloc` or `ThemeNotifier` with `Provider`
- Persist the preference in `Hive` or `SharedPreferences`
- Animate the transition between themes using `AnimatedTheme`

---

## Phase 4 — Missing Features 🔍
> *Priority: MEDIUM · Adds real product completeness.*

### 4.1 — Search Functionality

**Current State:** No search feature.

**Implementation Plan:**
- Build a `SearchScreen` with a `TextField` at the top
- Implement debounce (300ms delay) so API calls don't fire on every keystroke
  ```dart
  _searchController.stream
    .debounceTime(Duration(milliseconds: 300))
    .listen((query) => context.read<SearchBloc>().add(SearchQuery(query)));
  ```
- Show results grouped by: Songs, Albums, Artists, Playlists
- Show recent searches when the search bar is focused but empty
- If using local data: implement fuzzy search using the `fuse_dart` package

---

### 4.2 — Liked Songs & Personal Library

**Current State:** No way to like/save songs.

**Implementation:**
- Add a heart icon to every song card and player screen
- Tapping creates/removes a record in local Hive DB (or Firestore)
- A dedicated "Liked Songs" playlist is auto-generated from all liked songs
- Sort/filter liked songs by date liked, artist, or album

---

### 4.3 — Podcast Section

**Current State:** Mentioned in the README but likely incomplete.

**Recommended Approach:**
- Use a free podcast API like [Listen Notes API](https://www.listennotes.com/api/) or [Podcast Index API](https://podcastindex.org/)
- Build a `PodcastScreen` with categories (True Crime, Tech, Comedy, etc.)
- Implement episode detail with playback — reuse your `AudioPlayerBloc` since podcasts and music are both just audio

---

### 4.4 — Sleep Timer

A simple but impressive feature:

```dart
// In AudioPlayerBloc
class SetSleepTimer extends AudioPlayerEvent {
  final Duration duration; // 15, 30, 45, 60 mins
}
// After duration elapses, dispatch PauseSong
```

Show a countdown in the player screen. Users can cancel it. Tiny feature, big UX impact.

---

### 4.5 — Crossfade Between Tracks

When a song ends, the next one fades in while the current one fades out over ~3 seconds. Implement using `just_audio`'s `AudioPipeline` with an `AndroidLoudnessEnhancer` and volume ramping.

---

## Phase 5 — Code Quality 🧹
> *Priority: HIGH for portfolio · Shows engineering maturity.*

### 5.1 — Unit & Widget Tests

BLoC is one of the most testable state management solutions in Flutter — this is a huge advantage. Not writing tests wastes it.

**What to test:**
```
test/
├── blocs/
│   ├── audio_player_bloc_test.dart
│   ├── album_bloc_test.dart
│   └── search_bloc_test.dart
├── repositories/
│   ├── spotify_repository_test.dart
│   └── local_db_repository_test.dart
└── widgets/
    ├── mini_player_test.dart
    └── song_card_test.dart
```

**Target:** At least 70% code coverage. Use `bloc_test` package for BLoC-specific testing helpers.

---

### 5.2 — Clean Architecture Layer Separation

**Recommended folder structure:**

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/           # Dio client, interceptors
│   └── utils/
├── data/
│   ├── datasources/       # Remote (API) & Local (Hive)
│   ├── models/            # JSON-serializable DTOs
│   └── repositories/      # Implements domain interfaces
├── domain/
│   ├── entities/          # Pure Dart business objects
│   ├── repositories/      # Abstract interfaces
│   └── usecases/          # Single-responsibility use cases
└── presentation/
    ├── blocs/
    ├── screens/
    └── widgets/
```

This is the architecture pattern used in large-scale Flutter apps. Having it in your portfolio signals you can work on real team codebases.

---

### 5.3 — Error Handling & Empty States

Every screen that loads data must handle three states:

1. **Loading** → Show skeleton shimmer
2. **Error** → Show an error card with a retry button and the actual error message
3. **Empty** → Show a relevant empty state illustration with a CTA (e.g., "No liked songs yet — start exploring")

Never let the app show a blank white screen or an unhandled exception.

---

### 5.4 — CI/CD with GitHub Actions

Add a `.github/workflows/flutter.yml` that runs on every Pull Request:

```yaml
name: Flutter CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
```

This shows you work like a professional developer, not a solo hobbyist.

---

### 5.5 — Proper Dependency Injection

Replace direct instantiation with [`get_it`](https://pub.dev/packages/get_it) + [`injectable`](https://pub.dev/packages/injectable) for a clean service locator pattern. This makes testing and refactoring dramatically easier.

---

## Phase 6 — Wow Factor ⚡
> *Priority: LOW but HIGH impact for portfolio demos.*

### 6.1 — Spotify Barcode Scanner Upgrade

**Current State:** Scanner exists but likely doesn't do much with the result.

**Improvement:** When a Spotify URI barcode is scanned:
1. Parse the URI (format: `spotify:track:4iV5W9uYEdYUVa79Axb7Rh`)
2. Call the Spotify API with the extracted ID
3. Open the song/album/playlist detail screen with the real data
4. Add a torch button for scanning in dark environments

---

### 6.2 — Animated Lyrics with Sync

**Current State:** Lyrics section exists with animation but not time-synced.

**Improvement:**
- Fetch time-synced lyrics from [LRCLIB API](https://lrclib.net/) (free, no auth needed)
- Auto-scroll the lyrics list to the current line as the song progresses
- Highlight the current line in white, dim past/future lines in grey
- Implement a "lyrics-only" fullscreen mode

This is one of the most visually impressive features you can add and always wows people watching a demo.

---

### 6.3 — Spotify Wrapped — Local Stats Page

A fun stats page showing:
- Your most-played songs this week/month (from local play history in Hive)
- Total minutes listened
- Favourite artist (most played)
- Top 5 songs visualized with a bar chart using `fl_chart`
- Shareable card generated with `screenshot` package

No Spotify API needed — all local data. Shows creative product thinking.

---

### 6.4 — Equalizer UI

A visual 5-band equalizer screen:
- Use `just_audio`'s built-in `AndroidEqualizer` for real audio effects on Android
- Display as an animated waveform using `CustomPainter`
- Presets: Normal, Bass Boost, Treble, Vocal, Electronic

---

### 6.5 — Offline / Download Mode Simulation

Since actual DRM-protected downloads aren't possible without Spotify Premium:
- Mark songs as "downloaded" in local DB
- Show a download icon that animates (progress ring) when tapped
- Filter to show only "downloaded" songs in an offline tab
- Use cached network images + cached audio previews for true offline behavior

---

## 📊 Suggested Timeline

| Week | Focus |
|------|-------|
| Week 1 | Audio player (1.1), Background playback (1.2) |
| Week 2 | Spotify API integration (2.1) |
| Week 3 | Local DB + Liked Songs (2.2, 4.2) |
| Week 4 | Mini player + Dynamic color theming (3.1, 3.2) |
| Week 5 | Search (4.1), Skeleton loaders (3.3) |
| Week 6 | Animations polish (3.4), Sleep timer (4.4) |
| Week 7 | Tests + Clean Architecture (5.1, 5.2) |
| Week 8 | Lyrics sync + Stats page (6.2, 6.3) |

---

## 📦 Recommended Packages Summary

| Package | Purpose |
|---------|---------|
| `just_audio` | Core audio playback engine |
| `audio_service` | Background playback + OS media controls |
| `isar` | Local database for persistence |
| `dio` | HTTP client for Spotify API calls |
| `flutter_animate` | Declarative animations |
| `palette_generator` | Dynamic album art color extraction |
| `shimmer` | Skeleton loading screens |
| `lottie` | Micro-interaction animations |
| `get_it` + `injectable` | Dependency injection |
| `bloc_test` | BLoC unit testing helpers |
| `fl_chart` | Charts for stats page |
| `screenshot` | Generate shareable cards |

---

## 🎯 Portfolio Talking Points

When presenting this project, highlight:

1. **"I refactored the local data layer into a real repository pattern connected to the Spotify Web API"** — shows API integration skills
2. **"I implemented background audio playback with OS media controls on both Android and iOS"** — shows platform-aware development
3. **"I added dynamic album art color extraction that animates the player UI"** — shows attention to UX details
4. **"I achieved 70%+ test coverage on all BLoC classes"** — shows engineering discipline
5. **"I implemented time-synced lyrics that auto-scroll with the song"** — shows you go above and beyond

---

> Made with 🎧 — Built to impress, not just to ship.