import 'dart:convert';

class LocationModel {
  final int? id;
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1;
  final String? admin2;
  final String? countryCode;
  final int? population;
  final String? featureCode;

  LocationModel({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
    this.admin2,
    this.countryCode,
    this.population,
    this.featureCode,
  });

  /// Nama lengkap yang ramah pengguna
  String get displayName {
    final parts = <String>[name];
    if (admin2 != null && admin2!.isNotEmpty && admin2 != name) {
      parts.add(admin2!);
    }
    if (admin1 != null && admin1!.isNotEmpty && admin1 != name && admin1 != admin2) {
      parts.add(admin1!);
    }
    if (country != null && country!.isNotEmpty) {
      parts.add(country!);
    }
    return parts.join(', ');
  }

  String get subtitle {
    final parts = <String>[];
    if (admin2 != null && admin2!.isNotEmpty && admin2 != name) {
      parts.add(admin2!);
    }
    if (admin1 != null && admin1!.isNotEmpty && admin1 != name && admin1 != admin2) {
      parts.add(admin1!);
    }
    if (country != null && country!.isNotEmpty) {
      parts.add(country!);
    }
    return parts.isEmpty
        ? 'Koordinat: ${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}'
        : parts.join(', ');
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? 'Lokasi Tidak Dikenal',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String?,
      admin1: json['admin1'] as String?,
      admin2: json['admin2'] as String?,
      countryCode: json['country_code'] as String?,
      population: (json['population'] as num?)?.toInt(),
      featureCode: json['feature_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'admin1': admin1,
      'admin2': admin2,
      'country_code': countryCode,
      'population': population,
      'feature_code': featureCode,
    };
  }

  static String encodeList(List<LocationModel> list) {
    return jsonEncode(list.map((loc) => loc.toJson()).toList());
  }

  static List<LocationModel> decodeList(String jsonString) {
    if (jsonString.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((item) => LocationModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LocationModel) return false;
    if (id != null && other.id != null && id == other.id) {
      return true;
    }
    return name.toLowerCase() == other.name.toLowerCase() &&
        (latitude - other.latitude).abs() < 0.05 &&
        (longitude - other.longitude).abs() < 0.05;
  }

  @override
  int get hashCode {
    if (id != null) return id.hashCode;
    return name.toLowerCase().hashCode ^ latitude.round().hashCode ^ longitude.round().hashCode;
  }
}
