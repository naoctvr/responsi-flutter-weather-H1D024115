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
      body: SafeArea(
        child: Consumer<WeatherViewModel>(
          builder: (context, weatherVM, _) {
            // 1. Kondisi Loading Awal
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

            return Stack(
              children: [
                // Main Content
                RefreshIndicator(
                  onRefresh: () => weatherVM.refresh(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cute Top Header Bar
                        _buildTopHeader(isDark, weatherVM),

                        const SizedBox(height: 18),

                        // Error notification if refresh failed
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

                        // 1. Current Weather Card (Mascot & Big Temp)
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

                        const SizedBox(height: 16),

                        // 2. Weather Details Grid (Pastel Pills & Saran Hari Ini)
                        WeatherDetailGrid(
                          current: weather.current,
                          todayPrecipProbability: todayPrecipProb,
                        ),

                        const SizedBox(height: 20),

                        // 3. 7-Day Forecast
                        DailyForecastList(dailyList: weather.daily),
                      ],
                    ),
                  ),
                ),

                // Floating Cute Bottom Pill Bar
                Positioned(
                  bottom: 20,
                  left: 24,
                  right: 24,
                  child: _buildCuteBottomBar(isDark, weatherVM),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Cute Top Header (seperti di foto referensi)
  Widget _buildTopHeader(bool isDark, WeatherViewModel weatherVM) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // App Pill Logo: (• •) CuacaKita
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFDE68A),
                ),
                child: const Center(
                  child: Text(
                    '• •',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E242B),
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'CuacaKita',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),

        // Search Round Button
        InkWell(
          onTap: _openSearchScreen,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? Colors.white : AppColors.darkPill,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.search_rounded,
              color: isDark ? AppColors.darkPill : Colors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  /// Floating Cute Bottom Bar (seperti di referensi foto pengguna)
  Widget _buildCuteBottomBar(bool isDark, WeatherViewModel weatherVM) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Tab Beranda (Aktif dalam Pill Kuning Pastel)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.pastelYellowBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.home_rounded,
                  color: AppColors.pastelYellowText,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Beranda',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.pastelYellowText,
                  ),
                ),
              ],
            ),
          ),

          // 2. Tombol Cari & Lokasi Favorit
          InkWell(
            onTap: _openSearchScreen,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Favorit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Tombol Refresh
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? Colors.white70 : Colors.grey.shade600,
              size: 22,
            ),
            tooltip: 'Segarkan Cuaca',
            onPressed: weatherVM.isLoading ? null : () => weatherVM.refresh(),
          ),
        ],
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
                backgroundColor: AppColors.darkPill,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
