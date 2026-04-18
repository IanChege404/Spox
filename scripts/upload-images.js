#!/usr/bin/env node

/**
 * Firebase Storage Image Upload Script
 * 
 * Uploads images from the /images directory to Firebase Storage
 * and generates URLs for use in Firestore seed data
 * 
 * Images are organized as:
 * - playlists/{playlist-id}/cover.jpg
 * - albums/{album-id}/cover.jpg
 * - artists/{artist-id}/image.jpg
 * 
 * Usage:
 *   npm run upload-images
 *   npm run upload-images -- --force  (re-upload existing files)
 *   npm run upload-images -- --dry-run (shows what would be uploaded)
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const SERVICE_ACCOUNT_PATH = path.join(__dirname, 'serviceAccountKey.json');
const PROJECT_ID = 'spox-60047';
const IMAGES_DIR = path.join(__dirname, '../images');

// Parse command line args
const args = process.argv.slice(2);
const isDryRun = args.includes('--dry-run');
const isForce = args.includes('--force');

/**
 * Initialize Firebase Admin SDK
 */
function initializeFirebase() {
  if (!fs.existsSync(SERVICE_ACCOUNT_PATH)) {
    console.error('❌ serviceAccountKey.json not found!');
    console.error(`Expected at: ${SERVICE_ACCOUNT_PATH}`);
    process.exit(1);
  }

  const serviceAccount = require(SERVICE_ACCOUNT_PATH);

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: PROJECT_ID,
    storageBucket: `${PROJECT_ID}.appspot.com`,
  });

  return admin.storage().bucket();

  return admin.storage().bucket();
}

/**
 * Map image files to Firebase Storage paths
 */
const imageMapping = {
  // Playlists
  'images/home/2010s-Mix.jpg': 'playlists/2010s/cover.jpg',
  'images/home/Chill-Mix.jpg': 'playlists/chill/cover.jpg',
  'images/home/Upbeat-Mix.jpg': 'playlists/upbeat/cover.jpg',
  'images/home/Drake-Mix.jpg': 'playlists/drake-mix/cover.jpg',

  // Albums
  'images/artists/Drake-For-All-The-Dogs.jpg': 'albums/drake-for-all-the-dogs/cover.jpg',
  'images/artists/Travis-Scott-Utopia.jpg': 'albums/travis-scott-utopia/cover.jpg',
  'images/artists/Post-Malone-Austin.jpg': 'albums/post-malone-austin/cover.jpg',
  'images/artists/21-Savage-American-Dream.jpg': 'albums/21-savage-american-dream/cover.jpg',

  // Artists (sample - expand as needed)
  'images/artists/Drake.jpg': 'artists/drake/image.jpg',
  'images/artists/Travis-Scott.jpg': 'artists/travis-scott/image.jpg',
  'images/artists/Post-Malone.jpg': 'artists/post-malone/image.jpg',
  'images/artists/21-Savage.jpg': 'artists/21-savage/image.jpg',
  'images/artists/Adele.jpg': 'artists/adele/image.jpg',
  'images/artists/Kanye-West.jpg': 'artists/kanye-west/image.jpg',
};

/**
 * Generate Firebase Storage URL for uploaded file
 */
function getStorageUrl(storagePath) {
  return `https://firebasestorage.googleapis.com/v0/b/${PROJECT_ID}.appspot.com/o/${encodeURIComponent(storagePath)}?alt=media`;
}

/**
 * Upload images to Firebase Storage
 */
async function uploadImages(storageBucket) {
  console.log('🚀 Starting image upload to Firebase Storage...\n');

  const results = {
    uploaded: [],
    skipped: [],
    failed: [],
  };

  for (const [localPath, storagePath] of Object.entries(imageMapping)) {
    const fullLocalPath = path.join(__dirname, '..', localPath);

    // Check if local file exists
    if (!fs.existsSync(fullLocalPath)) {
      console.warn(`⚠️  SKIP: ${localPath} (file not found)`);
      results.skipped.push({
        local: localPath,
        storage: storagePath,
        reason: 'File not found',
      });
      continue;
    }

    try {
      if (isDryRun) {
        console.log(`📋 DRY-RUN: Would upload ${localPath} → ${storagePath}`);
        results.uploaded.push({ local: localPath, storage: storagePath });
        continue;
      }

      // Check if file already exists (unless --force)
      const [exists] = await storageBucket.file(storagePath).exists();
      if (exists && !isForce) {
        console.log(`✓ EXISTS: ${storagePath} (use --force to re-upload)`);
        results.skipped.push({
          local: localPath,
          storage: storagePath,
          reason: 'Already exists',
        });
        continue;
      }

      // Upload file
      await storageBucket.upload(fullLocalPath, {
        destination: storagePath,
        metadata: {
          cacheControl: 'public, max-age=31536000', // 1 year cache
          contentType: 'image/jpeg',
        },
      });

      const url = getStorageUrl(storagePath);
      console.log(`✓ UPLOAD: ${localPath}`);
      console.log(`  → ${storagePath}`);
      console.log(`  → URL: ${url}\n`);

      results.uploaded.push({
        local: localPath,
        storage: storagePath,
        url,
      });
    } catch (error) {
      console.error(`✗ FAILED: ${localPath}`);
      console.error(`  Error: ${error.message}\n`);
      results.failed.push({
        local: localPath,
        storage: storagePath,
        error: error.message,
      });
    }
  }

  return results;
}

/**
 * Generate mapping config file for ImageService
 */
function generateMappingConfig(results) {
  const config = {
    version: 1,
    storageBase: `https://firebasestorage.googleapis.com/v0/b/${PROJECT_ID}.appspot.com/o`,
    mappings: {},
    uploadedAt: new Date().toISOString(),
  };

  // Build mappings from uploaded images
  for (const item of results.uploaded) {
    if (item.url) {
      // Extract relative path for local->storage mapping
      const relativeLocal = item.local.replace('images/', '');
      config.mappings[`images/${relativeLocal}`] = item.storage;
    }
  }

  // Save to file for reference
  const configPath = path.join(__dirname, 'image-storage-mapping.json');
  fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
  console.log(`\n📄 Mapping config saved to: ${configPath}`);

  return config;
}

/**
 * Print summary report
 */
function printSummary(results) {
  console.log('\n' + '='.repeat(60));
  console.log('📊 Upload Summary');
  console.log('='.repeat(60));
  console.log(`✓ Uploaded: ${results.uploaded.length}`);
  console.log(`⊘ Skipped:  ${results.skipped.length}`);
  console.log(`✗ Failed:   ${results.failed.length}`);
  console.log('='.repeat(60) + '\n');

  if (results.failed.length > 0) {
    console.log('Failed uploads:');
    results.failed.forEach((item) => {
      console.log(`  - ${item.local}: ${item.error}`);
    });
  }

  if (isDryRun) {
    console.log('🟡 DRY-RUN mode: No files were actually uploaded');
  }

  console.log(
    '\n✅ Next step: Run "npm run seed:with-urls" to populate Firestore with image URLs\n'
  );
}

/**
 * Main
 */
async function main() {
  try {
    console.log('🔥 Firebase Storage Image Uploader');
    console.log('==================================\n');

    if (isDryRun) {
      console.log('🟡 DRY-RUN MODE - No files will be uploaded\n');
    }

    const storageBucket = initializeFirebase();
    const results = await uploadImages(storageBucket);

    generateMappingConfig(results);
    printSummary(results);

    process.exit(results.failed.length > 0 ? 1 : 0);
  } catch (error) {
    console.error('❌ Fatal error:', error.message);
    process.exit(1);
  }
}

main();
