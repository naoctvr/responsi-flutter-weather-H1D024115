import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:responsi_flutter_weather/main.dart';
import 'package:responsi_flutter_weather/services/weather_api_service.dart';
import 'package:responsi_flutter_weather/views/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('WeatherApp builds and displays HomeScreen', (WidgetTester tester) async {
    final mockClient = MockClient((request) async {
      final mockData = {
        'latitude': -7.79,
        'longitude': 110.36,
        'timezone': 'Asia/Jakarta',
        'current': {
          'time': '2026-11-26T12:00',
          'temperature_2m': 27.0,
          'relative_humidity_2m': 80,
          'apparent_temperature': 30.0,
          'precipitation': 0.0,
          'weather_code': 1,
          'wind_speed_10m': 8.0,
        },
        'daily': {
          'time': ['2026-11-26'],
          'weather_code': [1],
          'temperature_2m_max': [31.0],
          'temperature_2m_min': [24.0],
          'precipitation_probability_max': [30],
        }
      };
      return http.Response(jsonEncode(mockData), 200);
    });

    final mockApiService = WeatherApiService(client: mockClient);

    await tester.pumpWidget(WeatherApp(apiService: mockApiService));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('CuacaKita'), findsOneWidget);
  });
}
