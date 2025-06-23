import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_for_traveler/models/place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class KakaoApiService {
  static const String kakaoApiKey = '008935e7ada68384e86fbd19dcb8fc10'; // 주어진 Kakao API 키
  static const String categoryBaseUrl = 'https://dapi.kakao.com/v2/local/search/category.json';
  static const String keywordBaseUrl = 'https://dapi.kakao.com/v2/local/search/keyword.json';
  static const String coordToAddressUrl = 'https://dapi.kakao.com/v2/local/geo/coord2address.json';

  // 여러 지역 좌표 추가
  static const List<LatLng> keyPositions = [
    LatLng(36.1195, 128.3445),
    LatLng(36.1050, 128.3330),
    LatLng(36.1300, 128.3600), 
    LatLng(36.1500, 128.3200),
    LatLng(36.1450, 128.4100),
    LatLng(35.8714, 128.6014), // 대구
    LatLng(35.8562, 129.2247), // 경주
    LatLng(37.5665, 126.9780), // 서울
    LatLng(35.1796, 129.0756), // 부산
  ];
  static const int radius = 20000; // 반경 20km
  static const int maxPlacesPerCategory = 10000;

  Future<List<Place>> fetchPharmacies() async {
    return _fetchPlacesByCategory('PM9', '응급 & 안전', '약국 위치');
  }

  Future<List<Place>> fetchPoliceStations() async {
    final places = await _fetchPlacesByCategory('PO3', '응급 & 안전', '경찰서/파출소');
    // 경찰서 또는 파출소만 필터링
    return places.where((place) {
      final categoryName = place.category.toLowerCase();
      return categoryName.contains('경찰서') || categoryName.contains('파출소') || categoryName.contains('지구대');
    }).toList();
  }

  Future<List<Place>> fetchAtms() async {
    return _fetchPlacesByCategory('AT4', '금융 & 환전', 'ATM기 위치');
  }

  Future<List<Place>> fetchBanks() async {
    return _fetchPlacesByCategory('BK9', '금융 & 환전', '은행 위치');
  }

  Future<List<Place>> fetchCurrencyExchanges() async {
    return _fetchPlacesByKeyword('환전소', '금융 & 환전', '환전소 위치');
  }

  Future<List<Place>> fetchPublicToilets() async {
    return _fetchPlacesByKeyword('공중 화장실', '편의시설', '공중 화장실');
  }

  Future<List<Place>> fetchLockers() async {
    return _fetchPlacesByKeyword('물품 보관함', '편의시설', '물품 보관함');
  }

  Future<List<Place>> fetchCafes() async {
    return _fetchPlacesByCategory('CE7', '카페', '카페');
  }

  Future<List<Place>> fetchRestaurants() async {
    return _fetchPlacesByCategory('FD6', '음식점', '음식점');
  }

  Future<List<Place>> fetchLandmarks() async {
    final placesFromCategory = await _fetchPlacesByCategory('AT4', '랜드마크', '랜드마크');
    final placesFromKeyword = await _fetchPlacesByKeyword('랜드마크', '랜드마크', '랜드마크');

    final allPlaces = [...placesFromCategory, ...placesFromKeyword];
    final uniquePlaces = <String, Place>{};
    for (var place in allPlaces) {
      if (uniquePlaces.containsKey(place.id)) {
        print('중복된 장소 발견: ID ${place.id}, 이름: ${place.name}');
      }
      uniquePlaces[place.id] = place;
    }

    print('랜드마크 총 데이터 개수 (중복 제거 후): ${uniquePlaces.length}');
    return uniquePlaces.values.toList();
  }

  // _getAddressFromCoordinates: 좌표를 주소로 변환
  // 역할: 카카오맵 좌표 -> 주소 변환 API 호출
  // 분류: 로직
  Future<String> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      final url = Uri.parse('$coordToAddressUrl?x=$lng&y=$lat');
      print('좌표 -> 주소 변환 API 요청 URL: $url');
      final response = await http.get(
        url,
        headers: {'Authorization': 'KakaoAK $kakaoApiKey'},
      );

      print('좌표 -> 주소 변환 API 응답 상태 코드: ${response.statusCode}');
      print('좌표 -> 주소 변환 API 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final documents = data['documents'] as List<dynamic>?;

        if (documents != null && documents.isNotEmpty) {
          final addressData = documents[0] as Map<String, dynamic>?;
          final address = addressData?['address']?['address_name'] as String? ?? '주소 정보 없음';
          return address;
        } else {
          print('좌표 -> 주소 변환: documents가 비어 있음');
          return '주소 정보 없음';
        }
      } else {
        print('좌표 -> 주소 변환 API 호출 실패: ${response.statusCode}, 본문: ${response.body}');
        return '주소 정보 없음';
      }
    } catch (e) {
      print('좌표 -> 주소 변환 실패: $e');
      return '주소 정보 없음';
    }
  }

  // _fetchPlacesByCategory: 카테고리별 장소 데이터 가져오기
  // 역할: 카카오맵 카테고리 API 호출로 장소 목록 생성
  // 분류: 로직
  Future<List<Place>> _fetchPlacesByCategory(String categoryCode, String category, String subcategory) async {
    List<Place> allPlaces = [];
    try {
      for (var position in keyPositions) {
        double lat = position.latitude;
        double lng = position.longitude;

        int page = 1;
        bool hasMore = true;

        while (hasMore && allPlaces.length < maxPlacesPerCategory) {
          final url = Uri.parse('$categoryBaseUrl?category_group_code=$categoryCode&page=$page&x=$lng&y=$lat&radius=$radius&sort=accuracy');
          print('카카오맵 API 요청 URL (카테고리, 좌표: $lat, $lng): $url');
          final response = await http.get(
            url,
            headers: {'Authorization': 'KakaoAK $kakaoApiKey'},
          );

          print('카카오맵 API 응답 상태 코드: ${response.statusCode}');
          print('카카오맵 API 응답 본문: ${response.body}');

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final List<dynamic> documents = data['documents'] as List<dynamic>;
            print('$subcategory 데이터 개수 (페이지 $page, 좌표: $lat, $lng): ${documents.length}');
            print('응답 데이터 (첫 번째 장소): ${documents.isNotEmpty ? documents[0] : "데이터 없음"}');

            for (var doc in documents) {
              final placeLat = double.tryParse(doc['y']?.toString() ?? '');
              final placeLng = double.tryParse(doc['x']?.toString() ?? '');
              if (placeLat == null || placeLng == null) {
                print('좌표 파싱 실패: ${doc['place_name']}');
                continue;
              }

              String address = doc['address_name']?.toString() ?? doc['road_address_name']?.toString() ?? '주소 정보 없음';

              // 주소 정보가 없으면 좌표를 사용해 주소 조회
              if (address == '주소 정보 없음') {
                address = await _getAddressFromCoordinates(placeLat, placeLng);
              }

              allPlaces.add(Place(
                id: doc['id']?.toString() ?? '',
                name: doc['place_name']?.toString() ?? '이름 없음',
                location: LatLng(placeLat, placeLng),
                category: doc['category_name']?.toString() ?? category, // category_name으로 세부 카테고리 설정
                subcategory: subcategory,
                isEncrypted: false,
                isUserAdded: false,
                address: address,
              ));
            }

            final meta = data['meta'] as Map<String, dynamic>?;
            hasMore = (meta?['is_end'] == false) && (page < 45) && (allPlaces.length < maxPlacesPerCategory);
            page++;
          } else {
            throw Exception('카카오맵 API 호출 실패: ${response.statusCode}, 본문: ${response.body}');
          }
        }
      }

      final uniquePlaces = <String, Place>{};
      for (var place in allPlaces) {
        if (uniquePlaces.containsKey(place.id)) {
          print('중복된 장소 발견: ID ${place.id}, 이름: ${place.name}');
        }
        uniquePlaces[place.id] = place;
      }

      print('$subcategory 총 데이터 개수 (중복 제거 후): ${uniquePlaces.length}');
      return uniquePlaces.values.toList();
    } catch (e) {
      print('$subcategory 데이터 로드 실패: $e');
      return [];
    }
  }

  // _fetchPlacesByKeyword: 키워드별 장소 데이터 가져오기
  // 역할: 카카오맵 키워드 API 호출로 장소 목록 생성
  // 분류: 로직
  Future<List<Place>> _fetchPlacesByKeyword(String keyword, String category, String subcategory) async {
    List<Place> allPlaces = [];
    try {
      for (var position in keyPositions) {
        double lat = position.latitude;
        double lng = position.longitude;

        int page = 1;
        bool hasMore = true;

        while (hasMore && allPlaces.length < maxPlacesPerCategory) {
          final url = Uri.parse('$keywordBaseUrl?query=$keyword&page=$page&x=$lng&y=$lat&radius=$radius&sort=accuracy');
          print('카카오맵 API 요청 URL (키워드, 좌표: $lat, $lng): $url');
          final response = await http.get(
            url,
            headers: {'Authorization': 'KakaoAK $kakaoApiKey'},
          );

          print('카카오맵 API 응답 상태 코드: ${response.statusCode}');
          print('카카오맵 API 응답 본문: ${response.body}');

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final List<dynamic> documents = data['documents'] as List<dynamic>;
            print('$subcategory 데이터 개수 (페이지 $page, 좌표: $lat, $lng): ${documents.length}');
            print('응답 데이터 (첫 번째 장소): ${documents.isNotEmpty ? documents[0] : "데이터 없음"}');

            for (var doc in documents) {
              final placeLat = double.tryParse(doc['y']?.toString() ?? '');
              final placeLng = double.tryParse(doc['x']?.toString() ?? '');
              if (placeLat == null || placeLng == null) {
                print('좌표 파싱 실패: ${doc['place_name']}');
                continue;
              }

              String address = doc['address_name']?.toString() ?? doc['road_address_name']?.toString() ?? '주소 정보 없음';

              // 주소 정보가 없으면 좌표를 사용해 주소 조회
              if (address == '주소 정보 없음') {
                address = await _getAddressFromCoordinates(placeLat, placeLng);
              }

              allPlaces.add(Place(
                id: doc['id']?.toString() ?? '',
                name: doc['place_name']?.toString() ?? '이름 없음',
                location: LatLng(placeLat, placeLng),
                category: doc['category_name']?.toString() ?? category, // category_name으로 세부 카테고리 설정
                subcategory: subcategory,
                isEncrypted: false,
                isUserAdded: false,
                address: address,
              ));
            }

            final meta = data['meta'] as Map<String, dynamic>?;
            hasMore = (meta?['is_end'] == false) && (page < 45) && (allPlaces.length < maxPlacesPerCategory);
            page++;
          } else {
            throw Exception('카카오맵 API 호출 실패: ${response.statusCode}, 본문: ${response.body}');
          }
        }
      }

      final uniquePlaces = <String, Place>{};
      for (var place in allPlaces) {
        if (uniquePlaces.containsKey(place.id)) {
          print('중복된 장소 발견: ID ${place.id}, 이름: ${place.name}');
        }
        uniquePlaces[place.id] = place;
      }

      print('$subcategory 총 데이터 개수 (중복 제거 후): ${uniquePlaces.length}');
      return uniquePlaces.values.toList();
    } catch (e) {
      print('$subcategory 데이터 로드 실패: $e');
      return [];
    }
  }
}