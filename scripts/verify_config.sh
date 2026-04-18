#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$PROJECT_DIR/.env"
FIREBASE_CONFIG="$PROJECT_DIR/lib/firebase_options.dart"

echo ""
echo "========================================================================"
echo "🔍 SPOTIFY CLONE - CONFIGURATION VERIFICATION SCRIPT"
echo "========================================================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counter for issues
ISSUES=0

# ============================================================================
# 1. CHECK .env FILE EXISTS
# ============================================================================
echo -e "${BLUE}1️⃣  Checking .env file exists...${NC}"
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}✗ .env file not found at $ENV_FILE${NC}"
    echo "  Please create it by copying .env.example"
    exit 1
else
    echo -e "${GREEN}✓ .env file found${NC}"
fi

echo ""

# ============================================================================
# 2. VERIFY SPOTIFY CREDENTIALS
# ============================================================================
echo -e "${BLUE}2️⃣  Verifying Spotify Configuration...${NC}"

# Helper function to extract env value
get_env_value() {
    grep "^${1}=" "$ENV_FILE" | cut -d'=' -f2 || echo ""
}

SPOTIFY_CLIENT_ID=$(get_env_value "SPOTIFY_CLIENT_ID")
SPOTIFY_CLIENT_SECRET=$(get_env_value "SPOTIFY_CLIENT_SECRET")
SPOTIFY_REDIRECT_URL=$(get_env_value "SPOTIFY_REDIRECT_URL")

# Validate Client ID
if [ -z "$SPOTIFY_CLIENT_ID" ] || [ "$SPOTIFY_CLIENT_ID" = "YOUR_SPOTIFY_CLIENT_ID" ]; then
    echo -e "${RED}✗ SPOTIFY_CLIENT_ID: Missing or not configured${NC}"
    ISSUES=$((ISSUES+1))
elif [ ${#SPOTIFY_CLIENT_ID} -lt 20 ]; then
    echo -e "${RED}✗ SPOTIFY_CLIENT_ID: Looks invalid (too short: ${#SPOTIFY_CLIENT_ID} chars)${NC}"
    ISSUES=$((ISSUES+1))
else
    echo -e "${GREEN}✓ SPOTIFY_CLIENT_ID: Valid (${SPOTIFY_CLIENT_ID:0:10}***)${NC}"
fi

# Validate Client Secret
if [ -z "$SPOTIFY_CLIENT_SECRET" ] || [ "$SPOTIFY_CLIENT_SECRET" = "YOUR_SPOTIFY_CLIENT_SECRET" ]; then
    echo -e "${RED}✗ SPOTIFY_CLIENT_SECRET: Missing or not configured${NC}"
    ISSUES=$((ISSUES+1))
elif [ ${#SPOTIFY_CLIENT_SECRET} -lt 20 ]; then
    echo -e "${RED}✗ SPOTIFY_CLIENT_SECRET: Looks invalid (too short: ${#SPOTIFY_CLIENT_SECRET} chars)${NC}"
    ISSUES=$((ISSUES+1))
else
    echo -e "${GREEN}✓ SPOTIFY_CLIENT_SECRET: Valid (${SPOTIFY_CLIENT_SECRET:0:10}***)${NC}"
fi

# Validate Redirect URL
if [ -z "$SPOTIFY_REDIRECT_URL" ]; then
    echo -e "${RED}✗ SPOTIFY_REDIRECT_URL: Missing${NC}"
    ISSUES=$((ISSUES+1))
elif [[ ! "$SPOTIFY_REDIRECT_URL" =~ "spotify.clone" ]] && [[ ! "$SPOTIFY_REDIRECT_URL" =~ "com.spotify" ]]; then
    echo -e "${YELLOW}⚠ SPOTIFY_REDIRECT_URL: Looks unusual ($SPOTIFY_REDIRECT_URL)${NC}"
else
    echo -e "${GREEN}✓ SPOTIFY_REDIRECT_URL: $SPOTIFY_REDIRECT_URL${NC}"
fi

echo ""

# ============================================================================
# 3. VERIFY API ENDPOINTS
# ============================================================================
echo -e "${BLUE}3️⃣  Verifying API Endpoints...${NC}"

API_BASE_URL=$(get_env_value "API_BASE_URL")
AUTH_BASE_URL=$(get_env_value "AUTH_BASE_URL")
LRCLIB_API_URL=$(get_env_value "LRCLIB_API_URL")

if [[ "$API_BASE_URL" =~ "api.spotify.com" ]]; then
    echo -e "${GREEN}✓ API_BASE_URL: $API_BASE_URL${NC}"
else
    echo -e "${RED}✗ API_BASE_URL: Invalid or missing${NC}"
    ISSUES=$((ISSUES+1))
fi

if [[ "$AUTH_BASE_URL" =~ "accounts.spotify.com" ]]; then
    echo -e "${GREEN}✓ AUTH_BASE_URL: $AUTH_BASE_URL${NC}"
else
    echo -e "${RED}✗ AUTH_BASE_URL: Invalid or missing${NC}"
    ISSUES=$((ISSUES+1))
fi

if [[ "$LRCLIB_API_URL" =~ "lrclib" ]]; then
    echo -e "${GREEN}✓ LRCLIB_API_URL: $LRCLIB_API_URL${NC}"
else
    echo -e "${YELLOW}⚠ LRCLIB_API_URL: Not configured (lyrics sync may not work)${NC}"
fi

echo ""

# ============================================================================
# 4. VERIFY FIREBASE CONFIGURATION
# ============================================================================
echo -e "${BLUE}4️⃣  Verifying Firebase Configuration...${NC}"

if [ ! -f "$FIREBASE_CONFIG" ]; then
    echo -e "${RED}✗ firebase_options.dart not found${NC}"
    echo "  Run: flutterfire configure"
    ISSUES=$((ISSUES+1))
else
    if grep -q "projectId: 'spox-60047'" "$FIREBASE_CONFIG"; then
        echo -e "${GREEN}✓ Firebase Project ID: spox-60047${NC}"
    else
        echo -e "${YELLOW}⚠ Firebase Project ID: Different or missing${NC}"
    fi

    # Check for platform configs
    PLATFORMS=("android" "ios" "macos" "web" "windows")
    for platform in "${PLATFORMS[@]}"; do
        if grep -q "$platform" "$FIREBASE_CONFIG"; then
            echo -e "${GREEN}✓ $platform: Configured${NC}"
        else
            echo -e "${YELLOW}⚠ $platform: Not configured${NC}"
        fi
    done
fi

echo ""

# ============================================================================
# 5. VERIFY FEATURE FLAGS
# ============================================================================
echo -e "${BLUE}5️⃣  Verifying Feature Flags...${NC}"

OFFLINE_MODE=$(get_env_value "ENABLE_OFFLINE_MODE")
LYRICS_SYNC=$(get_env_value "ENABLE_LYRICS_SYNC")
STATS_PAGE=$(get_env_value "ENABLE_STATS_PAGE")
EQUALIZER=$(get_env_value "ENABLE_EQUALIZER")

echo "  Offline Mode: $OFFLINE_MODE"
echo "  Lyrics Sync: $LYRICS_SYNC"
echo "  Stats Page: $STATS_PAGE"
echo "  Equalizer: $EQUALIZER"

echo ""

# ============================================================================
# 6. VERIFY STORAGE PATHS
# ============================================================================
echo -e "${BLUE}6️⃣  Verifying Storage Configuration...${NC}"

CACHE_DIR=$(get_env_value "CACHE_DIR")
DOWNLOADS_DIR=$(get_env_value "DOWNLOADS_DIR")
LOGS_DIR=$(get_env_value "LOGS_DIR")

if [ -n "$CACHE_DIR" ]; then
    echo -e "${GREEN}✓ CACHE_DIR: $CACHE_DIR${NC}"
else
    echo -e "${YELLOW}⚠ CACHE_DIR: Not configured${NC}"
fi

if [ -n "$DOWNLOADS_DIR" ]; then
    echo -e "${GREEN}✓ DOWNLOADS_DIR: $DOWNLOADS_DIR${NC}"
else
    echo -e "${YELLOW}⚠ DOWNLOADS_DIR: Not configured${NC}"
fi

if [ -n "$LOGS_DIR" ]; then
    echo -e "${GREEN}✓ LOGS_DIR: $LOGS_DIR${NC}"
else
    echo -e "${YELLOW}⚠ LOGS_DIR: Not configured${NC}"
fi

echo ""

# ============================================================================
# 7. FINAL SUMMARY
# ============================================================================
echo "========================================================================"
echo -e "${BLUE}📊 VERIFICATION SUMMARY${NC}"
echo "========================================================================"
echo ""

if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}✓ All critical checks passed!${NC}"
    echo ""
    echo "Status: READY FOR DEVELOPMENT ✓"
    exit 0
else
    echo -e "${RED}✗ Found $ISSUES critical issue(s)${NC}"
    echo ""
    echo "Status: NEEDS FIXES ✗"
    echo ""
    echo "Next steps:"
    echo "  1. Update .env with your Spotify credentials"
    echo "  2. Run: flutterfire configure (if Firebase setup needed)"
    echo "  3. Run this script again to verify"
    exit 1
fi
