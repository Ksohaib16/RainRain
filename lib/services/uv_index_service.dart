import 'dart:math';

class UvIndexService {
  UvIndexService._();

  /// Calculate estimated UV index based on weather conditions, time, and location
  static double estimateUvIndex({
    required int weatherId,
    required DateTime dateTime,
    required double latitude,
    required double cloudiness,
  }) {
    // Base UV calculation based on time of year and latitude
    final dayOfYear =
        dateTime.difference(DateTime(dateTime.year, 1, 1)).inDays + 1;
    final solarDeclination =
        23.45 * sin(degToRad(360 * (284 + dayOfYear) / 365));

    final hour = dateTime.hour + dateTime.minute / 60.0;
    final solarTime = hour - 12; // Solar noon at 12:00

    // Simplified UV calculation
    final baseUv = _calculateBaseUv(latitude, solarDeclination, solarTime);

    // Adjust for cloudiness
    final cloudAdjustment = 1 - (cloudiness / 100) * 0.5;

    // Adjust for weather conditions
    final weatherAdjustment = _getWeatherAdjustment(weatherId);

    final estimatedUv = baseUv * cloudAdjustment * weatherAdjustment;

    // Clamp to reasonable range (0-11+)
    return max(0, min(11, estimatedUv));
  }

  static double _calculateBaseUv(
    double latitude,
    double solarDeclination,
    double solarTime,
  ) {
    final latRad = degToRad(latitude);
    final decRad = degToRad(solarDeclination);

    // Solar elevation angle
    final sinElevation =
        sin(latRad) * sin(decRad) +
        cos(latRad) * cos(decRad) * cos(degToRad(15 * solarTime));

    final elevation = asin(sinElevation);

    if (elevation <= 0) return 0; // Sun below horizon

    // UV index approximation
    final airMass =
        1 / (sinElevation + 0.50572 * pow(elevation + 6.07995, -1.6364));

    return 12.5 * pow(0.9, airMass) * sinElevation;
  }

  static double _getWeatherAdjustment(int weatherId) {
    // Weather condition adjustments based on OpenWeather weather IDs
    if (weatherId >= 200 && weatherId < 300) return 0.3; // Thunderstorm
    if (weatherId >= 300 && weatherId < 400) return 0.7; // Drizzle
    if (weatherId >= 500 && weatherId < 600) return 0.5; // Rain
    if (weatherId >= 600 && weatherId < 700) return 0.8; // Snow
    if (weatherId >= 700 && weatherId < 800) {
      return 0.6; // Atmosphere (fog, mist, etc.)
    }
    if (weatherId == 800) return 1.0; // Clear sky
    if (weatherId > 800) return 0.9; // Clouds

    return 1.0; // Default
  }

  /// Get UV index category and description
  static Map<String, dynamic> getUvInfo(double uvIndex) {
    final index = uvIndex.round();

    switch (index) {
      case 0:
        return {
          'category': 'Low',
          'description': 'Minimal sun protection required',
          'color': 0xFF00AA00, // Green
          'recommendation': 'You can safely stay outside without protection.',
        };
      case 1:
      case 2:
        return {
          'category': 'Low',
          'description': 'Minimal sun protection required',
          'color': 0xFF00AA00, // Green
          'recommendation': 'Wear sunglasses on bright days.',
        };
      case 3:
      case 4:
      case 5:
        return {
          'category': 'Moderate',
          'description': 'Sun protection essential',
          'color': 0xFFFFAA00, // Yellow
          'recommendation':
              'Wear protective clothing, sunglasses, and apply SPF 15+ sunscreen.',
        };
      case 6:
      case 7:
        return {
          'category': 'High',
          'description': 'Sun protection essential',
          'color': 0xFFFF8800, // Orange
          'recommendation':
              'Wear protective clothing, sunglasses, and apply SPF 30+ sunscreen. Seek shade during midday.',
        };
      case 8:
      case 9:
      case 10:
        return {
          'category': 'Very High',
          'description': 'Extra sun protection required',
          'color': 0xFFFF0000, // Red
          'recommendation':
              'Wear protective clothing, sunglasses, and apply SPF 50+ sunscreen. Avoid sun exposure between 10 AM and 4 PM.',
        };
      default: // 11+
        return {
          'category': 'Extreme',
          'description': 'Avoid sun exposure',
          'color': 0xFFAA00AA, // Purple
          'recommendation':
              'Wear protective clothing, sunglasses, and apply SPF 50+ sunscreen. Avoid outdoor activities between 10 AM and 4 PM.',
        };
    }
  }

  /// Get UV index level as percentage for progress indicators
  static double getUvPercentage(double uvIndex) {
    return min(uvIndex / 11.0, 1.0);
  }

  static double degToRad(double degrees) {
    return degrees * pi / 180;
  }
}
