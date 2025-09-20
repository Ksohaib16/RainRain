import 'dart:convert';

import 'package:RainRain/utils/config.dart';
import 'package:RainRain/utils/logger.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherService {
  WeatherService._();

  static const String _base =
      'https://api.openweathermap.org/data/2.5/forecast';

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
    final uri = Uri.parse('$_base?lat=$lat&lon=$lon&appid=$key&units=metric');
    return _get(uri);
  }

  static Future<Map<String, dynamic>> fetchByCity(String city) async {
    final key = Config.openWeatherApiKey;
    if (key.isEmpty) {
      throw Exception(
        'Missing OpenWeather API key. Define OPENWEATHER_API_KEY in .env',
      );
    }
    final uri = Uri.parse(
      '$_base?q=${Uri.encodeQueryComponent(city)}&appid=$key&units=metric',
    );
    return _get(uri);
  }

  static Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      AppLogger.info('Requesting: $uri');
      final res = await http.get(uri);
      final body = res.body;
      final data = jsonDecode(body);

      if (res.statusCode != 200) {
        final message =
            (data is Map && data['message'] != null)
                ? data['message']
                : 'Failed to load weather data';
        throw Exception('HTTP ${res.statusCode}: $message');
      }

      return Map<String, dynamic>.from(data);
    } catch (e, st) {
      AppLogger.error('Weather API request failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Extracts daily weather summaries from 5-day forecast data
  static List<Map<String, dynamic>> extractDailyForecast(
    Map<String, dynamic> data,
  ) {
    final List<dynamic> list = data['list'];
    final Map<String, List<Map<String, dynamic>>> dailyData = {};

    for (final item in list) {
      final dateTime = DateTime.parse(item['dt_txt']);
      final dateKey = DateFormat('yyyy-MM-dd').format(dateTime);

      if (!dailyData.containsKey(dateKey)) {
        dailyData[dateKey] = [];
      }
      dailyData[dateKey]!.add(item);
    }

    final List<Map<String, dynamic>> dailyForecast = [];
    final sortedDates = dailyData.keys.toList()..sort();

    for (final dateKey in sortedDates) {
      final dayData = dailyData[dateKey]!;
      final temps = dayData.map((item) => item['main']['temp'] as num).toList();
      final weatherConditions =
          dayData.map((item) => item['weather'][0]['main'] as String).toList();

      // Get most common weather condition for the day
      final mostCommonWeather = _getMostCommon(weatherConditions);

      // Get min and max temps
      final minTemp = temps.reduce((a, b) => a < b ? a : b);
      final maxTemp = temps.reduce((a, b) => a > b ? a : b);

      dailyForecast.add({
        'date': dateKey,
        'day': DateFormat('EEEE').format(DateTime.parse(dateKey)),
        'temp_min': minTemp,
        'temp_max': maxTemp,
        'weather_main': mostCommonWeather,
        'weather_description': dayData[0]['weather'][0]['description'],
        'humidity': dayData.first['main']['humidity'],
        'wind_speed': dayData.first['wind']['speed'],
        'pressure': dayData.first['main']['pressure'],
        'icon': dayData[0]['weather'][0]['icon'],
      });
    }

    return dailyForecast.take(7).toList(); // Return up to 7 days
  }

  /// Helper method to get the most common item in a list
  static String _getMostCommon(List<String> items) {
    final Map<String, int> frequency = {};
    for (final item in items) {
      frequency[item] = (frequency[item] ?? 0) + 1;
    }

    String mostCommon = items.first;
    int maxCount = 0;

    frequency.forEach((key, value) {
      if (value > maxCount) {
        maxCount = value;
        mostCommon = key;
      }
    });

    return mostCommon;
  }
}
