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
    // Generate saran cuaca lucu berdasarkan kondisi
    final tip = _getWeatherTip(current.weatherCode, todayPrecipProbability);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 3 Pastel Cards Row (Hujan, Angin, Lembap)
        Row(
          children: [
            // 1. Peluang Hujan (Pastel Blue)
            Expanded(
              child: _buildPastelCard(
                bgColor: AppColors.pastelBlueBg,
                textColor: AppColors.pastelBlueText,
                icon: Icons.umbrella_rounded,
                value: '$todayPrecipProbability%',
                label: 'Hujan',
              ),
            ),
            const SizedBox(width: 10),

            // 2. Kecepatan Angin (Pastel Mint Green)
            Expanded(
              child: _buildPastelCard(
                bgColor: AppColors.pastelGreenBg,
                textColor: AppColors.pastelGreenText,
                icon: Icons.air_rounded,
                value: '${current.windSpeed.round()} km/j',
                label: 'Angin',
              ),
            ),
            const SizedBox(width: 10),

            // 3. Kelembapan (Pastel Pink)
            Expanded(
              child: _buildPastelCard(
                bgColor: AppColors.pastelPinkBg,
                textColor: AppColors.pastelPinkText,
                icon: Icons.water_drop_rounded,
                value: '${current.relativeHumidity}%',
                label: 'Lembap',
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Curah Hujan & Info Tambahan Card (Pastel Yellow / Lavender)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.pastelYellowBg,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.grain_rounded,
                  color: AppColors.pastelYellowText,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Curah Hujan',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pastelYellowText,
                      ),
                    ),
                    Text(
                      '${current.precipitation.toStringAsFixed(1)} mm per jam',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.pastelYellowText,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                current.precipitation > 0 ? 'Sedang Basah' : 'Kering',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.pastelYellowText,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Saran Hari Ini Banner (Cute aesthetic banner seperti di contoh foto)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.pastelGreenBg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SARAN HARI INI!',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.pastelGreenText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tip,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pastelGreenText,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Mini cute cloud with eyes
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '• •',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E242B),
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPastelCard({
    required Color bgColor,
    required Color textColor,
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }

  String _getWeatherTip(int code, int rainProb) {
    if (rainProb >= 70 || (code >= 51 && code <= 82)) {
      return 'Bawa payung, kemungkinan hujan sangat tinggi hari ini!';
    } else if (rainProb >= 40) {
      return 'Sedia payung sebelum hujan, awan mendung mulai tampak.';
    } else if (code == 0 || code == 1) {
      return 'Cuaca cerah dan bersahabat, jangan lupa gunakan sunscreen!';
    } else {
      return 'Hari yang nyaman dan sejuk, nikmati aktivitasmu!';
    }
  }
}
