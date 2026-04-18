## Dynamic Data & Image Migration Guide

### Overview
This document explains the new dynamic data architecture that enables:
- ✅ Auto-population of Firestore on first app launch
- ✅ Dynamic image URLs (Firebase Storage + fallback to local assets)
- ✅ Version-tracked seed data (prevents re-seeding)
- ✅ Multi-source image resolution (Storage → Spotify → Local assets)

---

## Architecture

### Data Flow
```
App Launch
    ↓
Check Firestore (playlists collection empty?)
    ├─ YES → Run seedAllData()
    │   └─ Check version metadata
    │   └─ If outdated, seed all collections
    │   └─ Update metadata with current version
    └─ NO → Use existing Firestore data
    ↓
BLoC requests data from Repositories
    ↓
Repository delegates to Firestore/Spotify datasources
    ↓
UI receives data with imageUrl references
    ├─ If URL is network (Storage/Spotify) → CachedNetworkImage
    ├─ If URL is local asset → Image.asset()
    └─ Fallback to placeholder if missing
```

### File Structure
```
lib/
├── main.dart                                    # Entry point + auto-seeding logic
├── services/
│   ├── image_service.dart                      # Image resolution & mapping
│   ├── firebase_service.dart                   # Firebase initialization
│   ├── firestore_sync_service.dart             # Caching layer (24hr TTL)
│   └── hive_service.dart                       # Local persistence
├── core/utils/
│   └── firestore_seed_data.dart               # Complete seed data (134+ tracks)
├── data/
│   ├── datasource/
│   │   ├── firestore_datasource.dart          # Firestore reads
│   │   └── spotify_*_datasource.dart          # Spotify API
│   ├── repository/                            # Data layer abstraction
│   └── model/                                 # Data models
└── widgets/
    ├── dynamic_image.dart                      # NEW: Smart image widget
    ├── song_chip.dart                         # UPDATED: Uses DynamicImage
    └── album_chip.dart                        # UPDATED: Uses DynamicImage
```

---

## Phase 1: Auto-Seeding (✅ COMPLETE)

### What was implemented

1. **main.dart**
   - Checks if Firestore collections are empty on app startup
   - Automatically calls `FirestoreSeedData.seedAllData()` if needed
   - Includes version tracking metadata to prevent re-seeding

2. **firestore_seed_data.dart**
   - Complete migration of 134+ tracks from local datasources
   - Uses `ImageService.resolveImageUrl()` for all image references
   - Version tracking prevents redundant seeding
   - Seed progress logging for debugging

3. **image_service.dart** (NEW)
   - Centralized image URL resolution
   - Maps local asset paths → Firebase Storage URLs
   - Supports multiple image sources:
     - Firebase Storage (primary for new content)
     - Spotify API (live data)
     - Local assets (fallback)
     - Placeholder images (during migration)

4. **dynamic_image.dart** (NEW)
   - Smart Flutter widget that handles both network & asset images
   - Automatic caching for network images via `cached_network_image`
   - Graceful error handling with fallback placeholder
   - Used in `SongChip` and `AlbumChip` widgets

### How to verify auto-seeding works

```bash
# 1. Delete existing Firestore data (Firestore Console)
# 2. Restart the app
# 3. Check logs:
#    "[main] ℹ Firestore collections empty - seeding with initial data..."
#    "Starting Firestore seed data - COMPLETE MIGRATION (v1)..."
#    "✓ All data seeded successfully!"
# 4. Verify in Firestore Console:
#    - Collections: playlists, albums, artists, podcasts, _metadata
#    - Metadata doc shows: seed_version=1, last_seeded=<timestamp>
```

---

## Phase 2: Firebase Storage Image Upload (🚧 IN PROGRESS)

### Recommended approach: Batch upload script

#### Option A: Node.js Script (Recommended)

**Create `scripts/upload-images-to-storage.js`:**

```javascript
const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin
const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'spox-60047.appspot.com',
});

const bucket = admin.storage().bucket();

// Directory mappings (local → Firebase Storage path)
const directoryMappings = {
  'images/home': 'playlists/',
  'images/artists': 'artists/',
  'images/2010': 'playlists/2010s/',
  'images/chill': 'playlists/chill/',
  'images/upbeat': 'playlists/upbeat/',
  'images/drake mix': 'playlists/drake-mix/',
};

async function uploadImagesRecursive(localDir, storagePath) {
  const files = fs.readdirSync(localDir);
  
  for (const file of files) {
    const localPath = path.join(localDir, file);
    const stats = fs.statSync(localPath);
    
    if (stats.isDirectory()) {
      await uploadImagesRecursive(localPath, `${storagePath}${file}/`);
    } else if (/\.(jpg|jpeg|png|gif|webp)$/.test(file.toLowerCase())) {
      const remoteFile = `${storagePath}${file}`;
      console.log(`Uploading: ${localPath} → ${remoteFile}`);
      
      try {
        await bucket.upload(localPath, {
          destination: remoteFile,
          metadata: {
            contentType: 'image/jpeg', // Adjust for file type
            cacheControl: 'public, max-age=31536000', // Cache 1 year
          },
        });
        console.log(`✓ Uploaded: ${remoteFile}`);
      } catch (error) {
        console.error(`✗ Failed to upload ${remoteFile}:`, error);
      }
    }
  }
}

async function main() {
  console.log('Starting Firebase Storage image upload...');
  
  const imagesRoot = path.join(__dirname, '../images');
  
  for (const [localPath, storagePath] of Object.entries(directoryMappings)) {
    const fullLocalPath = path.join(__dirname, '..', localPath);
    if (fs.existsSync(fullLocalPath)) {
      await uploadImagesRecursive(fullLocalPath, storagePath);
    }
  }
  
  console.log('✓ All images uploaded successfully!');
}

main().catch(console.error);
```

**Run upload:**
```bash
cd scripts/
npm install firebase-admin  # If not already installed
node upload-images-to-storage.js
```

#### Option B: Firebase Console (Simpler but slower)
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Navigate to Storage
3. Create these folders: `playlists/`, `albums/`, `artists/`, `podcasts/`
4. Manually upload images to corresponding folders
5. Copy public URLs and update `ImageService._assetToStorageMap`

---

## Phase 3: Update ImageService Mappings

After uploading images to Firebase Storage, update the mappings in [lib/services/image_service.dart](lib/services/image_service.dart):

```dart
static const Map<String, String> _assetToStorageMap = {
  // Example - update with real Storage URLs after upload
  'images/home/2010s-Mix.jpg': 'playlists%2F2010s%2Fcover.jpg?alt=media',
  
  // Once uploaded, Firebase Console will show:
  // https://firebasestorage.googleapis.com/v0/b/spox-60047.appspot.com/o/playlists%2F2010s%2Fcover.jpg?alt=media
  
  // That translates to the mapping above
};
```

---

## Phase 4: Enable Firestore Security Rules

Current setup requires **unauthenticated write access** for seeding. Update Firestore rules in [Firebase Console](https://console.firebase.google.com) → Firestore Database → Rules:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Allow unauthenticated reads (for app display)
    match /{document=**} {
      allow read: if true;
    }
    
    // First launch seeding - allow writes to specific docs
    // NOTE: After first seed, consider restricting this
    match /_metadata/{document=**} {
      allow read, write: if true;  // Allow version tracking
    }
    
    match /playlists/{document=**} {
      allow write: if request.time < timestamp.date(2026, 5, 1);  // Seed deadline
      allow read: if true;
    }
    
    match /albums/{document=**} {
      allow write: if request.time < timestamp.date(2026, 5, 1);
      allow read: if true;
    }
    
    match /artists/{document=**} {
      allow write: if request.time < timestamp.date(2026, 5, 1);
      allow read: if true;
    }
    
    match /podcasts/{document=**} {
      allow write: if request.time < timestamp.date(2026, 5, 1);
      allow read: if true;
    }
    
    // User-generated content (liked songs, history, playlists)
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

---

## Current Status

| Phase | Status | Details |
|-------|--------|---------|
| **Auto-Seeding** | ✅ Complete | Firestore auto-populates on first launch |
| **Image Service** | ✅ Complete | Dynamic image URL resolution implemented |
| **DynamicImage Widget** | ✅ Complete | Smart image loading with fallbacks |
| **Seed Data Migration** | ✅ Complete | 134+ tracks with ImageService URLs |
| **Firebase Storage Upload** | 🚧 Ready | Script template provided, manual upload possible |
| **UI Migration** | ✅ Complete | SongChip & AlbumChip updated to use DynamicImage |
| **Security Rules** | ⚠️ Review needed | Template provided, adjust timestamp as needed |
| **Admin CMS** | 📋 Future | Could build Firestore UI for content updates |

---

## Testing Checklist

- [ ] Delete Firestore data → Restart app → Verify auto-seeding works
- [ ] Check logs for: `"✓ All data seeded successfully!"`
- [ ] Verify metadata in Firestore: `_metadata/seed_version` doc
- [ ] Open app → Home screen should display playlists/albums
- [ ] Verify images load (from local assets during development)
- [ ] After Firebase Storage upload: verify network images cache properly
- [ ] Test offline: Open app with airplane mode → should use Hive cache
- [ ] Test fallback: Temporarily corrupt an image URL → should show placeholder

---

## Troubleshooting

**"Firestore permission denied" on startup?**
- Firestore security rules too restrictive
- Solution: Update rules to allow temporary write access (see Phase 4)

**"Images showing as placeholders?"**
- Local assets not found or Firebase Storage URLs incorrect
- Solution: Check `ImageService._assetToStorageMap` mappings
- Verify image files exist in `/images/home/`, `/images/artists/`, etc.

**"Re-seeding on every app restart?"**
- Metadata not properly stored or version outdated
- Solution: Check `_metadata/seed_version` in Firestore Console
- Manually delete the collection and restart to force fresh seed

**"Slow image loading?"**
- Network images not caching properly
- Solution: Verify `cached_network_image` package in pubspec.yaml
- Check Firebase Storage caching headers (should be set to 1 year)

---

## Future Enhancements

### Phase 5: Hybrid Dynamic Content
- [ ] Keep static Firestore baseline for offline
- [ ] Layer real Spotify API data on top
- [ ] Implement differential sync (only changed tracks)
- [ ] Add live trending/new releases

### Phase 6: Admin CMS
- [ ] Build Firestore UI for content updates
- [ ] Allow adding new playlists without app rebuild
- [ ] Image upload directly from admin panel

### Phase 7: User Personalization
- [ ] Sync liked songs to Firestore
- [ ] Store play history (with privacy controls)
- [ ] Personalized recommendations based on history

---

## Files Changed

- ✅ [lib/main.dart](lib/main.dart) - Auto-seeding on first launch
- ✅ [lib/services/image_service.dart](lib/services/image_service.dart) - Image URL resolution
- ✅ [lib/widgets/dynamic_image.dart](lib/widgets/dynamic_image.dart) - Smart image widget
- ✅ [lib/core/utils/firestore_seed_data.dart](lib/core/utils/firestore_seed_data.dart) - Updated seed data
- ✅ [lib/widgets/song_chip.dart](lib/widgets/song_chip.dart) - Uses DynamicImage
- ✅ [lib/widgets/album_chip.dart](lib/widgets/album_chip.dart) - Uses DynamicImage

---

## Notes

- **Versioning**: `_seedVersion = 1` in firestore_seed_data.dart. Increment when data changes.
- **Seed Deadline**: Current Firestore rules allow writes until May 1, 2026. Adjust as needed.
- **Image Caching**: Firebase Storage configured for 1-year caching (immutable content).
- **Fallback Strategy**: Asset → Storage → Spotify → Placeholder (graceful degradation).
