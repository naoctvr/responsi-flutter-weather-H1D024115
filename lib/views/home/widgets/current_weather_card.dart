import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/weather_code_helper.dart';
import '../../../models/location_model.dart';
import '../../../models/weather_model.dart';
import 'cute_weather_mascot.dart';

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
    final cardBg = isDark ? AppColors.mainCardBgDark : AppColors.mainCardBgLight;
    final weatherDesc = WeatherCodeHelper.getDescription(current.weatherCode);
    final dateStr = DateFormat('EEEE, d MMM', 'id_ID').format(current.time);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Tag "CUACA SAAT INI" + Bookmark Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'CUACA SAAT INI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                  ),
                ),
              ),
              InkWell(
                onTap: onToggleFavorite,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2E3848) : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: isFavorite ? AppColors.starGold : Colors.grey.shade400,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // City Name & Subtitle
          Text(
            location.name,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
              letterSpacing: -0.6,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${location.subtitle} • $dateStr',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 20),

          // Temperature, Condition, and Mascot
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
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          letterSpacing: -2,
                        ),
                      ),
                      Text(
                        '°',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weatherDesc,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Terasa seperti ${current.apparentTemperature.round()}°',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),

              // Cute Mascot
              CuteWeatherMascot(
                weatherCode: current.weatherCode,
                size: 96,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
