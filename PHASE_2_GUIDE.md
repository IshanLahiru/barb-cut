# Phase 2 Quickstart - Shared Components (Atomic Design)

**Estimated Time**: 3-4 hours  
**Difficulty**: Medium  
**Blockers**: None (Phase 1 complete)

## Overview

Phase 2 extracts reusable UI components into a shared library following **Atomic Design principles**:
- **Atoms**: Smallest reusable units (Button, Input, Chip)
- **Molecules**: Combinations of atoms (ProductCard, HeaderCard)
- **Organisms**: Complete layouts (AppBar, BottomNav, Carousel)

## Directory Structure (to create)

```
lib/shared/
├── widgets/
│   ├── atoms/
│   │   ├── ai_button.dart
│   │   ├── ai_text_field.dart
│   │   ├── ai_chip.dart
│   │   ├── ai_badge.dart
│   │   ├── ai_divider.dart
│   │   └── index.dart
│   ├── molecules/
│   │   ├── product_card.dart
│   │   ├── profile_card.dart
│   │   ├── stat_item.dart
│   │   ├── category_chip_group.dart
│   │   └── index.dart
│   ├── organisms/
│   │   ├── app_bar_custom.dart
│   │   ├── bottom_nav_bar.dart
│   │   ├── image_carousel.dart
│   │   └── index.dart
│   └── index.dart
├── utils/
│   ├── validators.dart
│   ├── formatters.dart
│   └── index.dart
├── navigation/
│   └── routes.dart
└── index.dart
```

## Tasks (in order)

### 1. Create Folder Structure
```bash
mkdir -p lib/shared/widgets/{atoms,molecules,organisms}
mkdir -p lib/shared/utils
mkdir -p lib/shared/navigation
```

### 2. Extract Atoms (Smallest Components)

#### Create `lib/shared/widgets/atoms/ai_button.dart`
Move `AiPrimaryButton` and `AiSecondaryButton` from existing files. Keep NO business logic - just styling.

```dart
class AiButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final double? width;
  final bool isLoading;

  const AiButton({
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.width,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        // ... styling
      ),
    );
  }
}
```

#### Create `lib/shared/widgets/atoms/ai_text_field.dart`
Extract text input styling into reusable component.

#### Create `lib/shared/widgets/atoms/ai_chip.dart`
Extract chip components used in products view.

#### Create `lib/shared/widgets/atoms/ai_badge.dart`
For user stats, notifications, etc.

### 3. Create Molecules (Atom Combinations)

#### Create `lib/shared/widgets/molecules/product_card.dart`
Combines: Image + Title + Price + AiButton + AiChip

```dart
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool isSelected;

  const ProductCard({
    required this.product,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    // Uses: Image, Text, AiButton, AiChip (all atoms)
  }
}
```

#### Create `lib/shared/widgets/molecules/profile_card.dart`
For user profile display in profile view.

#### Create `lib/shared/widgets/molecules/stat_item.dart`
For stats row (Generations, Favorites, Bookings).

### 4. Create Organisms (Full Sections)

#### Create `lib/shared/widgets/organisms/app_bar_custom.dart`
Reusable custom app bar.

#### Create `lib/shared/widgets/organisms/image_carousel.dart`
Already using in home - extract to shared.

### 5. Export via Index Files

#### `lib/shared/widgets/atoms/index.dart`
```dart
export 'ai_button.dart';
export 'ai_text_field.dart';
export 'ai_chip.dart';
export 'ai_badge.dart';
export 'ai_divider.dart';
```

#### `lib/shared/widgets/molecules/index.dart`
```dart
export 'product_card.dart';
export 'profile_card.dart';
export 'stat_item.dart';
export 'category_chip_group.dart';
```

#### `lib/shared/widgets/index.dart`
```dart
export 'atoms/index.dart';
export 'molecules/index.dart';
export 'organisms/index.dart';
```

### 6. Update Views to Use Shared Widgets

#### In `lib/views/products_view.dart`
- Replace local ProductCard with `shared.ProductCard`
- Replace local category chips with `shared.atoms.AiChip`

#### In `lib/views/profile_view.dart`
- Replace local stat display with `shared.molecules.StatItem`
- Replace local cards with `shared.molecules.ProfileCard`

### 7. Update Imports Across App

Before:
```dart
import 'widgets/ai_buttons.dart';
import 'views/product_card.dart';
```

After:
```dart
import 'shared/widgets/index.dart';
// or
import 'shared/widgets/atoms/ai_button.dart';
```

## Code Example: Converting Existing Button

### Before (scattered in views)
```dart
// In products_view.dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  child: Text('Add to Favorites'),
)

// In profile_view.dart - DUPLICATED
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  child: Text('Edit Profile'),
)
```

### After (centralized in shared)
```dart
// In lib/shared/widgets/atoms/ai_button.dart
class AiButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const AiButton({
    required this.label,
    required this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? context.colors.primary,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label),
    );
  }
}

// Usage - everywhere
AiButton(
  label: 'Add to Favorites',
  onPressed: () {},
)
```

## Implementation Checklist

- [ ] Create folder structure (`lib/shared/widgets/atoms|molecules|organisms`)
- [ ] Extract atoms from existing views
- [ ] Create molecules by combining atoms
- [ ] Create organisms for full sections
- [ ] Add index.dart files for clean exports
- [ ] Update home_view.dart to use shared widgets
- [ ] Update products_view.dart to use shared widgets
- [ ] Update profile_view.dart to use shared widgets
- [ ] Delete old duplicated widget files
- [ ] Test all views still render correctly
- [ ] Commit Phase 2 changes

## Expected Outcomes

✅ **Code Reusability**: Button defined once, used everywhere  
✅ **Maintainability**: Change button style in one place  
✅ **Consistency**: All buttons have same look/feel  
✅ **Testing**: Atoms can be unit tested independently  
✅ **Scalability**: Easy to add new atom/molecule combinations  

## Next After Phase 2

Phase 3: Feature Architecture (Data/Domain/Presentation for each feature)
- Create `lib/features/home/` with complete clean architecture
- Create repositories with data/domain layers
- Implement BLoC for state management
- Then apply same pattern to other features

---

**Ready to start Phase 2?** Let's build the shared component library!
