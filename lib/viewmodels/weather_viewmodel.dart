import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';

class WeatherViewModel extends ChangeNotifier {
  final WeatherApiService _apiService;
  final LocalStorageService _storageService;

  WeatherViewModel({
    WeatherApiService? apiService,
    LocalStorageService? storageService,
  })  : _apiService = apiService ?? WeatherApiService(),
        _storageService = storageService ?? LocalStorageService();

  LocationModel? _currentLocation;
  WeatherModel? _weatherData;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFavorite = false;

  LocationModel? get currentLocation => _currentLocation;
  WeatherModel? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isFavorite => _isFavorite;

  /// Inisialisasi awal saat aplikasi dibuka:
  /// Muat lokasi terakhir yang disimpan atau default ke Jakarta/Yogyakarta
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final savedLocation = await _storageService.getLastLocation();
      if (savedLocation != null) {
        _currentLocation = savedLocation;
      } else {
        // Default awal jika pengguna baru pertama kali membuka aplikasi
        _currentLocation = LocationModel(
          name: 'Yogyakarta',
          latitude: -7.7956,
          longitude: 110.3695,
          country: 'Indonesia',
          admin1: 'Daerah Istimewa Yogyakarta',
        );
      }

      await _fetchWeatherInternal(_currentLocation!);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memuat cuaca untuk lokasi tertentu yang dipilih pengguna
  Future<void> setLocation(LocationModel location) async {
    _currentLocation = location;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _storageService.saveLastLocation(location);
      await _fetchWeatherInternal(location);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh data cuaca terkini (misalnya saat pull-to-refresh)
  Future<void> refresh() async {
    if (_currentLocation == null) return;
    try {
      await _fetchWeatherInternal(_currentLocation!);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  /// Internal fetch data cuaca dan cek status favorit
  Future<void> _fetchWeatherInternal(LocationModel location) async {
    final weather = await _apiService.fetchWeather(
      latitude: location.latitude,
      longitude: location.longitude,
    );
    _weatherData = weather;
    _isFavorite = await _storageService.isFavorite(location);
  }

  /// Toggle status favorit untuk lokasi yang sedang tampil
  Future<void> toggleFavorite() async {
    if (_currentLocation == null) return;

    if (_isFavorite) {
      await _storageService.removeFavorite(_currentLocation!);
      _isFavorite = false;
    } else {
      await _storageService.addFavorite(_currentLocation!);
      _isFavorite = true;
    }
    notifyListeners();
  }
}
