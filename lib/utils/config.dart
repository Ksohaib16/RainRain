import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  Config._();

  /// OpenWeather API key sourced from .env
  /// Add a line in .env: OPENWEATHER_API_KEY=your_api_key
  static String get openWeatherApiKey {
    return dotenv.env['OPENWEATHER_API_KEY'] ?? '';
  }
}
