# ⚡ Phase 2: Quick Start (5 Minutes)

## 🎯 Goal
One command to populate Firestore with all seed data and images.

## 📋 Checklist

- [ ] Download Firebase service account key (see below)
- [ ] Save to `/scripts/serviceAccountKey.json`
- [ ] Run one command
- [ ] Done!

## 🔑 Get Your Firebase Key

1. Open [Firebase Console](https://console.firebase.google.com/project/spox-60047)
2. Click ⚙️ **Project Settings** → **Service Accounts** tab
3. Click **Generate New Private Key**
4. Download JSON file
5. Copy to: `scripts/serviceAccountKey.json`

## 🚀 Run It

```bash
cd scripts/
npm install
npm run populate
```

Wait 2-3 minutes...

```
✓ Images uploaded
✓ Firestore populated
✓ Ready!
```

## ✅ Verify

```bash
npm run status
```

Should show:
- Playlists: 4
- Albums: 4
- Artists: 25
- Podcasts: 15

## 🧪 Test in App

```bash
flutter run
```

You should see:
- Playlists with images ✅
- Albums with covers ✅
- Artists with photos ✅
- No re-seeding on re-launch ✅

## ⚠️ Problems?

### "serviceAccountKey.json not found"
→ Did you download and place the Firebase key? (Step 1 above)

### "Dependencies not installed"
→ Run `npm install` in scripts/ folder

### "Permission denied"
→ Your Firestore security rules might be too strict. For testing, allow writes.

### Need more help?
→ See detailed [PHASE_2_SETUP.md](PHASE_2_SETUP.md)

---

**That's it!** Your database is now populated with real data. 🎉
