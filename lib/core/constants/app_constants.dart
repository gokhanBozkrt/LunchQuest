abstract final class AppConstants {
  static const String appName = 'Lunch Quest';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = 'https://api.lunchquest.app/v1';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Cache
  static const Duration cacheDuration = Duration(hours: 1);
  static const int maxCacheSize = 100;

  // Pagination
  static const int defaultPageSize = 20;

  // Distances (km)
  static const double defaultSearchRadius = 1.5;
  static const double maxSearchRadius = 10.0;

  // Storage keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyUserLocation = 'user_location';
  static const String keySavedRestaurants = 'saved_restaurants';
  static const String keyRecentSearches = 'recent_searches';
}

abstract final class AppAssets {
  static const String _images = 'assets/images/';
  static const String _icons = 'assets/icons/';

  // Images
  static const String logoFull = '${_images}logo_full.png';
  static const String logoMark = '${_images}logo_mark.png';
  static const String onboarding1 = '${_images}onboarding_1.png';
  static const String onboarding2 = '${_images}onboarding_2.png';
  static const String onboarding3 = '${_images}onboarding_3.png';
  static const String emptyPlate = '${_images}empty_plate.png';
  static const String restaurantPlaceholder = '${_images}restaurant_placeholder.png';

  // Icons
  static const String iconBurger = '${_icons}ic_burger.svg';
  static const String iconSushi = '${_icons}ic_sushi.svg';
  static const String iconSalad = '${_icons}ic_salad.svg';
  static const String iconPizza = '${_icons}ic_pizza.svg';
}
