import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final double latitude = 43.47;
  final double longitude = 142.64;

  late Future<Map<String, dynamic>> weatherData;

  @override
  void initState() {
    super.initState();
    weatherData = fetchWeatherData();
  }

  Future<Map<String, dynamic>> fetchWeatherData() async {
    const apiKey = 'd466dff3cefa829496644e53b72c2940';
    final dio = Dio();

    final weatherResponse = await dio.get(
      'https://api.openweathermap.org/data/2.5/weather',
      queryParameters: {
        'lat': latitude,
        'lon': longitude,
        'appid': apiKey,
        'units': 'metric',
      },
    );

    final forecastResponse = await dio.get(
      'https://api.openweathermap.org/data/2.5/forecast',
      queryParameters: {
        'lat': latitude,
        'lon': longitude,
        'appid': apiKey,
        'units': 'metric',
      },
    );

    return {
      'weather': weatherResponse.data,
      'forecast': forecastResponse.data,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background1.jpg',
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: weatherData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return weatherWidget(snapshot.data!);
                } else {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget weatherWidget(Map<String, dynamic> data) {
    final current = data['weather'];
    final forecast = data['forecast'];
    final List<dynamic> forecastList = forecast['list'];

    final temp = current['main']['temp'].toStringAsFixed(1);
    final feelsLike = current['main']['feels_like'].toStringAsFixed(1);
    final desc = current['weather'][0]['description'];
    final iconCode = current['weather'][0]['icon'];
    final city = current['name'];
    final iconPath = 'assets/weather/$iconCode.png';

    final today = DateTime.fromMillisecondsSinceEpoch(forecastList[0]['dt'] * 1000);
    final todayLabel = '${today.month}/${today.day}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 현재 날씨 카드
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(city, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                      Text('$temp°C', style: const TextStyle(fontSize: 40)),
                      const SizedBox(height: 6),
                      Image.asset(iconPath, width: 40),
                      Text(desc, style: const TextStyle(fontSize: 16)),
                      Text('Feels like: $feelsLike°C', style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: const [
                      // 지도 좌표 선택 등 추가 예정
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 시간별 예보
          Container(
            height: 180, 
            decoration: BoxDecoration(
              color: Colors.blueGrey.withOpacity(0.6),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$todayLabel Hourly Forecast',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Expanded( 
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      final item = forecastList[index];
                      final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
                      final time = '${dt.hour}:00';
                      final temp = item['main']['temp'].toStringAsFixed(0);
                      final icon = item['weather'][0]['icon'];
                      final iconPath = 'assets/weather/$icon.png';

                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(time),
                            const SizedBox(height: 5,),
                            Image.asset(
                              iconPath,
                              width: 40,
                              errorBuilder: (context, _, __) =>
                                  Image.asset('assets/weather/01d.png', width: 40),
                            ),
                            const SizedBox(height: 5,),
                            Text('$temp°C', style: TextStyle(fontSize: 15),),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),


          const SizedBox(height: 20),

          // 일간 예보
          Container(
            decoration: BoxDecoration(
              color: Colors.blueGrey.withOpacity(0.6),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('5-Day Forecast',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._buildDailyForecast(forecastList),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDailyForecast(List<dynamic> forecastList) {
    final Map<String, List<Map<String, dynamic>>> dailyMap = {};

    for (var item in forecastList) {
      final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      final dateKey = '${dt.year}-${dt.month}-${dt.day}';

      dailyMap.putIfAbsent(dateKey, () => []);
      dailyMap[dateKey]!.add(item);
    }

    final widgets = <Widget>[];
    final keys = dailyMap.keys.take(5);

    for (final key in keys) {
      final items = dailyMap[key]!;

      double minTemp = items.first['main']['temp_min'];
      double maxTemp = items.first['main']['temp_max'];
      String icon = items.first['weather'][0]['icon'];
      final dtSample = DateTime.fromMillisecondsSinceEpoch(items.first['dt'] * 1000);
      final label = '${dtSample.month}/${dtSample.day}';

      for (final item in items) {
        final tMin = (item['main']['temp_min']).toDouble();
        final tMax = (item['main']['temp_max']).toDouble();
        if (tMin < minTemp) minTemp = tMin;
        if (tMax > maxTemp) maxTemp = tMax;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 16))),
              Image.asset('assets/weather/$icon.png', width: 30),
              Expanded(
                flex: 3,
                child: Text(
                  '    Low: ${minTemp.toStringAsFixed(0)}°C / High: ${maxTemp.toStringAsFixed(0)}°C',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }
}
