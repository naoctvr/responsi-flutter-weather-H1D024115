import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:responsi_flutter_weather/main.dart';
import 'package:responsi_flutter_weather/views/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('WeatherApp builds and displays HomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const WeatherApp());
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Cuaca Terkini'), findsOneWidget);
  });
}
