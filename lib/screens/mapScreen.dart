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

// 지도 화면 StatefulWidget
// 역할: Google Maps로 장소 표시, 사용자 장소 추가 및 리뷰 관리
class MapScreen extends StatefulWidget {
  final String currentUserId; // 현재 사용자 ID
  final String? selectedPlaceId; // 선택된 장소 ID

  const MapScreen({
    super.key,
    required this.currentUserId,
    this.selectedPlaceId,
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
  List<Place> _touristAttractions = []; // 관광 명소 리스트 추가
  bool _isLoading = true; // 로딩 상태
  LatLng? _currentPosition; // 현재 위치
  bool _locationPermissionGranted = false; // 위치 권한 상태
  String? _currentUserNickname; // 사용자 닉네임
  String _syncProgressMessage = "데이터 동기화 중..."; // 동기화 메시지
  bool _isMapReady = false; // 지도 준비 상태
  String? _lastProcessedPlaceId; // 마지막 처리된 장소 ID
  bool _isMapVisible = false; // 지도 표시 상태

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 독립 카테고리로 변경 (관광 명소 카테고리 추가)
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
    '관광 명소': true, // 관광 명소 카테고리 추가
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
  BitmapDescriptor? touristAttractionIcon; // 관광 명소 아이콘 추가
  BitmapDescriptor? currentLocationIcon; // 현재 위치 마커 아이콘

  static const LatLng initialPosition = LatLng(37.5665, 126.9780);

  // initState: 위젯 초기화, 데이터 초기화 시작
  // 역할: 초기 설정 및 데이터 로드
  // 분류: 로직
  @override
  void initState() {
    super.initState();
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
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
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
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
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
      Position position = await Geolocator.getCurrentPosition(
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
    setState(() {}); // 마커 업데이트를 위해 새로고침
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

  // _setupMarkerIcons: 각 카테고리별 마커 아이콘 설정
  // 역할: 지도 마커 아이콘 초기화 (관광 명소 아이콘 추가)
  // 분류: 로직
  Future<void> _setupMarkerIcons() async {
    hospitalIcon = await BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    pharmacyIcon = await BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    policeIcon = await BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    atmIcon = await BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    bankIcon = await BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    currencyExchangeIcon = await BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    publicToiletIcon = await BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
    lockerFreeIcon = await BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta);
    lockerPaidIcon = await BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
    chargingStationIcon = await BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta);
    publicWifiIcon = await BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
    touristAttractionIcon = await BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow); // 관광 명소 아이콘 추가
    currentLocationIcon = await BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  }

  // _isKakaoDataSynced: Kakao 데이터 동기화 여부 확인
  // 역할: SharedPreferences로 동기화 상태 확인
  // 분류: 로직
  Future<bool> _isKakaoDataSynced() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('kakao_data_synced') ?? false;
  }

  // _setKakaoDataSynced: Kakao 데이터 동기화 완료 설정
  // 역할: SharedPreferences에 동기화 상태 저장
  // 분류: 로직
  Future<void> _setKakaoDataSynced() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('kakao_data_synced', true);
  }

  // _fetchData: Kakao API 및 Firestore에서 장소 데이터 가져오기
  // 역할: 장소 데이터 동기화 및 로드, 선택된 장소 처리
  // 분류: 로직
  Future<void> _fetchData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      bool isSynced = await _isKakaoDataSynced();
      if (!isSynced) {
        final kakaoApiService = KakaoApiService();
        final publicWifiService = PublicWifiService(); // 공공 와이파이 서비스 추가

        if (mounted) setState(() => _syncProgressMessage = "병원 위치 동기화 중...");
        final hospitals = await kakaoApiService.fetchHospitals();
        await _syncKakaoDataToFirestore(hospitals);

        if (mounted) setState(() => _syncProgressMessage = "약국 위치 동기화 중...");
        final pharmacies = await kakaoApiService.fetchPharmacies();
        await _syncKakaoDataToFirestore(pharmacies);

        if (mounted) setState(() => _syncProgressMessage = "경찰서/파출소 동기화 중...");
        final policeStations = await kakaoApiService.fetchPoliceStations();
        await _syncKakaoDataToFirestore(policeStations);

        if (mounted) setState(() => _syncProgressMessage = "ATM기 위치 동기화 중...");
        final atms = await kakaoApiService.fetchAtms();
        await _syncKakaoDataToFirestore(atms);

        if (mounted) setState(() => _syncProgressMessage = "은행 위치 동기화 중...");
        final banks = await kakaoApiService.fetchBanks();
        await _syncKakaoDataToFirestore(banks);

        if (mounted) setState(() => _syncProgressMessage = "환전소 위치 동기화 중...");
        final currencyExchanges = await kakaoApiService.fetchCurrencyExchanges();
        await _syncKakaoDataToFirestore(currencyExchanges);

        if (mounted) setState(() => _syncProgressMessage = "공중 화장실 동기화 중...");
        final publicToilets = await kakaoApiService.fetchPublicToilets();
        await _syncKakaoDataToFirestore(publicToilets);

        if (mounted) setState(() => _syncProgressMessage = "물품 보관함 동기화 중...");
        final lockers = await kakaoApiService.fetchLockers();
        await _syncKakaoDataToFirestore(lockers);

        // 공공 와이파이 데이터를 공공 데이터 포털에서 가져오기
        if (mounted) setState(() => _syncProgressMessage = "공공 와이파이 동기화 중...");
        final publicWifis = await publicWifiService.fetchPublicWifis();
        await _syncKakaoDataToFirestore(publicWifis);

        // 관광 명소 데이터를 카카오맵 API에서 가져오기
        if (mounted) setState(() => _syncProgressMessage = "관광 명소 동기화 중...");
        final touristAttractions = await kakaoApiService.fetchTouristAttractions();
        await _syncKakaoDataToFirestore(touristAttractions);

        await _setKakaoDataSynced();
      }

      // imageUri 추가
      final userPlacesSnapshot = await _firestore.collection('places').get();

      final userPlaces = userPlacesSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        List<Review> reviews = [];
        if (data['reviews'] != null) {
          reviews = (data['reviews'] as List).map((raw) {
            final reviewData = raw as Map<String, dynamic>;
            return Review(
              userId: reviewData['userId'] as String,
              rating: (reviewData['rating'] as num?)?.toDouble() ?? 0.0,
              comment: reviewData['comment'] as String,
              likes: (reviewData['likes'] as num?)?.toInt() ?? 0,
              imageUri: reviewData['imageUri'] as String?,  // ← 여기서 읽어오기
            );
          }).toList();
        }

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
        );
      }).toList();

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
          _restrooms = userPlaces.where((place) => place.subcategory == '공중 화장실').toList();
          _chargingStations = userPlaces.where((place) => place.subcategory == '휴대폰 충전 가능 장소').toList();
          _publicWifis = userPlaces.where((place) => place.subcategory == '공공 와이파이').toList();
          _touristAttractions = userPlaces.where((place) => place.subcategory == '관광 명소').toList(); // 관광 명소 데이터 추가

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
        });
        batchCount++;

        if (batchCount >= batchSize) {
          await batch.commit();
          batch = _firestore.batch();
          batchCount = 0;
        }
      }
    }

    if (batchCount > 0) {
      await batch.commit();
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
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(widget.currentUserId).get();
    if (userDoc.exists) {
      List<String> favorites = List<String>.from(userDoc['favorites'] ?? []);
      return favorites.contains(placeId);
    }
    return false;
  }

  // _toggleFavorite: 장소 찜 목록 추가/제거
  // 역할: Firestore에서 사용자 및 장소 찜 상태 업데이트
  // 분류: 로직
  Future<void> _toggleFavorite(String placeId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(widget.currentUserId).get();
      List<String> favorites = [];
      if (userDoc.exists) {
        favorites = List<String>.from(userDoc['favorites'] ?? []);
      }

      bool isFavorited = favorites.contains(placeId);
      if (isFavorited) {
        favorites.remove(placeId);
      } else {
        favorites.add(placeId);
      }

      await _firestore.collection('users').doc(widget.currentUserId).update({
        'favorites': favorites,
      });

      DocumentSnapshot placeDoc = await _firestore.collection('places').doc(placeId).get();
      List<String> favoritedBy = [];
      if (placeDoc.exists) {
        favoritedBy = List<String>.from(placeDoc['favoritedBy'] ?? []);
      }

      if (isFavorited) {
        favoritedBy.remove(widget.currentUserId);
      } else {
        favoritedBy.add(widget.currentUserId);
      }

      await _firestore.collection('places').doc(placeId).update({
        'favoritedBy': favoritedBy,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('찜 목록 업데이트 중 오류가 발생했습니다.')),
      );
    }
  }

  // _moveToSelectedPlace: 선택된 장소로 지도 이동 및 세부 정보 표시
  // 역할: 지도 카메라 이동 및 바텀시트 표시
  // 분류: 로직
  Future<void> _moveToSelectedPlace(String placeId) async {
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
      ..._touristAttractions, // 관광 명소 추가
    ]) {
      if (place.id == placeId) {
        selectedPlace = place;
        break;
      }
    }

    if (selectedPlace != null) {
      await mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(selectedPlace.location, 15),
      );
      _showPlaceDetailsBottomSheet(selectedPlace);
      _lastProcessedPlaceId = placeId;
    }
  }

  // 이미지 -> 파이어베이스 연동
  Future<String?> uploadImageToFirebase(File imageFile) async {
    try {
      final fileName = 'review_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('이미지 업로드 실패: $e');
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
              File(imagePath),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FutureBuilder<bool>(
              future: _isPlaceFavorited(place.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                bool isFavorited = snapshot.data ?? false;
                double averageRating = place.reviews.isNotEmpty
                    ? place.reviews.map((r) => r.rating).reduce((a, b) => a + b) / place.reviews.length
                    : 0.0;

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
                                await _toggleFavorite(place.id);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // ────────────────────────── 평균 별점
                        Text('평균 별점: ${averageRating.toStringAsFixed(1)}'),
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
                        const SizedBox(height: 8),
                        // ────────────────────────── 리뷰 목록
                        const Text('코멘트:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                    if (review.imageUri != null) ... [
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () => _showImagePreview(review.imageUri!),
                                        child: ClipRRect (
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.file(
                                            File(review.imageUri!),
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    ]
                                    /*Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Image.file(
                                          File(review.imageUri!),
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),*/
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

  // _getNickname: Firestore에서 사용자 닉네임 조회
  // 역할: 리뷰 작성자 닉네임 가져오기
  // 분류: 로직
  Future<String> _getNickname(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return (userDoc.data() as Map<String, dynamic>)['nickname'] as String? ?? userId;
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
    final TextEditingController commentController = TextEditingController();
    double newRating = 3.0;

    if (_currentUserNickname == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보를 불러오는 중입니다. 잠시 후 다시 시도해주세요.')),
      );
      return;
    }

    // ImagePicker 인스턴스와 선택된 파일 참조
    final ImagePicker _picker = ImagePicker();
    XFile? pickedImage;

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
                        final XFile? image = await _picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 800,
                          imageQuality: 80,
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
                                child: Image.file(File(pickedImage!.path)),
                              ),
                            ),
                          );
                        },
                        child: Image.file(
                          File(pickedImage!.path),
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
                      Review newReview = Review(
                        userId: widget.currentUserId,
                        rating: newRating,
                        comment: commentController.text,
                        likes: 0,
                        imageUri: pickedImage?.path, // imageUri 추가
                      );

                      DocumentSnapshot doc = await _firestore.collection('places').doc(place.id).get();
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

                      await _fetchData();

                      if (mounted) {
                        Navigator.pop(context);
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

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('새 장소 추가'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      hint: const Text('카테고리 선택'),
                      value: selectedCategory,
                      items: _categoryEnabled.keys.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
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
                          selectedCategory!,
                        );
                      }
                          : null,
                      child: const Text('위치 선택'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
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
    // 현재 위치가 없으면 initialPosition 사용
    LatLng initialMarkerPosition = _currentPosition ?? initialPosition;
    LatLng selectedPosition = initialMarkerPosition;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('위치 선택'),
          content: SizedBox(
            height: 400,
            width: 300,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: initialMarkerPosition, // 현재 위치에서 시작
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {},
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
                  child: Icon(
                    Icons.add,
                    size: 30,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showAddPlaceDetailsDialog(category, subcategory, selectedPosition);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // _showAddPlaceDetailsDialog: 장소 세부 정보 입력 다이얼로그
  // 역할: 장소 이름, 무료/유료 여부 입력 UI 제공
  // 분류: 디자인
  void _showAddPlaceDetailsDialog(String category, String subcategory, LatLng position) {
    final nameController = TextEditingController();
    bool isFree = true;

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
                      decoration: const InputDecoration(labelText: '장소 이름'),
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
                    final name = nameController.text;
                    if (name.isNotEmpty) {
                      final newPlace = Place(
                        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        location: position,
                        category: category,
                        subcategory: subcategory,
                        isUserAdded: true,
                        isFree: subcategory == '물품 보관함' ? isFree : true,
                      );

                      try {
                        await _firestore.collection('places').doc(newPlace.id).set({
                          'id': newPlace.id,
                          'name': newPlace.name,
                          'latitude': newPlace.location.latitude,
                          'longitude': newPlace.location.longitude,
                          'category': newPlace.category,
                          'subcategory': newPlace.subcategory,
                          'isEncrypted': newPlace.isEncrypted,
                          'isFree': newPlace.isFree,
                          'isUserAdded': newPlace.isUserAdded,
                          'reviews': [],
                          'reports': [],
                          'favoritedBy': [],
                        });

                        setState(() {
                          switch (subcategory) {
                            case '병원':
                              _hospitals.add(newPlace);
                              break;
                            case '약국':
                              _pharmacies.add(newPlace);
                              break;
                            case '경찰서':
                              _policeStations.add(newPlace);
                              break;
                            case 'ATM':
                              _atms.add(newPlace);
                              break;
                            case '은행':
                              _banks.add(newPlace);
                              break;
                            case '환전소':
                              _currencyExchanges.add(newPlace);
                              break;
                            case '공중 화장실':
                              _publicToilets.add(newPlace);
                              _restrooms.add(newPlace);
                              break;
                            case '물품 보관함':
                              _lockers.add(newPlace);
                              break;
                            case '휴대폰 충전소':
                              _chargingStations.add(newPlace);
                              break;
                            case '공공 와이파이':
                              _publicWifis.add(newPlace);
                              break;
                            case '관광 명소':
                              _touristAttractions.add(newPlace);
                              break;
                          }
                        });

                        mapController?.animateCamera(CameraUpdate.newLatLng(position));
                      } catch (e) {}

                      Navigator.pop(context);
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

  // _createMarkers: 지도에 표시할 마커 생성
  // 역할: 카테고리별 장소 마커 생성 (관광 명소 추가)
  // 분류: 로직
  Set<Marker> _createMarkers() {
    final List<Place> allPlaces = [];

    if (_categoryEnabled['병원'] == true) {
      allPlaces.addAll(_hospitals);
    }
    if (_categoryEnabled['약국'] == true) {
      allPlaces.addAll(_pharmacies);
    }
    if (_categoryEnabled['경찰서'] == true) {
      allPlaces.addAll(_policeStations);
    }
    if (_categoryEnabled['ATM'] == true) {
      allPlaces.addAll(_atms);
    }
    if (_categoryEnabled['은행'] == true) {
      allPlaces.addAll(_banks);
    }
    if (_categoryEnabled['환전소'] == true) {
      allPlaces.addAll(_currencyExchanges);
    }
    if (_categoryEnabled['공중 화장실'] == true) {
      allPlaces.addAll(_publicToilets);
      allPlaces.addAll(_restrooms);
    }
    if (_categoryEnabled['물품 보관함'] == true) {
      allPlaces.addAll(_lockers);
    }
    if (_categoryEnabled['휴대폰 충전소'] == true) {
      allPlaces.addAll(_chargingStations);
    }
    if (_categoryEnabled['공공 와이파이'] == true) {
      allPlaces.addAll(_publicWifis);
    }
    if (_categoryEnabled['관광 명소'] == true) {
      allPlaces.addAll(_touristAttractions); // 관광 명소 추가
    }

    final Set<Marker> markers = allPlaces.map((place) {
      BitmapDescriptor icon;
      switch (place.subcategory) {
        case '병원 위치':
          icon = hospitalIcon ?? BitmapDescriptor.defaultMarker;
          break;
        case '약국 위치':
          icon = pharmacyIcon ?? BitmapDescriptor.defaultMarker;
          break;
        case '경찰서/파출소':
          icon = policeIcon ?? BitmapDescriptor.defaultMarker;
          break;
        case 'ATM기 위치':
          icon = atmIcon ?? BitmapDescriptor.defaultMarker;
          break;
        case '은행 위치':
          icon = bankIcon ?? BitmapDescriptor.defaultMarker;
          break;
        case '환전소 위치':
          icon = currencyExchangeIcon ?? BitmapDescriptor.defaultMarker;
          break;
        case '공중 화장실':
          icon = publicToiletIcon ?? BitmapDescriptor.defaultMarker;
          break;
        case '물품 보관함':
          icon = place.isFree
              ? (lockerFreeIcon ?? BitmapDescriptor.defaultMarker)
              : (lockerPaidIcon ?? BitmapDescriptor.defaultMarker);
          break;
        case '휴대폰 충전 가능 장소':
          icon = chargingStationIcon ?? BitmapDescriptor.defaultMarker;
          break;
        case '공공 와이파이':
          icon = publicWifiIcon ?? BitmapDescriptor.defaultMarker;
          break;
        case '관광 명소':
          icon = touristAttractionIcon ?? BitmapDescriptor.defaultMarker;
          break;
        default:
          icon = BitmapDescriptor.defaultMarker;
      }

      return Marker(
        markerId: MarkerId(place.id),
        position: place.location,
        icon: icon,
        onTap: () {
          _showPlaceDetailsBottomSheet(place);
        },
      );
    }).toSet();

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

  // build: 지도, 카테고리 필터, 로딩 UI 렌더링
  // 역할: 지도 화면 및 UI 구성
  // 분류: 디자인
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('지도'),
      ),
      body: Stack(
        children: [
          _isMapVisible
              ? GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: initialPosition,
              zoom: 12,
            ),
            markers: _createMarkers(),
            myLocationEnabled: _locationPermissionGranted,
            myLocationButtonEnabled: true,
          )
              : const Center(child: Text('지도 로드 대기 중...')),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categoryEnabled.keys.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: _categoryEnabled[category]!,
                      onSelected: (selected) {
                        setState(() {
                          _categoryEnabled[category] = selected;
                        });
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
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlaceDialog,
        child: const Icon(Icons.add),
        tooltip: '장소 추가',
      ),
    );
  }
}