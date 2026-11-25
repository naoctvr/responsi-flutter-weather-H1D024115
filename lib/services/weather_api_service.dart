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

  // Kamus alias nama kota dan provinsi populer di Indonesia
  static const Map<String, List<String>> _indonesianAliases = {
    'lampung': ['Bandarlampung', 'Bandar Lampung'],
    'jogja': ['Yogyakarta'],
    'yogya': ['Yogyakarta'],
    'solo': ['Surakarta'],
    'surakarta': ['Solo'],
    'aceh': ['Banda Aceh'],
    'bali': ['Denpasar'],
    'lombok': ['Mataram'],
    'papua': ['Jayapura'],
    'ujung pandang': ['Makassar'],
    'sulsel': ['Makassar'],
    'sumut': ['Kota Medan'],
    'sumbar': ['Kota Padang'],
    'sumsel': ['Kota Palembang'],
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

  /// Mencari lokasi kota dengan pembersihan duplikat dan pemfilteran cerdas
  Future<List<LocationModel>> searchLocation(String query) async {
    final trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.isEmpty) return [];

    try {
      // 1. Kumpulkan kueri utama, alias, dan variasi 'Kota <nama>'
      final queriesToFetch = <String>[trimmedQuery];
      if (_indonesianAliases.containsKey(trimmedQuery)) {
        queriesToFetch.addAll(_indonesianAliases[trimmedQuery]!);
      }
      if (!trimmedQuery.startsWith('kota ') && trimmedQuery.length >= 3) {
        queriesToFetch.add('Kota $trimmedQuery');
      }

      final List<LocationModel> rawResults = [];
      final Set<int> seenIds = {};

      for (final q in queriesToFetch) {
        final results = await _fetchRawGeocoding(q);
        for (final item in results) {
          if (item.id != null) {
            if (!seenIds.contains(item.id)) {
              seenIds.add(item.id!);
              rawResults.add(item);
            }
          } else {
            rawResults.add(item);
          }
        }
      }

      if (rawResults.isEmpty) return [];

      final aliases = _indonesianAliases[trimmedQuery]?.map((a) => a.toLowerCase()).toList() ?? [];

      // 2. Cek apakah ada hasil dari Indonesia
      final hasIndonesianResults = rawResults.any(
        (loc) => loc.countryCode?.toUpperCase() == 'ID' || loc.country?.toLowerCase() == 'indonesia',
      );

      // 3. Filter: Jika ada hasil dari Indonesia, BUANG SEMUA HASIL LUAR NEGERI
      List<LocationModel> pool = hasIndonesianResults
          ? rawResults
              .where((loc) =>
                  loc.countryCode?.toUpperCase() == 'ID' ||
                  loc.country?.toLowerCase() == 'indonesia')
              .toList()
          : rawResults;

      // Cek apakah ada kota / entitas utama dengan populasi signifikan atau status ibukota
      final hasMajorCity = pool.any(
        (loc) =>
            (loc.population != null && loc.population! >= 20000) ||
            (loc.featureCode != null && ['PPLC', 'PPLA', 'PPLA2'].contains(loc.featureCode)) ||
            loc.name.toLowerCase().startsWith('kota '),
      );

      // Cek apakah ada hasil yang provinsinya cocok dengan nama pencarian (misal "lampung" -> "Provinsi Lampung")
      final hasMatchingProvince = pool.any(
        (loc) => loc.admin1?.toLowerCase().contains(trimmedQuery) ?? false,
      );

      // 4. Buang noise / kampung kecil tanpa data populasi & non-kota:
      pool = pool.where((loc) {
        // Buang bandara/pulau jika kota/pemukiman tersedia
        if (loc.featureCode == 'AIRP' || loc.featureCode == 'ISL') {
          return false;
        }

        final nameLower = loc.name.toLowerCase();
        final isMajorEntity = (loc.population != null && loc.population! >= 20000) ||
            (loc.featureCode != null && ['PPLC', 'PPLA', 'PPLA2'].contains(loc.featureCode)) ||
            nameLower.startsWith('kota ');

        // Jika sudah ada kota utama (e.g. Jambi, Medan, Solo, Bogor):
        // Buang semua kampung kecil (PPL/PPLA4) tanpa populasi atau populasi < 5000!
        if (hasMajorCity && !isMajorEntity) {
          return false;
        }

        // Jika mencari nama provinsi (misal lampung), buang desa di provinsi lain
        if (hasMatchingProvince) {
          final inTargetProvince = loc.admin1?.toLowerCase().contains(trimmedQuery) ?? false;
          if (!inTargetProvince && (loc.population == null || loc.population! < 10000)) {
            return false;
          }
        }

        // Cek kecocokan nama atau alias
        final isExactMatch = nameLower == trimmedQuery ||
            nameLower == 'kota $trimmedQuery' ||
            nameLower == 'kabupaten $trimmedQuery' ||
            aliases.any((alias) => nameLower == alias || nameLower == 'kota $alias');

        final isMinorHamlet = (loc.population == null || loc.population! < 5000) &&
            (loc.featureCode == null || ['PPL', 'PPLA4', 'PPLA3'].contains(loc.featureCode));

        if (isMinorHamlet && !isExactMatch) {
          return false;
        }

        return true;
      }).toList();

      // 5. DEDUPLIKASI KOTA YANG SAMA:
      // Kelompokkan berdasarkan base name (tanpa kata 'Kota', 'Kabupaten', 'Bandar')
      final Map<String, List<LocationModel>> groupedByName = {};
      for (final loc in pool) {
        final baseKey = loc.name
            .toLowerCase()
            .replaceAll('kota ', '')
            .replaceAll('kabupaten ', '')
            .replaceAll('kodya ', '')
            .replaceAll('bandar ', '')
            .trim();
        groupedByName.putIfAbsent(baseKey, () => []).add(loc);
      }

      final List<LocationModel> deduplicatedList = [];
      for (final entry in groupedByName.entries) {
        final group = entry.value;
        // Urutkan kandidat dalam grup yang sama untuk mengambil kota terpenting
        group.sort((a, b) {
          final rankA = _calculateInternalRank(a, trimmedQuery, aliases);
          final rankB = _calculateInternalRank(b, trimmedQuery, aliases);
          return rankB.compareTo(rankA);
        });
        // Ambil hanya 1 kota terbaik untuk nama yang sama persis
        deduplicatedList.add(group.first);
      }

      // 6. Urutkan seluruh daftar akhir berdasarkan relevansi pencarian pengguna
      deduplicatedList.sort((a, b) {
        final scoreA = _calculateSearchRelevance(a, trimmedQuery, aliases);
        final scoreB = _calculateSearchRelevance(b, trimmedQuery, aliases);
        return scoreB.compareTo(scoreA);
      });

      return deduplicatedList.take(10).toList();
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

  /// Menilai ranking kepentingan kota untuk deduplikasi nama identik
  int _calculateInternalRank(LocationModel loc, String query, List<String> aliases) {
    int rank = 0;
    final admin1Lower = loc.admin1?.toLowerCase() ?? '';
    final nameLower = loc.name.toLowerCase();

    // Keselarasan dengan provinsi atau alias pencarian
    if (admin1Lower.contains(query) || aliases.any((a) => admin1Lower.contains(a))) {
      rank += 10000000;
    }

    final feat = loc.featureCode ?? '';
    if (feat == 'PPLC') {
      rank += 20000000; // Ibukota negara
    } else if (feat == 'PPLA') {
      rank += 15000000; // Ibukota provinsi
    } else if (feat.startsWith('PPLA2') || nameLower.startsWith('kota ')) {
      rank += 10000000; // Ibukota kabupaten / kotamadya
    } else if (feat.startsWith('PPLA3')) {
      rank += 2000000;
    }

    if (loc.population != null && loc.population! > 0) {
      rank += loc.population!;
    }

    return rank;
  }

  /// Menghitung skor relevansi akhir untuk urutan tampilan
  int _calculateSearchRelevance(LocationModel loc, String query, List<String> aliases) {
    int score = 0;
    final nameLower = loc.name.toLowerCase();
    final admin1Lower = loc.admin1?.toLowerCase() ?? '';
    final admin2Lower = loc.admin2?.toLowerCase() ?? '';
    final feat = loc.featureCode ?? '';
    final pop = loc.population ?? 0;

    // Kecocokan nama persis atau alias
    final isExactOrAlias = nameLower == query ||
        nameLower == 'kota $query' ||
        nameLower.contains(query) ||
        aliases.any((alias) => nameLower == alias || nameLower == 'kota $alias' || nameLower.contains(alias));

    if (isExactOrAlias) score += 100000;
    if (nameLower.startsWith(query) || aliases.any((a) => nameLower.startsWith(a))) score += 30000;
    if (admin1Lower.contains(query) || admin2Lower.contains(query) || aliases.any((a) => admin1Lower.contains(a))) {
      score += 50000;
    }

    // Prioritas status ibukota / kota
    final isCityOrRegency = feat == 'PPLC' ||
        feat == 'PPLA' ||
        feat.startsWith('PPLA2') ||
        nameLower.startsWith('kota ') ||
        nameLower.startsWith('kabupaten ');

    if (feat == 'PPLC') {
      score += 100000;
    } else if (feat == 'PPLA') {
      score += 80000;
    } else if (isCityOrRegency) {
      score += 50000;
    } else if (feat.startsWith('PPLA3')) {
      score += 20000;
    }

    // Bobot populasi
    if (pop > 1000000) {
      score += 60000;
    } else if (pop > 500000) {
      score += 45000;
    } else if (pop > 100000) {
      score += 35000;
    } else if (pop > 20000) {
      score += 20000;
    } else if (pop > 0) {
      score += 10000;
    }

    return score;
  }
}
