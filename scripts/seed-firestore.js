#!/usr/bin/env node

/**
 * Firestore Database Seeding Script
 * 
 * Populates the Firestore database with initial seed data for playlists,
 * albums, artists, podcasts, and home screen configuration.
 * 
 * Setup Instructions:
 * 1. Download service account key from Firebase Console:
 *    - Go to Project Settings → Service Accounts
 *    - Click "Generate New Private Key"
 *    - Save as serviceAccountKey.json in this scripts/ directory
 * 
 * 2. Install dependencies:
 *    npm install
 * 
 * 3. Run the seed script:
 *    npm run seed
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Configuration
const SERVICE_ACCOUNT_PATH = path.join(__dirname, 'serviceAccountKey.json');
const PROJECT_ID = 'spox-60047';

/**
 * Check if service account key exists
 */
function checkServiceAccountKey() {
  if (!fs.existsSync(SERVICE_ACCOUNT_PATH)) {
    console.error('❌ ERROR: serviceAccountKey.json not found!');
    console.error('');
    console.error('Setup Instructions:');
    console.error('1. Go to Firebase Console: https://console.firebase.google.com/project/spox-60047');
    console.error('2. Click "Project Settings" (gear icon) → "Service Accounts" tab');
    console.error('3. Click "Generate New Private Key"');
    console.error('4. Save the downloaded JSON as:');
    console.error(`   ${SERVICE_ACCOUNT_PATH}`);
    console.error('');
    process.exit(1);
  }
}

/**
 * Initialize Firebase Admin SDK
 */
function initializeFirebase() {
  const serviceAccount = require(SERVICE_ACCOUNT_PATH);
  
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: PROJECT_ID,
  });
  
  return admin.firestore();
}

/**
 * Seed playlists collection
 */
async function seedPlaylists(db) {
  console.log('📝 Seeding playlists...');
  
  const playlists = [
    {
      id: '2010s',
      name: '2010s Mix',
      description: 'The biggest hits from the 2010s',
      coverUrl: 'https://via.placeholder.com/300x300/FF6B6B/FFFFFF?text=2010s+Mix',
      trackCount: 15,
      ownerName: 'Spotify',
      isPlayable: true,
    },
    {
      id: 'chill',
      name: 'Chill Mix',
      description: 'Smooth vibes for relaxation',
      coverUrl: 'https://via.placeholder.com/300x300/4ECDC4/FFFFFF?text=Chill+Mix',
      trackCount: 20,
      ownerName: 'Spotify',
      isPlayable: true,
    },
    {
      id: 'workout',
      name: 'Workout Mix',
      description: 'High energy tracks to pump you up',
      coverUrl: 'https://via.placeholder.com/300x300/95E1D3/FFFFFF?text=Workout',
      trackCount: 18,
      ownerName: 'Spotify',
      isPlayable: true,
    },
    {
      id: 'party',
      name: 'Party Bangers',
      description: 'Ultimate party playlist',
      coverUrl: 'https://via.placeholder.com/300x300/F38181/FFFFFF?text=Party',
      trackCount: 25,
      ownerName: 'Spotify',
      isPlayable: true,
    },
  ];
  
  for (const playlist of playlists) {
    await db.collection('playlists').doc(playlist.id).set(playlist);
    console.log(`  ✓ Added playlist: ${playlist.name}`);
  }
}

/**
 * Seed albums collection
 */
async function seedAlbums(db) {
  console.log('📝 Seeding albums...');
  
  const albums = [
    {
      id: 'album_1',
      name: 'Abbey Road',
      artist: 'The Beatles',
      releaseDate: '1969',
      coverUrl: 'https://via.placeholder.com/300x300/FF7675/FFFFFF?text=Abbey+Road',
      trackCount: 17,
      genre: 'Rock',
    },
    {
      id: 'album_2',
      name: 'Thriller',
      artist: 'Michael Jackson',
      releaseDate: '1982',
      coverUrl: 'https://via.placeholder.com/300x300/FFA502/FFFFFF?text=Thriller',
      trackCount: 9,
      genre: 'Pop',
    },
    {
      id: 'album_3',
      name: 'Rumours',
      artist: 'Fleetwood Mac',
      releaseDate: '1977',
      coverUrl: 'https://via.placeholder.com/300x300/74B9FF/FFFFFF?text=Rumours',
      trackCount: 40,
      genre: 'Rock',
    },
  ];
  
  for (const album of albums) {
    await db.collection('albums').doc(album.id).set(album);
    console.log(`  ✓ Added album: ${album.name}`);
  }
}

/**
 * Seed artists collection
 */
async function seedArtists(db) {
  console.log('📝 Seeding artists...');
  
  const artists = [
    {
      id: 'artist_1',
      name: 'The Beatles',
      profileImageUrl: 'https://via.placeholder.com/200x200/000000/FFFFFF?text=Beatles',
      followers: 8500000,
      genre: 'Rock',
    },
    {
      id: 'artist_2',
      name: 'Michael Jackson',
      profileImageUrl: 'https://via.placeholder.com/200x200/000000/FFFFFF?text=MJ',
      followers: 9200000,
      genre: 'Pop',
    },
    {
      id: 'artist_3',
      name: 'Fleetwood Mac',
      profileImageUrl: 'https://via.placeholder.com/200x200/000000/FFFFFF?text=FM',
      followers: 2100000,
      genre: 'Rock',
    },
  ];
  
  for (const artist of artists) {
    await db.collection('artists').doc(artist.id).set(artist);
    console.log(`  ✓ Added artist: ${artist.name}`);
  }
}

/**
 * Seed podcasts collection
 */
async function seedPodcasts(db) {
  console.log('📝 Seeding podcasts...');
  
  const podcasts = [
    {
      id: 'podcast_1',
      title: 'The Joe Rogan Experience',
      host: 'Joe Rogan',
      description: 'Long-form interviews and conversations',
      coverUrl: 'https://via.placeholder.com/300x300/C0392B/FFFFFF?text=JRE',
      episodeCount: 2000,
      genre: 'Talk',
    },
    {
      id: 'podcast_2',
      title: 'Serial',
      host: 'Serial Productions',
      description: 'Audio journalism and storytelling',
      coverUrl: 'https://via.placeholder.com/300x300/2980B9/FFFFFF?text=Serial',
      episodeCount: 50,
      genre: 'True Crime',
    },
  ];
  
  for (const podcast of podcasts) {
    await db.collection('podcasts').doc(podcast.id).set(podcast);
    console.log(`  ✓ Added podcast: ${podcast.title}`);
  }
}

/**
 * Seed home screen configuration
 */
async function seedHomeScreenConfig(db) {
  console.log('📝 Seeding home screen configuration...');
  
  const config = {
    featuredPlaylists: ['2010s', 'chill', 'workout', 'party'],
    recentlyPlayed: ['album_1', 'artist_2'],
    recommendations: ['album_2', 'podcast_1'],
  };
  
  await db.collection('homeScreenConfig').doc('default').set(config);
  console.log('  ✓ Added home screen configuration');
}

/**
 * Main seed function
 */
async function seed() {
  console.log('\n🌱 Starting Firestore Seed Data Population...\n');
  
  try {
    // Check if service account key exists
    checkServiceAccountKey();
    
    // Initialize Firebase
    const db = initializeFirebase();
    console.log('✓ Connected to Firestore\n');
    
    // Seed all collections
    await seedPlaylists(db);
    console.log('');
    
    await seedAlbums(db);
    console.log('');
    
    await seedArtists(db);
    console.log('');
    
    await seedPodcasts(db);
    console.log('');
    
    await seedHomeScreenConfig(db);
    console.log('');
    
    console.log('✅ Firestore seeding completed successfully!\n');
    process.exit(0);
    
  } catch (error) {
    console.error('❌ Error during seeding:', error.message);
    console.error('\nFull error:', error);
    process.exit(1);
  }
}

// Run the seed function
seed();
