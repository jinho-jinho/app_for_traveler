import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_for_traveler/models/place.dart';
import 'package:app_for_traveler/services/kakao_api_service.dart';
import 'package:app_for_traveler/services/public_wifi_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io'; // File 클래스용
import 'package:image_picker/image_picker.dart'; // 이미지 피커 관련
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:ui' as ui; // 이미지 리사이즈를 위해 추가
import 'dart:typed_data'; // Uint8List를 위해 추가
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// 지도 화면 StatefulWidget
// 역할: Google Maps로 장소 표시, 사용자 장소 추가 및 리뷰 관리
class MapScreen extends StatefulWidget {
  final String currentUserId; // 현재 사용자 ID
  final String? selectedPlaceId; // 선택된 장소 ID
  final String? searchKeyword;
  final String? selectedCategory;

  const MapScreen({
    super.key,
    required this.currentUserId,
    this.selectedPlaceId,
    this.searchKeyword,
    this.selectedCategory
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

// MapScreen 상태 관리 클래스
// 역할: 지도 상태, 장소 데이터, 사용자 위치, 카테고리 필터 관리
class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  List<Place> _hospitals = [];
  List<Place> _pharmacies = [];
  List<Place> _policeStations = [];
  List<Place> _atms = [];
  List<Place> _banks = [];
  List<Place> _currencyExchanges = [];
  List<Place> _publicToilets = [];
  List<Place> _lockers = [];
  List<Place> _restrooms = [];
  List<Place> _chargingStations = [];
  List<Place> _publicWifis = [];
  List<Place> _cafes = []; // 카페 리스트
  List<Place> _restaurants = []; // 음식점 리스트
  List<Place> _landmarks = []; // 랜드마크 리스트
  bool _isLoading = true; // 로딩 상태
  LatLng? _currentPosition; // 현재 위치
  bool _locationPermissionGranted = false; // 위치 권한 상태
  String? _currentUserNickname; // 사용자 닉네임
  String _syncProgressMessage = "데이터 동기화 중..."; // 동기화 메시지
  bool _isMapReady = false; // 지도 준비 상태
  String? _lastProcessedPlaceId; // 마지막 처리된 장소 ID
  bool _isMapVisible = false; // 지도 표시 상태

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 독립 카테고리로 변경 (관광 명소 카테고리 제거, 카페/음식점/랜드마크 추가)
  final Map<String, bool> _categoryEnabled = {
    '병원': true,
    '약국': true,
    '경찰서': true,
    'ATM': true,
    '은행': true,
    '환전소': true,
    '공중 화장실': true,
    '물품 보관함': true,
    '휴대폰 충전소': true,
    '공공 와이파이': true,
    '카페': true, // 새로운 카테고리 추가
    '음식점': true, // 새로운 카테고리 추가
    '랜드마크': true, // 새로운 카테고리 추가
  };

  BitmapDescriptor? hospitalIcon;
  BitmapDescriptor? pharmacyIcon;
  BitmapDescriptor? policeIcon;
  BitmapDescriptor? atmIcon;
  BitmapDescriptor? bankIcon;
  BitmapDescriptor? currencyExchangeIcon;
  BitmapDescriptor? publicToiletIcon;
  BitmapDescriptor? lockerFreeIcon;
  BitmapDescriptor? lockerPaidIcon;
  BitmapDescriptor? chargingStationIcon;
  BitmapDescriptor? publicWifiIcon;
  BitmapDescriptor? cafeIcon; // 카페 아이콘 추가
  BitmapDescriptor? restaurantIcon; // 음식점 아이콘 추가
  BitmapDescriptor? landmarkIcon; // 랜드마크 아이콘 추가
  BitmapDescriptor? currentLocationIcon; // 현재 위치 마커 아이콘

  static const LatLng initialPosition = LatLng(37.5665, 126.9780); //

  // initState: 위젯 초기화, 데이터 초기화 시작
  // 역할: 초기 설정 및 데이터 로드
  // 분류: 로직
  @override
  void initState() {
    super.initState();
    if (widget.searchKeyword != null) {
      // 예를 들어, searchKeyword를 사용하여 지도 검색 API 호출 또는 마커 표시 로직
      print('MapScreen received search keyword: ${widget.searchKeyword}');
      // 여기에 지도 검색을 실행하는 로직을 추가합니다.
    }
    _isMapVisible = true;
    _initializeData();
  }

  // didUpdateWidget: 위젯 업데이트 시 선택된 장소 처리
  // 역할: 선택된 장소 ID 변경 시 지도 이동
  // 분류: 로직
  @override
  void didUpdateWidget(MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPlaceId != oldWidget.selectedPlaceId && widget.selectedPlaceId != null) {
      if (_isMapReady && !_isLoading) {
        _moveToSelectedPlace(widget.selectedPlaceId!);
      }
    }
  }

  // _initializeData: 마커 아이콘, 위치 권한, 닉네임, 데이터 초기화
  // 역할: 초기 데이터 설정 및 로드
  // 분류: 로직
  Future<void> _initializeData() async {
    await _setupMarkerIcons();
    if (mounted) {
      setState(() {});
    }
    await _checkLocationPermission();
    await _fetchCurrentUserNickname();
    await _fetchData();
  }


  // _checkLocationPermission: 위치 권한 확인 및 현재 위치 가져오기
  // 역할: 사용자 위치 권한 처리 및 위치 설정
  // 분류: 로직
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 활성화 여부 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled(); //
    if (!serviceEnabled) {
      _currentPosition = initialPosition;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 서비스가 비활성화되어 있습니다. 위치 서비스를 활성화해주세요.')),
        );
      }
      print('위치 서비스 비활성화됨');
      return;
    }

    // 위치 권한 확인 및 요청
    permission = await Geolocator.checkPermission(); //
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission(); //
      if (permission == LocationPermission.denied) {
        _currentPosition = initialPosition;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('위치 권한이 거부되었습니다. 설정에서 권한을 허용해주세요.')),
          );
        }
        print('위치 권한 거부됨');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _currentPosition = initialPosition;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.')),
        );
      }
      print('위치 권한 영구 거부됨');
      return;
    }

    // 현재 위치 가져오기
    try {
      Position position = await Geolocator.getCurrentPosition( //
        desiredAccuracy: LocationAccuracy.bestForNavigation, // 더 높은 정확도 설정
        timeLimit: const Duration(seconds: 10), // 10초 타임아웃 설정
        forceAndroidLocationManager: true, // 안드로이드에서 위치 관리자 강제 사용
      );
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _locationPermissionGranted = true;
          // 디버깅 로그 추가
          print('현재 위치: ${position.latitude}, ${position.longitude}');
          print('위치 제공자: ${position.isMocked ? "가짜 위치 (Mock)" : "실제 위치"}');
        });
      }
    } catch (e) {
      _currentPosition = initialPosition;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('위치 정보를 가져오는 데 실패했습니다: $e')),
        );
        print('위치 가져오기 실패: $e');
      }
    }
  }

  // 위치 새로고침 메서드 추가
  Future<void> _refreshLocation() async {
    await _checkLocationPermission();
    if (_currentPosition != null && mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
    }
    setState(() {});
    await _fetchData(); // 위치 새로고침 후 데이터 다시 조회
  }

  // _fetchCurrentUserNickname: Firestore에서 사용자 닉네임 가져오기
  // 역할: 사용자 닉네임 조회 및 상태 업데이트
  // 분류: 로직
  Future<void> _fetchCurrentUserNickname() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(widget.currentUserId).get();
      if (userDoc.exists) {
        if (mounted) {
          setState(() {
            _currentUserNickname = (userDoc.data() as Map<String, dynamic>)['nickname'] as String? ?? widget.currentUserId;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _currentUserNickname = widget.currentUserId;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentUserNickname = widget.currentUserId;
        });
      }
    }
  }

  String _getLocalizedCategoryName(String categoryKey, AppLocalizations appLocalizations) {
    switch (categoryKey) {
      case '병원':
        return appLocalizations.hospital;
      case '약국':
        return appLocalizations.pharmacy;
      case '경찰서':
        return appLocalizations.policeStation;
      case 'ATM':
        return appLocalizations.atm;
      case '은행':
        return appLocalizations.bank;
      case '환전소':
        return appLocalizations.currencyExchange;
      case '공중 화장실':
        return appLocalizations.publicRestroom;
      case '물품 보관함':
        return appLocalizations.locker;
      case '휴대폰 충전소':
        return appLocalizations.phoneChargingStation;
      case '공공 와이파이':
        return appLocalizations.publicwifi;
      case '카페':
        return appLocalizations.cafe;
      case '음식점':
        return appLocalizations.restaurant;
      case '랜드마크':
        return appLocalizations.landmark; // app_en.arb에 atm 정의 필요
      default:
        return categoryKey; // 매핑되지 않은 경우 원래 키 반환
    }
  }
  // 이미지 크기 조정을 위한 유틸리티 메서드
  Future<BitmapDescriptor> resizeIcon(String assetPath, int width, int height) async {
    // 에셋 이미지 로드
    final ByteData data = await rootBundle.load(assetPath); //
    final Uint8List bytes = data.buffer.asUint8List(); //

    // 이미지 디코딩
    final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: width, targetHeight: height); //
    final ui.FrameInfo frameInfo = await codec.getNextFrame(); //
    final ui.Image image = frameInfo.image; //

    // 이미지 크기 조정 후 바이트 데이터로 변환
    final ByteData? resizedByteData = await image.toByteData(format: ui.ImageByteFormat.png); //
    final Uint8List resizedBytes = resizedByteData!.buffer.asUint8List(); //

    // BitmapDescriptor 생성
    return BitmapDescriptor.fromBytes(resizedBytes); //
  }

  // _setupMarkerIcons: 각 카테고리별 마커 아이콘 설정
  // 역할: 지도 마커 아이콘 초기화 (관광 명소 아이콘 제거, 새로운 카테고리 아이콘 추가)
  // 분류: 로직
  Future<void> _setupMarkerIcons() async {
    try {
      atmIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'lib/screens/assets/atm_icon.png',
      );
      bankIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'lib/screens/assets/bank_icon.png',
      );
      chargingStationIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'lib/screens/assets/charging_station_icon.png',
      );
      currencyExchangeIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'lib/screens/assets/currency_exchange_icon.png',
      );
      hospitalIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'lib/screens/assets/hospital_icon.png',
      );
      pharmacyIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'lib/screens/assets/pharmacy_icon.png',
      );
      policeIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'lib/screens/assets/police_icon.png',
      );
      lockerFreeIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'lib/screens/assets/locker_icon.png',
      );
      lockerPaidIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'lib/screens/assets/locker_icon.png',
      );
      publicToiletIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'lib/screens/assets/public_toilet_icon.png',
      );
      publicWifiIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'lib/screens/assets/public_wifi_icon.png',
      );
      cafeIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'lib/screens/assets/cafe_icon.png',
      );
      restaurantIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'lib/screens/assets/restaurant_icon.png',
      );
      landmarkIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'lib/screens/assets/landmark_icon.png',
      );
    } catch (e) {
      print('마커 아이콘 로드 실패: $e');
    }
  }

  // _isKakaoDataSynced: Kakao 데이터 동기화 여부 확인
  // 역할: SharedPreferences로 동기화 상태 확인
  // 분류: 로직
  Future<bool> _isKakaoDataSynced() async {
    final prefs = await SharedPreferences.getInstance(); //
    return prefs.getBool('kakao_data_synced') ?? false; //
  }

  // _setKakaoDataSynced: Kakao 데이터 동기화 완료 설정
  // 역할: SharedPreferences에 동기화 상태 저장
  // 분류: 로직
  Future<void> _setKakaoDataSynced() async {
    final prefs = await SharedPreferences.getInstance(); //
    await prefs.setBool('kakao_data_synced', true); //
    print('데이터 동기화 완료, 동기화 상태 저장됨.');
  }

  // _fetchData: Kakao API 및 Firestore에서 장소 데이터 가져오기
  // 역할: 장소 데이터 동기화 및 로드, 선택된 장소 처리
  // 분류: 로직
  Future<void> _fetchData({bool forceSync = false}) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      bool isSynced = await _isKakaoDataSynced(); //
      if (!isSynced || forceSync) {
        final kakaoApiService = KakaoApiService(); //
        final publicWifiService = PublicWifiService(); //

        if (mounted) setState(() => _syncProgressMessage = "약국 위치 동기화 중..."); //
        final pharmacies = await kakaoApiService.fetchPharmacies(); //
        await _syncKakaoDataToFirestore(pharmacies); //
        print('약국 동기화 완료: ${pharmacies.length}개');

        if (mounted) setState(() => _syncProgressMessage = "경찰서/파출소 동기화 중..."); //
        final policeStations = await kakaoApiService.fetchPoliceStations(); //
        await _syncKakaoDataToFirestore(policeStations); //
        print('경찰서 동기화 완료: ${policeStations.length}개');

        if (mounted) setState(() => _syncProgressMessage = "ATM기 위치 동기화 중..."); //
        final atms = await kakaoApiService.fetchAtms(); //
        await _syncKakaoDataToFirestore(atms); //
        print('ATM 동기화 완료: ${atms.length}개');

        if (mounted) setState(() => _syncProgressMessage = "은행 위치 동기화 중..."); //
        final banks = await kakaoApiService.fetchBanks(); //
        await _syncKakaoDataToFirestore(banks); //
        print('은행 동기화 완료: ${banks.length}개');

        if (mounted) setState(() => _syncProgressMessage = "환전소 위치 동기화 중..."); //
        final currencyExchanges = await kakaoApiService.fetchCurrencyExchanges(); //
        await _syncKakaoDataToFirestore(currencyExchanges); //
        print('환전소 동기화 완료: ${currencyExchanges.length}개');

        if (mounted) setState(() => _syncProgressMessage = "공중 화장실 동기화 중..."); //
        final publicToilets = await kakaoApiService.fetchPublicToilets(); //
        await _syncKakaoDataToFirestore(publicToilets); //
        print('공중 화장실 동기화 완료: ${publicToilets.length}개');

        if (mounted) setState(() => _syncProgressMessage = "물품 보관함 동기화 중..."); //
        final lockers = await kakaoApiService.fetchLockers(); //
        await _syncKakaoDataToFirestore(lockers); //
        print('물품 보관함 동기화 완료: ${lockers.length}개');

        if (mounted) setState(() => _syncProgressMessage = "공공 와이파이 동기화 중..."); //
        final publicWifis = await publicWifiService.fetchPublicWifis(); //
        await _syncKakaoDataToFirestore(publicWifis); //
        print('공공 와이파이 동기화 완료: ${publicWifis.length}개');

        // 새로운 카테고리 동기화
        if (mounted) setState(() => _syncProgressMessage = "카페 동기화 중..."); //
        final cafes = await kakaoApiService.fetchCafes(); //
        await _syncKakaoDataToFirestore(cafes); //
        print('카페 동기화 완료: ${cafes.length}개');

        if (mounted) setState(() => _syncProgressMessage = "음식점 동기화 중..."); //
        final restaurants = await kakaoApiService.fetchRestaurants(); //
        await _syncKakaoDataToFirestore(restaurants); //
        print('음식점 동기화 완료: ${restaurants.length}개');

        if (mounted) setState(() => _syncProgressMessage = "랜드마크 동기화 중..."); //
        final landmarks = await kakaoApiService.fetchLandmarks(); //
        await _syncKakaoDataToFirestore(landmarks); //
        print('랜드마크 동기화 완료: ${landmarks.length}개');

        await _setKakaoDataSynced(); //
      } else {
        print('데이터 동기화 건너뜀. 기존 데이터를 로드합니다.');
      }

      final userPlacesSnapshot = await _firestore.collection('places').get(); //
      print('Firestore에서 조회된 장소 개수: ${userPlacesSnapshot.docs.length}');

      final userPlaces = userPlacesSnapshot.docs.map((doc) {
        final data = doc.data(); //
        List<Review> reviews = []; //
        if (data['reviews'] != null) {
          reviews = (data['reviews'] as List).map((raw) {
            final reviewData = raw as Map<String, dynamic>; //
            return Review(
              userId: reviewData['userId'] as String, //
              rating: (reviewData['rating'] as num?)?.toDouble() ?? 0.0, //
              comment: reviewData['comment'] as String, //
              likes: (reviewData['likes'] as num?)?.toInt() ?? 0, //
              imageUri: reviewData['imageUri'] as String?, //
            );
          }).toList();
        }

        print('Firestore 장소 데이터: ID ${doc.id}, 이름: ${data['name']}, 주소: ${data['address'] ?? "주소 없음"}'); //

        return Place(
          id: doc.id,
          name: data['name'] as String,
          location: LatLng(
            (data['latitude'] as num).toDouble(),
            (data['longitude'] as num).toDouble(),
          ),
          category: data['category'] as String,
          subcategory: data['subcategory'] as String,
          isEncrypted: data['isEncrypted'] as bool? ?? false,
          isFree: data['isFree'] as bool? ?? true,
          isUserAdded: data['isUserAdded'] as bool? ?? false,
          reviews: reviews,
          reports: data['reports'] != null ? List<String>.from(data['reports']) : [],
          address: data['address'] as String?, // 주소 필드 매핑
        );
      }).toList();

      // 모든 장소를 표시
      if (mounted) {
        setState(() {
          _hospitals = userPlaces.where((place) => place.subcategory == '병원 위치').toList();
          _pharmacies = userPlaces.where((place) => place.subcategory == '약국 위치').toList();
          _policeStations = userPlaces.where((place) => place.subcategory == '경찰서/파출소').toList();
          _atms = userPlaces.where((place) => place.subcategory == 'ATM기 위치').toList();
          _banks = userPlaces.where((place) => place.subcategory == '은행 위치').toList();
          _currencyExchanges = userPlaces.where((place) => place.subcategory == '환전소 위치').toList();
          _publicToilets = userPlaces.where((place) => place.subcategory == '공중 화장실').toList();
          _lockers = userPlaces.where((place) => place.subcategory == '물품 보관함').toList();
          _chargingStations = userPlaces.where((place) => place.subcategory == '휴대폰 충전 가능 장소').toList();
          _publicWifis = userPlaces.where((place) => place.subcategory == '공공 와이파이').toList();
          _cafes = userPlaces.where((place) => place.subcategory == '카페').toList();
          _restaurants = userPlaces.where((place) => place.subcategory == '음식점').toList();
          _landmarks = userPlaces.where((place) => place.subcategory == '랜드마크').toList();

          _isLoading = false;
        });
      }

      if (widget.selectedPlaceId != null && _isMapReady) {
        await _moveToSelectedPlace(widget.selectedPlaceId!);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 동기화 실패: 네트워크 연결을 확인하거나 나중에 다시 시도해주세요. (에러: $e)')),
        );
        print('데이터 조회 실패: $e');
      }
    }
  }

  // _syncKakaoDataToFirestore: Kakao 데이터를 Firestore에 동기화
  // 역할: 새로운 장소 데이터를 Firestore에 배치 쓰기로 저장
  // 분류: 로직
  Future<void> _syncKakaoDataToFirestore(List<Place> places) async {
    const int batchSize = 100;
    WriteBatch batch = _firestore.batch();
    int batchCount = 0;

    print('Firestore에 저장할 장소 개수: ${places.length}');

    for (var place in places) {
      DocumentReference docRef = _firestore.collection('places').doc(place.id);
      DocumentSnapshot doc = await docRef.get();

      if (!doc.exists) {
        batch.set(docRef, {
          'id': place.id,
          'name': place.name,
          'latitude': place.location.latitude,
          'longitude': place.location.longitude,
          'category': place.category,
          'subcategory': place.subcategory,
          'isEncrypted': place.isEncrypted,
          'isFree': place.isFree,
          'isUserAdded': place.isUserAdded,
          'reviews': [],
          'reports': [],
          'favoritedBy': [],
          'address': place.address ?? '주소 정보 없음', // 주소 필드 추가
        });
        batchCount++;
        print('Firestore 배치에 추가: ${place.id}, 주소: ${place.address}');
      } else {
        batch.update(docRef, {
          'name': place.name,
          'latitude': place.location.latitude,
          'longitude': place.location.longitude,
          'category': place.category,
          'subcategory': place.subcategory,
          'isEncrypted': place.isEncrypted,
          'isFree': place.isFree,
          'isUserAdded': place.isUserAdded,
          'address': place.address ?? '주소 정보 없음',
        });
        batchCount++;
        print('Firestore 데이터 업데이트: ${place.id}, 주소: ${place.address}');
      }

      if (batchCount >= batchSize) {
        await batch.commit();
        print('Firestore 배치 커밋 완료: $batchCount 개');
        batch = _firestore.batch();
        batchCount = 0;
      }
    }

    if (batchCount > 0) {
      await batch.commit();
      print('Firestore 최종 배치 커밋 완료: $batchCount 개');
    }
  }

  // _onMapCreated: Google Map 초기화 및 카메라 설정
  // 역할: 지도 컨트롤러 설정 및 초기 위치 이동
  // 분류: 로직
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (mounted) {
      setState(() {
        _isMapReady = true;
      });
    }
    if (_currentPosition != null) {
      controller.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
    }
    if (widget.selectedPlaceId != null && !_isLoading) {
      _moveToSelectedPlace(widget.selectedPlaceId!);
    }
  }

  // _isPlaceFavorited: 장소가 찜 목록에 있는지 확인
  // 역할: Firestore에서 사용자 찜 목록 조회
  // 분류: 로직
  Future<bool> _isPlaceFavorited(String placeId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(widget.currentUserId).get(); //
    if (userDoc.exists) {
      List<String> favorites = List<String>.from(userDoc['favorites'] ?? []); //
      return favorites.contains(placeId); //
    }
    return false;
  }

  // _toggleFavorite: 장소 찜 목록 추가/제거
  // 역할: Firestore에서 사용자 및 장소 찜 상태 업데이트
  // 분류: 로직
  Future<void> _toggleFavorite(String placeId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(widget.currentUserId).get(); //
      List<String> favorites = []; //
      if (userDoc.exists) {
        favorites = List<String>.from(userDoc['favorites'] ?? []); //
      }

      bool isFavorited = favorites.contains(placeId); //
      if (isFavorited) {
        favorites.remove(placeId); //
      } else {
        favorites.add(placeId); //
      }

      await _firestore.collection('users').doc(widget.currentUserId).update({
        'favorites': favorites,
      }); //

      DocumentSnapshot placeDoc = await _firestore.collection('places').doc(placeId).get(); //
      List<String> favoritedBy = []; //
      if (placeDoc.exists) {
        favoritedBy = List<String>.from(placeDoc['favoritedBy'] ?? []); //
      }

      if (isFavorited) {
        favoritedBy.remove(widget.currentUserId); //
      } else {
        favoritedBy.add(widget.currentUserId); //
      }

      await _firestore.collection('places').doc(placeId).update({
        'favoritedBy': favoritedBy,
      }); //
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('찜 목록 업데이트 중 오류가 발생했습니다. 네트워크를 확인해주세요.')),
        );
      }
    }
  }

  // _moveToSelectedPlace: 선택된 장소로 지도 이동 및 세부 정보 표시
  // 역할: 지도 카메라 이동 및 바텀시트 표시
  // 분류: 로직
  Future<void> _moveToSelectedPlace(String placeId) async {
    double zoomLevel = 15; // 기본 줌 레벨
    while (mapController == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (_lastProcessedPlaceId == placeId) {
      return;
    }

    Place? selectedPlace;
    for (var place in [
      ..._hospitals,
      ..._pharmacies,
      ..._policeStations,
      ..._atms,
      ..._banks,
      ..._currencyExchanges,
      ..._publicToilets,
      ..._lockers,
      ..._restrooms,
      ..._chargingStations,
      ..._publicWifis,
      ..._cafes,
      ..._restaurants,
      ..._landmarks,
    ]) {
      if (place.id == placeId) {
        selectedPlace = place;
        break;
      }
    }

    if (selectedPlace == null) {
      final snap = await _firestore.collection('user_places').doc(placeId).get();

      if (snap.exists) {
        zoomLevel = 20; // 사용자 추가 장소는 더 가까이 보여줌, 아이콘 없음
        final d = snap.data()!;
        selectedPlace = Place(
          id: snap.id,
          name: d['name'] ?? '',
          location: LatLng(
            (d['latitude'] as num).toDouble(),
            (d['longitude'] as num).toDouble(),
          ),
          category: d['category'] ?? '',
          subcategory: d['subcategory'] ?? '',
          isEncrypted: d['isEncrypted'] ?? false,
          isFree: d['isFree'] ?? true,
          isUserAdded: true,
          reviews: const [],
          reports: const [],
          address: d['address'],
        );
      }
    }

    if (selectedPlace == null) return; // 못 찾으면 종료

    await mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(selectedPlace.location, zoomLevel), 
    );
    _showPlaceDetailsBottomSheet(selectedPlace);
    _lastProcessedPlaceId = placeId;
  }

  // 이미지 업로드 함수 (base64 인코딩)
  Future<String?> encodeImageToBase64(File imageFile) async {
    try {
      final compressed = await FlutterImageCompress.compressWithFile( //
        imageFile.absolute.path, //
        minWidth: 600, //
        quality: 70, //
      );
      if (compressed == null) return null; //

      return base64Encode(compressed); //
    } catch (e) {
      print('이미지 인코딩 실패: $e');
      return null;
    }
  }

  // 이미지 전체 보기 다이얼로그
  void _showImagePreview(String imagePath) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.zero,       // 화면 가득
        child: SizedBox.expand(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.file(
              File(imagePath), //
              fit: BoxFit.contain,            // 꽉 차게
            ),
          ),
        ),
      ),
    );
  }

  // _showPlaceDetailsBottomSheet: 장소 세부 정보 바텀시트 표시
  // 역할: 장소 정보, 리뷰, 찜 버튼 UI 표시
  // 분류: 디자인
  void _showPlaceDetailsBottomSheet(Place place) {
    print('바텀시트 표시 - 장소 이름: ${place.name}, 주소: ${place.address ?? "주소 정보 없음"}'); // 디버깅 로그 추가
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FutureBuilder<bool>(
              future: _isPlaceFavorited(place.id), //
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                bool isFavorited = snapshot.data ?? false; //
                double averageRating = place.reviews.isNotEmpty
                    ? place.reviews.map((r) => r.rating).reduce((a, b) => a + b) / place.reviews.length
                    : 0.0; //

                return FractionallySizedBox(
                  heightFactor: 0.4,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ────────────────────────── 헤더 (이름 + 찜 버튼)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              place.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: Icon(
                                isFavorited ? Icons.favorite : Icons.favorite_border,
                                color: isFavorited ? Colors.red : Colors.grey,
                              ),
                              onPressed: () async {
                                await _toggleFavorite(place.id); //
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // ────────────────────────── 주소 표시
                        Text(
                          '주소: ${place.address ?? "주소 정보 없음"}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 12), // 간격 조정
                        // ────────────────────────── 평균 별점
                        Text(
                          '평균 별점: ${averageRating.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        RatingBarIndicator(
                          rating: averageRating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 20.0,
                          direction: Axis.horizontal,
                        ),
                        const SizedBox(height: 12), // 간격 조정
                        // ────────────────────────── 리뷰 목록
                        const Text(
                          '코멘트:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: place.reviews.isEmpty
                              ? const Center(child: Text('코멘트가 없습니다.'))
                              : ListView.builder(
                            itemCount: place.reviews.length,
                            itemBuilder: (context, index) {
                              final review = place.reviews[index];
                              return ListTile(
                                // 별점과 코멘트 + 이미지 표시
                                title: Text('별점: ${review.rating}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(review.comment),

                                    if (review.imageUri != null) ...[
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => Dialog(
                                              child: InteractiveViewer(
                                                child: _buildImageFromBase64(review.imageUri!),
                                              ),
                                            ),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: _buildImageFromBase64(review.imageUri!),
                                        ),
                                      )
                                    ]
                                  ],
                                ),
                                // 작성자 + (본인 글이면) 삭제 버튼
                                trailing: FutureBuilder<String>(
                                  future: _getNickname(review.userId),
                                  builder: (context, nickSnap) {
                                    if (nickSnap.connectionState == ConnectionState.waiting) {
                                      return const Text('로딩 중...');
                                    }
                                    final nickname = nickSnap.data ?? review.userId;
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('작성자: $nickname'),
                                        const SizedBox(width: 8),
                                        if (widget.currentUserId == review.userId)
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                                            onPressed: () async {
                                              // 삭제 확인 다이얼로그
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('리뷰 삭제'),
                                                  content: const Text('이 리뷰를 삭제하시겠습니까?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, false),
                                                      child: const Text('취소'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, true),
                                                      child: const Text('삭제'),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true) {
                                                // 로컬 리스트에서 제거
                                                place.reviews.removeAt(index);
                                                // Firestore 업데이트
                                                await _firestore
                                                    .collection('places')
                                                    .doc(place.id)
                                                    .update({
                                                  'reviews': place.reviews.map((r) => {
                                                    'userId': r.userId,
                                                    'rating': r.rating,
                                                    'comment': r.comment,
                                                    'likes': r.likes,
                                                    'imageUri': r.imageUri?.toString(),
                                                  }).toList(),
                                                });
                                                setState(() {}); // UI 갱신
                                              }
                                            },
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        // ────────────────────────── 코멘트 추가 버튼
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showAddCommentDialog(place);
                            },
                            child: const Text('코멘트 추가'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // base64 이미지 디코딩 함수
  Widget _buildImageFromBase64(String base64String) {
    try {
      Uint8List imageBytes = base64Decode(base64String); //
      return Image.memory(
        imageBytes,
        height: 100,
        width: 100,
        fit: BoxFit.cover,
      );
    } catch (e) {
      return const Text('이미지 불러오기 실패');
    }
  }

  // _getNickname: Firestore에서 사용자 닉네임 조회
  // 역할: 리뷰 작성자 닉네임 가져오기
  // 분류: 로직
  Future<String> _getNickname(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get(); //
      if (userDoc.exists) {
        return (userDoc.data() as Map<String, dynamic>)['nickname'] as String? ?? userId; //
      }
      return userId;
    } catch (e) {
      return userId;
    }
  }

  // _showAddCommentDialog: 리뷰 추가 다이얼로그 표시
  // 역할: 별점 및 코멘트 입력 UI 제공
  // 분류: 디자인
  void _showAddCommentDialog(Place place) {
    final TextEditingController commentController = TextEditingController(); //
    double newRating = 3.0; //

    if (_currentUserNickname == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보를 불러오는 중입니다. 잠시 후 다시 시도해주세요.')),
      );
      return;
    }

    // ImagePicker 인스턴스 및 선택된 파일 참조
    final ImagePicker _picker = ImagePicker(); //
    XFile? pickedImage; //

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('코멘트 추가'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 별점 입력
                    RatingBar.builder(
                      initialRating: newRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 30.0,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        newRating = rating;
                      },
                    ),
                    const SizedBox(height: 10),
                    // 코멘트 입력
                    TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        labelText: '코멘트',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),

                    // 사진 첨부 버튼
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo),
                      label: const Text('사진 첨부'),
                      onPressed: () async {
                        final XFile? image = await _picker.pickImage( //
                          source: ImageSource.gallery, //
                          maxWidth: 800, //
                          imageQuality: 80, //
                        );
                        if (image != null) {
                          setState(() => pickedImage = image);
                        }
                      },
                    ),

                    // 첨부 사진 미리보기
                    if (pickedImage != null) ...[
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          // 다이얼로그로 전체 보기
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              child: InteractiveViewer(
                                child: Image.file(File(pickedImage!.path)), //
                              ),
                            ),
                          );
                        },
                        child: Image.file(
                          File(pickedImage!.path), //
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () async {
                    if (commentController.text.isNotEmpty) {
                      String? uploadedUrl;

                      if (pickedImage != null) {
                        uploadedUrl = await encodeImageToBase64(File(pickedImage!.path)); //
                        if (uploadedUrl == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('이미지 업로드에 실패했습니다. 다시 시도해주세요.')),
                          );
                          return;
                        }
                      }

                      Review newReview = Review(
                        userId: widget.currentUserId,
                        rating: newRating,
                        comment: commentController.text,
                        likes: 0,
                        imageUri: uploadedUrl,
                      );

                      DocumentSnapshot doc = await _firestore.collection('places').doc(place.id).get(); //
                      List<Review> reviews = [];

                      if (doc.exists && (doc.data() as Map<String, dynamic>)['reviews'] != null) {
                        reviews = (doc.data() as Map<String, dynamic>)['reviews'].map<Review>((reviewData) {
                          return Review(
                            userId: reviewData['userId'] as String,
                            rating: reviewData['rating']?.toDouble() ?? 0.0,
                            comment: reviewData['comment'] as String,
                            likes: reviewData['likes']?.toInt() ?? 0,
                            imageUri: reviewData['imageUri'], // imageUri 추가
                          );
                        }).toList();
                      }

                      reviews.add(newReview);

                      await _firestore.collection('places').doc(place.id).update({
                        'reviews': reviews.map((r) => {
                          'userId': r.userId,
                          'rating': r.rating,
                          'comment': r.comment,
                          'likes': r.likes,
                          'imageUri': r.imageUri, // imageUri 추가
                        }).toList(),
                      });

                      await _fetchData(); //

                      // 업데이트 된 코멘트 창 즉시 보이기
                      await _fetchData(); //
                      if (mounted) {
                        Navigator.pop(context); // 다이얼로그 닫기

                        // place.id에 해당하는 최신 데이터로 업데이트된 place 찾기
                        final updateDoc = await _firestore.collection('places').doc(place.id).get(); //
                        if (updateDoc.exists) {
                          final data = updateDoc.data() as Map<String, dynamic>; //

                          List<Review> updatedReviews = []; //
                          if (data['reviews'] != null) {
                            updatedReviews = (data['reviews'] as List).map((reviewData) {
                              final r = reviewData as Map<String, dynamic>; //
                              return Review(
                                userId: r['userId'] as String, //
                                rating: (r['rating'] as num?)?.toDouble() ?? 0.0, //
                                comment: r['comment'] as String, //
                                likes: (r['likes'] as num?)?.toInt() ?? 0, //
                                imageUri: r['imageUri'] as String?, //
                              );
                            }).toList();
                          }

                          final updatedPlace = Place(
                            id: data['id'],
                            name: data['name'],
                            location: LatLng((data['latitude'] as num).toDouble(), (data['longitude'] as num).toDouble()),
                            category: data['category'],
                            subcategory: data['subcategory'],
                            isEncrypted: data['isEncrypted'] ?? false,
                            isFree: data['isFree'] ?? true,
                            isUserAdded: data['isUserAdded'] ?? false,
                            reviews: updatedReviews,
                            reports: data['reports'] != null ? List<String>.from(data['reports']) : [],
                          );

                          _showPlaceDetailsBottomSheet(updatedPlace);
                        }
                      }
                    }
                  },
                  child: const Text('추가'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // _showAddPlaceDialog: 새 장소 추가 카테고리 선택 다이얼로그
  // 역할: 카테고리 선택 UI 제공 (상위/하위 구분 제거)
  // 분류: 디자인
  void _showAddPlaceDialog() {
    String? selectedCategory;
    // Access AppLocalizations for localized strings
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(appLocalizations.addNewPlaceTitle), // Localized string for '새 장소 추가'
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      hint: Text(appLocalizations.selectCategoryHint), // Localized string for '카테고리 선택'
                      value: selectedCategory,
                      items: _categoryEnabled.keys.map((categoryKey) {
                        return DropdownMenuItem<String>(
                          value: categoryKey,
                          // You might also want to localize the category names themselves
                          // if they are displayed to the user and need translation.
                          // For simplicity, we are using the raw category key here.
                          child: Text(categoryKey),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: selectedCategory != null
                          ? () {
                        Navigator.pop(context);
                        _showLocationPickerDialog(
                          selectedCategory!,
                          selectedCategory!, // Pass category name, potentially localized
                        );
                      }
                          : null,
                      child: Text(appLocalizations.selectLocationButton), // Localized string for '위치 선택'
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(appLocalizations.cancelButton), // Localized string for '취소'
                ),
              ],
            );
          },
        );
      },
    );
  }

  // _showLocationPickerDialog: 장소 위치 선택 다이얼로그
  // 역할: 지도에서 위치 선택 UI 제공 (현재 위치에서 시작)
  // 분류: 디자인
  void _showLocationPickerDialog(String category, String subcategory) {
    // Access AppLocalizations for localized strings
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    // Use current position if available, otherwise use initialPosition
    LatLng initialMarkerPosition = _currentPosition ?? initialPosition;
    LatLng selectedPosition = initialMarkerPosition; // Initialize with initialMarkerPosition

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(appLocalizations.selectLocationTitle), // Localized string for '위치 선택'
          content: SizedBox(
            height: 400,
            width: 300,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: initialMarkerPosition, // Start at current/initial position
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    // You might want to store the controller if you need to programmatically control the map
                  },
                  onCameraMove: (position) {
                    // Update selectedPosition as the camera moves
                    selectedPosition = position.target;
                  },
                  markers: {
                    // Display a single marker at the initial position
                    Marker(
                      markerId: const MarkerId('selected_position'),
                      position: initialMarkerPosition,
                      draggable: true, // Allow user to drag the marker
                      onDragEnd: (newPosition) {
                        // Update selectedPosition if the marker is dragged
                        selectedPosition = newPosition;
                      },
                    ),
                  },
                ),
                // This icon centers on the map, indicating the chosen point
                const Center(
                  child: Icon(
                    Icons.add_location_alt, // Changed to a more relevant icon
                    size: 40, // Increased size for better visibility
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(appLocalizations.cancelButton), // Localized string for '취소'
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showAddPlaceDetailsDialog(category, subcategory, selectedPosition);
              },
              child: Text(appLocalizations.confirmButton), // Localized string for '확인'
            ),
          ],
        );
      },
    );
  }

  // _showAddPlaceDetailsDialog: 장소 세부 정보 입력 다이얼로그
  // 역할: 장소 이름, 무료/유료 여부, 주소 입력 UI 제공
  // 분류: 디자인
  void _showAddPlaceDetailsDialog(String category, String subcategory, LatLng position) {
    final nameController = TextEditingController(); //
    final addressController = TextEditingController(); // 주소 입력 컨트롤러 추가
    bool isFree = true; //

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('$subcategory 추가'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: '장소 이름 (필수)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: '주소 (필수, 예: 대학로 52-1)'),
                    ),
                    if (subcategory == '물품 보관함') ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text('무료/유료: '),
                          Switch(
                            value: isFree,
                            onChanged: (value) {
                              setState(() {
                                isFree = value;
                              });
                            },
                          ),
                          Text(isFree ? '무료' : '유료'),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () async {
                    final name = nameController.text; //
                    final address = addressController.text; //
                    if (name.isEmpty || address.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('장소 이름과 주소를 모두 입력해주세요.')),
                      );
                      return;
                    }

                    final newPlace = Place(
                      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      location: position,
                      category: category,
                      subcategory: subcategory,
                      isUserAdded: true,
                      isFree: subcategory == '물품 보관함' ? isFree : true,
                      address: address,
                    );

                    try {
                      final placeData = {
                        'id': newPlace.id,
                        'name': newPlace.name,
                        'latitude': newPlace.location.latitude,
                        'longitude': newPlace.location.longitude,
                        'category': newPlace.category,
                        'subcategory': newPlace.subcategory,
                        'isEncrypted': newPlace.isEncrypted,
                        'isFree': newPlace.isFree,
                        'Added': false,
                        'address': newPlace.address,
                        'createdAt': FieldValue.serverTimestamp(),
                        'submittedBy': widget.currentUserId,
                      };

                      await _firestore.collection('user_places').doc(newPlace.id).set(placeData);

                      // setState(() {
                      //   switch (subcategory) {
                      //     case '병원':
                      //       _hospitals.add(newPlace);
                      //       break;
                      //     case '약국':
                      //       _pharmacies.add(newPlace);
                      //       break;
                      //     case '경찰서':
                      //       _policeStations.add(newPlace);
                      //       break;
                      //     case 'ATM':
                      //       _atms.add(newPlace);
                      //       break;
                      //     case '은행':
                      //       _banks.add(newPlace);
                      //       break;
                      //     case '환전소':
                      //       _currencyExchanges.add(newPlace);
                      //       break;
                      //     case '공중 화장실':
                      //       _publicToilets.add(newPlace);
                      //       _restrooms.add(newPlace);
                      //       break;
                      //     case '물품 보관함':
                      //       _lockers.add(newPlace);
                      //       break;
                      //     case '휴대폰 충전소':
                      //       _chargingStations.add(newPlace);
                      //       break;
                      //     case '공공 와이파이':
                      //       _publicWifis.add(newPlace);
                      //       break;
                      //     case '카페':
                      //       _cafes.add(newPlace);
                      //       break;
                      //     case '음식점':
                      //       _restaurants.add(newPlace);
                      //       break;
                      //     case '랜드마크':
                      //       _landmarks.add(newPlace);
                      //       break;
                      //   }
                      // });
                      //mapController?.animateCamera(CameraUpdate.newLatLng(position));

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('장소 제안이 완료되었습니다. 검토 후 반영됩니다.')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('장소 추가 실패: $e')),
                        );
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('추가'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // _createMarkers: 지도에 표시할 마커 생성
  // 역할: 카테고리별 장소 마커 생성 (관광 명소 제거, 새로운 카테고리 추가)
  // 분류: 로직
  Set<Marker> _createMarkers() {
    final Set<Marker> markers = {};

    // 각 카테고리별 데이터 개수 출력 및 마커 생성
    print('병원 데이터 개수: ${_hospitals.length}');
    if (_categoryEnabled['병원'] == true) {
      markers.addAll(_hospitals.map((place) => Marker(
        markerId: MarkerId(place.id),
        position: place.location,
        icon: hospitalIcon ?? BitmapDescriptor.defaultMarker,
        onTap: () => _showPlaceDetailsBottomSheet(place),
      )));
    }

    print('약국 데이터 개수: ${_pharmacies.length}');
    if (_categoryEnabled['약국'] == true) {
      markers.addAll(_pharmacies.map((place) => Marker(
        markerId: MarkerId(place.id),
        position: place.location,
        icon: pharmacyIcon ?? BitmapDescriptor.defaultMarker,
        onTap: () => _showPlaceDetailsBottomSheet(place),
      )));
    }

    print('경찰서 데이터 개수: ${_policeStations.length}');
    if (_categoryEnabled['경찰서'] == true) {
      markers.addAll(_policeStations.map((place) => Marker(
        markerId: MarkerId(place.id),
        position: place.location,
        icon: policeIcon ?? BitmapDescriptor.defaultMarker,
        onTap: () => _showPlaceDetailsBottomSheet(place),
      )));
    }

    print('ATM 데이터 개수: ${_atms.length}');
    if (_categoryEnabled['ATM'] == true) {
      markers.addAll(_atms.map((place) => Marker(
        markerId: MarkerId(place.id),
        position: place.location,
        icon: atmIcon ?? BitmapDescriptor.defaultMarker,
        onTap: () => _showPlaceDetailsBottomSheet(place),
      )));
    }

    print('은행 데이터 개수: ${_banks.length}');
    if (_categoryEnabled['은행'] == true) {
      markers.addAll(_banks.map((place) => Marker(
        markerId: MarkerId(place.id),
        position: place.location,
        icon: bankIcon ?? BitmapDescriptor.defaultMarker,
        onTap: () => _showPlaceDetailsBottomSheet(place),
      )));
    }

    print('환전소 데이터 개수: ${_currencyExchanges.length}');
    if (_categoryEnabled['환전소'] == true) {
      markers.addAll(_currencyExchanges.map((place) => Marker(
        markerId: MarkerId(place.id),
        position: place.location,
        icon: currencyExchangeIcon ?? BitmapDescriptor.defaultMarker,
        onTap: () => _showPlaceDetailsBottomSheet(place),
      )));
    }

    print('공중 화장실 데이터 개수: ${_publicToilets.length}');
    if (_categoryEnabled['공중 화장실'] == true) {
      markers.addAll(_publicToilets.map((place) => Marker(
        markerId: MarkerId(place.id),
        position: place.location,
        icon: publicToiletIcon ?? BitmapDescriptor.defaultMarker,
        onTap: () => _showPlaceDetailsBottomSheet(place),
      )));
      markers.addAll(_restrooms.map((place) => Marker(
        markerId: MarkerId(place.id),
        position: place.location,
        icon: publicToiletIcon ?? BitmapDescriptor.defaultMarker,
        onTap: () => _showPlaceDetailsBottomSheet(place),
      )));
    }

    print('물품 보관함 데이터 개수: ${_lockers.length}');
    if (_categoryEnabled['물품 보관함'] == true) {
      markers.addAll(_lockers.map((place) => Marker(
        markerId: MarkerId(place.id),
        position: place.location,
        icon: place.isFree
            ? (lockerFreeIcon ?? BitmapDescriptor.defaultMarker)
            : (lockerPaidIcon ?? BitmapDescriptor.defaultMarker),
        onTap: () => _showPlaceDetailsBottomSheet(place),
      )));
    }

    print('휴대폰 충전소 데이터 개수: ${_chargingStations.length}');
    if (_categoryEnabled['휴대폰 충전소'] == true) {
      markers.addAll(_chargingStations.map((place) => Marker(
        markerId: MarkerId(place.id),
        position: place.location,
        icon: chargingStationIcon ?? BitmapDescriptor.defaultMarker,
        onTap: () => _showPlaceDetailsBottomSheet(place),
      )));
    }

    print('공공 와이파이 데이터 개수: ${_publicWifis.length}');
    if (_categoryEnabled['공공 와이파이'] == true) {
      markers.addAll(_publicWifis.map((place) => Marker(
        markerId: MarkerId(place.id),
        position: place.location,
        icon: publicWifiIcon ?? BitmapDescriptor.defaultMarker,
        onTap: () => _showPlaceDetailsBottomSheet(place),
      )));
    }

    print('카페 데이터 개수: ${_cafes.length}');
    if (_categoryEnabled['카페'] == true) {
      markers.addAll(_cafes.map((place) => Marker(
        markerId: MarkerId(place.id),
        position: place.location,
        icon: cafeIcon ?? BitmapDescriptor.defaultMarker,
        onTap: () => _showPlaceDetailsBottomSheet(place),
      )));
    }

    print('음식점 데이터 개수: ${_restaurants.length}');
    if (_categoryEnabled['음식점'] == true) {
      markers.addAll(_restaurants.map((place) => Marker(
        markerId: MarkerId(place.id),
        position: place.location,
        icon: restaurantIcon ?? BitmapDescriptor.defaultMarker,
        onTap: () => _showPlaceDetailsBottomSheet(place),
      )));
    }

    print('랜드마크 데이터 개수: ${_landmarks.length}');
    if (_categoryEnabled['랜드마크'] == true) {
      markers.addAll(_landmarks.map((place) => Marker(
        markerId: MarkerId(place.id),
        position: place.location,
        icon: landmarkIcon ?? BitmapDescriptor.defaultMarker,
        onTap: () => _showPlaceDetailsBottomSheet(place),
      )));
    }

    print('총 생성된 마커 개수: ${markers.length}');

    // 현재 위치 마커 추가
    if (_currentPosition != null && _locationPermissionGranted) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentPosition!,
          icon: currentLocationIcon ?? BitmapDescriptor.defaultMarker,
          infoWindow: const InfoWindow(title: '현재 위치'),
        ),
      );
    }

    return markers;
  }

// _performMapSearch 함수 추가: 검색을 수행하고 지도에 표시하는 함수
  Future<void> _performMapSearch(String query) async {
    print("지도에서 '$query' 검색을 시작합니다!"); //
    if (mounted) {
      setState(() {
        _isLoading = true; // 검색 중 로딩 표시
        _syncProgressMessage = "'$query' 검색 중...";
      });
    }

    try {
      // 기존 searchPlacesFromFirestore 함수를 활용하여 Firestore에서 검색
      final results = await searchPlacesFromFirestore(query); //

      if (results.isNotEmpty) {
        // 검색 결과가 있다면 첫 번째 결과로 지도 이동 및 바텀시트 표시
        final firstPlace = results.first;
        await _moveToSelectedPlace(firstPlace.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("'$query'에 대한 검색 결과가 지도에 표시되었습니다: ${firstPlace.name}")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("'$query'에 대한 검색 결과가 없습니다.")),
        );
      }
    } catch (e) {
      print("지도 검색 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("지도 검색 중 오류 발생: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // 검색 완료 후 로딩 해제
          _syncProgressMessage = "데이터 동기화 완료"; // 메시지 초기화
        });
      }
    }
  }


  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String searchText = '';
        List<Place> searchResults = [];
        bool isSearching = false;

        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _handleSearch(String keyword) async {
              if (keyword.trim().isEmpty) return;

              setState(() => isSearching = true);
              try {
                final results = await searchPlacesFromFirestore(keyword); //
                searchResults = results;
              } catch (e) {
                searchResults = [];
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('검색 실패: $e')),
                );
              } finally {
                setState(() => isSearching = false);
              }
            }

            final bool hasResults = searchResults.isNotEmpty || isSearching;

            return AlertDialog(
              content: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: hasResults ? 500 : 100,
                width: 500,
                child: // ...중략...
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            textInputAction: TextInputAction.search,
                            decoration: const InputDecoration(
                              hintText: '장소 이름 또는 주소를 입력하세요', // 힌트 텍스트 변경
                              prefixIcon: Icon(Icons.search),
                            ),
                            onSubmitted: (value) {
                              searchText = value;
                              _handleSearch(value);
                            },
                            onChanged: (value) {
                              searchText = value;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _handleSearch(searchText),
                          child: const Text('검색'), // 텍스트 변경
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Expanded(
                      child: isSearching
                          ? const Center(child: CircularProgressIndicator())
                          : searchText.isEmpty
                          ? const SizedBox() // 검색 전에는 아무것도 안 보임
                          : searchResults.isEmpty
                          ? const Center(child: Text('검색 결과가 없습니다.')) // 텍스트 변경
                          : ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final place = searchResults[index];
                          return _buildSearchResultCard(
                            place,
                                () async {
                              Navigator.pop(context);
                              await _moveToSelectedPlace(place.id); //
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기'), // 텍스트 변경
                ),
              ],
            );
          },
        );
      },
    );
  }


  Widget _buildSearchResultCard(Place place, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: const Icon(Icons.location_on_outlined, color: Colors.redAccent, size: 22),
        title: Text(
          place.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          place.address ?? 'No Address',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: onTap,
      ),
    );
  }

  // build: 지도, 카테고리 필터, 로딩 UI 렌더링
  // 역할: 지도 화면 및 UI 구성
  // 분류: 디자인
  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('지도'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _fetchData(forceSync: true); //
            },
            tooltip: '데이터 동기화',
          ),
        ],
      ),
      body: Stack(
        children: [
          _isMapVisible
              ? GoogleMap(
            onMapCreated: _onMapCreated, //
            initialCameraPosition: const CameraPosition(
              target: initialPosition,
              zoom: 12,
            ),
            markers: _createMarkers(), //
            myLocationEnabled: _locationPermissionGranted, //
            myLocationButtonEnabled: true, //
          )
              : const Center(child: Text('지도 로드 대기 중...')),
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton(
              heroTag: 'search_button',
              onPressed: _showSearchDialog, //
              child: const Icon(Icons.search),
              tooltip: '장소 검색',
            ),
          ),

          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categoryEnabled.keys.map((categoryKey) { // 'category'를 'categoryKey'로 변경하여 명확성을 높임
                  // 여기서 지역화 함수를 호출합니다.
                  String localizedCategoryName = _getLocalizedCategoryName(categoryKey, appLocalizations);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(localizedCategoryName), // 지역화된 이름을 사용
                      selected: _categoryEnabled[categoryKey]!,
                      onSelected: (selected) {
                        setState(() {
                          _categoryEnabled[categoryKey] = selected;
                        });
                        // 여기에 필터링 함수를 호출할 수도 있습니다.
                        // _filterMarkersByCategory(categoryKey);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  Text(_syncProgressMessage),
                ],
              ),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlaceDialog, //
        child: const Icon(Icons.add),
        tooltip: '장소 추가',
      ),
    );
  }
}

Future<List<Place>> searchPlacesFromFirestore(String keyword) async {
  final firestore = FirebaseFirestore.instance;

  final querySnapshot = await firestore.collection('places').get(); // 전체 가져오기

  return querySnapshot.docs
      .where((doc) =>
  (doc.data()['name'] as String?)?.toLowerCase().contains(keyword.toLowerCase()) ?? false)
      .map((doc) {
    final data = doc.data();

    return Place(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'],
      category: data['category'] ?? '',
      location: LatLng(
        (data['latitude'] as num).toDouble(),
        (data['longitude'] as num).toDouble(),
      ),
      subcategory: data['subcategory'] ?? '',
      isEncrypted: data['isEncrypted'] ?? false,
      isFree: data['isFree'] ?? true,
      isUserAdded: data['isUserAdded'] ?? false,
      reviews: [],
      reports: [],
    );
  }).toList();
}