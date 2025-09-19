import 'package:first/utils/app_theme.dart';
import 'package:flutter/material.dart';

class DailyWeatherCard extends StatelessWidget {
  final String day;
  final String highTemp;
  final String lowTemp;
  final IconData icon;
  final bool isToday;

  const DailyWeatherCard({
    super.key,
    required this.day,
    required this.highTemp,
    required this.lowTemp,
    required this.icon,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient:
            isToday
                ? LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.2),
                    AppTheme.secondaryPurple.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : LinearGradient(
                  colors: [
                    AppTheme.cardDark.withOpacity(0.8),
                    AppTheme.cardDark.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        border: Border.all(
          color:
              isToday
                  ? AppTheme.primaryBlue.withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
          width: isToday ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isToday
                    ? AppTheme.primaryBlue.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
            blurRadius: isToday ? 12 : 8,
            spreadRadius: isToday ? 2 : 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Day and Icon
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                        color: isToday ? AppTheme.primaryBlue : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            isToday
                                ? AppTheme.primaryBlue.withOpacity(0.2)
                                : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: 24,
                        color: isToday ? AppTheme.primaryBlue : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // High and Low Temps
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      highTemp,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lowTemp,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
