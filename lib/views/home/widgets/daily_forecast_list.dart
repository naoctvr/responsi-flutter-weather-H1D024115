import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/weather_code_helper.dart';
import '../../../models/weather_model.dart';

class DailyForecastList extends StatelessWidget {
  final List<DailyForecast> dailyList;

  const DailyForecastList({
    super.key,
    required this.dailyList,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Perkiraan Cuaca 7 Hari',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${dailyList.length} Hari ke Depan',
              style: TextStyle(
                fontSize: 12,
                color: textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dailyList.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: isDark ? Colors.white12 : Colors.grey.shade100,
            ),
            itemBuilder: (context, index) {
              final forecast = dailyList[index];
              final isToday = index == 0;
              final dayName = isToday
                  ? 'Hari Ini'
                  : index == 1
                      ? 'Besok'
                      : DateFormat('EEEE', 'id_ID').format(forecast.date);
              final dateStr = DateFormat('d MMM', 'id_ID').format(forecast.date);
              final weatherDesc = WeatherCodeHelper.getDescription(forecast.weatherCode);
              final weatherIcon = WeatherCodeHelper.getIcon(forecast.weatherCode);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Day & Date
                    SizedBox(
                      width: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dayName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                              color: isToday
                                  ? const Color(0xFF2563EB)
                                  : (isDark ? Colors.white : const Color(0xFF0F172A)),
                            ),
                          ),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 11,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Weather Icon & Description
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            weatherIcon,
                            size: 24,
                            color: const Color(0xFF38BDF8),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              weatherDesc,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : const Color(0xFF334155),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Rain Chance
                    if (forecast.precipitationProbabilityMax > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: const Color(0x1F38BDF8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.water_drop,
                              size: 10,
                              color: Color(0xFF0284C7),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${forecast.precipitationProbabilityMax}%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Min / Max Temperature
                    SizedBox(
                      width: 75,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${forecast.maxTemp.round()}°',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${forecast.minTemp.round()}°',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
