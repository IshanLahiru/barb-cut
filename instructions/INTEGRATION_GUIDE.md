# 🚀 Integration Guide - Apply AI UI System to Your App

## Step 1: Update Main App Theme

Update `lib/main.dart`:

```dart
import 'package:barbcut/theme/ai_theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController(AuthService())),
        ChangeNotifierProvider(create: (_) => ThemeController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: 'AI Image Generator',
            // ✨ NEW: Use AI theme
            theme: AiTheme.darkTheme,  // Changed from AppTheme.lightTheme
            darkTheme: AiTheme.darkTheme,
            themeMode: ThemeMode.dark,  // Always dark mode (dark-first approach)
            debugShowCheckedModeBanner: false,
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasData) {
                  return const MainScreen();
                }
                return const AuthScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
```

## Step 2: Migrate Existing Buttons

**Before:**
```dart
ElevatedButton(
  onPressed: () {},
  child: Text('Generate'),
)
```

**After:**
```dart
import '../widgets/ai_buttons.dart';

AiPrimaryButton(
  label: 'Generate Image',
  icon: Icons.flash_on_rounded,
  onPressed: () {},
  fullWidth: true,
  height: AiSpacing.buttonHeightXL,
)
```

## Step 3: Migrate Text Inputs

**Before:**
```dart
TextField(
  decoration: InputDecoration(
    hintText: 'Enter prompt...',
    border: OutlineInputBorder(),
  ),
)
```

**After:**
```dart
import '../widgets/ai_input_components.dart';

AiTextField(
  label: 'Image Prompt',
  hintText: 'Describe your vision...',
  controller: _promptController,
  isMultiline: true,
  maxLines: 4,
)
```

## Step 4: Replace Screens with Example

Replace your home screen with the example AI generation screen:

```dart
import '../views/ai_generation_screen.dart';

// In navigation
case 0:
  return const AiGenerationScreen();
```

Or copy the structure from `ai_generation_screen.dart` to your existing screens.

## Step 5: Update Spacing Throughout App

**Before:**
```dart
Padding(
  padding: EdgeInsets.all(16),
  child: child,
)
```

**After:**
```dart
import '../theme/ai_spacing.dart';

Padding(
  padding: const EdgeInsets.all(AiSpacing.md),  // 16pt
  child: child,
)
```

## Step 6: Update Border Radius

**Before:**
```dart
BorderRadius.circular(12),
```

**After:**
```dart
BorderRadius.circular(AiSpacing.radiusLarge),  // 16pt (2026 standard)
```

## Step 7: Use Glass Cards for Sections

**Before:**
```dart
Container(
  color: Colors.grey[900],
  child: content,
)
```

**After:**
```dart
import '../widgets/ai_input_components.dart';

AiGlassCard(
  accentBorder: AiColors.neonCyan,
  child: content,
)
```

## Step 8: Add Loading States

**Before:**
```dart
CircularProgressIndicator()
```

**After:**
```dart
import '../widgets/ai_loading_states.dart';

if (isLoading)
  AiLoadingState(
    message: 'Creating your masterpiece...',
  )
```

## Step 9: Add Color Imports

Add to your view files:
```dart
import '../theme/ai_colors.dart';
import '../theme/ai_spacing.dart';
import '../widgets/ai_buttons.dart';
import '../widgets/ai_input_components.dart';
import '../widgets/ai_image_card.dart';
import '../widgets/ai_loading_states.dart';
import '../widgets/ai_bento_grid.dart';
```

## Step 10: Test All Screens

- [ ] Check colors render correctly (cyan, coral, purple)
- [ ] Verify spacing is consistent (8pt grid)
- [ ] Test button interactions (glow, scale)
- [ ] Verify loading animations smooth
- [ ] Test on multiple device sizes
- [ ] Profile performance on real device

## File Checklist

### New Theme Files
```
✅ lib/theme/ai_colors.dart
✅ lib/theme/ai_spacing.dart
✅ lib/theme/ai_theme.dart
```

### New Widget Files
```
✅ lib/widgets/ai_buttons.dart
✅ lib/widgets/ai_input_components.dart
✅ lib/widgets/ai_image_card.dart
✅ lib/widgets/ai_loading_states.dart
✅ lib/widgets/ai_bento_grid.dart
```

### Example Files
```
✅ lib/views/ai_generation_screen.dart
```

### Documentation
```
✅ AI_UI_SYSTEM_GUIDE.md
✅ AI_UI_QUICK_REFERENCE.md
✅ INTEGRATION_GUIDE.md (this file)
```

## Color Migration Mapping

| Old Color | New Color | Component |
|-----------|-----------|-----------|
| AppColors.primary | AiColors.neonCyan | Primary actions |
| AppColors.accent | AiColors.sunsetCoral | Secondary |
| AppColors.background | AiColors.backgroundDeep | Screen bg |
| AppColors.surface | AiColors.surface | Cards |
| AppColors.textPrimary | AiColors.textPrimary | Headings |
| AppColors.textSecondary | AiColors.textSecondary | Body |

## Animation Reference

### Button Press (AiPrimaryButton)
- Duration: 150ms
- Effect: Scale 1.0 → 0.92 (squishy)
- Glow: 60% → 100% opacity

### Focus Glow (AiTextField)
- Duration: 200ms
- Effect: Border color change + shadow glow
- Blur: 16px radius

### Loading Shimmer (AiLoadingState)
- Duration: 1500ms
- Effect: Grid cells shimmer with stagger
- Central glow pulses 0.8x → 1.2x

### Success Pop (AiSuccessState)
- Duration: 600ms
- Curve: elasticOut
- Effect: Scale 0.5 → 1.0 with bounce

## Performance Tips

1. **Use const constructors** everywhere:
   ```dart
   const AiPrimaryButton(...)
   ```

2. **Lazy load screens** with Navigator:
   ```dart
   Navigator.push(
     context,
     MaterialPageRoute(builder: (_) => AiGenerationScreen()),
   )
   ```

3. **Profile animations** on real device:
   ```bash
   flutter run --profile
   ```

4. **Use `RepaintBoundary`** for complex animations:
   ```dart
   RepaintBoundary(
     child: CustomWidget(),
   )
   ```

## Troubleshooting

### Colors look wrong
- Ensure `AiTheme.darkTheme` is set in `main.dart`
- Verify `useMaterial3: true` is enabled
- Check that `themeMode: ThemeMode.dark` is forced

### Spacing inconsistent
- Use `AiSpacing.*` constants everywhere
- Don't hardcode pixel values
- Use `EdgeInsets` presets (e.g., `AiSpacing.p2`)

### Animations stuttering
- Profile with `--profile` flag
- Reduce animation complexity
- Use `const` for all static widgets
- Profile on actual device, not simulator

### Text not rendering
- Ensure text styles use `Theme.of(context).textTheme.*`
- Verify color contrast (text on surface)
- Check font sizes aren't below 10pt

## Next Phase: Advanced

After basic integration:

1. **Add Haptic Feedback:**
   ```dart
   HapticFeedback.mediumImpact()
   ```

2. **Add Advanced Animations:**
   - Staggered loading sequences
   - Parallax backgrounds
   - Physics-based interactions

3. **Add Navigation Animations:**
   - Page transitions with gradient
   - Hero animations for images
   - Shared axis transitions

4. **Add Accessibility:**
   - Semantic labels for screen readers
   - High contrast mode support
   - Text scale support

---

## Quick Command Reference

```bash
# Run with AI theme
flutter run --release

# Profile performance
flutter run --profile

# Build for iOS
flutter build ios --release

# Build for Android
flutter build apk --release

# Format code
dart format lib/

# Analyze issues
dart analyze lib/
```

---

**Ready to launch your 2026 AI app!** 🚀✨
