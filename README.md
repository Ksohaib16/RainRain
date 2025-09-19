# Weather App (Flutter)

A simple but polished weather app showcasing best practices and a few handy features.

## Features
- Animated splash screen → Weather screen via named routes
- Current location weather (OpenWeather 5-day/3-hour API)
- City search (look up any city by name)
- Temperature unit toggle (°C/°F)
- Pull-to-refresh
- Basic error handling (retry, quick link to OS location settings)
- Centralized app theming, routing, and logging

## Setup
1. Flutter 3.7+ and Dart 3.7+ recommended.
2. Get a free API key from https://openweathermap.org/api
3. Create a .env file in the project root with:
   OPENWEATHER_API_KEY=your_api_key_here
   (.env is ignored by git)
4. Run the app:
   - flutter pub get
   - flutter run

## Structure (high level)
- lib/app.dart → MaterialApp configuration, theme and routes
- lib/routes/app_routes.dart → Named routes and router
- lib/utils/app_theme.dart → Central theme
- lib/utils/logger.dart → Lightweight logger
- lib/utils/config.dart → API keys and constants
- lib/utils/location.dart → Geolocator utilities
- lib/services/weather_service.dart → Weather API client
- lib/pages/weather_screen.dart → Main weather UI
- lib/widgets/splash_screen.dart → Splash animation
- lib/widgets/* → Small UI pieces

## Notes
- Location permissions are required for current location mode. If denied, use the search to select a city.
- Wind speed is displayed in km/h (converted from m/s).
- This sample keeps preferences in memory only to avoid adding extra dependencies. Persisting them with SharedPreferences is straightforward to add later.


## Maintenance
- Pubspec cleaned: improved description and removed unused `cupertino_icons` dependency.
- Assets kept minimal: `.env` is bundled for flutter_dotenv and ignored by git.
- Runtime dependencies: `geolocator`, `http`, `intl`, `flutter_dotenv`.
- Dev dependencies: `flutter_test`, `flutter_lints`.
