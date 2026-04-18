# 📋 Phase 2 Deployment Checklist

Use this checklist when deploying Phase 2 to your team.

## Pre-Deployment (Setup Only Once)

### Firebase Preparation
- [ ] Firebase project created (spox-60047)
- [ ] Firestore database initialized
- [ ] Firebase Storage enabled
- [ ] Service account key generated
- [ ] Security rules set to permissive for testing

### Repository Preparation
- [ ] Phase 2 scripts in `scripts/` folder:
  - [ ] `populate-db.js`
  - [ ] `upload-images.js`
  - [ ] `status.js`
  - [ ] `seed-firestore.js` (already exists)
- [ ] `package.json` updated with npm commands
- [ ] Documentation committed:
  - [ ] `PHASE_2_SETUP.md`
  - [ ] `PHASE_2_QUICK_START.md`
  - [ ] `PHASE_2_IMPLEMENTATION.md`
- [ ] Image files in `/images/` folder
- [ ] `serviceAccountKey.json` in `.gitignore`

### Flutter App (Phase 1 Integration)
- [ ] `ImageService.dart` exists in `lib/services/`
- [ ] `DynamicImage.dart` exists in `lib/widgets/`
- [ ] `FirestoreInitializationService.dart` exists
- [ ] `lib/main.dart` initializes Firestore (500ms delay)
- [ ] Seed data uses `ImageService.resolveImageUrl()`
- [ ] All code compiles without errors

---

## Deployment Steps (Team Member)

### Step 1: Get Service Account Key (Admin Only)
```bash
# Do this ONCE and share with team
1. Go to Firebase Console
2. Project Settings → Service Accounts
3. Generate New Private Key
4. Save as scripts/serviceAccountKey.json
5. Share securely with team (NOT in git!)
```

### Step 2: Each Team Member - One Time Setup
```bash
# Pull latest code
git pull origin main

# Install dependencies
cd scripts/
npm install

# Verify setup
ls -la serviceAccountKey.json      # Should exist
ls -la populate-db.js              # Should exist
npm run status                     # Should show status
```

Expected output from `npm run status`:
```
✓ Service account configured
✓ Firestore connected
✓ (Might show empty collections first time)
```

### Step 3: Populate Database
```bash
# DRY RUN first (no changes!)
npm run populate:dry-run

# If dry-run looks good, execute
npm run populate

# Watch output - should complete in 2-3 minutes
```

Expected output:
```
🚀 Starting database population...
Uploading images to Firebase Storage...
✓ 33 images uploaded
Populating Firestore...
✓ 4 playlists seeded
✓ 4 albums seeded
✓ 25 artists seeded
✓ 15 podcasts seeded
✅ Database population complete!
```

### Step 4: Verify Population
```bash
npm run status

# Expected output:
# Playlists: 4 documents
# Albums: 4 documents
# Artists: 25 documents
# Podcasts: 15 documents
```

### Step 5: Test in Flutter
```bash
# From project root (not scripts/)
flutter run

# Expected:
# ✓ App launches
# ✓ Playlists show with images
# ✓ Albums show with cover art
# ✓ Artists show with photos
# ✓ No re-seeding message
```

### Step 6: Test Offline Caching
```bash
# In app: Toggle device connectivity off
# Expected: Data still loads from Hive cache

# Then toggle back on
# Expected: Fresh data from Firestore
```

---

## Troubleshooting During Deployment

### ❌ "module not found: firebase-admin"
```bash
# Solution: Install dependencies
cd scripts/
npm install
```

### ❌ "serviceAccountKey.json not found"
```bash
# 1. Get key from admin
# 2. Save to scripts/serviceAccountKey.json
# 3. Do NOT commit to git
echo "scripts/serviceAccountKey.json" >> .gitignore
```

### ❌ "Permission denied" on Firestore writes
```bash
# Solution: Update Firestore security rules
# 1. Go to Firebase Console
# 2. Firestore → Rules tab
# 3. Set to permissive (testing):
#
# rules_version = '2';
# service cloud.firestore {
#   match /databases/{database}/documents {
#     match /{document=**} {
#       allow read, write: if true;
#     }
#   }
# }
#
# 4. Retry npm run populate
```

### ❌ "Image file not found"
```bash
# Verify images exist:
ls -la ../images/
ls -la ../images/home/
ls -la ../images/artists/

# If missing, check with team for image files
```

### ❌ Script hangs or times out
```bash
# 1. Check internet connection
# 2. Check Firebase project status:
#    - Open Firebase Console
#    - Verify Firestore database accessible
#    - Verify Storage bucket accessible
# 3. Try again with verbose logging:
#    - Run: npm run status (diagnostic)
# 4. If still fails, check node_modules:
#    - Delete: rm -rf node_modules/
#    - Reinstall: npm install
```

### ❌ Duplicate data after re-run
```bash
# This is safe! (Version tracking prevents re-seeding)
# 1. Optional: Create fresh deployment
# 2. Or: Update version in Firestore metadata
# 3. Or: Use --force on next run
npm run populate:skip-images
```

---

## Post-Deployment Verification

### Checklist
- [ ] `npm run status` shows 48+ documents
- [ ] All 4 playlists present
- [ ] All 4 albums present
- [ ] All 25 artists present
- [ ] All 15 podcasts present
- [ ] `flutter run` shows images
- [ ] App doesn't re-seed on relaunch
- [ ] Offline mode shows cached data

### Data Verification Script

```bash
# Run detailed verification
npm run status

# Manual checks in Firestore Console:
# 1. Go to https://console.firebase.google.com/firestore/data/spox-60047
# 2. Check collections exist:
#    - playlists (should have 4 docs)
#    - albums (should have 4 docs)
#    - artists (should have 25 docs)
#    - podcasts (should have 15 docs)
#    - _metadata (should have seed_version doc)
# 3. Click a playlist → verify tracks subcollection
# 4. Check image URLs are accessible
```

---

## Timeline & Support

### First Deployment (Cold Start)
- Setup: ~15 minutes
- Population: ~3 minutes
- Verification: ~5 minutes
- **Total: ~20-30 minutes** (first time)

### Subsequent Deployments
- Just run: `npm run populate`
- Takes: ~2-3 minutes
- Verify: `npm run status`

### Support Channels
- **Script errors:** Check troubleshooting above
- **Firebase issues:** Check Firebase Console
- **Flutter errors:** Check flutter run output
- **Data questions:** Contact team lead

---

## Rollback Procedure (If Needed)

### Option 1: Revert to Empty State
```bash
# 1. Delete Firestore collections manually
#    - Open Firebase Console
#    - Delete: playlists, albums, artists, podcasts, _metadata
# 2. Re-populate:
npm run populate
```

### Option 2: Delete Firebase Storage Images
```bash
# 1. Open Firebase Console → Storage
# 2. Delete all objects in bucket
# 3. Re-upload:
npm run upload-images:force
npm run populate:skip-images
```

### Option 3: Only Keep Local State
```bash
# Disable Firestore seeding
# Keep local hardcoded data as fallback
# (App already supports this via fallback chain)
```

---

## Phase 2 Success Criteria

Once deployed, you should have:

✅ **Database Populated**
- 4 playlists with 59 tracks
- 4 albums with 75 tracks
- 25 artists with metadata
- 15 podcasts
- All images in Firebase Storage

✅ **Images Working**
- Firebase Storage uploaded (33 images)
- Public URLs generated
- App displays images correctly
- Network + offline caching working

✅ **App Integration**
- Flutter app loads data from Firestore
- No re-seeding on relaunch
- Images display immediately
- Offline mode shows cached data

✅ **Team Ready**
- All developers can run `npm run populate`
- `serviceAccountKey.json` secure
- Scripts documented and tested
- Troubleshooting guide available

---

## Communication Template

### For Team Announcement
```
🚀 Phase 2 Database Population Ready!

Great news! We've implemented script-based database population.
This means no app rebuild needed to load data.

⚡ Quick Start (5 minutes):
1. Pull latest code
2. cd scripts/
3. npm install
4. npm run populate
5. npm run status (to verify)
6. flutter run (to test)

Full guide: PHASE_2_QUICK_START.md
Detailed setup: PHASE_2_SETUP.md

Questions? Check PHASE_2_IMPLEMENTATION.md or ask in #dev channel.

Let's go! 🎉
```

---

## Long-term Maintenance

### Weekly
- [ ] Check Firebase usage in Console
- [ ] Monitor Firestore read/write rates
- [ ] Ensure no unexpected collection growth

### Monthly
- [ ] Review security rules
- [ ] Backup Firestore data
- [ ] Monitor costs (should be $0 on Spark)

### Before Production
- [ ] Implement proper security rules
- [ ] Set up rate limiting if needed
- [ ] Implement data backup procedure
- [ ] Plan for scale-up beyond Spark plan

---

## Next Sprint Planning

### Phase 2.1: Security Hardening
- [ ] Implement proper Firestore security rules
- [ ] Rotate service account key
- [ ] Enable audit logging

### Phase 3: User Authentication
- [ ] Firebase Auth integration
- [ ] User-specific data persistence
- [ ] Session recovery

### Phase 4: Real Data Integration
- [ ] Sync with Spotify API
- [ ] Real user playlists
- [ ] Dynamic content updates

---

**Ready to deploy?** Start with [Pre-Deployment Checklist](#pre-deployment-setup-only-once) above! 🚀
