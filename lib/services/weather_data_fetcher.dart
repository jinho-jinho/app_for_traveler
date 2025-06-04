// lib/services/weather_data_fetcher.dart
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart'; // showDialog와 BuildContext를 위해 필요

class WeatherDataFetcher {
  // 중요: 'd466dff3cefa829496644e53b72c2940'는 예시 API 키입니다.
  // 실제 OpenWeatherMap API 키로 교체해야 합니다.
  // API 키는 https://openweathermap.org/api 에서 발급받을 수 있습니다.
  // 무료 계정의 경우 키 활성화까지 시간이 걸릴 수 있습니다 (몇 시간).
  final String _apiKey = 'd466dff3cefa829496644e53b72c2940'; // 여기에 실제 API 키를 입력하세요!
  final Dio _dio = Dio(); // Dio 인스턴스를 한 번만 생성

  /// 현재 기기의 위치(위도, 경도)를 가져옵니다.
  /// 필요한 권한을 요청하고 위치 서비스가 활성화되어 있는지 확인합니다.
  Future<Position?> getCurrentLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스가 활성화되어 있는지 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ignore: use_build_context_synchronously
      _showLocationServiceDialog(context); // context를 사용하기 때문에 lint 경고 무시
      return null;
    }

    // 위치 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission(); // 권한 요청
      if (permission == LocationPermission.denied) {
        // ignore: use_build_context_synchronously
        _showPermissionDeniedDialog(context); // context를 사용하기 때문에 lint 경고 무시
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // ignore: use_build_context_synchronously
      _showPermissionDeniedForeverDialog(context); // context를 사용하기 때문에 lint 경고 무시
      return null;
    }

    // 현재 위치 가져오기
    try {
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      print("위치 정보 가져오기 오류: $e");
      // ignore: use_build_context_synchronously
      _showErrorDialog(context, '위치 오류', '위치 정보를 가져오는 데 실패했습니다: $e'); // context를 사용하기 때문에 lint 경고 무시
      return null;
    }
  }

  /// OpenWeatherMap API에서 현재 날씨 및 5일 예보 데이터를 가져옵니다.
  Future<Map<String, dynamic>> fetchWeatherData(double lat, double lon) async {
    try {
      final weatherResponse = await _dio.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': _apiKey,
          'units': 'metric', // 온도를 섭씨로 가져오기
          'lang': 'kr', // 설명을 한국어로 가져오기
        },
      );

      final forecastResponse = await _dio.get(
        'https://api.openweathermap.org/data/2.5/forecast',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': _apiKey,
          'units': 'metric', // 온도를 섭씨로 가져오기
          'lang': 'kr', // 설명을 한국어로 가져오기
        },
      );

      return {
        'weather': weatherResponse.data,
        'forecast': forecastResponse.data,
      };
    } on DioException catch (e) {
      String errorMessage = 'OpenWeatherMap API 오류: ';
      if (e.response != null) {
        errorMessage += '상태 코드: ${e.response?.statusCode}, 응답: ${e.response?.data}';
      } else {
        errorMessage += e.message ?? '알 수 없는 네트워크 오류';
      }
      print(errorMessage);
      throw Exception('날씨 데이터를 가져오는 데 실패했습니다: $errorMessage');
    } catch (e) {
      print('알 수 없는 날씨 데이터 오류: $e');
      throw Exception('날씨 데이터를 가져오는 중 알 수 없는 오류가 발생했습니다: $e');
    }
  }

  // --- 헬퍼 다이얼로그 함수들 ---
  void _showLocationServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('위치 서비스 비활성화'),
          content: const Text('날씨 정보를 가져오려면 위치 서비스를 활성화해야 합니다.'),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('위치 권한 거부'),
          content: const Text('위치 권한이 거부되었습니다. 날씨 정보를 표시할 수 없습니다.'),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedForeverDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('위치 권한 영구 거부'),
          content: const Text('위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 수동으로 권한을 부여해야 합니다.'),
          actions: <Widget>[
            TextButton(
              child: const Text('설정으로 이동'),
              onPressed: () {
                Geolocator.openAppSettings();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}