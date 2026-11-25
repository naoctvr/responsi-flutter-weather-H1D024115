import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';

class SearchViewModel extends ChangeNotifier {
  final WeatherApiService _apiService;
  final LocalStorageService _storageService;

  SearchViewModel({
    WeatherApiService? apiService,
    LocalStorageService? storageService,
  })  : _apiService = apiService ?? WeatherApiService(),
        _storageService = storageService ?? LocalStorageService();

  List<LocationModel> _searchResults = [];
  List<LocationModel> _favoriteLocations = [];
  List<LocationModel> _searchHistory = [];
  bool _isSearching = false;
  String? _errorMessage;
  String _currentQuery = '';

  List<LocationModel> get searchResults => _searchResults;
  List<LocationModel> get favoriteLocations => _favoriteLocations;
  List<LocationModel> get searchHistory => _searchHistory;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  String get currentQuery => _currentQuery;

  /// Memuat data favorit dan riwayat pencarian dari SharedPreferences
  Future<void> loadLocalData() async {
    _favoriteLocations = await _storageService.getFavorites();
    _searchHistory = await _storageService.getSearchHistory();
    notifyListeners();
  }

  /// Mencari lokasi melalui Open-Meteo Geocoding REST API
  Future<void> search(String query) async {
    _currentQuery = query.trim();
    if (_currentQuery.isEmpty) {
      _searchResults = [];
      _errorMessage = null;
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _apiService.searchLocation(_currentQuery);
      _searchResults = results;
      if (results.isEmpty) {
        _errorMessage = 'Kota "$query" tidak ditemukan. Coba gunakan nama kota lain.';
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Membersihkan hasil pencarian saat input di-clear
  void clearSearch() {
    _currentQuery = '';
    _searchResults = [];
    _errorMessage = null;
    _isSearching = false;
    notifyListeners();
  }

  /// Ketika pengguna memilih sebuah lokasi: simpan ke riwayat pencarian
  Future<void> onLocationSelected(LocationModel location) async {
    await _storageService.addSearchHistory(location);
    _searchHistory = await _storageService.getSearchHistory();
    notifyListeners();
  }

  /// Menambah kota ke daftar favorit secara instan (optimistic UI update)
  Future<void> addFavorite(LocationModel location) async {
    if (!_favoriteLocations.contains(location)) {
      _favoriteLocations.insert(0, location);
      notifyListeners();
    }
    await _storageService.addFavorite(location);
  }

  /// Menghapus kota dari daftar favorit secara instan (optimistic UI update)
  Future<void> removeFavorite(LocationModel location) async {
    _favoriteLocations.removeWhere((loc) => loc == location);
    notifyListeners();
    await _storageService.removeFavorite(location);
  }

  /// Cek apakah lokasi ini ada di dalam list favorit
  bool isLocationFavorite(LocationModel location) {
    return _favoriteLocations.any((loc) => loc == location);
  }

  /// Toggle favorit dari item hasil pencarian secara instan (0ms response)
  Future<bool> toggleFavorite(LocationModel location) async {
    final alreadyFav = isLocationFavorite(location);
    if (alreadyFav) {
      _favoriteLocations.removeWhere((loc) => loc == location);
      notifyListeners();
      await _storageService.removeFavorite(location);
      return false; // Sekarang tidak difavoritkan
    } else {
      _favoriteLocations.insert(0, location);
      notifyListeners();
      await _storageService.addFavorite(location);
      return true; // Sekarang difavoritkan
    }
  }

  /// Menghapus riwayat pencarian
  Future<void> clearHistory() async {
    _searchHistory = [];
    notifyListeners();
    await _storageService.clearSearchHistory();
  }
}
