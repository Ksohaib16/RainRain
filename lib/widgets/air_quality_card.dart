import 'package:RainRain/services/air_quality_service.dart';
import 'package:RainRain/utils/app_theme.dart';
import 'package:flutter/material.dart';

class AirQualityCard extends StatelessWidget {
  final int aqi;
  final Map<String, dynamic>? components;

  const AirQualityCard({super.key, required this.aqi, this.components});

  @override
  Widget build(BuildContext context) {
    final aqiColor = Color(AirQualityService.getAqiColor(aqi));
    final aqiDescription = AirQualityService.getAqiDescription(aqi);
    final recommendation = AirQualityService.getHealthRecommendation(aqi);

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
        border: Border.all(color: aqiColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: aqiColor.withOpacity(0.2),
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
                  color: aqiColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.air, color: aqiColor, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Air Quality',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // AQI Value and Description
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: aqiColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$aqi',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aqiDescription,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recommendation,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Pollutant details (if available)
          if (components != null) ...[
            const SizedBox(height: 20),
            const Text(
              'Pollutants',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildPollutantsGrid(components!),
          ],
        ],
      ),
    );
  }

  Widget _buildPollutantsGrid(Map<String, dynamic> components) {
    final pollutants = ['co', 'no', 'no2', 'o3', 'so2', 'pm2_5', 'pm10', 'nh3'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          pollutants.map((pollutant) {
            final value = components[pollutant];
            if (value == null || value == 0.0) return const SizedBox.shrink();

            final info = AirQualityService.getPollutantInfo(
              pollutant,
              value.toDouble(),
            );

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    info['name'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${value.toStringAsFixed(1)} ${info['unit']}',
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
