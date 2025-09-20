import 'dart:async';
import 'package:RainRain/routes/app_routes.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _dropFall;
  late Animation<double> _splashScale;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    // Single controller for all animations
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Sequential animations with intervals
    _dropFall = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _splashScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.7, curve: Curves.elasticOut),
      ),
    );

    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start animation
    _mainController.forward();

    // Navigate after animation
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.weather);
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          return Stack(
            children: [
              // Simple gradient background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0f0f23), Color(0xFF1a1a2e)],
                  ),
                ),
              ),

              // Small rain drops
              if (_dropFall.value > 0) ...[
                // Drop 1
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.3,
                  top:
                      MediaQuery.of(context).size.height *
                      _dropFall.value *
                      0.5,
                  child: Container(
                    width: 1,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(0.5),
                    ),
                  ),
                ),
                // Drop 2
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.7,
                  top:
                      MediaQuery.of(context).size.height *
                      (_dropFall.value * 0.6 - 0.1).clamp(0.0, 1.0),
                  child: Container(
                    width: 1,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(0.5),
                    ),
                  ),
                ),
                // Drop 3
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.5,
                  top:
                      MediaQuery.of(context).size.height *
                      (_dropFall.value * 0.7 - 0.2).clamp(0.0, 1.0),
                  child: Container(
                    width: 1,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(0.5),
                    ),
                  ),
                ),
                // Drop 4
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.2,
                  top:
                      MediaQuery.of(context).size.height *
                      (_dropFall.value * 0.8 - 0.15).clamp(0.0, 1.0),
                  child: Container(
                    width: 1,
                    height: 7,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(0.5),
                    ),
                  ),
                ),
                // Drop 5
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.8,
                  top:
                      MediaQuery.of(context).size.height *
                      (_dropFall.value * 0.4 - 0.05).clamp(0.0, 1.0),
                  child: Container(
                    width: 1,
                    height: 9,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(0.5),
                    ),
                  ),
                ),
              ],

              // Center content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Water splash circle
                    Transform.scale(
                      scale: _splashScale.value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade800.withOpacity(0.3),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Title and subtitle
                    Opacity(
                      opacity: _textFade.value,
                      child: Column(
                        children: [
                          const Text(
                            'Weather App',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 60),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'By Name',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
