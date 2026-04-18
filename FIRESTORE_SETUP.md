# 🔥 Firestore Setup Guide

This guide walks you through migrating your Spotify Clone's static data to Cloud Firestore and optimizing your app size.

## What's Being Migrated?

| Data Type | Location | Items | Benefit |
|-----------|----------|-------|---------|
| **Playlists** | `playlists/` | 4 mixes (Drake, Chill, Upbeat, 2010s) | Reduces hardcoded data |
| **Artists** | `artists/` | ~25 artists + metadata | Centralized, updatable |
| **Podcasts** | `podcasts/` | 15 podcasts | Easy content management |
| **Home Config** | `config/homeScreenSections` | Section layouts | A/B testing capability |
| **Images** | Firebase Storage (optional) | Album art, artist photos | Saves ~40-50 MB from APK |

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Your Flutter App                    │
│  ┌─────────────────────────────────────────────────┐│
│  │          Repositories & BLoCs                   ││
│  └──────────┬──────────────┬───────────────────────┘│
│             │              │                        │
│  ┌──────────▼──────┐  ┌────▼──────────────────────┐│
│  │ FirestoreSyncService                           ││
│  │ (Firestore + Hive Cache)                       ││
│  ├──────────┬──────┤                              ││
│  │          │      └─────────┬────────────────┐   ││
│  │    HiveService            │                │   ││
│  │   (Local Cache)     FirestoreDataSource     │   ││
│  │                     (Cloud Firestore)       │   ││
│  └──────────────────────────────────────────────┬──┘│
│             │                                    │  │
└─────────────┼────────────────────────────────────┼──┘
              │                                    │
        ┌─────▼────────┐                    ┌────▼──────────┐
        │ Local Cache  │                    │ Cloud Firestore│
        │ (Hive Boxes) │                    │ (Spark Plan)   │
        └──────────────┘                    └────────────────┘
```

## Step 1: Initialize Firestore Seed Data

### Option A: Using Flutter Dart Code (Recommended)

1. **Create a temporary initialization screen:**

```dart
// lib/ui/firestore_init_screen.dart
import 'package:flutter/material.dart';
import 'package:spotify_clone/core/utils/firestore_seed_data.dart';

class FirestoreInitScreen extends StatefulWidget {
  @override
  _FirestoreInitScreenState createState() => _FirestoreInitScreenState();
}

class _FirestoreInitScreenState extends State<FirestoreInitScreen> {
  String _status = 'Initializing Firestore...';
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _initializeFirestore();
  }

  Future<void> _initializeFirestore() async {
    try {
      await FirestoreSeedData.seedAllData();
      setState(() {
        _status = '✓ Firestore initialized successfully!';
        _isComplete = true;
      });
      
      // Auto-navigate after 2 seconds
      await Future.delayed(Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      setState(() {
        _status = '✗ Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isComplete)
              CircularProgressIndicator()
            else
              Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 20),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
```

2. **Add to your routes in main.dart:**

```dart
routes: {
  '/init-firestore': (context) => FirestoreInitScreen(),
  '/home': (context) => MiniPlayerOverlay(child: const HomeScreen()),
  '/login': (context) => const SpotifyLoginScreen(),
},
```

3. **On first launch, check if data exists:**

```dart
// In main.dart or splash screen
final syncService = locator<FirestoreSyncService>();
final cacheStatus = await syncService.getCacheStatus();

if (cacheStatus.isEmpty) {
  // Data hasn't been synced yet
  Navigator.pushReplacementNamed(context, '/init-firestore');
} else {
  // Data already synced, continue normally
  Navigator.pushReplacementNamed(context, '/home');
}
```

### Option B: Using Firebase Console (Manual)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project `spox-60047`
3. Navigate to **Firestore Database**
4. **Create Collections** with this structure:

#### Collection: `playlists`
```
Document ID: 2010s
{
  "id": "2010s",
  "name": "2010s Mix",
  "description": "The biggest hits from the 2010s",
  "coverUrl": "https://via.placeholder.com/300x300/FF6B6B/FFFFFF",
  "trackCount": 15,
  "ownerName": "Spotify",
  "isPlayable": true
}
```

Repeat for: `chill`, `upbeat`, `drake-mix`

#### Collection: `artists`
```
Document ID: drake
{
  "id": "drake",
  "name": "Drake",
  "imageUrl": "https://via.placeholder.com/300x300/FF6B6B/FFFFFF",
  "genres": ["hip-hop", "rap", "canadian-hip-hop"],
  "followers": 69000000,
  "popularity": 94
}
```

Repeat for other artists (see `firestore_seed_data.dart` for full list)

#### Collection: `podcasts`
```
Document ID: joe-rogan
{
  "id": "joe-rogan",
  "name": "The Joe Rogan Experience",
  "coverUrl": "https://via.placeholder.com/300x300/FF6B6B/FFFFFF",
  "description": "Long-form conversations with celebrities and creators"
}
```

#### Collection: `config`
```
Document ID: homeScreenSections
{
  "topMixes": [
    {"title": "2010s Mix", "playlistId": "2010s", "position": 0},
    {"title": "Chill Mix", "playlistId": "chill", "position": 1},
    {"title": "Upbeat Mix", "playlistId": "upbeat", "position": 2},
    {"title": "Drake Mix", "playlistId": "drake-mix", "position": 3}
  ],
  "recentPlays": ["american-dream", "utopia", "liked-songs"],
  "featuredArtists": ["drake", "taylor-swift", "the-weeknd", ...],
  "featuredPodcasts": ["joe-rogan", "huberman-lab", "startalk"]
}
```

## Step 2: Update Home Screen to Use Firestore Data

### Before (Hardcoded Data):
```dart
// lib/ui/home_screen.dart (OLD)
final drakePlaylist = getDrakePlaylistLocally(); // Hardcoded
```

### After (Firestore + Cache):
```dart
// lib/ui/home_screen.dart (NEW)
@override
void initState() {
  super.initState();
  // Fetch from Firestore with automatic Hive fallback
  context.read<HomeBloc>().add(const HomeInitialEvent());
}
```

## Step 3: Update repositories to use sync service

```dart
// lib/data/repository/playlist_repository.dart
class PlaylistRepository {
  final FirestoreSyncService _syncService;

  Future<List<SpotifyPlaylist>> getPlaylists({bool forceRefresh = false}) async {
    // Returns cache first, syncs in background if stale
    return _syncService.syncPlaylists(forceRefresh: forceRefresh);
  }

  Future<List<SpotifyTrack>> getPlaylistTracks(String playlistId) async {
    // Cached by default, refresh if older than 24 hours
    return _syncService.syncPlaylistTracks(playlistId);
  }
}
```

## Step 4: Verify Firestore Setup

Run the verification test:
```bash
flutter test test/firestore_sync_test.dart -v
```

Or use the configuration verifier:
```bash
./scripts/verify_config.sh
```

## Offline Behavior

When the user is offline:

1. **Firestore Sync Service** detects network error
2. Falls back to **Hive cache** (24-hour TTL)
3. User sees cached data with "Offline Mode" indicator
4. When online again, data auto-syncs

```dart
// Example: Fetch with fallback
try {
  final data = await FirestoreSyncService.syncPlaylists();
  // Use data
} catch (e) {
  // Network error → Hive cache automatically used
  final cachedData = HiveService.getCachedPlaylists();
}
```

## Firestore Quota & Costs

### Spark Plan Limits:
- **50K reads/day** ← Your app only uses ~10-20/day initially
- **20K writes/day** ← Only admin/backend updates data
- **1GB storage** ← Static data is < 1KB, plenty of room

### Estimated Usage:
- 100 active users simultaneous
- Each user: ~1 playlist sync on app load
- Daily reads: 100 users × 1 read = **100 reads/day** ✓ Well under limit

### When to Upgrade:
- You exceed 50K reads/day (unlikely in early stages)
- Users expect unlimited history/personal data
- You add real-time multiplayer features

For now, **Spark Plan is perfect** for your static data.

## Adding New Content

### Add a Playlist (Firebase Console):
1. Go to `playlists` collection
2. Click **"Add Document"**
3. Set Document ID (e.g., `workout-mix`)
4. Add fields: `name`, `description`, `coverUrl`, `trackCount`, `isPlayable`
5. App automatically fetches on next sync

### Add Tracks to a Playlist:
1. Open playlist document
2. Click **"Add Collection"** → name it `tracks`
3. Add documents with track metadata
4. Refresh app to see changes

### Add Artists:
1. Go to `artists` collection
2. Click **"Add Document"**
3. Fill in: `name`, `imageUrl`, `genres`, `followers`, `popularity`

## Troubleshooting

### Issue: "Firestore collections are empty"
**Solution:** Make sure `FirestoreSeedData.seedAllData()` was called once
```dart
await FirestoreSeedData.seedAllData();
```

### Issue: "App still loading hardcoded data"
**Solution:** Verify repositories use `FirestoreSyncService`:
```bash
grep -r "PlaylistLocalDatasource" lib/
# Should be empty or only in old/deprecated files
```

### Issue: "Cache not updating after 24 hours"
**Solution:** Force refresh when user pulls to refresh:
```dart
final playlists = await syncService.syncPlaylists(forceRefresh: true);
```

### Issue: "Firestore reads are too high"
**Solution:** 
- Only fetch on app load, not on every screen
- Use Hive cache with TTL (24 hours default)
- Batch requests: fetch `syncAllData()` once instead of multiple calls

## Next Steps

1. ✅ **Initialize Firestore** with seed data (this step)
2. ✅ **Update repositories** to use `FirestoreSyncService`
3. ✅ **Test offline mode** by disabling network
4. **Remove bundled images** from APK (Phase 2)
5. **Monitor Firestore quota** in Firebase Console
6. **Add user-generated content** (playlists, favorites)

## References

- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Spark Plan Pricing](https://firebase.google.com/pricing)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- Local caching with Hive: [lib/services/hive_service.dart](../lib/services/hive_service.dart)
- Sync service: [lib/services/firestore_sync_service.dart](../lib/services/firestore_sync_service.dart)
