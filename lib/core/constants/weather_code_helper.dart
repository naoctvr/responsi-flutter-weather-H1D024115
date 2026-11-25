import 'package:flutter/material.dart';

class WeatherCodeHelper {
  /// Mengembalikan deskripsi cuaca dalam Bahasa Indonesia berdasarkan WMO code
  static String getDescription(int code) {
    switch (code) {
      case 0:
        return 'Cerah';
      case 1:
        return 'Sebagian Besar Cerah';
      case 2:
        return 'Berawan Sebagian';
      case 3:
        return 'Mendung / Berawan Tebal';
      case 45:
        return 'Berkabut';
      case 48:
        return 'Kabut Tebal Berembun';
      case 51:
        return 'Gerimis Ringan';
      case 53:
        return 'Gerimis Sedang';
      case 55:
        return 'Gerimis Lebat';
      case 56:
      case 57:
        return 'Gerimis Dingin / Es';
      case 61:
        return 'Hujan Ringan';
      case 63:
        return 'Hujan Sedang';
      case 65:
        return 'Hujan Lebat';
      case 66:
      case 67:
        return 'Hujan Dingin / Membeku';
      case 71:
        return 'Salju Ringan';
      case 73:
        return 'Salju Sedang';
      case 75:
        return 'Salju Lebat';
      case 77:
        return 'Hujan Butiran Es';
      case 80:
        return 'Hujan Guyur Ringan';
      case 81:
        return 'Hujan Guyur Sedang';
      case 82:
        return 'Hujan Badai Sangat Lebat';
      case 85:
      case 86:
        return 'Hujan Salju Guyur';
      case 95:
        return 'Badai Petir';
      case 96:
      case 99:
        return 'Badai Petir Disertai Hujan Es';
      default:
        return 'Cuaca Tidak Diketahui';
    }
  }

  /// Mengembalikan ikon Material yang representatif sesuai WMO code
  static IconData getIcon(int code) {
    switch (code) {
      case 0:
        return Icons.wb_sunny_rounded;
      case 1:
      case 2:
        return Icons.wb_cloudy_rounded;
      case 3:
        return Icons.cloud_rounded;
      case 45:
      case 48:
        return Icons.foggy;
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return Icons.grain_rounded;
      case 61:
      case 63:
      case 80:
      case 81:
        return Icons.water_drop_rounded;
      case 65:
      case 82:
        return Icons.thunderstorm_rounded;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return Icons.ac_unit_rounded;
      case 95:
      case 96:
      case 99:
        return Icons.flash_on_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  /// Mengembalikan gradien warna latar belakang yang cocok untuk status cuaca
  static List<Color> getGradient(int code) {
    if (code == 0 || code == 1) {
      return [const Color(0xFF38B2AC), const Color(0xFF3182CE)];
    } else if (code == 2 || code == 3) {
      return [const Color(0xFF4A5568), const Color(0xFF2D3748)];
    } else if (code >= 51 && code <= 67) {
      return [const Color(0xFF2B6CB0), const Color(0xFF1A365D)];
    } else if (code >= 80 && code <= 82) {
      return [const Color(0xFF2C5282), const Color(0xFF1A202C)];
    } else if (code >= 95) {
      return [const Color(0xFF44337A), const Color(0xFF1A202C)];
    }
    return [const Color(0xFF3182CE), const Color(0xFF2B6CB0)];
  }
}
