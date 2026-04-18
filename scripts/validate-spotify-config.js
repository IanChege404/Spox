#!/usr/bin/env node

/**
 * Validate Spotify Configuration
 * 
 * This script validates that your Spotify API credentials are correctly
 * configured in the .env file and can successfully authenticate with Spotify.
 * 
 * Usage:
 *   node scripts/validate-spotify-config.js
 */

const fs = require('fs');
const path = require('path');
const https = require('https');

// Colors for console output
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  gray: '\x1b[90m',
};

function log(level, ...args) {
  const timestamp = new Date().toLocaleTimeString();
  const prefix = `[${timestamp}]`;
  
  switch (level) {
    case 'error':
      console.error(`${colors.red}${prefix} ✗ ERROR:${colors.reset}`, ...args);
      break;
    case 'success':
      console.log(`${colors.green}${prefix} ✓${colors.reset}`, ...args);
      break;
    case 'warning':
      console.log(`${colors.yellow}${prefix} ⚠${colors.reset}`, ...args);
      break;
    case 'info':
      console.log(`${colors.blue}${prefix} ℹ${colors.reset}`, ...args);
      break;
    case 'debug':
      console.log(`${colors.gray}${prefix}${colors.reset}`, ...args);
      break;
  }
}

/**
 * Load and parse .env file
 */
function loadEnvFile() {
  const envPath = path.join(__dirname, '..', '.env');
  
  if (!fs.existsSync(envPath)) {
    log('error', `.env file not found at ${envPath}`);
    process.exit(1);
  }
  
  const content = fs.readFileSync(envPath, 'utf8');
  const env = {};
  
  content.split('\n').forEach((line) => {
    const trimmed = line.trim();
    
    // Skip empty lines and comments
    if (!trimmed || trimmed.startsWith('#')) {
      return;
    }
    
    const [key, value] = trimmed.split('=');
    if (key && value) {
      env[key.trim()] = value.trim();
    }
  });
  
  return env;
}

/**
 * Validate client ID format (should be 32 hex characters)
 */
function isValidClientId(id) {
  return /^[a-f0-9]{32}$/.test(id.toLowerCase());
}

/**
 * Validate client secret format (should be 32 hex characters)
 */
function isValidClientSecret(secret) {
  return /^[a-f0-9]{32}$/.test(secret.toLowerCase());
}

/**
 * Validate redirect URL format
 */
function isValidRedirectUrl(url) {
  try {
    new URL(url);
    return true;
  } catch (e) {
    return false;
  }
}

/**
 * Test Spotify API authentication
 */
function testSpotifyAuth(clientId, clientSecret) {
  return new Promise((resolve) => {
    const auth = Buffer.from(`${clientId}:${clientSecret}`).toString('base64');
    const postData = 'grant_type=client_credentials';
    
    const options = {
      hostname: 'accounts.spotify.com',
      path: '/api/token',
      method: 'POST',
      headers: {
        'Authorization': `Basic ${auth}`,
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': Buffer.byteLength(postData),
      },
    };
    
    const req = https.request(options, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          
          if (res.statusCode === 200 && response.access_token) {
            resolve({
              success: true,
              token: response.access_token,
              expiresIn: response.expires_in,
            });
          } else if (res.statusCode === 401) {
            resolve({
              success: false,
              error: 'Invalid credentials (401): Check SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET',
            });
          } else {
            resolve({
              success: false,
              error: `Spotify API error (${res.statusCode}): ${response.error_description || data}`,
            });
          }
        } catch (e) {
          resolve({
            success: false,
            error: `Failed to parse response: ${e.message}`,
          });
        }
      });
    });
    
    req.on('error', (e) => {
      resolve({
        success: false,
        error: `Network error: ${e.message}`,
      });
    });
    
    req.write(postData);
    req.end();
  });
}

/**
 * Validate a Spotify access token with an API call
 */
function testSpotifyToken(token) {
  return new Promise((resolve) => {
    const options = {
      hostname: 'api.spotify.com',
      path: '/v1/me',
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
      },
    };
    
    const req = https.request(options, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          
          if (res.statusCode === 200) {
            resolve({
              success: true,
              user: response.display_name || response.id,
            });
          } else if (res.statusCode === 401) {
            resolve({
              success: false,
              error: 'Token is invalid or expired',
            });
          } else {
            resolve({
              success: false,
              error: `API error: ${response.error?.message || data}`,
            });
          }
        } catch (e) {
          resolve({
            success: false,
            error: `Failed to parse response: ${e.message}`,
          });
        }
      });
    });
    
    req.on('error', (e) => {
      resolve({
        success: false,
        error: `Network error: ${e.message}`,
      });
    });
    
    req.end();
  });
}

/**
 * Main validation function
 */
async function main() {
  log('info', 'Starting Spotify configuration validation...\n');
  
  // Load .env file
  log('info', 'Loading .env file...');
  const env = loadEnvFile();
  log('success', '.env file loaded\n');
  
  let hasErrors = false;
  
  // 1. Validate required fields exist
  log('info', 'Checking required fields...');
  const requiredFields = ['SPOTIFY_CLIENT_ID', 'SPOTIFY_CLIENT_SECRET', 'SPOTIFY_REDIRECT_URL'];
  
  for (const field of requiredFields) {
    if (!env[field]) {
      log('error', `${field} is missing from .env file`);
      hasErrors = true;
    } else {
      log('success', `${field}: ${field === 'SPOTIFY_CLIENT_SECRET' ? '***' : env[field]}`);
    }
  }
  
  if (hasErrors) {
    log('error', '\n❌ Validation failed: Missing required fields');
    process.exit(1);
  }
  
  console.log();
  
  // 2. Validate format
  log('info', 'Validating field formats...');
  
  const { SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, SPOTIFY_REDIRECT_URL } = env;
  
  // Client ID validation
  if (!isValidClientId(SPOTIFY_CLIENT_ID)) {
    log('warning', `SPOTIFY_CLIENT_ID format is unexpected (should be 32 hex chars): ${SPOTIFY_CLIENT_ID}`);
  } else {
    log('success', 'SPOTIFY_CLIENT_ID format is valid');
  }
  
  // Client Secret validation
  if (!isValidClientSecret(SPOTIFY_CLIENT_SECRET)) {
    log('warning', `SPOTIFY_CLIENT_SECRET format is unexpected (should be 32 hex chars)`);
  } else {
    log('success', 'SPOTIFY_CLIENT_SECRET format is valid');
  }
  
  // Redirect URL validation
  if (!isValidRedirectUrl(SPOTIFY_REDIRECT_URL)) {
    log('error', `SPOTIFY_REDIRECT_URL is not a valid URL: ${SPOTIFY_REDIRECT_URL}`);
    hasErrors = true;
  } else {
    log('success', `SPOTIFY_REDIRECT_URL is valid: ${SPOTIFY_REDIRECT_URL}`);
  }
  
  if (hasErrors) {
    log('error', '\n❌ Validation failed: Invalid formats');
    process.exit(1);
  }
  
  console.log();
  
  // 3. Test API authentication
  log('info', 'Testing Spotify API authentication (Client Credentials Flow)...');
  const authResult = await testSpotifyAuth(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET);
  
  if (authResult.success) {
    log('success', 'Successfully authenticated with Spotify API');
    log('debug', `Access token: ${authResult.token.substring(0, 20)}...`);
    log('debug', `Expires in: ${authResult.expiresIn} seconds`);
    
    // Test the token
    log('info', '\nVerifying access token...');
    const tokenResult = await testSpotifyToken(authResult.token);
    
    if (tokenResult.success) {
      log('success', `Token is valid! Authenticated as: ${tokenResult.user}`);
    } else {
      log('warning', `Token verification warning: ${tokenResult.error}`);
    }
  } else {
    log('error', `Authentication failed: ${authResult.error}`);
    hasErrors = true;
  }
  
  console.log();
  
  // 4. Final summary
  if (!hasErrors && authResult.success) {
    log('success', '✅ All validations passed!');
    log('info', 'Your Spotify credentials are correctly configured.');
    log('info', 'You can now use the Spotify API.\n');
    process.exit(0);
  } else {
    log('error', '❌ Validation failed!');
    log('info', '\n📋 Troubleshooting tips:');
    log('info', '1. Verify your SPOTIFY_CLIENT_ID is correct (from developer.spotify.com)');
    log('info', '2. Verify your SPOTIFY_CLIENT_SECRET is correct');
    log('info', '3. Make sure your Spotify app is active and not rate-limited');
    log('info', '4. Check your internet connection\n');
    process.exit(1);
  }
}

// Run validation
main().catch((error) => {
  log('error', 'Unexpected error:', error);
  process.exit(1);
});
