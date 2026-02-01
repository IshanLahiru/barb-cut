# 🎨 AI UI System - Quick Reference

## Color Shortcuts

```dart
// Accents
const cyan = AiColors.neonCyan;          // #00D9FF
const coral = AiColors.sunsetCoral;      // #FF6B35
const purple = AiColors.neonPurple;      // #B933FF

// Text
const text1 = AiColors.textPrimary;      // Headings
const text2 = AiColors.textSecondary;    // Body
const text3 = AiColors.textTertiary;     // Supporting

// Background
const bg = AiColors.backgroundDeep;      // Deep charcoal
const surface = AiColors.surface;        // Cards
```

## Spacing Shortcuts

```dart
// Padding
EdgeInsets.all(AiSpacing.md)             // 16pt all sides
EdgeInsets.symmetric(
  horizontal: AiSpacing.lg,              // 24pt left/right
  vertical: AiSpacing.md,                // 16pt top/bottom
)

// Gaps
SizedBox(height: AiSpacing.lg)           // 24pt gap
SizedBox(width: AiSpacing.md)            // 16pt gap

// Border Radius
BorderRadius.circular(AiSpacing.radiusLarge)  // 16pt (standard)
```

## Common Patterns

### Button
```dart
AiPrimaryButton(
  label: 'Action',
  icon: Icons.check,
  onPressed: () {},
)
```

### Text Field
```dart
AiTextField(
  label: 'Prompt',
  isMultiline: true,
  maxLines: 4,
)
```

### Glass Card
```dart
AiGlassCard(
  accentBorder: AiColors.neonPurple,
  child: content,
)
```

### Loading
```dart
AiLoadingState(
  message: 'Processing...',
)
```

### Success
```dart
AiSuccessState(
  onContinue: () => resetForm(),
)
```

## Animation Timing

| Component | Duration | Curve |
|-----------|----------|-------|
| Button Press | 150ms | easeOut |
| Focus Glow | 200ms | easeInOut |
| Loading Shimmer | 1500ms | linear |
| Success Pop | 600ms | elasticOut |
| Scale Hover | 300ms | easeOut |

## Spacing Scale (8pt Grid)

| Size | Value | Example |
|------|-------|---------|
| xs | 4pt | Tight spacing |
| sm | 8pt | Compact |
| md | 16pt | Default |
| lg | 24pt | Spacious |
| xl | 32pt | Very spacious |

## Border Radius Scale

| Size | Value | Use |
|------|-------|-----|
| radiusSmall | 8pt | Small elements |
| radiusMedium | 12pt | Input fields |
| **radiusLarge** | **16pt** | Primary choice |
| radiusXL | 24pt | Large buttons |

## Gradients

```dart
// Button gradient
gradient: AiGradients.buttonPrimary  // Cyan → Coral

// Background
gradient: AiGradients.backgroundGradient()
```

## Shadow/Glow

```dart
// Glow on focus
boxShadow: [
  BoxShadow(
    color: AiColors.neonCyan.withOpacity(0.4),
    blurRadius: 16,
  ),
]
```

## Text Styles

```dart
// Heading
style: Theme.of(context).textTheme.displayMedium

// Body
style: Theme.of(context).textTheme.bodyMedium

// Label
style: Theme.of(context).textTheme.labelMedium
```

## State Colors

```dart
// Success
color: AiColors.success  // #00D977

// Error
color: AiColors.error    // #FF4654

// Info
color: AiColors.info     // #00D9FF
```

## Hover Effects

```dart
// On hover
color: widget.accentColor.withOpacity(1.0)

// Inactive
color: widget.accentColor.withOpacity(0.5)
```

## Opacity Values

```dart
// Glass effects
0.12  // Light glass overlay
0.18  // Medium glass overlay
0.24  // Dark glass overlay

// Glow effects
0.30  // Standard glow
0.40  // Strong glow
0.60  // Very strong glow
```

---

**2026 AI App Standards Ready** ✨
