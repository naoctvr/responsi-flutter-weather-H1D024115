import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/location_model.dart';
import '../../viewmodels/search_viewmodel.dart';
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
      context.read<SearchViewModel>().loadLocalData();
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

  /// Menampilkan daftar kota favorit dalam Modal Bottom Sheet
  void _showFavoritesBottomSheet(BuildContext context) {
    context.read<SearchViewModel>().loadLocalData();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        final isDark = Theme.of(modalContext).brightness == Brightness.dark;
        final sheetBg = isDark ? AppColors.surfaceDark : Colors.white;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(modalContext).size.height * 0.70,
          ),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Drag Handle
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Sheet Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: const BoxDecoration(
                            color: AppColors.pastelYellowBg,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: AppColors.starGold,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Kota Favorit',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    Consumer<SearchViewModel>(
                      builder: (context, searchVM, _) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${searchVM.favoriteLocations.length} Kota',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),

              // Favorites List
              Expanded(
                child: Consumer<SearchViewModel>(
                  builder: (context, searchVM, _) {
                    final favorites = searchVM.favoriteLocations;

                    if (favorites.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_border_rounded, size: 48, color: Colors.grey),
                              SizedBox(height: 12),
                              Text(
                                'Belum ada kota favorit tersimpan.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Ketuk ikon bookmark di kartu cuaca untuk menyimpan kota favorit Anda.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: favorites.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final location = favorites[index];
                        return Card(
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(9),
                              decoration: const BoxDecoration(
                                color: AppColors.pastelYellowBg,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.star_rounded,
                                color: AppColors.starGold,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              location.name,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              location.subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              tooltip: 'Hapus dari Favorit',
                              onPressed: () {
                                searchVM.removeFavorite(location);
                                context.read<WeatherViewModel>().checkFavoriteStatus();
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${location.name} dihapus dari favorit'),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                            onTap: () {
                              context.read<WeatherViewModel>().setLocation(location);
                              Navigator.pop(modalContext);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
      // Dedicated Cute Logo/Button untuk Kota Favorit di Pojok Bawah
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFavoritesBottomSheet(context),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        foregroundColor: AppColors.starGold,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(Icons.star_rounded, color: AppColors.starGold, size: 24),
        label: Text(
          'Kota Favorit',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
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
                        context.read<SearchViewModel>().loadLocalData();
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

                  const SizedBox(height: 80), // Padding bawah agar FAB tidak menutupi item terakhir
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
