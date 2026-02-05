# App Data Migration Guide

## Overview
All application data has been migrated from hardcoded Dart constants to JSON files stored in `assets/data/`. This provides better organization, easier maintenance, and separation of concerns.

## File Structure

```
apps/barbcut/
├── assets/
│   └── data/
│       ├── haircuts.json         (25 hairstyle entries)
│       ├── beard_styles.json     (24 beard style entries)
│       ├── products.json         (9 product entries)
│       ├── history.json          (7 generated history records)
│       └── profile.json          (default profile data)
└── lib/
    └── core/
        └── constants/
            └── app_data.dart     (Data loader & accessor)
```

## How It Works

### 1. Data Loading (in `main.dart`)
The app automatically loads all JSON files during initialization:

```dart
// Load app data from JSON files
await AppData.loadAppData();
```

### 2. Accessing Data Across the App

```dart
// Access haircuts
List<Map<String, dynamic>> haircuts = AppData.haircuts;

// Access beard styles
List<Map<String, dynamic>> beardStyles = AppData.beardStyles;

// Access products
List<Map<String, dynamic>> products = AppData.products;

// Access default profile
Map<String, dynamic> profile = AppData.defaultProfile;

// Check if data is loaded
bool loaded = AppData.isLoaded;
```

### 3. Current Usage Locations

These places already use AppData and will automatically use the JSON files:

- **HomeLocalDataSource** - Loads haircuts and beard styles
- **HistoryLocalDataSource** - Generates history records
- **Home View** - Displays all style data
- **Booking View** - Shows available services
- **Profile View** - Displays default user profile

## Benefits

✅ **Separation of Concerns** - Data is separate from code logic
✅ **Easier Maintenance** - Update data without recompiling
✅ **Better Organization** - All data in one centralized location
✅ **Scalability** - Easy to add new data categories
✅ **API Ready** - Can easily swap to network loading later
✅ **Clean Code** - No more huge hardcoded data arrays

## Adding New Data

1. Create a new JSON file in `assets/data/` (e.g., `new_data.json`)
2. Add it to `pubspec.yaml`:
   ```yaml
   assets:
     - assets/data/new_data.json
   ```
3. Update `app_data.dart` to load and expose it:
   ```dart
   static List<Map<String, dynamic>>? _newData;
   
   static Future<void> loadAppData() async {
     final newDataJson = await rootBundle.loadString('assets/data/new_data.json');
     _newData = List<Map<String, dynamic>>.from(jsonDecode(newDataJson));
   }
   ```

## Future Improvements

- [ ] Load data from network API instead of local assets
- [ ] Implement data caching with SharedPreferences
- [ ] Add real-time data updates from Firestore
- [ ] Create admin panel to manage data
