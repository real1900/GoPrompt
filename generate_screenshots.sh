#!/bin/bash
BASE_DIR="/Users/sulemanimdad/Documents/Developer/theman/GoPrompt"
STITCH_DIR="$BASE_DIR/stitch_exports"
OUT_DIR="$BASE_DIR/fastlane/screenshots/en-US"

mkdir -p "$OUT_DIR"
rm -f "$OUT_DIR"/*.png

# iPhone 6.5" (1284x2778)
npx playwright screenshot --viewport-size=1284,2778 "file://$STITCH_DIR/Recording_Screen.html" "$OUT_DIR/1_Recording_iphone65.png"
npx playwright screenshot --viewport-size=1284,2778 "file://$STITCH_DIR/Script_Library.html" "$OUT_DIR/2_Library_iphone65.png"
npx playwright screenshot --viewport-size=1284,2778 "file://$STITCH_DIR/Script_Editor.html" "$OUT_DIR/3_Editor_iphone65.png"
npx playwright screenshot --viewport-size=1284,2778 "file://$STITCH_DIR/Recording_Gallery.html" "$OUT_DIR/4_Gallery_iphone65.png"
npx playwright screenshot --viewport-size=1284,2778 "file://$STITCH_DIR/Settings.html" "$OUT_DIR/5_Settings_iphone65.png"

# iPad Pro 12.9" (2048x2732)
npx playwright screenshot --viewport-size=2048,2732 "file://$STITCH_DIR/Recording_Screen.html" "$OUT_DIR/1_Recording_ipadPro129.png"
npx playwright screenshot --viewport-size=2048,2732 "file://$STITCH_DIR/Script_Library.html" "$OUT_DIR/2_Library_ipadPro129.png"
npx playwright screenshot --viewport-size=2048,2732 "file://$STITCH_DIR/Script_Editor.html" "$OUT_DIR/3_Editor_ipadPro129.png"
npx playwright screenshot --viewport-size=2048,2732 "file://$STITCH_DIR/Recording_Gallery.html" "$OUT_DIR/4_Gallery_ipadPro129.png"
npx playwright screenshot --viewport-size=2048,2732 "file://$STITCH_DIR/Settings.html" "$OUT_DIR/5_Settings_ipadPro129.png"

echo "Done"
