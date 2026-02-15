#!/bin/bash

# Barbcut Local Development Startup Script
# This script coordinates Firebase emulators and data migration

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Barbcut Local Development Setup     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if we're in the root directory
if [ ! -f "turbo.json" ]; then
    echo -e "${RED}❌ Error: Please run this script from the monorepo root${NC}"
    exit 1
fi

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}❌ Firebase CLI not found. Installing...${NC}"
    npm install -g firebase-tools
fi

# Check if Node.js is available
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is required but not installed${NC}"
    exit 1
fi

echo -e "${YELLOW}📦 Installing dependencies...${NC}"
npm install

echo ""
echo -e "${BLUE}🔥 Starting Firebase Emulators...${NC}"
echo -e "${YELLOW}   This will start:${NC}"
echo -e "   - Auth Emulator (port 9099)"
echo -e "   - Firestore Emulator (port 8081)"
echo -e "   - Storage Emulator (port 9199)"
echo -e "   - Functions Emulator (port 5001)"
echo -e "   - Emulator UI (http://127.0.0.1:4000)"
echo ""

# Start Firebase emulators in background
cd firebase
mkdir -p emulator-data
firebase emulators:start --import=./emulator-data --export-on-exit=./emulator-data &
EMULATOR_PID=$!
cd ..

cleanup() {
    if [ -n "${EMULATOR_PID:-}" ] && kill -0 "$EMULATOR_PID" 2>/dev/null; then
        echo -e "${YELLOW}🛑 Stopping emulators to export data...${NC}"
        kill -SIGINT "$EMULATOR_PID" 2>/dev/null || true
        wait "$EMULATOR_PID" 2>/dev/null || true
    fi
    rm -f .emulator.pid
}

trap cleanup INT TERM EXIT

echo -e "${YELLOW}⏳ Waiting for emulators to be ready...${NC}"

# Wait for emulators to start (check Firestore emulator)
MAX_WAIT=60
WAIT_COUNT=0
until curl -s http://127.0.0.1:8081 > /dev/null 2>&1; do
    sleep 2
    WAIT_COUNT=$((WAIT_COUNT + 2))
    if [ $WAIT_COUNT -ge $MAX_WAIT ]; then
        echo -e "${RED}❌ Emulators failed to start within ${MAX_WAIT}s${NC}"
        kill $EMULATOR_PID 2>/dev/null || true
        exit 1
    fi
    echo -e "${YELLOW}   Waiting... (${WAIT_COUNT}s)${NC}"
done

echo -e "${GREEN}✅ Emulators are ready!${NC}"
echo ""

# Check if data already exists
if [ -d "firebase/emulator-data" ]; then
    echo -e "${GREEN}✅ Emulator data found - using persisted data${NC}"
    echo -e "${YELLOW}   To reset data, run: npm run emulator:migrate${NC}"
else
    echo -e "${YELLOW}📊 No persisted data found. Running initial migration...${NC}"
    cd firebase/functions
    npm run migrate:data:local:clear
    cd ../..
    echo -e "${GREEN}✅ Migration complete!${NC}"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  🎉 Local Environment Ready!           ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📍 Open in your browser:${NC}"
echo -e "   Emulator UI: ${GREEN}http://127.0.0.1:4000${NC}"
echo ""
echo -e "${BLUE}📱 To run the Flutter app:${NC}"
echo -e "   ${YELLOW}cd apps/barbcut${NC}"
echo -e "   ${YELLOW}flutter run${NC}"
echo ""
echo -e "${BLUE}🔄 To re-migrate data:${NC}"
echo -e "   ${YELLOW}npm run emulator:migrate${NC}"
echo ""
echo -e "${BLUE}🛑 To stop emulators:${NC}"
echo -e "   ${YELLOW}Press Ctrl+C or kill process: $EMULATOR_PID${NC}"
echo ""
echo -e "${YELLOW}ℹ️  Emulator data will persist between restarts${NC}"
echo ""

# Save PID for cleanup
echo $EMULATOR_PID > .emulator.pid

# Wait for emulators (keeps script running)
wait $EMULATOR_PID
