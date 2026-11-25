import 'package:flutter_test/flutter_test.dart';
import 'package:responsi_flutter_weather/core/constants/weather_code_helper.dart';
import 'package:responsi_flutter_weather/models/location_model.dart';
import 'package:responsi_flutter_weather/models/weather_model.dart';

void main() {
  group('WeatherCodeHelper Tests', () {
    test('Code 0 returns Cerah', () {
      expect(WeatherCodeHelper.getDescription(0), 'Cerah');
    });

    test('Code 3 returns Mendung / Berawan Tebal', () {
      expect(WeatherCodeHelper.getDescription(3), 'Mendung / Berawan Tebal');
    });

    test('Code 95 returns Badai Petir', () {
      expect(WeatherCodeHelper.getDescription(95), 'Badai Petir');
    });
  });

  group('LocationModel Tests', () {
    test('toJson and fromJson preserves data', () {
      final location = LocationModel(
        id: 123,
        name: 'Bandung',
        latitude: -6.9175,
        longitude: 107.6191,
        country: 'Indonesia',
        admin1: 'Jawa Barat',
      );

      final json = location.toJson();
      final decoded = LocationModel.fromJson(json);

      expect(decoded.name, 'Bandung');
      expect(decoded.latitude, -6.9175);
      expect(decoded.longitude, 107.6191);
      expect(decoded.country, 'Indonesia');
      expect(decoded.admin1, 'Jawa Barat');
    });

    test('displayName formats properly', () {
      final loc = LocationModel(
        name: 'Surabaya',
        latitude: -7.2575,
        longitude: 112.7521,
        country: 'Indonesia',
        admin1: 'Jawa Timur',
      );
      expect(loc.displayName, 'Surabaya, Jawa Timur, Indonesia');
    });
  });

  group('WeatherModel Tests', () {
    test('Parses Open-Meteo json correctly', () {
      final mockJson = {
        'latitude': -6.2,
        'longitude': 106.8,
        'timezone': 'Asia/Jakarta',
        'current': {
          'time': '2026-11-25T12:00',
          'temperature_2m': 28.5,
          'relative_humidity_2m': 80,
          'apparent_temperature': 32.1,
          'precipitation': 1.2,
          'weather_code': 61,
          'wind_speed_10m': 12.4,
        },
        'daily': {
          'time': ['2026-11-25', '2026-11-26'],
          'weather_code': [61, 80],
          'temperature_2m_max': [31.0, 30.0],
          'temperature_2m_min': [24.0, 23.5],
          'precipitation_probability_max': [85, 90],
        }
      };

      final model = WeatherModel.fromJson(mockJson);
      expect(model.current.temperature, 28.5);
      expect(model.current.relativeHumidity, 80);
      expect(model.current.apparentTemperature, 32.1);
      expect(model.current.precipitation, 1.2);
      expect(model.current.weatherCode, 61);
      expect(model.current.windSpeed, 12.4);
      expect(model.daily.length, 2);
      expect(model.daily[0].maxTemp, 31.0);
      expect(model.daily[0].minTemp, 24.0);
      expect(model.daily[0].precipitationProbabilityMax, 85);
    });
  });
}
