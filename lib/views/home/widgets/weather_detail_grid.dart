import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/weather_model.dart';

class WeatherDetailGrid extends StatelessWidget {
  final CurrentWeather current;
  final int todayPrecipProbability;

  const WeatherDetailGrid({
    super.key,
    required this.current,
    required this.todayPrecipProbability,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detail Cuaca Hari Ini',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        // 2x2 Clean Pastel Macaron Grid
        Row(
          children: [
            // 1. Peluang Hujan (Pastel Powder Blue)
            Expanded(
              child: _buildPastelDetailCard(
                bgColor: AppColors.pastelBlueBg,
                textColor: AppColors.pastelBlueText,
                icon: Icons.umbrella_rounded,
                title: 'Peluang Hujan',
                value: '$todayPrecipProbability%',
                subtitle: todayPrecipProbability > 50 ? 'Potensi Tinggi' : 'Rendah',
              ),
            ),
            const SizedBox(width: 12),
            // 2. Kecepatan Angin (Pastel Mint Green)
            Expanded(
              child: _buildPastelDetailCard(
                bgColor: AppColors.pastelGreenBg,
                textColor: AppColors.pastelGreenText,
                icon: Icons.air_rounded,
                title: 'Kecepatan Angin',
                value: '${current.windSpeed.toStringAsFixed(1)} km/j',
                subtitle: current.windSpeed > 15 ? 'Angin Kencang' : 'Semilir',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // 3. Kelembapan Udara (Pastel Rosy Peach)
            Expanded(
              child: _buildPastelDetailCard(
                bgColor: AppColors.pastelPinkBg,
                textColor: AppColors.pastelPinkText,
                icon: Icons.water_drop_rounded,
                title: 'Kelembapan Udara',
                value: '${current.relativeHumidity}%',
                subtitle: current.relativeHumidity > 75 ? 'Lembap' : 'Ideal',
              ),
            ),
            const SizedBox(width: 12),
            // 4. Curah Hujan (Pastel Lavender Mist)
            Expanded(
              child: _buildPastelDetailCard(
                bgColor: AppColors.pastelPurpleBg,
                textColor: AppColors.pastelPurpleText,
                icon: Icons.grain_rounded,
                title: 'Curah Hujan',
                value: '${current.precipitation.toStringAsFixed(1)} mm',
                subtitle: current.precipitation > 0 ? 'Basah' : 'Tidak Ada',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPastelDetailCard({
    required Color bgColor,
    required Color textColor,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: textColor, size: 16),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textColor.withAlpha(200),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor.withAlpha(190),
            ),
          ),
        ],
      ),
    );
  }
}
