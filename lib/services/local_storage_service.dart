import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

class LocalStorageService {
  static const String _keyFavorites = 'favorite_locations';
  static const String _keyHistory = 'search_history';
  static const String _keyLastLocation = 'last_selected_location';

  SharedPreferences? _cachedPrefs;

  Future<SharedPreferences> _getPrefs() async {
    return _cachedPrefs ??= await SharedPreferences.getInstance();
  }

  /// Mendapatkan daftar kota favorit dari SharedPreferences
  Future<List<LocationModel>> getFavorites() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_keyFavorites);
      if (jsonString == null || jsonString.isEmpty) {
        // Default favorites jika masih kosong (Jakarta & Yogyakarta)
        final defaultFavs = [
          LocationModel(
            name: 'Jakarta',
            latitude: -6.21462,
            longitude: 106.84513,
            country: 'Indonesia',
            admin1: 'DKI Jakarta',
            countryCode: 'ID',
          ),
          LocationModel(
            name: 'Yogyakarta',
            latitude: -7.7956,
            longitude: 110.3695,
            country: 'Indonesia',
            admin1: 'Daerah Istimewa Yogyakarta',
            countryCode: 'ID',
          ),
        ];
        await saveFavorites(defaultFavs);
        return defaultFavs;
      }
      return LocationModel.decodeList(jsonString);
    } catch (e) {
      return [];
    }
  }

  /// Menyimpan seluruh list favorit
  Future<void> saveFavorites(List<LocationModel> favorites) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyFavorites, LocationModel.encodeList(favorites));
  }

  /// Menambah kota ke favorit
  Future<bool> addFavorite(LocationModel location) async {
    final list = await getFavorites();
    if (!list.any((loc) => loc == location)) {
      list.insert(0, location);
      await saveFavorites(list);
      return true;
    }
    return false;
  }

  /// Menghapus kota dari favorit
  Future<bool> removeFavorite(LocationModel location) async {
    final list = await getFavorites();
    final initialLength = list.length;
    list.removeWhere((loc) => loc == location);
    if (list.length != initialLength) {
      await saveFavorites(list);
      return true;
    }
    return false;
  }

  /// Cek apakah lokasi ini difavoritkan
  Future<bool> isFavorite(LocationModel location) async {
    final list = await getFavorites();
    return list.any((loc) => loc == location);
  }

  /// Mendapatkan riwayat pencarian
  Future<List<LocationModel>> getSearchHistory() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_keyHistory);
      if (jsonString == null || jsonString.isEmpty) return [];
      return LocationModel.decodeList(jsonString);
    } catch (e) {
      return [];
    }
  }

  /// Menambah item ke riwayat pencarian (maksimal 10 item terbaru)
  Future<void> addSearchHistory(LocationModel location) async {
    try {
      final prefs = await _getPrefs();
      final list = await getSearchHistory();
      list.removeWhere((loc) => loc == location);
      list.insert(0, location);
      if (list.length > 10) {
        list.removeRange(10, list.length);
      }
      await prefs.setString(_keyHistory, LocationModel.encodeList(list));
    } catch (_) {}
  }

  /// Menghapus seluruh riwayat pencarian
  Future<void> clearSearchHistory() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyHistory);
  }

  /// Menyimpan lokasi terakhir yang sedang dibuka pengguna
  Future<void> saveLastLocation(LocationModel location) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyLastLocation, jsonEncode(location.toJson()));
  }

  /// Membaca lokasi terakhir yang dibuka pengguna saat aplikasi pertama kali launch
  Future<LocationModel?> getLastLocation() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_keyLastLocation);
      if (jsonString == null || jsonString.isEmpty) return null;
      return LocationModel.fromJson(jsonDecode(jsonString));
    } catch (_) {
      return null;
    }
  }
}
