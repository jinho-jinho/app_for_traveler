// weatherScreen.dart
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
    const apiKey = 'd466dff3cefa829496644e53b72c2940'; // 🔴 실제 OpenWeatherMap API 키로 교체 필요
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 현재 날씨 카드
          Container(
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(city, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('$temp°C', style: const TextStyle(fontSize: 60)),
                const SizedBox(height: 8),
                Image.asset(iconPath, width: 50),
                Text(desc, style: const TextStyle(fontSize: 20)),
                Text('Feels like: $feelsLike°C', style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 시간별 예보 리스트
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.blueGrey.withOpacity(0.6),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 8, // 24시간 예보용
              itemBuilder: (context, index) {
                final item = forecastList[index];
                final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
                final time = '${dt.hour}시';
                final temp = item['main']['temp'].toStringAsFixed(0);
                final icon = item['weather'][0]['icon'];
                final iconPath = 'assets/weather/$icon.png';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(time),
                      Image.asset(
                        iconPath,
                        width: 40,
                        errorBuilder: (context, _, __) => Image.asset('assets/weather/01d.png', width: 40),
                      ),
                      Text('$temp°C'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
