# Compilation Error Fixes - wine_journal_pro

## Summary
Fixed all 6 compilation errors in the Flutter project at `C:\Users\86150\.qclaw\workspace\wine_journal_pro\flutter_app`.

## Changes Made

### 1. pubspec.yaml ✅
- Added `file_picker: ^8.0.0` under dependencies section

### 2. Icons.wine_bottle → Icons.local_bar ✅
Replaced all 8 occurrences across 7 files:
- `lib/screens/main_screen.dart` — 1 occurrence
- `lib/screens/wine_list_screen.dart` — 2 occurrences
- `lib/screens/wine_detail_screen.dart` — 1 occurrence
- `lib/screens/wine_archive_screen.dart` — 1 occurrence
- `lib/screens/cellar_screen.dart` — 1 occurrence
- `lib/screens/cellar_add_screen.dart` — 1 occurrence
- `lib/screens/cellar_detail_screen.dart` — 1 occurrence

### 3. String?.isNotEmpty promotion error ✅
In `lib/utils/scoring_helper.dart`, changed:
- `a.intensity != null && a.intensity.isNotEmpty` → `a.intensity?.isNotEmpty == true`
- `a.color != null && a.color.isNotEmpty` → `a.color?.isNotEmpty == true`
- `a.clarity != null && a.clarity.isNotEmpty` → `a.clarity?.isNotEmpty == true`
(The null check is now handled by the null-safe conditional access operator.)

### 4. ScatterSpot radius parameter ✅
In `lib/screens/stats_screen.dart`, removed `radius: 6,` from the ScatterSpot constructor (the parameter doesn't exist in the current fl_chart API version).

### 5. selectedBackgroundColor → backgroundColor ✅
In `lib/screens/tasting_form_screen.dart` line 505, changed `selectedBackgroundColor: WidgetStateProperty.all(AppTheme.wineRed)` to `backgroundColor: WidgetStateProperty.all(AppTheme.wineRed)`.

### 6. file_picker API ✅
In `lib/screens/profile_screen.dart`:
- Removed `type: FileType.custom,` from 2 `FilePicker.platform.saveFile()` calls (saveFile doesn't have a `type` parameter in file_picker ^8.0.0)
- Changed `type: FileType.custom,` to `type: FileType.any,` in 2 `FilePicker.platform.pickFiles()` calls

## Verification
- All `Icons.wine_bottle` references eliminated ✓
- No `FileType.custom` remaining ✓
- No `selectedBackgroundColor` remaining ✓
- No `radius: 6` in ScatterSpot ✓
- `file_picker: ^8.0.0` added to pubspec.yaml ✓
- Null-safe `?.isNotEmpty == true` checks in scoring_helper ✓
