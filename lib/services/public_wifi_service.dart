import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_for_traveler/models/place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PublicWifiService {
  static const String apiKey = 'CTi/psmxgc5IoYjcSxtqmK7xc+DF4/kJADp/cfo+j54=';
  static const String baseUrl = 'http://api.odcloud.kr/api/15083112/v1/uddi:ec2c85b9-5644-4f53-8c1f-41b529981d8c';

  Future<List<Place>> fetchPublicWifis() async {
    final List<Place> wifiPlaces = [];
    int page = 1;
    const int perPage = 1000; // 한 페이지당 데이터 수

    while (true) {
      final url = '$baseUrl?page=$page&perPage=$perPage&serviceKey=$apiKey';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> wifiList = data['data'];

          for (var wifi in wifiList) {
            final double? lat = double.tryParse(wifi['위도']?.toString() ?? '');
            final double? lng = double.tryParse(wifi['경도']?.toString() ?? '');

            if (lat != null && lng != null) {
              wifiPlaces.add(Place(
                id: wifi['와이파이AP설치장소명']?.toString() ?? 'unknown',
                name: wifi['와이파이AP설치장소명']?.toString() ?? 'Unknown WiFi',
                location: LatLng(lat, lng), // LatLng 클래스 사용
                category: '공공 와이파이',
                subcategory: '공공 와이파이',
                isEncrypted: false,
                isFree: true,
                isUserAdded: false,
                reviews: [],
                reports: [],
              ));
            }
          }

          // 페이지 끝 확인
          if (wifiList.length < perPage) break;
          page++;
        } else {
          print('API 요청 실패: ${response.statusCode}');
          break;
        }
      } catch (e) {
        print('API 요청 중 오류: $e');
        break;
      }
    }

    return wifiPlaces;
  }
}