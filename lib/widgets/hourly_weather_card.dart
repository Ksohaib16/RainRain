import 'package:RainRain/utils/app_theme.dart';
import 'package:flutter/material.dart';

class HourlyWeatherCard extends StatefulWidget {
  final String time;
  final String temperature;
  final IconData icon;
  final bool isCurrentHour;

  const HourlyWeatherCard({
    super.key,
    required this.icon,
    this.time = "12:00",
    this.temperature = "300° K",
    this.isCurrentHour = false,
  });

  @override
  State<HourlyWeatherCard> createState() => _HourlyWeatherCardState();
}

class _HourlyWeatherCardState extends State<HourlyWeatherCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isCurrentHour) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(HourlyWeatherCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrentHour != oldWidget.isCurrentHour) {
      if (widget.isCurrentHour) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 100,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient:
                  widget.isCurrentHour
                      ? LinearGradient(
                        colors: [
                          AppTheme.primaryBlue.withOpacity(0.3),
                          AppTheme.secondaryPurple.withOpacity(0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                      : null,
              border: Border.all(
                color:
                    widget.isCurrentHour
                        ? AppTheme.primaryBlue.withOpacity(0.5)
                        : Colors.white.withOpacity(0.1),
                width: widget.isCurrentHour ? 2 : 1,
              ),
            ),
            child: Card(
              elevation: widget.isCurrentHour ? 12 : 6,
              color:
                  widget.isCurrentHour
                      ? AppTheme.cardDark.withOpacity(0.9)
                      : AppTheme.cardDark.withOpacity(0.7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.time,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            widget.isCurrentHour
                                ? FontWeight.bold
                                : FontWeight.w500,
                        color:
                            widget.isCurrentHour
                                ? AppTheme.primaryBlue
                                : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      widget.icon,
                      size: 28,
                      color:
                          widget.isCurrentHour
                              ? AppTheme.primaryBlue
                              : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.temperature,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            widget.isCurrentHour
                                ? FontWeight.bold
                                : FontWeight.w500,
                        color:
                            widget.isCurrentHour
                                ? AppTheme.primaryBlue
                                : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
