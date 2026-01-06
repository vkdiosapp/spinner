#!/bin/bash

# App Icon Generator Script for iOS
# This script generates all required iOS app icon sizes from a single 1024x1024 source image

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}iOS App Icon Generator${NC}"
echo "================================"
echo ""

# Check if source image is provided
if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage: ./generate_app_icons.sh <path-to-1024x1024-icon.png>${NC}"
    echo ""
    echo "Example: ./generate_app_icons.sh my-icon.png"
    echo ""
    echo "The script will generate all required iOS app icon sizes and place them in:"
    echo "ios/Runner/Assets.xcassets/AppIcon.appiconset/"
    exit 1
fi

SOURCE_IMAGE="$1"
OUTPUT_DIR="ios/Runner/Assets.xcassets/AppIcon.appiconset"

# Check if source image exists
if [ ! -f "$SOURCE_IMAGE" ]; then
    echo -e "${RED}Error: Source image not found: $SOURCE_IMAGE${NC}"
    exit 1
fi

# Check if output directory exists
if [ ! -d "$OUTPUT_DIR" ]; then
    echo -e "${RED}Error: Output directory not found: $OUTPUT_DIR${NC}"
    exit 1
fi

# Check if sips is available (macOS only)
if ! command -v sips &> /dev/null; then
    echo -e "${RED}Error: 'sips' command not found. This script requires macOS.${NC}"
    echo "Please use Xcode or an online tool to generate app icons."
    exit 1
fi

echo -e "${GREEN}Generating app icons from: $SOURCE_IMAGE${NC}"
echo ""

# Function to resize image
resize_icon() {
    local size=$1
    local filename=$2
    local output_path="$OUTPUT_DIR/$filename"
    
    echo "Generating $filename ($size x $size)..."
    sips -z $size $size "$SOURCE_IMAGE" --out "$output_path" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} Created $filename"
    else
        echo -e "  ${RED}✗${NC} Failed to create $filename"
    fi
}

# Generate all required icon sizes
# iPhone icons
resize_icon 40 "Icon-App-20x20@2x.png"
resize_icon 60 "Icon-App-20x20@3x.png"
resize_icon 29 "Icon-App-29x29@1x.png"
resize_icon 58 "Icon-App-29x29@2x.png"
resize_icon 87 "Icon-App-29x29@3x.png"
resize_icon 80 "Icon-App-40x40@2x.png"
resize_icon 120 "Icon-App-40x40@3x.png"
resize_icon 120 "Icon-App-60x60@2x.png"
resize_icon 180 "Icon-App-60x60@3x.png"

# iPad icons
resize_icon 20 "Icon-App-20x20@1x.png"
resize_icon 40 "Icon-App-20x20@2x.png"  # Already created above
resize_icon 29 "Icon-App-29x29@1x.png"  # Already created above
resize_icon 58 "Icon-App-29x29@2x.png"  # Already created above
resize_icon 40 "Icon-App-40x40@1x.png"
resize_icon 80 "Icon-App-40x40@2x.png"  # Already created above
resize_icon 76 "Icon-App-76x76@1x.png"
resize_icon 152 "Icon-App-76x76@2x.png"
resize_icon 167 "Icon-App-83.5x83.5@2x.png"

# App Store icon (1024x1024)
echo "Copying App Store icon (1024x1024)..."
cp "$SOURCE_IMAGE" "$OUTPUT_DIR/Icon-App-1024x1024@1x.png"
if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} Created Icon-App-1024x1024@1x.png"
else
    echo -e "  ${RED}✗${NC} Failed to copy App Store icon"
fi

echo ""
echo -e "${GREEN}Done!${NC} All app icons have been generated."
echo ""
echo "Next steps:"
echo "1. Open Xcode: open ios/Runner.xcworkspace"
echo "2. Check Assets.xcassets → AppIcon to verify all icons"
echo "3. Build and test your app"

