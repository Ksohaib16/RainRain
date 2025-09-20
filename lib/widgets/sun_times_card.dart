import 'package:RainRain/services/sun_times_service.dart';
import 'package:RainRain/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SunTimesCard extends StatelessWidget {
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime currentTime;
  final double latitude;
  final double longitude;

  const SunTimesCard({
    super.key,
    required this.sunrise,
    required this.sunset,
    required this.currentTime,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final sunPosition = SunTimesService.getSunPosition(
      latitude: latitude,
      longitude: longitude,
      currentTime: currentTime,
    );

    final isSunUp = sunPosition['isSunUp'] as bool;
    final sunProgress = sunPosition['sunProgress'] as double;
    final dayLength = sunPosition['dayLength'] as double;
    final nightLength = sunPosition['nightLength'] as double;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppTheme.cardDark.withOpacity(0.9),
            AppTheme.cardDark.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: (isSunUp ? AppTheme.accentPink : AppTheme.primaryBlue)
              .withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isSunUp ? AppTheme.accentPink : AppTheme.primaryBlue)
                .withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isSunUp ? AppTheme.accentPink : AppTheme.primaryBlue)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSunUp ? Icons.wb_sunny : Icons.nightlight_round,
                  color: isSunUp ? AppTheme.accentPink : AppTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Sun & Moon',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sun position visual indicator
          Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.3),
                  AppTheme.accentPink.withOpacity(0.3),
                  AppTheme.secondaryPurple.withOpacity(0.3),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Progress arc background
                Container(
                  width: double.infinity,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                // Progress arc
                Positioned(
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryBlue, AppTheme.accentPink],
                        stops: [0.0, sunProgress],
                      ),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: sunProgress,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              isSunUp
                                  ? AppTheme.accentPink
                                  : AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ),
                // Sun icon
                Positioned(
                  left:
                      20 +
                      (MediaQuery.of(context).size.width - 80) * sunProgress -
                      12,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isSunUp ? AppTheme.accentPink : AppTheme.primaryBlue,
                      boxShadow: [
                        BoxShadow(
                          color: (isSunUp
                                  ? AppTheme.accentPink
                                  : AppTheme.primaryBlue)
                              .withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      isSunUp ? Icons.wb_sunny : Icons.nightlight_round,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Sunrise and Sunset times
          Row(
            children: [
              // Sunrise
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.wb_twilight,
                            color: AppTheme.primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sunrise',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.jm().format(sunrise),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Sunset
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPink.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.brightness_2,
                            color: AppTheme.accentPink,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sunset',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.jm().format(sunset),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Day/Night length info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${dayLength.toStringAsFixed(1)}h',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Daylight',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withOpacity(0.3),
                ),
                Column(
                  children: [
                    Text(
                      '${nightLength.toStringAsFixed(1)}h',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Night',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
