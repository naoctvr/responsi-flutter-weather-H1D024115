class CurrentWeather {
  final double temperature; // current.temperature_2m (°C)
  final int relativeHumidity; // current.relative_humidity_2m (%)
  final double apparentTemperature; // current.apparent_temperature (°C)
  final double precipitation; // current.precipitation (mm)
  final int weatherCode; // current.weather_code (WMO)
  final double windSpeed; // current.wind_speed_10m (km/h)
  final DateTime time;

  CurrentWeather({
    required this.temperature,
    required this.relativeHumidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    required this.time,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      apparentTemperature: (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      time: json['time'] != null ? DateTime.tryParse(json['time']) ?? DateTime.now() : DateTime.now(),
    );
  }
}

class DailyForecast {
  final DateTime date;
  final int weatherCode; // daily.weather_code
  final double maxTemp; // daily.temperature_2m_max (°C)
  final double minTemp; // daily.temperature_2m_min (°C)
  final int precipitationProbabilityMax; // daily.precipitation_probability_max (%)

  DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
    required this.precipitationProbabilityMax,
  });
}

class WeatherModel {
  final double latitude;
  final double longitude;
  final String timezone;
  final CurrentWeather current;
  final List<DailyForecast> daily;

  WeatherModel({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.current,
    required this.daily,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'] as Map<String, dynamic>? ?? {};
    final dailyJson = json['daily'] as Map<String, dynamic>? ?? {};

    final List<DailyForecast> dailyList = [];
    final times = dailyJson['time'] as List<dynamic>? ?? [];
    final weatherCodes = dailyJson['weather_code'] as List<dynamic>? ?? [];
    final maxTemps = dailyJson['temperature_2m_max'] as List<dynamic>? ?? [];
    final minTemps = dailyJson['temperature_2m_min'] as List<dynamic>? ?? [];
    final precipProbs = dailyJson['precipitation_probability_max'] as List<dynamic>? ?? [];

    for (int i = 0; i < times.length; i++) {
      dailyList.add(DailyForecast(
        date: DateTime.tryParse(times[i].toString()) ?? DateTime.now().add(Duration(days: i)),
        weatherCode: i < weatherCodes.length ? (weatherCodes[i] as num).toInt() : 0,
        maxTemp: i < maxTemps.length ? (maxTemps[i] as num).toDouble() : 0.0,
        minTemp: i < minTemps.length ? (minTemps[i] as num).toDouble() : 0.0,
        precipitationProbabilityMax: i < precipProbs.length ? (precipProbs[i] as num).toInt() : 0,
      ));
    }

    return WeatherModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timezone: json['timezone'] as String? ?? 'auto',
      current: CurrentWeather.fromJson(currentJson),
      daily: dailyList,
    );
  }
}
