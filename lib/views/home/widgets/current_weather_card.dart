import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = _getPastelGradient(current.weatherCode, isDark);
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
            color: gradientColors.first.withAlpha(isDark ? 30 : 60),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Location & Favorite Button
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
                          Icons.location_on_rounded,
                          size: 20,
                          color: Color(0xFF334155),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            location.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.only(left: 26),
                      child: Text(
                        location.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onToggleFavorite,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x10000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: isFavorite ? AppColors.starGold : Colors.grey.shade400,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Row 2: Big Temperature & Weather Icon
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
                          fontSize: 60,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          height: 1.0,
                          letterSpacing: -2,
                        ),
                      ),
                      const Text(
                        '°C',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    weatherDesc,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Suhu dirasakan: ${current.apparentTemperature.round()}°C',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),

              // Weather Icon Bubble
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(200),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  weatherIcon,
                  size: 42,
                  color: _getWeatherIconColor(current.weatherCode),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Date chip at bottom
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(160),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 13,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getPastelGradient(int code, bool isDark) {
    if (isDark) {
      return [const Color(0xFF1E293B), const Color(0xFF0F172A)];
    }
    if (code == 0 || code == 1) {
      return AppColors.heroGradientSunny;
    } else if (code >= 51 && code <= 82) {
      return AppColors.heroGradientRainy;
    } else {
      return AppColors.heroGradientCloudy;
    }
  }

  Color _getWeatherIconColor(int code) {
    if (code == 0 || code == 1) {
      return const Color(0xFFF59E0B);
    } else if (code >= 51 && code <= 82) {
      return const Color(0xFF3B82F6);
    } else if (code >= 95) {
      return const Color(0xFF8B5CF6);
    }
    return const Color(0xFF64748B);
  }
}
