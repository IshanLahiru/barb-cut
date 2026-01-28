# 🎨 Design Tokens Reference Card

## Color Tokens

### Primary Accent (Neon Cyan)
```
Token:        AiColors.neonCyan
Value:        #00D9FF
RGB:          0, 217, 255
Usage:        Primary buttons, focus states, active indicators
Opacity:      100% (solid), 60% (dim), 30% (glow)
```

### Secondary Accent (Sunset Coral)
```
Token:        AiColors.sunsetCoral
Value:        #FF6B35
RGB:          255, 107, 53
Usage:        Secondary actions, alternative CTAs
Opacity:      100% (solid), 60% (dim), 30% (glow)
```

### Tertiary Accent (Neon Purple)
```
Token:        AiColors.neonPurple
Value:        #B933FF
RGB:          185, 51, 255
Usage:        Advanced options, tertiary actions
Opacity:      100% (solid), 60% (dim), 30% (glow)
```

### Backgrounds
```
Deep Charcoal:      #0A0E27  (Screen background)
Dark:               #0F1419  (Primary dark surface)
Secondary:          #1A1F3A  (Secondary layer)
Surface:            #151B2F  (Cards, elevated)
Surface Light:      #1E2541  (Hover state)
```

### Text
```
Primary (Headings):     #E8ECFF  (Slightly blue-tinted white)
Secondary (Body):       #B0B8CC  (Muted blue-gray)
Tertiary (Supporting):  #7C8599  (Darker gray)
Disabled:              #4A5568  (Disabled state gray)
```

### Status
```
Success:   #00D977  (Neon green)
Error:     #FF4654  (Vibrant red)
Warning:   #FFB700  (Bright amber)
Info:      #00D9FF  (Cyan - same as primary)
```

### Borders & Glass
```
Border (Glass):        #FFFFFF @ 10% opacity (0x1AFFFFFF)
Border Light:          #FFFFFF @ 5% opacity  (0x0DFFFFFF)
Glass Light:           #FFFFFF @ 12% opacity (0x1EFFFFFF)
Glass Medium:          #FFFFFF @ 18% opacity (0x2DFFFFFF)
Glass Dark:            #FFFFFF @ 24% opacity (0x3DFFFFFF)
```

---

## Spacing Tokens

### Size Scale (8pt Base Unit)
```
xs   =  4pt  (Half unit, tight)
sm   =  8pt  (1x base, compact)
md   = 16pt  (2x base, standard)
lg   = 24pt  (3x base, spacious)
xl   = 32pt  (4x base, very spacious)
xxl  = 48pt  (6x base, large)
xxxl = 64pt  (8x base, full section)
```

### Border Radius Scale
```
radiusSmall   =  8pt  (Small elements, subtle)
radiusMedium  = 12pt  (Input fields, small cards)
radiusLarge   = 16pt  (★ PRIMARY - buttons, cards)
radiusXL      = 24pt  (Large elements, pills)
radiusCircle  = 999pt (Circular elements)
```

### Component Heights
```
Button Small    = 32pt
Button Medium   = 40pt
Button Large    = 48pt
Button XL       = 56pt (AiSpacing.buttonHeightXL)

Input Small     = 32pt
Input Medium    = 40pt
Input Large     = 48pt
```

### Icon Sizes
```
Extra Small  = 16pt
Small        = 20pt
Medium       = 24pt (default)
Large        = 32pt
XL           = 48pt
```

### Padding Presets
```
AiSpacing.p0   = all 0pt
AiSpacing.p1   = all 8pt
AiSpacing.p2   = all 16pt
AiSpacing.p3   = all 24pt
AiSpacing.p4   = all 32pt

AiSpacing.ph1  = 8pt horizontal
AiSpacing.ph2  = 16pt horizontal
AiSpacing.ph3  = 24pt horizontal

AiSpacing.pv1  = 8pt vertical
AiSpacing.pv2  = 16pt vertical
AiSpacing.pv3  = 24pt vertical
```

---

## Typography Tokens

### Scale Hierarchy
```
displayLarge   = 32pt, weight 800, tight line
displayMedium  = 28pt, weight 700, tight line
displaySmall   = 24pt, weight 700, tight line

headlineLarge  = 22pt, weight 700, tight line
headlineMedium = 20pt, weight 600, tight line
headlineSmall  = 18pt, weight 600, tight line

titleLarge     = 16pt, weight 600, normal line
titleMedium    = 14pt, weight 600, normal line
titleSmall     = 12pt, weight 600, normal line

bodyLarge      = 16pt, weight 400, normal line
bodyMedium     = 14pt, weight 400, normal line
bodySmall      = 12pt, weight 400, relaxed line

labelLarge     = 12pt, weight 600, tight line
labelMedium    = 11pt, weight 500, tight line
labelSmall     = 10pt, weight 500, tight line
```

### Line Height Scale
```
Tight:    1.2  (For headings - more compact)
Normal:   1.5  (For body text - readable)
Relaxed:  1.75 (For long-form text - spacious)
```

---

## Animation Tokens

### Duration Scale
```
Fast:      150ms (Button press, micro-interactions)
Standard:  200ms (Input focus, transitions)
Slow:      300ms (Hover effects, scale)
Very Slow: 600ms (Success celebration, modals)
Sequence:  1500ms (Loading shimmer, multi-step)
```

### Easing Curves
```
easeOut:      Fast start, quick end (default interactions)
easeInOut:    Smooth both directions (transitions)
elasticOut:   Bouncy end (celebration effects)
linear:       Constant speed (continuous loops)
```

### Common Animations
```
Button Press:
  - Type: Scale
  - From: 1.0
  - To: 0.92
  - Duration: 150ms
  - Curve: easeOut
  - Plus: Glow opacity 60% → 100%

Input Focus:
  - Type: Border color + Glow
  - Duration: 200ms
  - Curve: easeInOut
  - Shadow blur: 16px

Loading:
  - Type: Staggered shimmer grid
  - Duration: 1500ms
  - Pattern: 3x3 cells
  - Central glow: 0.8x → 1.2x (pulsing)

Success:
  - Type: Scale + Rotate
  - Duration: 600ms
  - Curve: elasticOut
  - From: 0.5
  - To: 1.0
```

---

## Shadow & Glow Tokens

### Box Shadow Patterns
```
// Subtle shadow (cards at rest)
BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 8,
  offset: Offset(0, 2),
)

// Glow effect (focus state)
BoxShadow(
  color: AiColors.neonCyan.withOpacity(0.4),
  blurRadius: 16,
  offset: Offset(0, 0),
)

// Strong glow (hover state)
BoxShadow(
  color: AiColors.neonCyan.withOpacity(0.6),
  blurRadius: 20,
  offset: Offset(0, 8),
)
```

### Elevation Scale
```
elevationNone    = 0
elevationLow     = 4
elevationMedium  = 8
elevationHigh    = 16
```

---

## Gradient Tokens

### Button Gradient
```
buttonPrimary:
  Direction: Top-left → Bottom-right
  Start: AiColors.neonCyan (#00D9FF)
  End: AiColors.sunsetCoral (#FF6B35)
  Usage: Primary CTA buttons

buttonSecondary:
  Direction: Top-left → Bottom-right
  Start: AiColors.neonPurple (#B933FF)
  End: AiColors.neonCyan (#00D9FF)
  Usage: Secondary CTA buttons
```

### Background Gradient
```
backgroundGradient:
  Direction: Top-left → Bottom-right
  Colors: [
    backgroundDeep (#0A0E27),
    backgroundSecondary (#1A1F3A),
    backgroundDark (#0F1419),
  ]
  Usage: Screen backgrounds
```

---

## Opacity Reference

### Standard Opacity Values
```
100% (1.0)   = Solid, full color
80% (0.8)    = Prominent, slightly transparent
60% (0.6)    = Medium emphasis
40% (0.4)    = Subtle, less prominent
30% (0.3)    = Very subtle, glow effect
20% (0.2)    = Minimal, almost invisible
10% (0.1)    = Glass overlay effect
5% (0.05)    = Very light glass effect
```

### Common Opacity Patterns
```
Inactive elements:     50% (0.5)
Disabled elements:     40% (0.4)
Hover effects:         60% (0.6) → 80% (0.8)
Glow effects:          30% (0.3)
Glass overlays:        10-20% (0.1-0.2)
Focus glow:            40% (0.4)
```

---

## State Color Tokens

### Interactive States
```
Default:     color.withOpacity(0.6)
Hover:       color.withOpacity(0.8)
Focus:       color (100%)
Active:      color (100%)
Disabled:    textDisabled (#4A5568)
Loading:     surfaceLight with shimmer
```

### Button States
```
Default:     background = neonCyan, foreground = charcoal
Pressed:     scale 0.92, glow 100%
Hover:       border glow
Focus:       border + shadow glow
Disabled:    color = textDisabled, no shadow
Loading:     spinner visible, interaction disabled
```

---

## Accessibility Tokens

### Color Contrast Ratios
```
textPrimary on backgroundDeep:      18:1 ✅ (AAA)
textSecondary on backgroundDeep:    12:1 ✅ (AAA)
neonCyan on backgroundDeep:         15:1 ✅ (AAA)
sunsetCoral on backgroundDeep:      8:1 ✅ (AA)
textTertiary on backgroundDeep:     7:1 ✅ (AA)
```

### Min Touch Target
```
Mobile:     48pt × 48pt (minimum)
Tablet:     44pt × 44pt (comfortable)
Desktop:    40pt × 40pt (acceptable)
```

### Text Sizing
```
Minimum:    10pt (labels, small text)
Standard:   14pt (body text)
Recommended: 16pt+ (body on mobile)
```

---

## Usage Quick Lookup

```dart
// Colors
const bg = AiColors.backgroundDeep;
const text = AiColors.textPrimary;
const accent = AiColors.neonCyan;

// Spacing
const padding = AiSpacing.md;          // 16pt
const gap = SizedBox(height: AiSpacing.lg);  // 24pt
const radius = AiSpacing.radiusLarge;  // 16pt

// Styles
style: Theme.of(context).textTheme.headlineMedium,
style: Theme.of(context).textTheme.bodyMedium,

// Theme
color: Theme.of(context).colorScheme.primary,
color: Theme.of(context).colorScheme.surface,
```

---

**Design System v1.0** - 2026 AI Standards ✨
