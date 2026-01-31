/// App-wide constants
class AppConstants {
  // API endpoints
  static const String apiBaseUrl = 'https://api.barbcut.local/v1';
  static const String apiTimeout = '30';

  // Cache keys
  static const String cacheKeyHaircuts = 'cached_haircuts';
  static const String cacheKeyBeardStyles = 'cached_beard_styles';
  static const String cacheKeyUserProfile = 'cached_user_profile';
  static const String cacheKeyFavorites = 'cached_favorites';

  // Durations
  static const Duration cacheExpiration = Duration(days: 7);
  static const Duration debounceDelay = Duration(milliseconds: 400);
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Pagination
  static const int pageSize = 20;

  // Form validation patterns
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^[0-9]{10,}$';
}

/// Firebase collection names
class FirebaseCollections {
  static const String users = 'users';
  static const String haircuts = 'haircuts';
  static const String beardStyles = 'beard_styles';
  static const String bookings = 'bookings';
  static const String favorites = 'favorites';
  static const String reviews = 'reviews';
}

/// Shared preference keys
class SharedPrefKeys {
  static const String isFirstTime = 'is_first_time';
  static const String isDarkMode = 'is_dark_mode';
  static const String lastSyncTime = 'last_sync_time';
  static const String userId = 'user_id';
}
