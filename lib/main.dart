import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'services/local_storage_service.dart';
import 'services/weather_api_service.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal dalam Bahasa Indonesia
  await initializeDateFormatting('id_ID', null);

  // Set orientasi sistem status bar transparan
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  final WeatherApiService? apiService;
  final LocalStorageService? storageService;

  const WeatherApp({
    super.key,
    this.apiService,
    this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WeatherViewModel(
            apiService: apiService ?? WeatherApiService(),
            storageService: storageService ?? LocalStorageService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchViewModel(
            apiService: apiService ?? WeatherApiService(),
            storageService: storageService ?? LocalStorageService(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Responsi Weather App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
