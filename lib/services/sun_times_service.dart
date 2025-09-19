import 'dart:math';

class SunTimesService {
  SunTimesService._();

  /// Calculate sunrise and sunset times for a given location and date
  static Map<String, DateTime> calculateSunTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) {
    // Convert latitude to radians
    final latRad = degToRad(latitude);

    // Calculate day of year
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;

    // Calculate solar declination
    final solarDeclination =
        23.45 * sin(degToRad(360 * (284 + dayOfYear) / 365));

    // Calculate equation of time
    final b = degToRad(360 * (dayOfYear - 81) / 364);
    final equationOfTime = 9.87 * sin(2 * b) - 7.53 * cos(b) - 1.5 * sin(b);

    // Calculate solar noon
    final solarNoon = 12 - longitude / 15 + equationOfTime / 60;

    // Calculate sunrise hour angle
    final declinationRad = degToRad(solarDeclination);
    final hourAngle = acos(
      (sin(degToRad(-0.83)) - sin(latRad) * sin(declinationRad)) /
          (cos(latRad) * cos(declinationRad)),
    );

    // Calculate sunrise and sunset times
    final sunrise = solarNoon - radToDeg(hourAngle) / 15;
    final sunset = solarNoon + radToDeg(hourAngle) / 15;

    // Convert to DateTime objects
    final sunriseTime = DateTime(
      date.year,
      date.month,
      date.day,
      sunrise.floor(),
      ((sunrise - sunrise.floor()) * 60).round(),
    );

    final sunsetTime = DateTime(
      date.year,
      date.month,
      date.day,
      sunset.floor(),
      ((sunset - sunset.floor()) * 60).round(),
    );

    return {
      'sunrise': sunriseTime,
      'sunset': sunsetTime,
      'solarNoon': DateTime(
        date.year,
        date.month,
        date.day,
        solarNoon.floor(),
        ((solarNoon - solarNoon.floor()) * 60).round(),
      ),
    };
  }

  /// Calculate day length in hours
  static double calculateDayLength(
    double latitude,
    double longitude,
    DateTime date,
  ) {
    final sunTimes = calculateSunTimes(
      latitude: latitude,
      longitude: longitude,
      date: date,
    );

    final sunrise = sunTimes['sunrise']!;
    final sunset = sunTimes['sunset']!;

    return sunset.difference(sunrise).inMinutes / 60.0;
  }

  /// Calculate night length in hours
  static double calculateNightLength(
    double latitude,
    double longitude,
    DateTime date,
  ) {
    return 24.0 - calculateDayLength(latitude, longitude, date);
  }

  /// Get sun position information for current time
  static Map<String, dynamic> getSunPosition({
    required double latitude,
    required double longitude,
    required DateTime currentTime,
  }) {
    final sunTimes = calculateSunTimes(
      latitude: latitude,
      longitude: longitude,
      date: currentTime,
    );

    final sunrise = sunTimes['sunrise']!;
    final sunset = sunTimes['sunset']!;
    final solarNoon = sunTimes['solarNoon']!;

    // Determine if sun is up
    final isSunUp =
        currentTime.isAfter(sunrise) && currentTime.isBefore(sunset);

    // Calculate sun elevation (simplified)
    double sunProgress = 0.0;
    if (isSunUp) {
      final totalDayMinutes = sunset.difference(sunrise).inMinutes;
      final elapsedMinutes = currentTime.difference(sunrise).inMinutes;
      sunProgress = elapsedMinutes / totalDayMinutes;
    } else if (currentTime.isBefore(sunrise)) {
      // Before sunrise
      sunProgress = -0.1;
    } else {
      // After sunset
      sunProgress = 1.1;
    }

    return {
      'isSunUp': isSunUp,
      'sunProgress': sunProgress.clamp(0.0, 1.0),
      'timeUntilSunrise':
          currentTime.isBefore(sunrise)
              ? sunrise.difference(currentTime)
              : sunrise.add(const Duration(days: 1)).difference(currentTime),
      'timeUntilSunset':
          currentTime.isBefore(sunset)
              ? sunset.difference(currentTime)
              : sunset.add(const Duration(days: 1)).difference(currentTime),
      'dayLength': calculateDayLength(latitude, longitude, currentTime),
      'nightLength': calculateNightLength(latitude, longitude, currentTime),
    };
  }

  /// Format duration to readable string
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  static double degToRad(double degrees) {
    return degrees * pi / 180;
  }

  static double radToDeg(double radians) {
    return radians * 180 / pi;
  }
}
