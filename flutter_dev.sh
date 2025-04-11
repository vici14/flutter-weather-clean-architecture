#!/bin/bash

# Flutter Development Shortcuts
# Author: Chau Viet Cuong

# Color codes for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print header
echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}    Flutter Development Shortcuts   ${NC}"
echo -e "${BLUE}====================================${NC}"

# Function to show help/usage
show_help() {
    echo -e "${YELLOW}Usage:${NC}"
    echo -e "  ${GREEN}./flutter_dev.sh${NC} ${YELLOW}<command>${NC}"
    echo
    echo -e "${YELLOW}Available commands:${NC}"
    echo -e "  ${GREEN}clean${NC}        - Clean the project"
    echo -e "  ${GREEN}get${NC}          - Get dependencies"
    echo -e "  ${GREEN}upgrade${NC}      - Upgrade dependencies"
    echo -e "  ${GREEN}build${NC}        - Run build_runner once"
    echo -e "  ${GREEN}watch${NC}        - Run build_runner in watch mode"
    echo -e "  ${GREEN}analyze${NC}      - Analyze the project"
    echo -e "  ${GREEN}test${NC}         - Run tests"
    echo -e "  ${GREEN}format${NC}       - Format code"
    echo -e "  ${GREEN}pub-get${NC}      - Clean and get dependencies"
    echo -e "  ${GREEN}build-apk${NC}    - Build Android APK"
    echo -e "  ${GREEN}build-appbundle${NC} - Build Android App Bundle"
    echo -e "  ${GREEN}build-ios${NC}    - Build iOS"
    echo -e "  ${GREEN}build-web${NC}    - Build web"
    echo -e "  ${GREEN}doctor${NC}       - Run Flutter doctor"
    echo -e "  ${GREEN}devices${NC}      - List connected devices"
    echo -e "  ${GREEN}launch-android${NC} - Launch on Android device/emulator"
    echo -e "  ${GREEN}launch-ios${NC}   - Launch on iOS simulator"
    echo
}

# Function to execute command with nice output
run_cmd() {
    echo -e "${YELLOW}Running:${NC} $1"
    echo -e "${BLUE}-----------------------------------${NC}"
    eval "$1"
    local status=$?
    echo -e "${BLUE}-----------------------------------${NC}"
    if [ $status -eq 0 ]; then
        echo -e "${GREEN}✓ Command completed successfully${NC}"
    else
        echo -e "${RED}✗ Command failed with status $status${NC}"
    fi
    echo
    return $status
}

# Handle commands
case "$1" in
    "clean")
        run_cmd "flutter clean"
        ;;
    "get")
        run_cmd "flutter pub get"
        ;;
    "upgrade")
        run_cmd "flutter pub upgrade"
        ;;
    "build")
        run_cmd "flutter pub run build_runner build --delete-conflicting-outputs"
        ;;
    "watch")
        run_cmd "flutter pub run build_runner watch --delete-conflicting-outputs"
        ;;
    "analyze")
        run_cmd "flutter analyze"
        ;;
    "test")
        run_cmd "flutter test"
        ;;
    "format")
        run_cmd "dart format lib test"
        ;;
    "pub-get")
        run_cmd "flutter clean && flutter pub get"
        ;;
    "build-apk")
        run_cmd "flutter build apk --release"
        ;;
    "build-appbundle")
        run_cmd "flutter build appbundle --release"
        ;;
    "build-ios")
        run_cmd "flutter build ios --release --no-codesign"
        ;;
    "build-web")
        run_cmd "flutter build web --release"
        ;;
    "doctor")
        run_cmd "flutter doctor -v"
        ;;
    "devices")
        run_cmd "flutter devices"
        ;;
    "launch-android")
        run_cmd "flutter run -d android"
        ;;
    "launch-ios")
        run_cmd "flutter run -d ios"
        ;;
    *)
        show_help
        ;;
esac 