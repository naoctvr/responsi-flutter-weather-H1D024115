import 'package:flutter/material.dart';

class CuteWeatherMascot extends StatelessWidget {
  final int weatherCode;
  final double size;

  const CuteWeatherMascot({
    super.key,
    required this.weatherCode,
    this.size = 110,
  });

  @override
  Widget build(BuildContext context) {
    // 0, 1 = Cerah
    final isSunny = weatherCode == 0 || weatherCode == 1;
    // 51-67, 80-82 = Hujan
    final isRainy = (weatherCode >= 51 && weatherCode <= 67) || (weatherCode >= 80 && weatherCode <= 82);
    // 95-99 = Petir
    final isStorm = weatherCode >= 95;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Background sun if partly cloudy
          if (!isSunny)
            Positioned(
              right: 8,
              top: 6,
              child: Container(
                width: size * 0.45,
                height: size * 0.45,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFBBF24),
                ),
              ),
            ),

          // Main cute body
          if (isSunny)
            _buildSunnyMascot()
          else
            _buildCloudMascot(isRainy: isRainy, isStorm: isStorm),

          // Little Raindrops if rainy
          if (isRainy) ...[
            Positioned(
              bottom: -4,
              left: size * 0.28,
              child: _buildRaindrop(),
            ),
            Positioned(
              bottom: -10,
              left: size * 0.48,
              child: _buildRaindrop(),
            ),
            Positioned(
              bottom: -4,
              right: size * 0.28,
              child: _buildRaindrop(),
            ),
          ],

          // Little Spark if storm
          if (isStorm)
            Positioned(
              bottom: -6,
              child: const Icon(
                Icons.flash_on_rounded,
                color: Color(0xFFF59E0B),
                size: 26,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSunnyMascot() {
    return Container(
      width: size * 0.85,
      height: size * 0.85,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFDE68A),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withAlpha(45),
            blurRadius: 18,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.72,
          height: size * 0.72,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFCD34D),
          ),
          child: _buildCuteFace(),
        ),
      ),
    );
  }

  Widget _buildCloudMascot({required bool isRainy, required bool isStorm}) {
    return Container(
      width: size * 0.9,
      height: size * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.35),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Upper puffy circle left
          Positioned(
            left: size * 0.12,
            top: -size * 0.18,
            child: Container(
              width: size * 0.42,
              height: size * 0.42,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
          // Upper puffy circle right
          Positioned(
            right: size * 0.14,
            top: -size * 0.26,
            child: Container(
              width: size * 0.50,
              height: size * 0.50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
          // Cute Eyes & Cheeks
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: size * 0.04),
              child: _buildCuteFace(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuteFace() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Left Eye
        Container(
          width: 7,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFF1E242B),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 14),
        // Right Eye
        Container(
          width: 7,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFF1E242B),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildRaindrop() {
    return Container(
      width: 5,
      height: 10,
      decoration: BoxDecoration(
        color: const Color(0xFF60A5FA),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
