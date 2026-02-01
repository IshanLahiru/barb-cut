# FlexColorScheme Migration Guide

## Overview
Successfully migrated barb-cut Flutter app from hardcoded `AiColors` constants to a dynamic **FlexColorScheme** theming system with `ThemeAdapter` helper class. This allows full support for light/dark mode with black and white design palette.

## Architecture

### 1. **FlexColorScheme Theme** (`flex_theme.dart`)
- `BarbCutTheme` class with `lightTheme` and `darkTheme` static methods
- Light: Black text (#000000) on white (#FFFFFF) background
- Dark: White text (#FFFFFF) on near-black (#1A1A1A) background
- Integrated into `main.dart` as primary theme

### 2. **ThemeAdapter Helper** (`theme_adapter.dart`)
Provides context-aware color methods that replace hardcoded constants:

```dart
// OLD (hardcoded, context-unaware):
color: AiColors.textPrimary

// NEW (dynamic, context-aware):
color: ThemeAdapter.getTextPrimary(context)
```

**Available Methods:**
- `getSurface(context)` → surface color
- `getBackgroundDark(context)` → dark background
- `getTextPrimary(context)` → primary text color
- `getTextSecondary(context)` → secondary text (70% opacity)
- `getTextTertiary(context)` → tertiary text color
- `getBorderLight(context)` → border/outline color
- `getNeonCyan(context)` → primary accent (theme primary)
- `getAccent(context)` → secondary accent
- `getError(context)` → error state color
- `getBackgroundSecondary(context)` → light surface
- `getBorderColor(context)` → general border color

## Files Refactored

### ✅ Completed
1. **Core Theme Files**
   - `lib/theme/flex_theme.dart` - Created BarbCutTheme
   - `lib/theme/theme.dart` - Added exports
   - `lib/theme/theme_adapter.dart` - Created adapter class
   - `lib/main.dart` - Updated theme references

2. **Views**
   - `lib/views/home_view.dart` - Removed theme import, updated color refs

3. **Widgets**
   - `lib/widgets/ai_bento_grid.dart` - Using ThemeAdapter + Theme.of()
   - `lib/widgets/ai_input_components.dart` - Updated all components
   - `lib/widgets/ai_buttons.dart` - All buttons now using ThemeAdapter
   - `lib/widgets/ai_image_card.dart` - Main colors migrated

4. **Shared Widgets**
   - `lib/shared/widgets/molecules/add_style_card.dart` - Updated
   - `lib/shared/widgets/molecules/style_preview_card_inline.dart` - Updated

### ⏳ Remaining Work

These files still contain `AiColors` references and need migration:

1. **Critical (UI-facing)**
   - `lib/widgets/ai_loading_states.dart` (15 AiColors references)
   - `lib/views/profile_view.dart`
   - `lib/views/questionnaire_view.dart`
   - `lib/views/products_view.dart`
   - `lib/views/history_view.dart`

2. **Medium Priority**
   - `lib/views/login_view.dart`
   - `lib/views/register_view.dart`
   - `lib/views/ai_generation_screen.dart`
   - `lib/views/appearance_view.dart`
   - `lib/views/main_screen.dart`
   - `lib/features/*/data/datasources/*.dart` (3 files)

3. **Low Priority**
   - Documentation files in `instructions/` (reference only)

## Migration Pattern

To migrate any file using old colors:

### Step 1: Check imports
```dart
// Remove if it only uses theme for AiColors:
// import '../theme/theme.dart';

// Keep if it needs theme for other reasons (like main.dart)
```

### Step 2: Replace color constants
```dart
// PATTERN: AiColors.* → ThemeAdapter.get*() or Theme.of(context)

// Examples:
AiColors.textPrimary → ThemeAdapter.getTextPrimary(context)
AiColors.textSecondary → ThemeAdapter.getTextSecondary(context)
AiColors.surface → ThemeAdapter.getSurface(context)
AiColors.borderLight → ThemeAdapter.getBorderLight(context)
AiColors.neonCyan → Theme.of(context).colorScheme.primary
```

### Step 3: Remove const qualifiers if needed
When replacing with `ThemeAdapter.get*()` calls, remove `const` from TextStyle:
```dart
// OLD:
style: const TextStyle(color: AiColors.textPrimary)

// NEW:
style: TextStyle(color: ThemeAdapter.getTextPrimary(context))
```

### Step 4: Test light/dark modes
After migration, toggle dark mode in settings to verify colors adapt correctly.

## Color Mapping Reference

| Old (Hardcoded) | New (Dynamic) | Purpose |
|---|---|---|
| `AiColors.textPrimary` | `ThemeAdapter.getTextPrimary(context)` | Primary text (heading, labels) |
| `AiColors.textSecondary` | `ThemeAdapter.getTextSecondary(context)` | Secondary text (70% opacity) |
| `AiColors.textTertiary` | `ThemeAdapter.getTextTertiary(context)` | Tertiary text (30% opacity) |
| `AiColors.surface` | `ThemeAdapter.getSurface(context)` | Card/surface background |
| `AiColors.backgroundDark` | `ThemeAdapter.getBackgroundDark(context)` | Dark overlay background |
| `AiColors.backgroundSecondary` | `ThemeAdapter.getBackgroundSecondary(context)` | Light surface variant |
| `AiColors.borderLight` | `ThemeAdapter.getBorderLight(context)` | Border/outline color |
| `AiColors.borderGlass` | `ThemeAdapter.getBorderColor(context)` | General border |
| `AiColors.neonCyan` | `Theme.of(context).colorScheme.primary` | Primary accent |
| `AiColors.neonPurple` | `Theme.of(context).colorScheme.secondary` | Secondary accent |
| `AiColors.sunsetCoral` | `Theme.of(context).colorScheme.secondary` | Alternative accent |
| `AiColors.error` | `ThemeAdapter.getError(context)` | Error state |

## Testing Checklist

After migrating each file:
- [ ] File compiles without errors
- [ ] Light mode: Colors render correctly (black text on white)
- [ ] Dark mode: Colors render correctly (white text on black)
- [ ] No console warnings about missing colors
- [ ] UI elements have proper contrast and readability
- [ ] Animations/transitions smooth with theme colors

## Build Commands

```bash
# Get dependencies with new theme
flutter pub get

# Build debug
flutter build apk --debug

# Run with hot reload
flutter run

# Check for build errors
flutter analyze

# Format code
flutter format lib/
```

## Notes

1. **Performance**: ThemeAdapter is lightweight - just wrapper methods, no overhead
2. **Backward Compatibility**: Old AiColors constants still exist in theme.dart for reference
3. **Consistency**: All colors now respect system light/dark mode settings
4. **Extensibility**: New accent colors easy to add via FlexColorScheme's schema
5. **Accessibility**: FlexColorScheme provides WCAG contrast checking

## Related Files

- `pubspec.yaml` - Contains `flex_color_scheme: ^7.3.0` dependency
- `lib/theme/flex_theme.dart` - Main theme definition
- `lib/theme/theme_adapter.dart` - Color adapter helper
- `lib/main.dart` - App theme setup (lines 65-66)

---

**Status**: ~40% complete | Next: Migrate remaining view and widget files | Time: 2-3 hours to complete
