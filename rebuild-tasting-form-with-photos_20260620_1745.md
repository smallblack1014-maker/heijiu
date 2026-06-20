# Wine Journal Pro - Tasting Form Reconstruction + Photo Feature

## Objective
Complete the `tasting_form_screen.dart` reconstruction (was corrupted to 0 bytes) and add photo capture functionality.

## Files Changed/Created

### 1. `lib/utils/image_utils.dart` (NEW - 1.4KB)
Photo picker and compressor utility using `image_picker` + `flutter_image_compress`.

### 2. `lib/database/database_helper.dart` (MODIFIED - +1KB)
- Added `tasting_photos` table with foreign key to `tastings(id)` + ON DELETE CASCADE
- Added CRUD: `insertTastingPhoto()`, `getTastingPhotos()`, `deleteTastingPhoto()`

### 3. `pubspec.yaml` (MODIFIED)
- Added `flutter_image_compress: ^2.3.0` dependency

### 4. `lib/screens/tasting_form_screen.dart` (RECONSTRUCTED - 51KB, 1469 lines)
Complete reconstruction from scratch. Key details:
- **StatefulWidget** with `TastingFormScreen` class
- **All required state variables** as specified in the task
- **Blind tasting mode** toggle (hides wine info section via AnimatedSize)
- **3 scoring modes**: quick (overall only), standard (aroma+palate+overall), professional (with extra dropdowns)
- **Photo section**: thumbnails from `_photoFiles` (List<File>) with remove button + camera icon to add
- **`_showPhotoSourceDialog`**: Bottom sheet with camera/gallery options using `ImageUtils.pickImage()`
- **Winery**: `TextFormField` with `_wineryController` (NOT a dropdown)
- **Country/Region**: Dropdowns that clear winery on change
- **Appearance**: Color/clarity/intensity/condition/tears/bubble dropdowns
- **Aroma**: 3 RatingSliders (intensity, condition, development) + professional mode development dropdown
- **Flavors**: Search bar + category filter chips + FlavorChipBuilder + custom word addition dialog
- **Palate**: 6 standard + 3 professional RatingSliders
- **Overall**: 5 standard + 1 professional dropdown
- **Score preview**: Live calculation using WeightConfig weights
- **Notes**: Multi-line TextFormField
- **`_saveTasting()`**: Full save with validation → wine → tasting → appearance → aroma → flavors → palate → overall → photos (compressed via ImageUtils)
- **Scoring guide dialog**
- **No references to `_selectedWinery` or `_availableWineries`**

## Build Status: ❌ Cannot Build

**Flutter SDK is NOT installed on this machine.** The Windows host has:
- winget v1.28.240 (available)
- No Flutter, Dart, Java, or Android SDK

To build the APK, the main agent needs to:
1. Install Flutter SDK (e.g., via winget: `winget install Google.Flutter` or manual download)
2. Ensure Java 17+ is installed
3. Run `flutter pub get`
4. Run `flutter analyze`
5. Fix any lint errors
6. Run `flutter build apk --release`

## Verification
- `tasting_form_screen.dart`: 51,760 bytes, 1,469 lines ✅ (>20KB)
- `image_utils.dart`: 1,394 bytes ✅
- `database_helper.dart`: All CRUD methods present ✅  
- `pubspec.yaml`: `flutter_image_compress: ^2.3.0` added ✅
- No `_selectedWinery` or `_availableWineries` references ✅
- `_wineryController` is TextEditingController, disposed in dispose() ✅
- Country/Region onChange clear `_wineryController` ✅
- Save uses `_wineryController.text.isNotEmpty ? ...trim() : null` ✅
