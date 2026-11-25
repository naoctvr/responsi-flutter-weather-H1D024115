import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/location_model.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../search/search_screen.dart';
import 'widgets/current_weather_card.dart';
import 'widgets/daily_forecast_list.dart';
import 'widgets/weather_detail_grid.dart';
import 'widgets/weather_loading_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherViewModel>().initialize();
    });
  }

  void _openSearchScreen() async {
    final selectedLocation = await Navigator.push<LocationModel>(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );

    if (mounted) {
      final weatherVM = context.read<WeatherViewModel>();
      if (selectedLocation != null) {
        weatherVM.setLocation(selectedLocation);
      } else {
        weatherVM.checkFavoriteStatus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                color: AppColors.pastelYellowBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wb_sunny_rounded,
                color: AppColors.starGold,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'CuacaKita',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, size: 24),
            tooltip: 'Cari Kota',
            onPressed: _openSearchScreen,
          ),
          Consumer<WeatherViewModel>(
            builder: (context, weatherVM, _) {
              return IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 24),
                tooltip: 'Segarkan',
                onPressed: weatherVM.isLoading ? null : () => weatherVM.refresh(),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Consumer<WeatherViewModel>(
        builder: (context, weatherVM, _) {
          // 1. Kondisi Loading
          if (weatherVM.isLoading && weatherVM.weatherData == null) {
            return const WeatherLoadingView();
          }

          // 2. Kondisi Error
          if (weatherVM.hasError && weatherVM.weatherData == null) {
            return _buildErrorView(
              errorMessage: weatherVM.errorMessage ?? 'Gagal memuat cuaca.',
              onRetry: () => weatherVM.initialize(),
            );
          }

          final location = weatherVM.currentLocation;
          final weather = weatherVM.weatherData;

          // 3. Kondisi Data Kosong
          if (location == null || weather == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_off_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('Belum ada lokasi yang dipilih.'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _openSearchScreen,
                    icon: const Icon(Icons.search),
                    label: const Text('Pilih Kota'),
                  ),
                ],
              ),
            );
          }

          final todayPrecipProb = weather.daily.isNotEmpty
              ? weather.daily.first.precipitationProbabilityMax
              : 0;

          // Buttery-smooth, completely scrollable view!
          return RefreshIndicator(
            onRefresh: () => weatherVM.refresh(),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner error jika refresh background gagal
                  if (weatherVM.hasError) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              weatherVM.errorMessage!,
                              style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 1. Hero Weather Card
                  CurrentWeatherCard(
                    location: location,
                    current: weather.current,
                    isFavorite: weatherVM.isFavorite,
                    onToggleFavorite: () async {
                      final isNowFav = await weatherVM.toggleFavorite();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isNowFav
                                  ? '⭐ ${location.name} ditambahkan ke favorit'
                                  : '🗑️ ${location.name} dihapus dari favorit',
                            ),
                            duration: const Duration(milliseconds: 1400),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  // 2. Weather Details Grid (4 Pastel Macaron Cards)
                  WeatherDetailGrid(
                    current: weather.current,
                    todayPrecipProbability: todayPrecipProb,
                  ),

                  const SizedBox(height: 24),

                  // 3. 7-Day Forecast List
                  DailyForecastList(dailyList: weather.daily),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView({
    required String errorMessage,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: AppColors.pastelPinkBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 50,
                color: AppColors.pastelPinkText,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Gagal Memuat Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondaryLight,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
