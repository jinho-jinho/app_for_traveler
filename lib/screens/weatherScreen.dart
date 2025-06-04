import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WeatherScreen extends StatefulWidget {
  // 1. initialWeatherData 파라미터 추가
  final Map<String, dynamic>? initialWeatherData;

  const WeatherScreen({
    super.key,
    this.initialWeatherData, // 생성자에 추가
  });

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}
class _WeatherScreenState extends State<WeatherScreen> {
  var latitude = 0.0;
  var longitude = 0.0;

  Future<Map<String, dynamic>>? weatherData;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  void _loadWeather() async {
    final loc = await _getCurrentLocation();
    if (loc != null) {
      setState(() {
        latitude = loc.latitude;
        longitude = loc.longitude;
        weatherData = fetchWeatherData();
      });
    }
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

  }

  Future<Map<String, dynamic>> fetchWeatherData() async {
    //return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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
              if (weatherData == null) {
                return const Center(child: Text("Loading location..."));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                return weatherWidget(snapshot.data!);
              } else {
                return const Center(child: Text('No weather data.'));
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
                  height: 210, // 고정 높이 or 필요시 맞춤 조정
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/images/korea.png', // 원하는 이미지 경로
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Set Location',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _showLocationPickerDialog,
                              icon: const Icon(Icons.map),
                              label: const Text('Pick on Map'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                Text('$todayLabel Hourly Forecast',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                            const SizedBox(height: 5),
                            Image.asset(iconPath, width: 40, errorBuilder: (_, __, ___) {
                              return Image.asset('assets/weather/01d.png', width: 40);
                            }),
                            const SizedBox(height: 5),
                            Text('$temp°C', style: const TextStyle(fontSize: 15)),
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

      double minTemp = items.first['main']['temp_min'].toDouble();
      double maxTemp = items.first['main']['temp_max'].toDouble();
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

  void _showLocationPickerDialog() {
    LatLng initialMarkerPosition = LatLng(latitude, longitude);
    LatLng selectedPosition = initialMarkerPosition;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Location'),
          content: SizedBox(
            height: 400,
            width: 300,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: initialMarkerPosition,
                    zoom: 15,
                  ),
                  onMapCreated: (_) {},
                  onCameraMove: (position) {
                    selectedPosition = position.target;
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('selected_position'),
                      position: initialMarkerPosition,
                    ),
                  },
                ),
                const Center(
                  child: Icon(Icons.add, size: 30, color: Colors.red),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  latitude = selectedPosition.latitude;
                  longitude = selectedPosition.longitude;
                  weatherData = fetchWeatherData();
                });
                Navigator.pop(context);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
