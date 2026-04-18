#!/usr/bin/env node

/**
 * Get a valid Spotify access token for testing on emulator
 * This uses Client Credentials flow to get a token that works with Spotify API
 * 
 * Usage: node scripts/get-test-token.js
 */

const http = require('http');
const https = require('https');
const dotenv = require('dotenv');
const path = require('path');

// Load .env from parent directory
dotenv.config({ path: path.join(__dirname, '../.env') });

const SPOTIFY_CLIENT_ID = process.env.SPOTIFY_CLIENT_ID;
const SPOTIFY_CLIENT_SECRET = process.env.SPOTIFY_CLIENT_SECRET;

if (!SPOTIFY_CLIENT_ID || !SPOTIFY_CLIENT_SECRET) {
  console.error('❌ Error: SPOTIFY_CLIENT_ID or SPOTIFY_CLIENT_SECRET not found in .env');
  process.exit(1);
}

async function getAccessToken() {
  return new Promise((resolve, reject) => {
    const auth = Buffer.from(`${SPOTIFY_CLIENT_ID}:${SPOTIFY_CLIENT_SECRET}`).toString('base64');
    
    const postData = 'grant_type=client_credentials';
    
    const options = {
      hostname: 'accounts.spotify.com',
      port: 443,
      path: '/api/token',
      method: 'POST',
      headers: {
        'Authorization': `Basic ${auth}`,
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': Buffer.byteLength(postData),
      }
    };

    const req = https.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        if (res.statusCode === 200) {
          try {
            const parsed = JSON.parse(data);
            resolve(parsed);
          } catch (e) {
            reject(new Error('Failed to parse token response'));
          }
        } else {
          reject(new Error(`HTTP ${res.statusCode}: ${data}`));
        }
      });
    });

    req.on('error', reject);
    req.write(postData);
    req.end();
  });
}

async function main() {
  console.log('\n🎵 Spotify Test Token Generator\n');
  console.log('Requesting access token from Spotify API...\n');

  try {
    const response = await getAccessToken();
    
    console.log('✅ Successfully obtained access token:\n');
    console.log(`Access Token: ${response.access_token}`);
    console.log(`Token Type: ${response.token_type}`);
    console.log(`Expires In: ${response.expires_in} seconds (${Math.round(response.expires_in / 60)} minutes)\n`);
    
    console.log('📝 To use this token in test mode:\n');
    console.log('1. Open: lib/ui/spotify_login_screen.dart');
    console.log('2. Find: _skipLoginForDevelopment() method');
    console.log('3. Uncomment and replace YOUR_VALID_SPOTIFY_ACCESS_TOKEN_HERE with:\n');
    console.log(`   _authService.enableTestMode('${response.access_token}');\n`);
    console.log('4. Run: flutter run\n');
    
    console.log('⚠️  Note: This token expires in', response.expires_in, 'seconds.');
    console.log('   Run this script again when the token expires.\n');
    
  } catch (error) {
    console.error('❌ Error getting access token:', error.message);
    process.exit(1);
  }
}

main();
