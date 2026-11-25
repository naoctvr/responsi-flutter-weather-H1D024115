import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/weather_code_helper.dart';
import '../../../models/location_model.dart';
import '../../../models/weather_model.dart';

class CurrentWeatherCard extends StatelessWidget {
  final LocationModel location;
  final CurrentWeather current;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const CurrentWeatherCard({
    super.key,
    required this.location,
    required this.current,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = WeatherCodeHelper.getGradient(current.weatherCode);
    final weatherDesc = WeatherCodeHelper.getDescription(current.weatherCode);
    final weatherIcon = WeatherCodeHelper.getIcon(current.weatherCode);
    final dateStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(current.time);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withAlpha(90),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative circle
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x14FFFFFF),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location & Favorite Button Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  location.name,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 28),
                            child: Text(
                              location.subtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xD9FFFFFF),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Padding(
                            padding: const EdgeInsets.only(left: 28),
                            child: Text(
                              dateStr,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xB3FFFFFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isFavorite ? const Color(0xFFFBBF24) : Colors.white,
                        size: 28,
                      ),
                      tooltip: isFavorite ? 'Hapus dari Favorit' : 'Simpan ke Favorit',
                      onPressed: onToggleFavorite,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Main Temperature & Weather Icon Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              current.temperature.round().toString(),
                              style: const TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            const Text(
                              '°C',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w400,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          weatherDesc,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Terasa seperti ${current.apparentTemperature.round()}°C',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xD9FFFFFF),
                          ),
                        ),
                      ],
                    ),

                    // Big Weather Icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0x26FFFFFF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        weatherIcon,
                        size: 64,
                        color: Colors.white,
                      ),
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
