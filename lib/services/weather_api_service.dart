import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';
import '../models/weather_model.dart';

class WeatherApiService {
  static const String _forecastBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _geocodingBaseUrl = 'https://geocoding-api.open-meteo.com/v1/search';
  static const Duration _timeoutDuration = Duration(seconds: 12);

  // Kamus alias pencarian kota & provinsi populer di Indonesia
  static const Map<String, List<String>> _indonesianAliases = {
    'lampung': ['Bandarlampung', 'Bandar Lampung'],
    'jogja': ['Yogyakarta'],
    'yogya': ['Yogyakarta'],
    'aceh': ['Banda Aceh'],
    'bali': ['Denpasar'],
    'lombok': ['Mataram'],
    'papua': ['Jayapura'],
    'ujung pandang': ['Makassar'],
    'sulsel': ['Makassar'],
    'sumut': ['Medan'],
    'sumbar': ['Padang'],
    'sumsel': ['Palembang'],
    'riau': ['Pekanbaru'],
    'kalsel': ['Banjarmasin'],
    'kaltim': ['Samarinda', 'Balikpapan'],
    'kalbar': ['Pontianak'],
    'sulteng': ['Palu'],
    'sulut': ['Manado'],
    'sultra': ['Kendari'],
    'gorontalo': ['Gorontalo'],
    'maluku': ['Ambon'],
    'banten': ['Serang', 'Tangerang'],
    'ntb': ['Mataram'],
    'ntt': ['Kupang'],
  };

  final http.Client _client;

  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Mengambil data cuaca berdasarkan koordinat latitude & longitude
  Future<WeatherModel> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final queryParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
      'timezone': 'auto',
    };

    final uri = Uri.parse(_forecastBaseUrl).replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw Exception('Gagal memuat data cuaca (Status: ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } on TimeoutException {
      throw Exception('Waktu permintaan habis. Silakan coba beberapa saat lagi.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Terjadi kesalahan tidak terduga: $e');
    }
  }

  /// Mencari lokasi kota berdasarkan input teks nama kota dengan pemeringkatan pintar
  Future<List<LocationModel>> searchLocation(String query) async {
    final trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.isEmpty) return [];

    try {
      // 1. Kumpulkan kueri utama dan alias yang relevan
      final queriesToFetch = <String>[trimmedQuery];
      if (_indonesianAliases.containsKey(trimmedQuery)) {
        queriesToFetch.addAll(_indonesianAliases[trimmedQuery]!);
      }

      final List<LocationModel> allResults = [];
      final Set<int> seenIds = {};

      for (final q in queriesToFetch) {
        final results = await _fetchRawGeocoding(q);
        for (final item in results) {
          if (item.id != null) {
            if (!seenIds.contains(item.id)) {
              seenIds.add(item.id!);
              allResults.add(item);
            }
          } else {
            if (!allResults.contains(item)) {
              allResults.add(item);
            }
          }
        }
      }

      if (allResults.isEmpty) return [];

      // 2. Cek apakah ada hasil dari Indonesia
      final hasIndonesianResults = allResults.any(
        (loc) => loc.countryCode?.toUpperCase() == 'ID' || loc.country?.toLowerCase() == 'indonesia',
      );

      // 3. Filter: Jika ada hasil dari Indonesia, utamakan Indonesia & hapus kota terpencil luar negeri yang membingungkan
      final filteredResults = allResults.where((loc) {
        final isIndonesia =
            loc.countryCode?.toUpperCase() == 'ID' || loc.country?.toLowerCase() == 'indonesia';
        if (hasIndonesianResults && !isIndonesia) {
          // Hanya izinkan hasil luar negeri jika memiliki populasi besar (misal kota metropolitan dunia)
          return (loc.population ?? 0) > 200000;
        }
        return true;
      }).toList();

      // 4. Hitung skor relevansi agar kota penting/ibu kota selalu di atas
      filteredResults.sort((a, b) {
        final scoreA = _calculateRelevanceScore(a, trimmedQuery);
        final scoreB = _calculateRelevanceScore(b, trimmedQuery);
        return scoreB.compareTo(scoreA); // Urutan terbesar ke terkecil
      });

      return filteredResults.take(15).toList();
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } on TimeoutException {
      throw Exception('Waktu pencarian habis. Silakan coba lagi.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Terjadi kesalahan saat mencari kota: $e');
    }
  }

  Future<List<LocationModel>> _fetchRawGeocoding(String query) async {
    final queryParams = {
      'name': query,
      'count': '25',
      'language': 'id',
      'format': 'json',
    };

    final uri = Uri.parse(_geocodingBaseUrl).replace(queryParameters: queryParams);
    final response = await _client.get(uri).timeout(_timeoutDuration);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey('results') && data['results'] != null) {
        final List<dynamic> results = data['results'];
        return results.map((item) => LocationModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    }
    return [];
  }

  /// Menghitung bobot relevansi kota berdasarkan kecocokan nama, negara, dan populasi
  int _calculateRelevanceScore(LocationModel loc, String query) {
    int score = 0;
    final nameLower = loc.name.toLowerCase();
    final adminLower = loc.admin1?.toLowerCase() ?? '';
    final isIndonesia =
        loc.countryCode?.toUpperCase() == 'ID' || loc.country?.toLowerCase() == 'indonesia';

    // Prioritas tinggi untuk Indonesia
    if (isIndonesia) score += 10000;

    // Kecocokan nama kota persis
    if (nameLower == query) {
      score += 8000;
    } else if (nameLower.startsWith(query)) {
      score += 4000;
    } else if (nameLower.contains(query)) {
      score += 2000;
    }

    // Kecocokan nama provinsi (misal cari "lampung" maka "Bandarlampung" di "Provinsi Lampung" dapat skor tinggi)
    if (adminLower.contains(query)) {
      score += 5000;
    }

    // Prioritas berdasarkan tipe wilayah administratif Open-Meteo
    final feat = loc.featureCode ?? '';
    if (feat == 'PPLC') {
      score += 4000; // Ibukota negara (Jakarta, dsb.)
    } else if (feat.startsWith('PPLA')) {
      score += 3000; // Ibukota provinsi / kota besar
    } else if (feat.startsWith('ADM')) {
      score += 2000; // Wilayah administratif
    }

    // Prioritas jumlah penduduk kota
    if (loc.population != null && loc.population! > 0) {
      score += (loc.population! / 1000).clamp(0, 5000).toInt();
    }

    return score;
  }
}
