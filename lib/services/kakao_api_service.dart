import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_for_traveler/models/place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Kakao API를 통해 장소 데이터를 가져오는 서비스 클래스
// 역할: 카카오맵 API 호출로 병원, 약국, 경찰서 등 장소 데이터 제공
class KakaoApiService {
  static const String kakaoApiKey = '008935e7ada68384e86fbd19dcb8fc10'; // Kakao API 키
  static const String categoryBaseUrl = 'https://dapi.kakao.com/v2/local/search/category.json'; // 카테고리 검색 URL
  static const String keywordBaseUrl = 'https://dapi.kakao.com/v2/local/search/keyword.json'; // 키워드 검색 URL

  // fetchHospitals: 병원 위치 데이터 가져오기
  // 역할: 카테고리 API로 병원 데이터 조회
  // 분류: 로직
  Future<List<Place>> fetchHospitals() async {
    return _fetchPlacesByCategory('HP8', '응급 & 안전', '병원 위치');
  }

  // fetchPharmacies: 약국 위치 데이터 가져오기
  // 역할: 카테고리 API로 약국 데이터 조회
  // 분류: 로직
  Future<List<Place>> fetchPharmacies() async {
    return _fetchPlacesByCategory('PM9', '응급 & 안전', '약국 위치');
  }

  // fetchPoliceStations: 경찰서/파출소 데이터 가져오기
  // 역할: 카테고리 API로 경찰서 데이터 조회
  // 분류: 로직
  Future<List<Place>> fetchPoliceStations() async {
    return _fetchPlacesByCategory('PO3', '응급 & 안전', '경찰서/파출소');
  }

  // fetchAtms: ATM 위치 데이터 가져오기
  // 역할: 카테고리 API로 ATM 데이터 조회
  // 분류: 로직
  Future<List<Place>> fetchAtms() async {
    return _fetchPlacesByCategory('AT4', '금융 & 환전', 'ATM기 위치');
  }

  // fetchBanks: 은행 위치 데이터 가져오기
  // 역할: 카테고리 API로 은행 데이터 조회
  // 분류: 로직
  Future<List<Place>> fetchBanks() async {
    return _fetchPlacesByCategory('BK9', '금융 & 환전', '은행 위치');
  }

  // fetchCurrencyExchanges: 환전소 위치 데이터 가져오기
  // 역할: 키워드 API로 환전소 데이터 조회
  // 분류: 로직
  Future<List<Place>> fetchCurrencyExchanges() async {
    return _fetchPlacesByKeyword('환전소', '금융 & 환전', '환전소 위치');
  }

  // fetchPublicToilets: 공중 화장실 데이터 가져오기
  // 역할: 키워드 API로 공중 화장실 데이터 조회
  // 분류: 로직
  Future<List<Place>> fetchPublicToilets() async {
    return _fetchPlacesByKeyword('공중 화장실', '편의시설', '공중 화장실');
  }

  // fetchLockers: 물품 보관함 데이터 가져오기
  // 역할: 키워드 API로 물품 보관함 데이터 조회
  // 분류: 로직
  Future<List<Place>> fetchLockers() async {
    return _fetchPlacesByKeyword('물품 보관함', '편의시설', '물품 보관함');
  }

  // _fetchPlacesByCategory: 카테고리별 장소 데이터 가져오기
  // 역할: 카카오맵 카테고리 API 호출로 장소 목록 생성
  // 분류: 로직
  Future<List<Place>> _fetchPlacesByCategory(String categoryCode, String category, String subcategory) async {
    List<Place> allPlaces = [];
    try {
      int page = 1;
      bool hasMore = true;

      while (hasMore) {
        final url = Uri.parse('$categoryBaseUrl?category_group_code=$categoryCode&page=$page');
        print('카카오맵 API 요청 URL (카테고리): $url');
        final response = await http.get(
          url,
          headers: {'Authorization': 'KakaoAK $kakaoApiKey'},
        );

        print('카카오맵 API 응답 상태 코드: ${response.statusCode}');
        print('카카오맵 API 응답 데이터: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> documents = data['documents'];
          print('$subcategory 데이터 개수 (페이지 $page): ${documents.length}');

          final places = documents.map((doc) {
            return Place(
              id: doc['id'],
              name: doc['place_name'],
              location: LatLng(
                double.parse(doc['y']),
                double.parse(doc['x']),
              ),
              category: category,
              subcategory: subcategory,
              isEncrypted: false,
              isUserAdded: false,
            );
          }).toList();

          allPlaces.addAll(places);

          final meta = data['meta'];
          hasMore = meta['is_end'] == false && page < 45;
          page++;
        } else {
          throw Exception('카카오맵 API 호출 실패: ${response.statusCode}');
        }
      }

      print('$subcategory 총 데이터 개수: ${allPlaces.length}');
      return allPlaces;
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
      int page = 1;
      bool hasMore = true;

      while (hasMore) {
        final url = Uri.parse('$keywordBaseUrl?query=$keyword&page=$page');
        print('카카오맵 API 요청 URL (키워드): $url');
        final response = await http.get(
          url,
          headers: {'Authorization': 'KakaoAK $kakaoApiKey'},
        );

        print('카카오맵 API 응답 상태 코드: ${response.statusCode}');
        print('카카오맵 API 응답 데이터: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> documents = data['documents'];
          print('$subcategory 데이터 개수 (페이지 $page): ${documents.length}');

          final places = documents.map((doc) {
            return Place(
              id: doc['id'],
              name: doc['place_name'],
              location: LatLng(
                double.parse(doc['y']),
                double.parse(doc['x']),
              ),
              category: category,
              subcategory: subcategory,
              isEncrypted: false,
              isUserAdded: false,
            );
          }).toList();

          allPlaces.addAll(places);

          final meta = data['meta'];
          hasMore = meta['is_end'] == false && page < 45;
          page++;
        } else {
          throw Exception('카카오맵 API 호출 실패: ${response.statusCode}');
        }
      }

      print('$subcategory 총 데이터 개수: ${allPlaces.length}');
      return allPlaces;
    } catch (e) {
      print('$subcategory 데이터 로드 실패: $e');
      return [];
    }
  }
}