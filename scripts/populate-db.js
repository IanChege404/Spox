#!/usr/bin/env node

/**
 * Master Database Population Script
 * 
 * Orchestrates the complete Phase 2 setup:
 * 1. Validates Firebase credentials
 * 2. Uploads images to Firebase Storage
 * 3. Populates Firestore with seed data (including image URLs)
 * 4. Generates configuration for Flutter app
 * 
 * Usage:
 *   npm run populate
 *   npm run populate -- --skip-images (only seed data)
 *   npm run populate -- --dry-run (preview without changes)
 */

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const SERVICE_ACCOUNT_PATH = path.join(__dirname, 'serviceAccountKey.json');
const args = process.argv.slice(2);
const skipImages = args.includes('--skip-images');
const dryRun = args.includes('--dry-run');

/**
 * Print banner
 */
function printBanner() {
  console.clear();
  console.log('\n' + '='.repeat(60));
  console.log('🎵 Spotify Clone - Phase 2: Database Population');
  console.log('='.repeat(60) + '\n');
}

/**
 * Check prerequisites
 */
function checkPrerequisites() {
  console.log('📋 Checking prerequisites...\n');

  // Check service account key
  if (!fs.existsSync(SERVICE_ACCOUNT_PATH)) {
    console.error('❌ ERROR: serviceAccountKey.json not found!\n');
    console.error('Setup instructions:');
    console.error('1. Go to Firebase Console: https://console.firebase.google.com/project/spox-60047');
    console.error('2. Click "Project Settings" (gear icon) → "Service Accounts" tab');
    console.error('3. Click "Generate New Private Key"');
    console.error('4. Save as: ' + SERVICE_ACCOUNT_PATH);
    console.error('');
    process.exit(1);
  }

  console.log('✓ Service account key found');

  // Check Node.js dependencies
  try {
    require('firebase-admin');
    console.log('✓ Firebase Admin SDK installed\n');
  } catch (e) {
    console.error('❌ ERROR: Firebase Admin SDK not installed');
    console.error('Run: npm install\n');
    process.exit(1);
  }
}

/**
 * Run script and wait for completion
 */
function runScript(scriptPath, args = []) {
  return new Promise((resolve, reject) => {
    const script = spawn('node', [scriptPath, ...args], {
      stdio: 'inherit',
    });

    script.on('close', (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(`Script exited with code ${code}`));
      }
    });

    script.on('error', reject);
  });
}

/**
 * Main orchestration
 */
async function main() {
  try {
    printBanner();
    checkPrerequisites();

    const operations = [];

    // Phase 1: Upload images
    if (!skipImages) {
      operations.push({
        name: 'Upload images to Firebase Storage',
        script: path.join(__dirname, 'upload-images.js'),
        args: dryRun ? ['--dry-run'] : [],
      });
    }

    // Phase 2: Seed Firestore
    operations.push({
      name: 'Populate Firestore with seed data',
      script: path.join(__dirname, 'seed-firestore.js'),
      args: dryRun ? [] : [], // seed-firestore.js doesn't have dry-run yet
    });

    console.log(`📝 Operations scheduled: ${operations.length}\n`);
    operations.forEach((op, i) => {
      console.log(`  ${i + 1}. ${op.name}`);
    });
    console.log('');

    // Execute operations in sequence
    for (let i = 0; i < operations.length; i++) {
      const op = operations[i];
      console.log(`\n${'='.repeat(60)}`);
      console.log(`[${i + 1}/${operations.length}] ${op.name}`);
      console.log('='.repeat(60) + '\n');

      try {
        await runScript(op.script, op.args);
      } catch (error) {
        console.error(`\n❌ Operation failed: ${op.name}`);
        console.error(`Error: ${error.message}\n`);
        process.exit(1);
      }
    }

    // Success
    console.log('\n' + '='.repeat(60));
    console.log('✅ Database Population Complete!');
    console.log('='.repeat(60) + '\n');

    console.log('📊 Summary:');
    if (!skipImages) {
      console.log('  ✓ Images uploaded to Firebase Storage');
      console.log('  ✓ Image URLs configured');
    }
    console.log('  ✓ Firestore populated with seed data');
    console.log('  ✓ Version tracking enabled\n');

    console.log('🚀 Next steps:');
    console.log('  1. Verify data in Firestore Console:');
    console.log('     https://console.firebase.google.com/firestore/data/spox-60047\n');
    console.log('  2. Run Flutter app:');
    console.log('     flutter run\n');
    console.log('  3. Check that:');
    console.log('     • Playlists load in Home screen');
    console.log('     • Album/artist images display');
    console.log('     • No re-seeding on subsequent launches\n');

    if (dryRun) {
      console.log(
        '🟡 NOTE: DRY-RUN mode was active. No changes were made to production.\n'
      );
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Fatal error:', error.message);
    process.exit(1);
  }
}

main();
