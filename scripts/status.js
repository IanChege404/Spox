#!/usr/bin/env node

/**
 * Firestore Status & Verification Script
 * 
 * Checks:
 * - Service account configuration
 * - Firestore collections populated
 * - Image URLs accessible
 * - Data version and integrity
 * 
 * Usage:
 *   npm run status
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');
const http = require('http');

const SERVICE_ACCOUNT_PATH = path.join(__dirname, 'serviceAccountKey.json');
const PROJECT_ID = 'spox-60047';

/**
 * Initialize Firebase
 */
function initializeFirebase() {
  if (!fs.existsSync(SERVICE_ACCOUNT_PATH)) {
    console.error('❌ serviceAccountKey.json not found');
    return null;
  }

  const serviceAccount = require(SERVICE_ACCOUNT_PATH);

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: PROJECT_ID,
  });

  return admin.firestore();
}

/**
 * Check URL accessibility
 */
function checkUrl(url, timeout = 5000) {
  return new Promise((resolve) => {
    const timer = setTimeout(() => {
      resolve(false);
    }, timeout);

    http
      .get(url, (res) => {
        clearTimeout(timer);
        resolve(res.statusCode >= 200 && res.statusCode < 400);
      })
      .on('error', () => {
        clearTimeout(timer);
        resolve(false);
      });
  });
}

/**
 * Get collection stats
 */
async function getCollectionStats(db) {
  const collections = {
    playlists: 0,
    albums: 0,
    artists: 0,
    podcasts: 0,
  };

  for (const [collectionName, count] of Object.entries(collections)) {
    try {
      const snapshot = await db.collection(collectionName).get();
      collections[collectionName] = snapshot.size;
    } catch (e) {
      collections[collectionName] = 'ERROR';
    }
  }

  return collections;
}

/**
 * Get seed version info
 */
async function getSeedInfo(db) {
  try {
    const doc = await db
      .collection('_metadata')
      .doc('seed_version')
      .get();

    if (doc.exists) {
      const data = doc.data();
      return {
        version: data.version,
        lastSeeded: data.last_seeded?.toDate?.(),
        appVersion: data.app_version,
      };
    }

    return null;
  } catch (e) {
    return null;
  }
}

/**
 * Check image URLs
 */
async function checkImageUrls(db) {
  try {
    const snapshot = await db
      .collection('playlists')
      .limit(2)
      .get();

    const results = {
      playlists: [],
      albums: [],
      artists: [],
    };

    for (const doc of snapshot.docs) {
      const data = doc.data();
      if (data.coverUrl) {
        const accessible = await checkUrl(data.coverUrl);
        results.playlists.push({
          name: data.name,
          url: data.coverUrl.substring(0, 50) + '...',
          accessible,
        });
      }
    }

    return results;
  } catch (e) {
    return null;
  }
}

/**
 * Print status report
 */
function printReport(stats, seedInfo, imageUrls) {
  console.log('\n' + '='.repeat(60));
  console.log('📊 Firestore Status Report');
  console.log('='.repeat(60) + '\n');

  // Collections
  console.log('📁 Collections:');
  console.log(`  Playlists: ${stats.playlists} documents`);
  console.log(`  Albums:    ${stats.albums} documents`);
  console.log(`  Artists:   ${stats.artists} documents`);
  console.log(`  Podcasts:  ${stats.podcasts} documents`);
  console.log('');

  // Seed info
  console.log('🌱 Seed Data:');
  if (seedInfo) {
    console.log(`  Version:     v${seedInfo.version}`);
    console.log(
      `  Last seeded: ${seedInfo.lastSeeded ? seedInfo.lastSeeded.toLocaleString() : 'N/A'}`
    );
    console.log(`  App version: ${seedInfo.appVersion || 'N/A'}`);
  } else {
    console.log('  ⚠️  No seed metadata found');
  }
  console.log('');

  // Totals
  const total = stats.playlists + stats.albums + stats.artists + stats.podcasts;
  console.log(`📈 Total documents: ${total}`);
  console.log('');

  // Image checks
  if (imageUrls && imageUrls.playlists.length > 0) {
    console.log('🖼️  Image URLs:');
    imageUrls.playlists.forEach((img) => {
      const status = img.accessible ? '✓' : '✗';
      console.log(`  ${status} ${img.name}`);
    });
  }

  console.log('\n' + '='.repeat(60) + '\n');

  // Status summary
  const isReady = total > 0 && seedInfo !== null;
  if (isReady) {
    console.log('✅ Status: READY FOR TESTING');
    console.log('   Your Firestore database is populated and ready.\n');
  } else {
    console.log('⚠️  Status: NEEDS SETUP');
    console.log('   Run: npm run populate\n');
  }
}

/**
 * Main
 */
async function main() {
  try {
    console.log('🔥 Checking Firestore Status...\n');

    const db = initializeFirebase();
    if (!db) {
      process.exit(1);
    }

    console.log('📋 Gathering data...\n');
    const stats = await getCollectionStats(db);
    const seedInfo = await getSeedInfo(db);
    const imageUrls = await checkImageUrls(db);

    printReport(stats, seedInfo, imageUrls);

    // Disconnect
    await admin.app().delete();

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

main();
