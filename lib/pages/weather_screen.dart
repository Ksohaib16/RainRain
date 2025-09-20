import 'dart:ui';

import 'package:RainRain/app.dart';
import 'package:RainRain/services/air_quality_service.dart';
import 'package:RainRain/services/sun_times_service.dart';
import 'package:RainRain/services/uv_index_service.dart';
import 'package:RainRain/services/weather_service.dart';
import 'package:RainRain/utils/app_theme.dart';
import 'package:RainRain/utils/location.dart';
import 'package:RainRain/widgets/air_quality_card.dart';
import 'package:RainRain/widgets/daily_weather_card.dart';
import 'package:RainRain/widgets/hourly_weather_card.dart';
import 'package:RainRain/widgets/sun_times_card.dart';
import 'package:RainRain/widgets/uv_index_card.dart';
import 'package:RainRain/widgets/weather_details_card.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> _weather;
  String? _selectedCity;
  bool _isFahrenheit = false;
  DateTime? _lastUpdated;
  List<Map<String, dynamic>>? _dailyForecast;
  Future<Map<String, dynamic>>? _airQuality;

  @override
  void initState() {
    super.initState();
    _weather = _fetchWeather();
  }

  Future<Map<String, dynamic>> _fetchWeather() async {
    final position = await getCurrentLocation();
    final data =
        _selectedCity != null && _selectedCity!.trim().isNotEmpty
            ? await WeatherService.fetchByCity(_selectedCity!.trim())
            : await WeatherService.fetchByCoords(
              lat: position.latitude,
              lon: position.longitude,
            );

    _lastUpdated = DateTime.now();
    _dailyForecast = WeatherService.extractDailyForecast(data);

    // Fetch air quality data for current location
    _airQuality = AirQualityService.fetchByCoords(
      lat: position.latitude,
      lon: position.longitude,
    );

    return data;
  }

  void _refresh() {
    setState(() {
      _weather = _fetchWeather();
    });
  }

  double _displayTemp(num celsius) =>
      _isFahrenheit ? (celsius * 9 / 5) + 32 : celsius.toDouble();
  String get _unitLabel => _isFahrenheit ? '°F' : '°C';

  IconData _iconFor(String main) {
    switch (main) {
      case 'Clouds':
        return Icons.cloud;
      case 'Rain':
      case 'Drizzle':
        return Icons.water_drop;
      case 'Thunderstorm':
        return Icons.thunderstorm;
      case 'Snow':
        return Icons.ac_unit;
      case 'Clear':
        return Icons.wb_sunny_outlined;
      default:
        return Icons.wb_cloudy_outlined;
    }
  }

  Future<void> _promptCitySearch() async {
    final controller = TextEditingController(text: _selectedCity ?? '');
    final city = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Search City'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'e.g. London, Tokyo'),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => Navigator.of(context).pop(value),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed:
                    () => Navigator.of(context).pop(controller.text.trim()),
                child: const Text('Search'),
              ),
            ],
          ),
    );

    if (city != null) {
      setState(() {
        _selectedCity = city.isEmpty ? null : city;
        _weather = _fetchWeather();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (_selectedCity != null)
            IconButton(
              tooltip: 'Use current location',
              icon: const Icon(Icons.my_location),
              onPressed: () {
                setState(() {
                  _selectedCity = null;
                  _weather = _fetchWeather();
                });
              },
            ),
          IconButton(
            tooltip: 'Search city',
            icon: const Icon(Icons.search),
            onPressed: _promptCitySearch,
          ),
          IconButton(
            tooltip:
                _isFahrenheit ? 'Switch to Celsius' : 'Switch to Fahrenheit',
            icon: Icon(
              _isFahrenheit ? Icons.thermostat_auto : Icons.device_thermostat,
            ),
            onPressed: () => setState(() => _isFahrenheit = !_isFahrenheit),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.backgroundDark, AppTheme.surfaceDark],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Fetching weather data...',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            final errorText = snapshot.error?.toString() ?? 'Unknown error';
            final isPermission = errorText.toLowerCase().contains('permission');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(errorText, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      children: [
                        FilledButton(
                          onPressed: _refresh,
                          child: const Text('Retry'),
                        ),
                        if (isPermission)
                          OutlinedButton(
                            onPressed: () async {
                              await Geolocator.openAppSettings();
                              await Geolocator.openLocationSettings();
                            },
                            child: const Text('Open Settings'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final current = data['list'][0];
          final cityName = (data['city']?['name'] ?? '').toString();
          final num tempC = current['main']['temp'];
          final String main = current['weather'][0]['main'];
          final double displayTemp = _displayTemp(tempC);

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.backgroundDark, AppTheme.surfaceDark],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 500),
              child: RefreshIndicator(
                onRefresh: () async => _refresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main weather card with gradient background
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          width: double.infinity,
                          constraints: const BoxConstraints(
                            minHeight: 180,
                            maxHeight: 250,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: AppTheme.getWeatherGradient(main),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.getWeatherGradient(
                                  main,
                                ).colors.first.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 16.0,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (cityName.isNotEmpty) ...[
                                        Flexible(
                                          child: Text(
                                            cityName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                      ],
                                      Flexible(
                                        child: AnimatedDefaultTextStyle(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 44,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black26,
                                                offset: Offset(0, 2),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              '${displayTemp.toStringAsFixed(0)}$_unitLabel',
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            child: Icon(
                                              _iconFor(main),
                                              key: ValueKey<String>(main),
                                              size: 48,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Flexible(
                                            child: Text(
                                              main,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (_lastUpdated != null) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          'Updated: ${DateFormat.Hm().format(_lastUpdated!)}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Hourly Forecast',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            itemCount: 6,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final item = data['list'][index];
                              final num t = item['main']['temp'];
                              final String m = item['weather'][0]['main'];
                              final itemTime = DateTime.parse(item['dt_txt']);
                              final now = DateTime.now();
                              final isCurrentHour =
                                  itemTime.hour == now.hour &&
                                  itemTime.day == now.day &&
                                  itemTime.month == now.month &&
                                  itemTime.year == now.year;

                              return HourlyWeatherCard(
                                icon: _iconFor(m),
                                time: DateFormat.j().format(itemTime),
                                temperature:
                                    '${_displayTemp(t).toStringAsFixed(0)}$_unitLabel',
                                isCurrentHour: isCurrentHour,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Weather Details',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            WeatherDetailsCard(
                              icon: Icons.water_drop,
                              label: 'Humidity',
                              value: '${current['main']['humidity']}%',
                            ),
                            WeatherDetailsCard(
                              icon: Icons.air,
                              label: 'Wind Speed',
                              value:
                                  '${((current['wind']['speed'] ?? 0) * 3.6).toStringAsFixed(1)} km/h',
                            ),
                            WeatherDetailsCard(
                              icon: Icons.thermostat,
                              label: 'Pressure',
                              value: '${current['main']['pressure']} hPa',
                            ),
                          ],
                        ),

                        // UV Index Section
                        const SizedBox(height: 20),
                        Builder(
                          builder: (context) {
                            final weatherId =
                                current['weather'][0]['id'] as int;
                            final cloudiness =
                                data['list'][0]['clouds']['all'] as int;
                            final latitude =
                                data['city']['coord']['lat'] as double;

                            final uvIndex = UvIndexService.estimateUvIndex(
                              weatherId: weatherId,
                              dateTime: _lastUpdated ?? DateTime.now(),
                              latitude: latitude,
                              cloudiness: cloudiness.toDouble(),
                            );

                            return SizedBox(
                              width: double.infinity,
                              child: UvIndexCard(
                                uvIndex: uvIndex,
                                currentTime: _lastUpdated,
                              ),
                            );
                          },
                        ),

                        // Sun Times Section
                        const SizedBox(height: 20),
                        Builder(
                          builder: (context) {
                            final sunTimes = SunTimesService.calculateSunTimes(
                              latitude: data['city']['coord']['lat'] as double,
                              longitude: data['city']['coord']['lon'] as double,
                              date: _lastUpdated ?? DateTime.now(),
                            );

                            return SizedBox(
                              width: double.infinity,
                              child: SunTimesCard(
                                sunrise: sunTimes['sunrise']!,
                                sunset: sunTimes['sunset']!,
                                currentTime: _lastUpdated ?? DateTime.now(),
                                latitude:
                                    data['city']['coord']['lat'] as double,
                                longitude:
                                    data['city']['coord']['lon'] as double,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 30),

                        // Air Quality Section
                        const Text(
                          'Air Quality',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (_airQuality != null)
                          FutureBuilder<Map<String, dynamic>>(
                            future: _airQuality,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: AppTheme.cardDark.withOpacity(0.5),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator.adaptive(),
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: AppTheme.cardDark.withOpacity(0.5),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.error,
                                          size: 32,
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Air quality data unavailable',
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              if (snapshot.hasData) {
                                final data = snapshot.data!;
                                final aqi =
                                    data['list']?[0]?['main']?['aqi'] ?? 0;
                                final components =
                                    data['list']?[0]?['components']
                                        as Map<String, dynamic>?;

                                return AirQualityCard(
                                  aqi: aqi,
                                  components: components,
                                );
                              }

                              return const SizedBox.shrink();
                            },
                          ),

                        const SizedBox(height: 30),
                        const Text(
                          '7-Day Forecast',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (_dailyForecast != null &&
                            _dailyForecast!.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _dailyForecast!.length,
                            itemBuilder: (context, index) {
                              final day = _dailyForecast![index];
                              final isToday = index == 0;
                              final dayName =
                                  isToday
                                      ? 'Today'
                                      : day['day'].substring(0, 3);
                              final highTemp =
                                  '${_displayTemp(day['temp_max']).toStringAsFixed(0)}$_unitLabel';
                              final lowTemp =
                                  '${_displayTemp(day['temp_min']).toStringAsFixed(0)}$_unitLabel';

                              return DailyWeatherCard(
                                day: dayName,
                                highTemp: highTemp,
                                lowTemp: lowTemp,
                                icon: _iconFor(day['weather_main']),
                                isToday: isToday,
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
