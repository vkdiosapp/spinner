# How to Add App Icon for Spinner

## Quick Method (Using Xcode - Recommended)

1. **Prepare your icon**:
   - Create a square icon image (1024x1024 pixels recommended)
   - PNG format, no transparency
   - No rounded corners (iOS adds them automatically)

2. **Open Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```

3. **Navigate to App Icon**:
   - In the left sidebar, find `Runner` → `Assets.xcassets` → `AppIcon`
   - Click on `AppIcon`

4. **Add your icon**:
   - Drag and drop your 1024x1024 icon into the "App Store" slot (1024x1024)
   - Xcode will automatically generate all required sizes for you!

## Manual Method (Replace Files Directly)

If you prefer to replace files manually, you need these sizes:

### Required Icon Sizes:

**iPhone:**
- 20x20 @2x (40x40 pixels)
- 20x20 @3x (60x60 pixels)
- 29x29 @1x (29x29 pixels)
- 29x29 @2x (58x58 pixels)
- 29x29 @3x (87x87 pixels)
- 40x40 @2x (80x80 pixels)
- 40x40 @3x (120x120 pixels)
- 60x60 @2x (120x120 pixels)
- 60x60 @3x (180x180 pixels)

**iPad:**
- 20x20 @1x (20x20 pixels)
- 20x20 @2x (40x40 pixels)
- 29x29 @1x (29x29 pixels)
- 29x29 @2x (58x58 pixels)
- 40x40 @1x (40x40 pixels)
- 40x40 @2x (80x80 pixels)
- 76x76 @1x (76x76 pixels)
- 76x76 @2x (152x152 pixels)
- 83.5x83.5 @2x (167x167 pixels)

**App Store:**
- 1024x1024 @1x (1024x1024 pixels) - **REQUIRED**

### Steps:

1. **Create or prepare your icon** (1024x1024 PNG)

2. **Generate all sizes** using one of these methods:
   - **Online tool**: https://www.appicon.co/ or https://appicon.build/
   - **macOS**: Use `sips` command (see script below)
   - **Design tool**: Export all sizes from Figma/Sketch/Photoshop

3. **Replace files** in:
   ```
   ios/Runner/Assets.xcassets/AppIcon.appiconset/
   ```

4. **Keep filenames exactly as they are** (don't rename the files)

## Using Command Line (macOS)

If you have a 1024x1024 icon ready, you can use this script:

```bash
# Save your icon as icon-1024.png in the project root
# Then run the script to generate all sizes
```

## Icon Design Guidelines

- **No transparency**: Use a solid background
- **No rounded corners**: iOS adds them automatically
- **Square format**: 1:1 aspect ratio
- **High quality**: Use vector or high-resolution source
- **Simple design**: Icons should be recognizable at small sizes
- **No text**: Avoid text in icons (it becomes unreadable at small sizes)

## Testing Your Icon

After adding your icon:

1. **Build and run**:
   ```bash
   flutter run
   ```

2. **Check on device/simulator**: Look at the home screen icon

3. **Verify in Xcode**: Open Assets.xcassets → AppIcon to see all sizes

## Current Icon Location

Your app icons are located at:
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

## Troubleshooting

- **Icon not showing**: Make sure all required sizes are present
- **Icon looks blurry**: Ensure you're using high-resolution images
- **Build errors**: Check that filenames match exactly what's in Contents.json
- **Xcode not generating sizes**: Make sure you're using Xcode 11+ for automatic generation

