# 📚 Phase 2 Scripts Repository

Complete command-line tools for populating Firestore with seed data and uploading images to Firebase Storage.

## 🎯 Quick Start (1 Minute)

```bash
npm install
npm run populate
```

Done! Your database is now populated with all seed data and images.

## 📋 Available Commands

### Master Orchestration
```bash
npm run populate                 # Complete setup: upload images + seed database
npm run populate:dry-run         # Preview changes without making them
npm run populate:skip-images     # Seed database only (images already uploaded)
```

### Individual Operations
```bash
npm run upload-images            # Upload images to Firebase Storage only
npm run upload-images:dry-run    # Preview image uploads
npm run upload-images:force      # Re-upload all images (bypass cache)
npm run seed                     # Seed Firestore database only
npm run status                   # Check database status and verify data
```

## 🔑 Prerequisites

### 1. Firebase Service Account Key

Download your Firebase Admin SDK credentials:

1. Go to [Firebase Console](https://console.firebase.google.com/project/spox-60047)
2. Click **⚙️ Project Settings** → **Service Accounts** tab
3. Click **Generate New Private Key**
4. Save the downloaded JSON file as: `serviceAccountKey.json`
   
   ```
   scripts/serviceAccountKey.json
   ```

⚠️ **DO NOT COMMIT TO GIT** - Already in `.gitignore`

### 2. Install Dependencies

```bash
npm install
```

### 3. Image Files

Ensure images exist in project root:
```
/images
  ├── home/           (playlist covers)
  ├── artists/        (artist photos)
  └── albums/         (album covers)
```

## 🚀 Scripts Overview

### `populate-db.js` (Master Orchestrator)
**Purpose:** Runs everything in sequence

**What it does:**
1. Validates prerequisites
2. Uploads images to Firebase Storage
3. Populates Firestore collections
4. Generates configuration files
5. Prints summary report

**Usage:**
```bash
node populate-db.js [--dry-run] [--skip-images]
```

**Output:**
- Console log with progress
- `image-storage-mapping.json` (image URL mappings)
- Success/failure report

---

### `upload-images.js` (Firebase Storage)
**Purpose:** Uploads local images to Firebase Storage and generates public URLs

**What it does:**
- Maps local image paths to Storage paths
- Generates public accessible URLs
- Saves mapping configuration
- Supports selective upload with --force flag

**Local → Storage Mapping:**
```
images/home/Drake-Mix.jpg           → playlists/drake-mix/cover.jpg
images/artists/Drake.jpg             → artists/drake/image.jpg
images/albums/Drake-For-All.jpg      → albums/drake-for-all/cover.jpg
```

**Usage:**
```bash
node upload-images.js                # Standard upload
node upload-images.js --dry-run      # Preview only
node upload-images.js --force        # Re-upload all
```

**Output:**
- Console progress report
- `image-storage-mapping.json` with public URLs
- Success count

---

### `seed-firestore.js` (Data Population)
**Purpose:** Populates Firestore collections with seed data

**What it does:**
- Creates `playlists/` collection (4 playlists, 59 tracks)
- Creates `albums/` collection (4 albums, 75 tracks)
- Creates `artists/` collection (25 artists)
- Creates `podcasts/` collection (15 podcasts)
- Sets version metadata (prevents re-seeding)

**Collections Created:**
```
Firestore
├── playlists/        (4 documents)
│   └── tracks/       (59 subcollection)
├── albums/           (4 documents)
│   └── tracks/       (75 subcollection)
├── artists/          (25 documents)
├── podcasts/         (15 documents)
└── _metadata/
    └── seed_version/ (version tracking)
```

**Usage:**
```bash
node seed-firestore.js
```

**Features:**
- Batch writes for efficiency
- Version tracking (safe multi-call)
- Detailed logging
- Image URL integration

---

### `status.js` (Verification)
**Purpose:** Checks Firestore status and verifies data integrity

**What it checks:**
- Service account configuration
- Firestore connectivity
- Collection document counts
- Seed version info
- Image URL accessibility

**Usage:**
```bash
node status.js
```

**Example Output:**
```
📊 Firestore Status Report
================================================

✅ Service Account: CONFIGURED

🗄️ Firestore Collections:
  playlists: 4 documents
  albums: 4 documents
  artists: 25 documents
  podcasts: 15 documents

🌱 Seed Data:
  Version: v1
  Last seeded: 2026-04-10 14:30:00
  App version: 1.0.0

📊 Total documents: 48

✅ Status: READY FOR TESTING
```

---

## 📊 Seed Data Overview

### Playlists (4)
| Name | Count | Tracks |
|------|-------|--------|
| 2010s | 1 | 15 tracks |
| Chill | 1 | 15 tracks |
| Upbeat | 1 | 15 tracks |
| Drake Mix | 1 | 14 tracks |

**Total: 59 tracks**

### Albums (4)
| Album | Artist | Tracks |
|-------|--------|--------|
| For All The Dogs | Drake | 21 tracks |
| UTOPIA | Travis Scott | 19 tracks |
| Austin | Post Malone | 20 tracks |
| American Dream | 21 Savage | 15 tracks |

**Total: 75 tracks**

### Artists (25)
Drake, Kanye West, Taylor Swift, The Weeknd, Ariana Grande, BTS, Bad Bunny, Eminem, Post Malone, SZA, Lana Del Rey, Weeknd, Travis Scott, Dua Lipa, Billie Eilish, and more...

### Podcasts (15)
The Daily, Pod Save America, Joe Rogan Experience, Stuff You Should Know, Revisionist History, and more...

---

## 🧪 Testing Workflow

### 1. Dry Run (Preview)
```bash
npm run populate:dry-run
```
Shows what would happen without making changes.

### 2. Populate Database
```bash
npm run populate
```
Execute full setup.

### 3. Verify Status
```bash
npm run status
```
Confirm collections populated correctly.

### 4. Test in Flutter App
```bash
cd ..
flutter run
```
Check that app loads data and images.

---

## ⚙️ Configuration Files

### Generated by Scripts

#### `image-storage-mapping.json`
Maps local images to Firebase Storage URLs.

**Location:** `scripts/` folder

**Content:**
```json
{
  "version": 1,
  "storageBase": "https://firebasestorage.googleapis.com/v0/b/spox-60047.appspot.com/o",
  "mappings": {
    "images/home/Drake-Mix.jpg": "playlists/drake-mix/cover.jpg",
    ...
  },
  "uploadedAt": "2026-04-10T14:30:00Z"
}
```

**Used by:** Flutter app's `ImageService.resolveImageUrl()`

---

## 🚨 Troubleshooting

### ❌ "serviceAccountKey.json not found"
**Solution:** Download key from Firebase Console (see Prerequisites section)

### ❌ "PERMISSION_DENIED"
**Solution:** Update Firestore security rules to allow writes:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

### ❌ "Image file not found"
**Solution:** Verify images exist:
```bash
ls -la ../images/home/
ls -la ../images/artists/
```

### ❌ Script hangs or times out
**Solution:**
1. Check internet connection
2. Verify Firebase project accessible
3. Check service account credentials
4. Try: `npm run status` to diagnose

### ❌ "Already exists" when uploading
**Solution:** Use `--force` flag:
```bash
npm run upload-images:force
```

---

## 📖 Full Documentation

### For Quick Setup
→ See: `PHASE_2_QUICK_START.md` in project root

### For Complete Guide
→ See: `PHASE_2_SETUP.md` in project root

### For Implementation Details
→ See: `PHASE_2_IMPLEMENTATION.md` in project root

### For Team Deployment
→ See: `PHASE_2_DEPLOYMENT.md` in project root

---

## 📦 Environment Variables

Create `.env` file if needed (optional):
```
FIREBASE_PROJECT_ID=spox-60047
FIREBASE_STORAGE_BUCKET=spox-60047.appspot.com
FIRESTORE_DATABASE_ID=(default)
NODE_ENV=production
```

Scripts will auto-detect from `serviceAccountKey.json`

---

## 🔐 Security Notes

### Current (Development)
- Permissive Firestore rules (allow all)
- Service account key stored locally
- Images publicly readable

### Before Production
- [ ] Implement proper Firestore security rules
- [ ] Rotate service account key
- [ ] Enable audit logging
- [ ] Set Firebase Storage rules

### Firebase Rules Template (Production)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read
    match /{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
  }
}
```

---

## 📞 Support

**Check Before Asking:**
1. Run `npm run status`
2. Check Firestore Console
3. Read troubleshooting above
4. Review full documentation links

---

## 🎓 Learning Resources

- [Firebase Admin SDK Docs](https://firebase.google.com/docs/admin/setup)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Firebase Storage Documentation](https://firebase.google.com/docs/storage)

---

**Ready to populate?** 🚀

```bash
npm run populate
```
  ...

✅ Firestore seeding completed successfully!
```

## What Gets Seeded?

- **Playlists**: 4 sample playlists (2010s, Chill, Workout, Party)
- **Albums**: 3 classic albums (Abbey Road, Thriller, Rumours)
- **Artists**: 3 legendary artists (The Beatles, Michael Jackson, Fleetwood Mac)
- **Podcasts**: 2 popular podcasts (Joe Rogan Experience, Serial)
- **Home Screen Config**: Featured collections for the home screen

## Troubleshooting

### "serviceAccountKey.json not found"
- Make sure you followed Step 1 correctly
- The file should be in the `scripts/` directory (where this README is)
- Filename must be exactly: `serviceAccountKey.json`

### "ProjectId doesn't match"
- The script is hardcoded for project `spox-60047`
- Make sure you're using the correct Firebase project

### Permission Denied Errors
- Go to Firebase Console → Firestore → Rules tab
- Update security rules to allow admin writes (or use service account which bypasses rules)
- Example permissive rule for development:
  ```firestore
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /{document=**} {
        allow read, write: if request.auth != null || request.time < timestamp.date(2099, 1, 1);
      }
    }
  }
  ```

### "Cannot find module 'firebase-admin'"
```bash
npm install
```

## Security Warning ⚠️

**IMPORTANT:** Never commit `serviceAccountKey.json` to git!

The `.gitignore` already excludes it, but double-check:
```bash
cat ../.gitignore | grep serviceAccountKey
```

If you see the key in git, remove it immediately:
```bash
git rm --cached scripts/serviceAccountKey.json
git commit -m "Remove service account key"
```

## Customizing Seed Data

Edit `seed-firestore.js` to change the seed data. Each function is clearly marked:
- `seedPlaylists()` - Add/modify playlists
- `seedAlbums()` - Add/modify albums  
- `seedArtists()` - Add/modify artists
- `seedPodcasts()` - Add/modify podcasts
- `seedHomeScreenConfig()` - Configure home screen

Then run `npm run seed` again to update the database.

## Clearing Old Data

To delete old collections before seeding:

```bash
# Create a file: clear-firestore.js
node -e "
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
const db = admin.firestore();
['playlists', 'albums', 'artists', 'podcasts'].forEach(async (collection) => {
  const snapshot = await db.collection(collection).get();
  snapshot.forEach(doc => doc.ref.delete());
});
"
```

Then run seed again.

## Next Steps

1. ✅ Run the seed script
2. ✅ Verify data in Firebase Console Firestore tab
3. ✅ Update Flutter app to fetch from Firestore (instead of mock data)
4. ✅ Test app with real data

Happy seeding! 🌱
