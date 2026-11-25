import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class WeatherLoadingView extends StatelessWidget {
  const WeatherLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Simulated Current Weather Card
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(28),
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
          const SizedBox(height: 20),

          // 2x2 Detail Grid Placeholder
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.pastelBlueBg,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.pastelGreenBg,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.pastelPinkBg,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.pastelPurpleBg,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Forecast List Placeholder
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(26),
            ),
          ),
        ],
      ),
    );
  }
}
