# 🎵 Spotify API Setup Guide

This guide walks you through setting up the Spotify Web API integration for the Spotify Clone app.

## Step 1: Register Your App at Spotify Developer Dashboard

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Log in or create a Spotify account (free account is fine)
3. Accept the terms and create an app
4. Name it: `Spotify Clone` (or any name you want)
5. Accept the terms and create the app

## Step 2: Get Your Credentials

After creating your app, you'll see a dashboard with:
- **Client ID** — Copy this
- **Client Secret** — Copy this

⚠️ **IMPORTANT:** Keep your Client Secret private! Don't commit it to public repos.

## Step 3: Configure Your App in Spotify Dashboard

In your app settings on the Spotify Dashboard:

1. Click "Edit Settings"
2. Under "Redirect URIs", add: `com.spotify.clone://callback`
3. Save the settings

This allows the app to redirect back after authentication.

## Step 4: Update Your .env File

Open `/home/devmahnx/Dev/Spotify-Clone-Old/.env` and replace:

```dotenv
# Replace these with your actual credentials from Spotify Dashboard
SPOTIFY_CLIENT_ID=YOUR_SPOTIFY_CLIENT_ID_HERE
SPOTIFY_CLIENT_SECRET=YOUR_SPOTIFY_CLIENT_SECRET_HERE
SPOTIFY_REDIRECT_URL=com.spotify.clone://callback
```

**Example:**
```dotenv
SPOTIFY_CLIENT_ID=abc123def456ghi789jkl
SPOTIFY_CLIENT_SECRET=xyz789uvw456rst123opq
SPOTIFY_REDIRECT_URL=com.spotify.clone://callback
```

## Step 5: Verify Configuration

Run this command to check if configuration loaded correctly:

```bash
cd /home/devmahnx/Dev/Spotify-Clone-Old
flutter pub get
flutter analyze
```

If you see no errors, you're ready to authenticate!

## Step 6: Understanding the OAuth Flow (PKCE)

The app uses **OAuth 2.0 PKCE** (Proof Key for Code Exchange):

1. User taps "Login with Spotify"
2. Browser opens Spotify login page
3. User grants permissions
4. Spotify redirects back to app with authorization code
5. App exchanges code for access token
6. App can now call Spotify API endpoints

**Why PKCE?** It's the safest OAuth flow for mobile apps (no client secret exposed).

## Available API Endpoints

Once authenticated, the app can access:

- **User Profile** — Get logged-in user's info
- **Playlists** — Fetch user's playlists
- **Featured Playlists** — Trending playlists for Home screen
- **Search** — Search for tracks, artists, albums, playlists
- **New Releases** — Get latest albums
- **Browse Categories** — Genre browsing
- **Tracks Preview** — 30-second preview URLs (playable without Premium)

**Note:** Full track streaming requires Spotify Premium + Spotify SDK. Preview URLs work for everyone.

## Testing the Integration

When Phase 2.1 implementation is complete:

1. Run the app: `flutter run`
2. When prompted to log in, tap "Login with Spotify"
3. Auth opens your default browser
4. Log in to Spotify
5. Grant permissions
6. App redirects back

If successful, your Home screen will show:
- Featured playlists from Spotify
- New releases
- Your profile info

## Troubleshooting

**"Failed to authenticate"**
- Verify credentials in .env are correct
- Check SPOTIFY_REDIRECT_URL matches your app settings

**"Unauthorized API call"**
- Access token may have expired
- auto-refresh is handled by `ensureValidToken()`

**"Scope error"**
- Make sure all required permissions are granted in Spotify Dashboard
- Revoke app access and re-authenticate

## What's Next?

After setup, Phase 2.1 will:
1. ✅ Authenticate users via OAuth PKCE
2. ✅ Fetch featured playlists to replace hardcoded data
3. ✅ Display user's playlists
4. ✅ Add real-time search functionality
5. ✅ Maintain local cache for offline browsing

---

**Questions?** Check [Spotify Web API Docs](https://developer.spotify.com/documentation/web-api)
