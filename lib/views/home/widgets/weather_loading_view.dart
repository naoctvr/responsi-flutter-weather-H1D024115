import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class WeatherLoadingView extends StatelessWidget {
  const WeatherLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholderColor = isDark ? AppColors.surfaceDark : Colors.white;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Simulated Current Weather Card
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.mainCardBgDark : AppColors.mainCardBgLight,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(strokeWidth: 3),
                  SizedBox(height: 16),
                  Text(
                    'Mengambil data cuaca...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Detail Grid Placeholder
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.pastelBlueBg,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.pastelGreenBg,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.pastelPinkBg,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Forecast List Placeholder
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: placeholderColor,
              borderRadius: BorderRadius.circular(26),
            ),
          ),
        ],
      ),
    );
  }
}
