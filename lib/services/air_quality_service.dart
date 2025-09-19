import 'dart:convert';

import 'package:first/utils/config.dart';
import 'package:first/utils/logger.dart';
import 'package:http/http.dart' as http;

class AirQualityService {
  AirQualityService._();

  static const String _base =
      'https://api.openweathermap.org/data/2.5/air_pollution';

  static Future<Map<String, dynamic>> fetchByCoords({
    required double lat,
    required double lon,
  }) async {
    final key = Config.openWeatherApiKey;
    if (key.isEmpty) {
      throw Exception(
        'Missing OpenWeather API key. Define OPENWEATHER_API_KEY in .env',
      );
    }
    final uri = Uri.parse('$_base?lat=$lat&lon=$lon&appid=$key');
    return _get(uri);
  }

  static Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      AppLogger.info('Requesting air quality: $uri');
      final res = await http.get(uri);
      final body = res.body;
      final data = jsonDecode(body);

      if (res.statusCode != 200) {
        final message =
            (data is Map && data['message'] != null)
                ? data['message']
                : 'Failed to load air quality data';
        throw Exception('HTTP ${res.statusCode}: $message');
      }

      return Map<String, dynamic>.from(data);
    } catch (e, st) {
      AppLogger.error(
        'Air quality API request failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Get air quality index description
  static String getAqiDescription(int aqi) {
    switch (aqi) {
      case 1:
        return 'Good';
      case 2:
        return 'Fair';
      case 3:
        return 'Moderate';
      case 4:
        return 'Poor';
      case 5:
        return 'Very Poor';
      default:
        return 'Unknown';
    }
  }

  /// Get health recommendation based on AQI
  static String getHealthRecommendation(int aqi) {
    switch (aqi) {
      case 1:
        return 'Air quality is good. Perfect for outdoor activities.';
      case 2:
        return 'Air quality is acceptable. Sensitive individuals should limit prolonged outdoor exertion.';
      case 3:
        return 'Members of sensitive groups may experience health effects. General public is not likely to be affected.';
      case 4:
        return 'Everyone may begin to experience health effects. Sensitive groups should avoid outdoor activities.';
      case 5:
        return 'Health alert: everyone may experience more serious health effects. Avoid all outdoor activities.';
      default:
        return 'Unable to determine air quality recommendation.';
    }
  }

  /// Get color for AQI level
  static int getAqiColor(int aqi) {
    switch (aqi) {
      case 1:
        return 0xFF00E400; // Green
      case 2:
        return 0xFFFFFF00; // Yellow
      case 3:
        return 0xFFFF7E00; // Orange
      case 4:
        return 0xFFFF0000; // Red
      case 5:
        return 0xFF8F3F97; // Purple
      default:
        return 0xFF808080; // Gray
    }
  }

  /// Get pollutant information
  static Map<String, dynamic> getPollutantInfo(
    String code,
    double concentration,
  ) {
    final Map<String, Map<String, dynamic>> pollutants = {
      'co': {
        'name': 'Carbon Monoxide',
        'unit': 'μg/m³',
        'description':
            'Colorless, odorless gas produced by incomplete combustion',
      },
      'no': {
        'name': 'Nitrogen Monoxide',
        'unit': 'μg/m³',
        'description': 'Contributes to the formation of smog and acid rain',
      },
      'no2': {
        'name': 'Nitrogen Dioxide',
        'unit': 'μg/m³',
        'description':
            'Reddish-brown gas that contributes to acid rain and photochemical smog',
      },
      'o3': {
        'name': 'Ozone',
        'unit': 'μg/m³',
        'description': 'Gas that can irritate the respiratory system',
      },
      'so2': {
        'name': 'Sulfur Dioxide',
        'unit': 'μg/m³',
        'description':
            'Colorless gas with a sharp odor that contributes to acid rain',
      },
      'pm2_5': {
        'name': 'PM2.5',
        'unit': 'μg/m³',
        'description': 'Fine particles that can penetrate deep into the lungs',
      },
      'pm10': {
        'name': 'PM10',
        'unit': 'μg/m³',
        'description':
            'Coarse particles that can irritate the respiratory system',
      },
      'nh3': {
        'name': 'Ammonia',
        'unit': 'μg/m³',
        'description': 'Colorless gas with a pungent odor',
      },
    };

    return {
      'name': pollutants[code]?['name'] ?? code.toUpperCase(),
      'concentration': concentration,
      'unit': pollutants[code]?['unit'] ?? 'μg/m³',
      'description': pollutants[code]?['description'] ?? 'Air pollutant',
    };
  }
}
