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
        _errorMessage = 'Kota "$query" tidak ditemukan. Coba nama lain.';
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

  /// Menambah kota ke daftar favorit
  Future<void> addFavorite(LocationModel location) async {
    await _storageService.addFavorite(location);
    _favoriteLocations = await _storageService.getFavorites();
    notifyListeners();
  }

  /// Menghapus kota dari daftar favorit
  Future<void> removeFavorite(LocationModel location) async {
    await _storageService.removeFavorite(location);
    _favoriteLocations = await _storageService.getFavorites();
    notifyListeners();
  }

  /// Cek apakah lokasi ini ada di dalam list favorit
  bool isLocationFavorite(LocationModel location) {
    return _favoriteLocations.any((loc) => loc == location);
  }

  /// Toggle favorit dari item hasil pencarian
  Future<void> toggleFavorite(LocationModel location) async {
    if (isLocationFavorite(location)) {
      await removeFavorite(location);
    } else {
      await addFavorite(location);
    }
  }

  /// Menghapus riwayat pencarian
  Future<void> clearHistory() async {
    await _storageService.clearSearchHistory();
    _searchHistory = [];
    notifyListeners();
  }
}
