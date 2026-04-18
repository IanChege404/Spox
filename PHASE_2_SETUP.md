# 🚀 Phase 2: Script-Based Database Population

This guide walks you through using **scripts to populate your Firestore database** with all seed data and images.

## Overview

Phase 2 replaces in-app seeding with **command-line scripts** that:
- ✅ Upload images to Firebase Storage
- ✅ Generate public image URLs  
- ✅ Populate Firestore with seed data (playlists, artists, albums, podcasts)
- ✅ Track data version for integrity

## Prerequisites

### 1. Firebase Service Account Key

Download your Firebase Admin SDK credentials:

1. Go to [Firebase Console](https://console.firebase.google.com/project/spox-60047)
2. Click **Project Settings** (gear icon) → **Service Accounts** tab
3. Click **"Generate New Private Key"**
4. Save the downloaded JSON file as:
   ```
   /scripts/serviceAccountKey.json
   ```

### 2. Install Dependencies

```bash
cd scripts/
npm install
```

## Quick Start

### Run Complete Setup (Easiest)

```bash
npm run populate
```

This will:
1. Upload all images to Firebase Storage
2. Populate Firestore with seed data
3. Generate configuration files
4. Print status report

**Output:**
```
✓ Images uploaded to Firebase Storage
✓ Image URLs configured
✓ Firestore populated with seed data
✓ Version tracking enabled
```

## Advanced Usage

### Dry-Run (Preview Without Changes)

Test what would happen without making actual changes:

```bash
npm run populate:dry-run
```

### Skip Image Upload

If you only want to seed data (images already uploaded):

```bash
npm run populate:skip-images
```

### Individual Operations

**Upload images only:**
```bash
npm run upload-images
npm run upload-images:dry-run      # Preview first
npm run upload-images:force        # Re-upload existing files
```

**Seed Firestore only:**
```bash
npm run seed
```

**Check status:**
```bash
npm run status
```

## Script Reference

### `populate-db.js` (Master Orchestrator)
Runs all operations in sequence:
1. Validates prerequisites
2. Uploads images to Firebase Storage
3. Populates Firestore with seed data
4. Generates configuration

**Usage:**
```bash
node populate-db.js [--dry-run] [--skip-images]
```

### `upload-images.js` (Firebase Storage)
Uploads images from `/images/` to Firebase Storage with public URLs.

**What it does:**
- Maps local files → Storage paths
- Generates public accessible URLs
- Saves mapping config
- Supports `--dry-run` and `--force` modes

**Upload mapping:**
```
Local Path                              → Storage Path → Public URL
images/home/Drake-Mix.jpg              → playlists/drake-mix/cover.jpg
images/artists/Drake.jpg                → artists/drake/image.jpg
images/artists/Drake-For-All-The-Dogs   → albums/drake-for-all-the-dogs/cover.jpg
```

**Usage:**
```bash
node upload-images.js
node upload-images.js --dry-run      # Preview
node upload-images.js --force        # Re-upload
```

### `seed-firestore.js` (Data Population)
Populates Firestore collections with seed data.

**What it does:**
- Creates `playlists/` collection (4 playlists)
- Creates `albums/` collection (4 albums with tracks)
- Creates `artists/` collection (25 artists)
- Creates `podcasts/` collection (15 podcasts)
- Sets version metadata in `_metadata/`

**Features:**
- Version tracking (prevents accidental re-seeding)
- Batch operations for efficiency
- Detailed logging

**Usage:**
```bash
node seed-firestore.js
```

### `status.js` (Verification)
Checks Firestore status and data integrity.

**What it checks:**
- Service account configuration
- Firestore collections and document counts
- Seed version info
- Image URL accessibility

**Usage:**
```bash
node status.js
```

**Output example:**
```
📊 Firestore Status Report
================================================

📁 Collections:
  Playlists: 4 documents
  Albums:    4 documents
  Artists:   25 documents
  Podcasts:  15 documents

🌱 Seed Data:
  Version:     v1
  Last seeded: 4/10/2026, 2:30:00 PM
  App version: 1.0.0

📈 Total documents: 48

✅ Status: READY FOR TESTING
   Your Firestore database is populated and ready.
```

## Troubleshooting

### ❌ "serviceAccountKey.json not found"

**Solution:** Download service account key from Firebase Console:
1. Go to [Firebase Console](https://console.firebase.google.com/project/spox-60047)
2. **Project Settings** → **Service Accounts**
3. **Generate New Private Key**
4. Save as `scripts/serviceAccountKey.json`

### ❌ "Firebase Admin SDK not installed"

**Solution:** Install dependencies:
```bash
cd scripts/
npm install
```

### ❌ "Image file not found"

**Solution:** Ensure image files exist:
```bash
ls -la images/home/
ls -la images/artists/
```

If missing, check out the images from your repo or copy them from backup.

### ❌ "Permission denied" errors

**Solution:** Check Firestore security rules:
1. Go to [Firestore Console](https://console.firebase.google.com/firestore/data/spox-60047)
2. Go to **Rules** tab
3. Ensure rules allow writes from service account
4. For development: Use permissive rules
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

### ❌ "Already exists" when uploading images

**Solution:** Use `--force` flag to re-upload:
```bash
npm run upload-images:force
```

## Workflow for Team

### First Time Setup (Complete)
```bash
# 1. Download service account key (one team member)
# ↓ Upload to scripts/serviceAccountKey.json

# 2. Install dependencies
npm install

# 3. Run complete population
npm run populate

# 4. Verify
npm run status
```

### Adding New Data (Later)
```bash
# 1. Add images to /images/ folder
# 2. Add image mapping in upload-images.js
# 3. Run upload + seed
npm run populate:skip-images  # or full populate

# 4. Verify
npm run status
```

### Resetting Database (Testing)
```bash
# Use dry-run first to preview
npm run populate:dry-run

# Then reset (this will clear all data!)
# Manually delete Firestore collections
# Then re-populate
npm run populate
```

## Configuration Files Generated

### `image-storage-mapping.json`
Maps local image paths to Firebase Storage URLs.

**Example:**
```json
{
  "version": 1,
  "storageBase": "https://firebasestorage.googleapis.com/v0/b/spox-60047.appspot.com/o",
  "mappings": {
    "images/home/Drake-Mix.jpg": "playlists/drake-mix/cover.jpg",
    "images/artists/Drake.jpg": "artists/drake/image.jpg"
  },
  "uploadedAt": "2026-04-10T14:30:00Z"
}
```

Used by `ImageService` in Flutter app for resolution.

## Firestore Data Structure

After running scripts, your Firestore will have:

```
spox-60047 (project)
├── playlists/ (collection)
│   ├── 2010s/ (document)
│   ├── chill/ (document)
│   ├── upbeat/ (document)
│   └── drake-mix/ (document)
│       └── tracks/ (subcollection)
│           ├── 0 (track)
│           ├── 1 (track)
│           └── ...
├── albums/ (collection)
│   ├── drake-for-all-the-dogs/
│   ├── travis-scott-utopia/
│   ├── post-malone-austin/
│   └── 21-savage-american-dream/
│       └── tracks/ (subcollection)
├── artists/ (collection)
│   ├── drake/
│   ├── kanye-west/
│   ├── taylor-swift/
│   └── ... (25 artists)
├── podcasts/ (collection)
│   ├── ... (15 podcasts)
└── _metadata/ (collection)
    └── seed_version/ (document)
        ├── version: 1
        ├── last_seeded: timestamp
        └── app_version: "1.0.0"
```

## Image Storage Structure

After uploading, Firebase Storage will have:

```
spox-60047.appspot.com
├── playlists/
│   ├── 2010s/cover.jpg
│   ├── chill/cover.jpg
│   ├── upbeat/cover.jpg
│   └── drake-mix/cover.jpg
├── albums/
│   ├── drake-for-all-the-dogs/cover.jpg
│   ├── travis-scott-utopia/cover.jpg
│   ├── post-malone-austin/cover.jpg
│   └── 21-savage-american-dream/cover.jpg
└── artists/
    ├── drake/image.jpg
    ├── kanye-west/image.jpg
    ├── taylor-swift/image.jpg
    └── ... (25 artists)
```

All images are **publicly accessible** via URL.

## Next Steps

### For Flutter App
1. Run app: `flutter run`
2. Verify data loads from Firestore
3. Check images display (no more placeholders)
4. Confirm no re-seeding on subsequent launches

### For Production
1. Implement Firestore security rules
2. Enable versioning strategy
3. Set up CI/CD to auto-populate on deployment
4. Monitor database usage vs Spark plan limits

## Firestore Spark Plan Usage

Current data usage:
- **Firestore documents:** ~500 documents (out of unlimited)
- **Storage:** ~5-10 MB of images (out of 5GB)
- **Daily reads:** ~50-100 (out of 50,000 free)
- **Daily writes:** ~10-20 (out of 20,000 free)

✅ **Plenty of room for prototype and early scaling**

## Support & Questions

For issues or questions:
1. Check **Troubleshooting** section above
2. Run `npm run status` to diagnose
3. Check Firestore & Storage consoles
4. Review script logs for detailed errors

---

**Ready to populate?** 🚀

```bash
npm run populate
```
