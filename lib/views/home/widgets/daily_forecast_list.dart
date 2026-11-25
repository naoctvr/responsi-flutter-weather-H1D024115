import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
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
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Perkiraan 7 Hari',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                letterSpacing: -0.3,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '7 Hari ke Depan',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 14,
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
                      width: 85,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dayName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                              color: isToday
                                  ? const Color(0xFF2563EB)
                                  : (isDark ? Colors.white : AppColors.textPrimaryLight),
                            ),
                          ),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Weather Icon with soft circle + description
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.pastelBlueBg.withAlpha(isDark ? 50 : 255),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        weatherIcon,
                        size: 18,
                        color: AppColors.pastelBlueText,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        weatherDesc,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : const Color(0xFF374151),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Rain Chance Pill
                    if (forecast.precipitationProbabilityMax > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: AppColors.pastelBlueBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${forecast.precipitationProbabilityMax}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.pastelBlueText,
                          ),
                        ),
                      ),

                    // Temperature Max / Min
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${forecast.maxTemp.round()}°',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${forecast.minTemp.round()}°',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
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
