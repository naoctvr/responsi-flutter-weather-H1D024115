import 'package:flutter/material.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final titleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final valueColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detail Cuaca Hari Ini',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.7,
          children: [
            _buildDetailCard(
              context: context,
              icon: Icons.water_drop_rounded,
              iconColor: const Color(0xFF38BDF8),
              title: 'Kelembapan Udara',
              value: '${current.relativeHumidity}%',
              subtext: current.relativeHumidity > 70 ? 'Cukup Lembap' : 'Normal',
              bgColor: cardBg,
              titleColor: titleColor,
              valueColor: valueColor,
            ),
            _buildDetailCard(
              context: context,
              icon: Icons.air_rounded,
              iconColor: const Color(0xFF34D399),
              title: 'Kecepatan Angin',
              value: '${current.windSpeed.toStringAsFixed(1)} km/j',
              subtext: current.windSpeed > 20 ? 'Angin Kencang' : 'Semilir',
              bgColor: cardBg,
              titleColor: titleColor,
              valueColor: valueColor,
            ),
            _buildDetailCard(
              context: context,
              icon: Icons.grain_rounded,
              iconColor: const Color(0xFF818CF8),
              title: 'Curah Hujan',
              value: '${current.precipitation.toStringAsFixed(1)} mm',
              subtext: current.precipitation > 0 ? 'Sedang Basah' : 'Tidak Ada Hujan',
              bgColor: cardBg,
              titleColor: titleColor,
              valueColor: valueColor,
            ),
            _buildDetailCard(
              context: context,
              icon: Icons.umbrella_rounded,
              iconColor: const Color(0xFFF472B6),
              title: 'Peluang Hujan',
              value: '$todayPrecipProbability%',
              subtext: todayPrecipProbability > 50 ? 'Kemungkinan Hujan' : 'Kecil Kemungkinan',
              bgColor: cardBg,
              titleColor: titleColor,
              valueColor: valueColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtext,
    required Color bgColor,
    required Color titleColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: titleColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
              ),
              Flexible(
                child: Text(
                  subtext,
                  style: TextStyle(
                    fontSize: 10,
                    color: titleColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
