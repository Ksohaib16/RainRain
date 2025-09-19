import 'package:first/services/uv_index_service.dart';
import 'package:first/utils/app_theme.dart';
import 'package:flutter/material.dart';

class UvIndexCard extends StatelessWidget {
  final double uvIndex;
  final DateTime? currentTime;

  const UvIndexCard({super.key, required this.uvIndex, this.currentTime});

  @override
  Widget build(BuildContext context) {
    final uvInfo = UvIndexService.getUvInfo(uvIndex);
    final uvColor = Color(uvInfo['color'] as int);
    final uvPercentage = UvIndexService.getUvPercentage(uvIndex);

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
        border: Border.all(color: uvColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: uvColor.withOpacity(0.2),
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
                  color: uvColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.wb_sunny, color: uvColor, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'UV Index',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // UV Value and Progress
          Row(
            children: [
              // UV Value
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: uvColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  uvIndex.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Progress Bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: uvPercentage,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: uvColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      uvInfo['category'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: uvColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Description and Recommendation
          Text(
            uvInfo['description'],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            uvInfo['recommendation'],
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              height: 1.4,
            ),
          ),

          // Time information (if available)
          if (currentTime != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    'Measured at ${currentTime!.hour}:${currentTime!.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
