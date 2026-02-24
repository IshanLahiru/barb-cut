# Barbcut Flutter App - Clean Architecture Guide

## Overview

This guide outlines the clean architecture structure for the BarberCut Flutter application, following feature-first organization principles with clear separation of concerns.

## Related Documentation

- **[IMPLEMENTATION_EXAMPLES.md](IMPLEMENTATION_EXAMPLES.md)** - Code examples for each architecture layer
- **[PHASE_1_COMPLETION_REPORT.md](PHASE_1_COMPLETION_REPORT.md)** - Phase 1 status and deliverables
- **[PHASE_2_GUIDE.md](PHASE_2_GUIDE.md)** - Phase 2 implementation (Atomic Design)

---

## 📁 Proposed Folder Structure (Feature-First Approach)

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── api_constants.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── theme_data.dart
│   │   ├── ai_colors.dart (existing)
│   │   ├── adaptive_theme_colors.dart (existing)
│   │   ├── ai_spacing.dart (existing)
│   │   └── typography.dart
│   ├── errors/
│   │   ├── failure.dart
│   │   └── exceptions.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   └── interceptors.dart
│   └── di/
│       └── service_locator.dart
│
├── features/
│   ├── home/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── home_local_datasource.dart
│   │   │   │   └── home_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── haircut_model.dart
│   │   │   └── repositories/
│   │   │       └── home_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── haircut_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── home_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_haircuts_usecase.dart
│   │   │       └── get_beard_styles_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── home_bloc.dart
│   │       │   ├── home_event.dart
│   │       │   └── home_state.dart
│   │       ├── pages/
│   │       │   └── home_page.dart
│   │       └── widgets/
│   │           ├── carousel_card.dart
│   │           ├── haircut_grid.dart
│   │           └── search_panel.dart
│   │
│   ├── history/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── products/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── profile/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── shared/
│   ├── widgets/
│   │   ├── atoms/
│   │   │   ├── app_button.dart
│   │   │   ├── app_text_field.dart
│   │   │   ├── app_chip.dart
│   │   │   └── app_badge.dart
│   │   ├── molecules/
│   │   │   ├── card_template.dart
│   │   │   ├── profile_header.dart
│   │   │   └── product_card.dart
│   │   └── organisms/
│   │       ├── app_bar_template.dart
│   │       ├── bottom_nav.dart
│   │       └── image_carousel.dart
│   ├── utils/
│   │   ├── extensions.dart
│   │   ├── validators.dart
│   │   └── formatters.dart
│   └── navigation/
│       └── app_router.dart
│
├── main.dart
└── config/
    └── app_config.dart
```

## 🏗️ Architecture Layers Explained

### **Core Layer** - App-wide utilities
- **Theme**: Centralized styling (never hardcode colors)
- **Constants**: API URLs, timeouts, etc.
- **Errors**: Custom exception and failure handling
- **DI**: GetIt service locator setup
- **Network**: Reusable HTTP client

### **Features Layer** - Feature-specific logic
Each feature has independent Data/Domain/Presentation

**Data Layer (Repository Pattern)**
```
home_repository_impl.dart (Implementation)
  └─ depends on
home_remote_datasource.dart (API calls)
home_local_datasource.dart (Local cache)
```

**Domain Layer (Business Logic)**
```
home_repository.dart (Interface - contract)
get_haircuts_usecase.dart (Orchestrates logic)
```

**Presentation Layer (UI + State)**
```
home_bloc.dart (State management)
home_page.dart (Screen)
```

### **Shared Layer** - Reusable UI & utilities
- **Atomic Design**: Atoms (buttons) → Molecules (cards) → Organisms (full layouts)
- **No feature-specific logic** - only generic widgets

## ✨ Key Principles

1. **Dependency Inversion**: Domain never depends on Data/Presentation
2. **Single Responsibility**: Each class does one thing
3. **Testability**: All dependencies are injected
4. **Scalability**: Add features without modifying existing code
5. **Maintainability**: Consistent patterns across all features

## 🔄 Migration Strategy

### Phase 1: Core Setup
- [ ] Create `/core` folder with theme, constants, DI
- [ ] Set up GetIt service locator
- [ ] Create base failure/exception classes

### Phase 2: Shared Components
- [ ] Extract existing AI buttons → `shared/widgets/atoms/`
- [ ] Create reusable card templates
- [ ] Centralize theme access

### Phase 3: Feature Refactor (One at a time)
- [ ] Start with `home` feature
- [ ] Create data layer (models, repos, datasources)
- [ ] Create domain layer (entities, usecases, interfaces)
- [ ] Refactor presentation to use BLoC
- [ ] Move to next feature

### Phase 4: Testing
- [ ] Unit tests for use cases
- [ ] Repository tests with mock datasources
- [ ] Widget tests for shared components

---

## Related Resources

### Implementation Guides
- **[IMPLEMENTATION_EXAMPLES.md](IMPLEMENTATION_EXAMPLES.md)** - Detailed code examples for all layers
- **[CLEAN_ARCHITECTURE_ROADMAP.md](CLEAN_ARCHITECTURE_ROADMAP.md)** - Migration roadmap with progress tracking
- **[PHASE_2_GUIDE.md](PHASE_2_GUIDE.md)** - Atomic Design implementation guide

### Feature Documentation
- **[PAYMENT_SYSTEM_COMPLETE.md](PAYMENT_SYSTEM_COMPLETE.md)** - Payment system following clean architecture
- **[MULTI_ANGLE_VIEW_GUIDE.md](MULTI_ANGLE_VIEW_GUIDE.md)** - Feature implementation example

### Project Setup
- **[PROJECT-OVERVIEW.md](PROJECT-OVERVIEW.md)** - High-level project context
- **[RULES.md](RULES.md)** - Development guidelines and best practices
