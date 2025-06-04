import 'package:flutter/material.dart';
import 'package:app_for_traveler/screens/mapScreen.dart';
import 'package:app_for_traveler/hotspotCard.dart';
import 'package:app_for_traveler/screens/myPageScreen.dart';
import 'package:app_for_traveler/screens/boardScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_for_traveler/models/place.dart';
import 'dart:async';
import 'package:app_for_traveler/services/disaster_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'companionListScreen.dart';
import 'notificationScreen.dart';
import 'companionDetailScreen.dart'; // 기존에 작성한 동행 상세 페이지 가져오기
import '../companionCard.dart';
import 'companionListScreen.dart';
import 'weatherScreen.dart';

// 추가된 임포트 (RecommendationService와 WeatherDataFetcher가 별도 파일에 있다고 가정)
import 'package:app_for_traveler/services/recommendation_service.dart';
import 'package:app_for_traveler/services/weather_data_fetcher.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


// 기존 CompanionCard 정의 (이 파일에 없으면 CompanionCard.dart에서 임포트)
class CompanionCard extends StatelessWidget {
  final String title;
  final String destination;
  final String content;
  final int currentCount;
  final int maxCount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isClosed;

  const CompanionCard({
    super.key,
    required this.title,
    required this.destination,
    required this.content,
    required this.currentCount,
    required this.maxCount,
    required this.startDate,
    required this.endDate,
    required this.isClosed,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy.MM.dd');
    final dateRange = '${dateFormat.format(startDate)} ~ ${dateFormat.format(endDate)}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.groups, color: Colors.blue),
                const SizedBox(width: 6),
                Text('$currentCount / $maxCount'),
                const Spacer(),
                if (isClosed)
                  const Text('모집 마감', style: TextStyle(color: Colors.red)),
              ],
            ),
            const SizedBox(height: 6),
            Text(dateRange, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 8),
            Text(content, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// 기존 TravelMateSection 정의 (이 파일에 없으면 TravelMateSection.dart에서 임포트)
class TravelMateSection extends StatefulWidget {
  final String currentUserId;

  const TravelMateSection({super.key, required this.currentUserId});

  @override
  State<TravelMateSection> createState() => _TravelMateSectionState();
}

class _TravelMateSectionState extends State<TravelMateSection> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _companions = [];

  @override
  void initState() {
    super.initState();
    _fetchCompanions();
  }

  Future<void> _fetchCompanions() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('companions')
          .orderBy('createdAt', descending: true)
          .limit(3)
          .get();

      final data = snapshot.docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'title': d['title'] ?? '제목 없음',
          'destination': d['destination'] ?? '여행지 미정',
          'content': d['content'] ?? '',
          'currentCount': d['currentCount'] ?? 1,
          'maxCount': d['maxCount'] ?? 4,
          'startDate': (d['startDate'] as Timestamp).toDate(),
          'endDate': (d['endDate'] as Timestamp).toDate(),
          'isClosed': d['isClosed'] is bool ? d['isClosed'] : false,
        };
      }).toList();

      setState(() {
        _companions = data;
      });
    } catch (e) {
      print('🔥 동행자 로드 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('동행자 구해요 👋', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        if (_companions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('현재 모집 중인 동행이 없습니다.', style: TextStyle(color: Colors.grey)),
          )
        else
          ..._companions.map((c) => GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CompanionDetailScreen(
                    companionId: c['id'],
                    currentUserId: widget.currentUserId,
                  ),
                ),
              );
            },
            child: CompanionCard(
              title: c['title'],
              destination: c['destination'],
              content: c['content'],
              currentCount: c['currentCount'],
              maxCount: c['maxCount'],
              startDate: c['startDate'],
              endDate: c['endDate'],
              isClosed: c['isClosed'],
            ),
          )),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CompanionListScreen(currentUserId: widget.currentUserId),
                ),
              );
            },
            child: const Text('더 많은 동행 보기...', style: TextStyle(fontSize: 14)),
          ),
        ),
      ],
    );
  }
}


class HomeScreen extends StatefulWidget {
  final String currentUserId;
  final Function(String?) onLogout;

  const HomeScreen({
    super.key,
    required this.currentUserId,
    required this.onLogout,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _selectedPlaceId;
  String? _currentUserNickname;
  Timer? _disasterCheckTimer;
  Set<int> _shownDisasterSNs = {};
  List<Map<String, dynamic>> _disasterAlerts = [];
  List<Map<String, dynamic>> _commentAlerts = [];

  // HomeContent에서 받아올 날씨 데이터를 저장할 변수
  Map<String, dynamic>? _weatherDataForWeatherScreen;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserNickname();
    _checkAndResetSNsIfNewDay();
    _startDisasterCheckTimer();
    _loadAllAlerts();
  }

  // HomeContent로부터 날씨 데이터를 받을 콜백 함수
  void _updateWeatherDataFromHomeContent(Map<String, dynamic>? data) {
    setState(() {
      _weatherDataForWeatherScreen = data;
    });
  }

  // HomeScreen의 탭을 변경하고, 필요시 선택된 장소 ID를 설정하는 공용 메서드
  void changeTab(int index, {String? placeId}) {
    setState(() {
      _selectedIndex = index;
      _selectedPlaceId = placeId; // 지도 탭으로 이동할 때만 placeId가 유효함
    });
  }


  Future<void> _loadAllAlerts() async {
    final disasters = await _loadDisasterAlerts();
    final comments = await _loadCommentAlerts(widget.currentUserId);
    setState(() {
      _disasterAlerts = disasters;
      _commentAlerts = comments;
    });
  }

  Future<void> _checkAndResetSNsIfNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _generateTodayKey();
    final lastSeenDate = prefs.getString('last_seen_date');

    if (lastSeenDate != today) {
      await prefs.remove('shown_sn_list');
      await prefs.remove('sn_time_map');
      await prefs.setString('last_seen_date', today);
    }

    final savedSnList = prefs.getStringList('shown_sn_list') ?? [];
    setState(() {
      _shownDisasterSNs = savedSnList.map(int.parse).toSet();
    });
  }

  String _generateTodayKey() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}}';
  }

  Future<void> _saveShownDisasterSNs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'shown_sn_list',
      _shownDisasterSNs.map((e) => e.toString()).toList(),
    );
  }

  void _startDisasterCheckTimer() {
    _disasterCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      try {
        final disasters = await DisasterApiService.fetchTodayDisasterMessages();
        for (final item in disasters) {
          final int sn = item['sn'];
          final String msg = item['msg'];

          if (!_shownDisasterSNs.contains(sn)) {
            _shownDisasterSNs.add(sn);
            await _saveShownDisasterSNs();
            if (mounted) _showDisasterAlert(msg);
          }
        }
      } catch (e) {
        print('재난 문자 확인 중 오류: $e');
      }
    });
  }

  void _showDisasterAlert(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('📢 새로운 재난 문자'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadDisasterAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSnList = prefs.getStringList('shown_sn_list') ?? [];
    final savedTimeMap = prefs.getString('sn_time_map');
    final timeMap = savedTimeMap != null ? jsonDecode(savedTimeMap) as Map<String, dynamic> : {};

    final disasters = await DisasterApiService.fetchTodayDisasterMessages();

    for (var d in disasters) {
      final snStr = d['sn'].toString();
      if (!timeMap.containsKey(snStr)) {
        timeMap[snStr] = (d['timestamp'] as DateTime).toIso8601String();
      }
    }

    await prefs.setString('sn_time_map', jsonEncode(timeMap));

    return disasters
        .where((d) => savedSnList.contains(d['sn'].toString()))
        .map((d) {
      final snStr = d['sn'].toString();
      final t = DateTime.tryParse(timeMap[snStr] ?? '') ?? d['timestamp'];
      return {
        'sn': d['sn'],
        'message': d['msg'],
        'timestamp': t,
      };
    })
        .toList();
  }

  Future<List<Map<String, dynamic>>> _loadCommentAlerts(String currentUserId) async {
    final firestore = FirebaseFirestore.instance;

    final myPostsSnapshot = await firestore
        .collection('posts')
        .where('authorId', isEqualTo: currentUserId)
        .get();

    List<Map<String, dynamic>> alerts = [];

    for (var postDoc in myPostsSnapshot.docs) {
      final postId = postDoc.id;
      final postData = postDoc.data();
      final postTitle = postData['title'] ?? '';
      final postContent = postData['content'] ?? '';
      final postCreatedAt = (postData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      final postAuthorNickname = postData['authorNickname'] ?? '알 수 없음';

      final commentSnapshot = await firestore
          .collection('comments')
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      for (var commentDoc in commentSnapshot.docs) {
        final commentData = commentDoc.data();
        if (commentData['authorId'] != currentUserId) {
          alerts.add({
            'nickname': commentData['authorNickname'] ?? '알 수 없음',
            'postId': postId,
            'postTitle': postTitle,
            'postContent': postContent,
            'postAuthorId': currentUserId,
            'postAuthorNickname': postAuthorNickname,
            'postCreatedAt': postCreatedAt,
            'timestamp': (commentData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          });
        }
      }
    }

    return alerts;
  }

  @override
  void dispose() {
    _disasterCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchCurrentUserNickname() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.currentUserId).get();
      if (userDoc.exists) {
        setState(() {
          _currentUserNickname = (userDoc.data() as Map<String, dynamic>)['nickname'] as String? ?? widget.currentUserId;
        });
      } else {
        setState(() {
          _currentUserNickname = widget.currentUserId;
        });
      }
    } catch (e) {
      setState(() {
        _currentUserNickname = widget.currentUserId;
      });
    }
  }

  // 이 메서드는 이제 HomeScreen 내부에서만 사용되고, 외부에서는 changeTab을 통해 접근합니다.
  // 이 메서드를 직접 호출하는 대신, HomeScreen의 changeTab 메서드를 사용하도록 변경할 것입니다.
  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //     if (index != 1) {
  //       _selectedPlaceId = null;
  //     }
  //   });
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 도우미'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.sunny),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WeatherScreen(
                    initialWeatherData: _weatherDataForWeatherScreen, // 날씨 데이터 전달
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationScreen(
                    disasterAlerts: _disasterAlerts,
                    commentAlerts: _commentAlerts,
                    currentUserId: widget.currentUserId,
                    currentUserNickname: _currentUserNickname,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            // HomeContent에 새로운 콜백 'onTabChanged'를 전달합니다.
            HomeContent(
              currentUserId: widget.currentUserId,
              onWeatherDataReady: _updateWeatherDataFromHomeContent,
              onTabChanged: changeTab, // HomeScreen의 changeTab 메서드를 전달
            ),
            MapScreen(
              currentUserId: widget.currentUserId,
              selectedPlaceId: _selectedPlaceId,
              key: const ValueKey('map_screen'),
            ),
            BoardScreen(
              currentUserId: widget.currentUserId,
              currentUserNickname: _currentUserNickname,
            ),
            MyPageScreen(
              currentUserId: widget.currentUserId,
              onLogout: widget.onLogout,
              // MyPageScreen에서도 탭 변경이 필요할 경우, changeTab을 전달할 수 있습니다.
              // 여기서는 이미 onPlaceSelected가 유사한 역할을 하므로 그대로 둡니다.
              onPlaceSelected: (placeId) {
                changeTab(1, placeId: placeId); // 지도 탭으로 이동하며 placeId 설정
              },
            ),
            CompanionListScreen(currentUserId: widget.currentUserId), // 예시로 추가, 실제 앱 구조에 따라 위치 변경
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: '지도'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: '게시판'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(color: Colors.grey),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: changeTab, // 여기서는 직접 changeTab을 호출
      ),
    );
  }
}



// 홈 화면 콘텐츠 StatefulWidget
// 역할: 추천, 인기 장소, 최근 게시물 표시
class HomeContent extends StatefulWidget {
  final String currentUserId;
  final Function(Map<String, dynamic>?) onWeatherDataReady;
  final Function(int index, {String? placeId}) onTabChanged; // 새로운 콜백 추가

  const HomeContent({
    super.key,
    required this.currentUserId,
    required this.onWeatherDataReady,
    required this.onTabChanged, // 생성자에 추가
  });

  @override
  _HomeContentState createState() => _HomeContentState();
}


// HomeContent 상태 관리 클래스
// 역할: Firestore 데이터 가져와 UI 업데이트
class _HomeContentState extends State<HomeContent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _topPlaces = [];
  List<Map<String, dynamic>> _recentPosts = [];

  // --- 날씨, 배터리, Wi-Fi 관련 상태 변수 추가 ---
  double _latitude = 0.0;
  double _longitude = 0.0;
  Map<String, dynamic>? _weatherData;
  bool _isLoadingWeather = true;
  String _weatherError = '';

  int _batteryLevel = 100;
  BatteryState _batteryState = BatteryState.full;
  late StreamSubscription<BatteryState> _batteryStateSubscription;
  Timer? _batteryLevelTimer;

  List<ConnectivityResult> _connectivityResult = [ConnectivityResult.none]; // 초기값도 리스트로 설정
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription; // 구독 타입도 리스트로 변경

  // 서비스 인스턴스
  final WeatherDataFetcher _weatherFetcher = WeatherDataFetcher();
  final RecommendationService _recommendationService = RecommendationService(); // RecommendationService 인스턴스
  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();
  // --- 여기까지 추가 ---

  void _initConnectivity() async {
    // 이제 _connectivityResult는 List<ConnectivityResult>를 받을 수 있습니다.
    _connectivityResult = await _connectivity.checkConnectivity();
    if (mounted) setState(() {});

    // 2. listen 콜백 함수의 result 인자 타입도 List<ConnectivityResult>로 변경
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if (mounted) {
        setState(() {
          _connectivityResult = result;
        });
      }
    });
  }
  // initState: 위젯 초기화, 데이터 조회 시작
  // 역할: 데이터 초기화
  // 분류: 로직
  @override
  void initState() {
    super.initState();
    _fetchTopPlaces();
    _fetchRecentPosts();
    _loadRecommendationData(); // 추천 관련 데이터 로드 함수 추가
  }

  @override
  void dispose() {
    _batteryStateSubscription.cancel();
    _connectivitySubscription.cancel();
    _batteryLevelTimer?.cancel();
    super.dispose();
  }

  // --- 추천 관련 데이터 로드 함수 추가 ---
  Future<void> _loadRecommendationData() async {
    await _loadWeatherAndForecast();
    _initBatteryState();
    _initConnectivity();
  }

  Future<void> _loadWeatherAndForecast() async {
    setState(() {
      _isLoadingWeather = true;
      _weatherError = '';
    });

    try {
      final position = await _weatherFetcher.getCurrentLocation(context);
      if (position != null) {
        _latitude = position.latitude;
        _longitude = position.longitude;
        final data = await _weatherFetcher.fetchWeatherData(_latitude, _longitude);
        if (mounted) {
          setState(() {
            _weatherData = data;
            _isLoadingWeather = false;
          });
        }
        widget.onWeatherDataReady(_weatherData); // 데이터 로드 완료 후 HomeScreen으로 전달
      } else {
        if (mounted) {
          setState(() {
            _isLoadingWeather = false;
            _weatherError = '위치 정보를 가져올 수 없습니다.';
          });
        }
        widget.onWeatherDataReady(null); // 데이터 로드 실패 시 HomeScreen으로 null 전달
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingWeather = false;
          _weatherError = '날씨 정보를 가져오는 중 오류 발생: $e';
        });
      }
      widget.onWeatherDataReady(null); // 오류 발생 시 HomeScreen으로 null 전달
    }
  }

  void _initBatteryState() async {
    _batteryLevel = await _battery.batteryLevel;
    _batteryState = await _battery.batteryState;
    if (mounted) setState(() {});

    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((BatteryState state) {
      if (mounted) {
        setState(() {
          _batteryState = state;
        });
      }
    });

    _batteryLevelTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      final level = await _battery.batteryLevel;
      if (mounted) {
        setState(() {
          _batteryLevel = level;
        });
      }
    });
  }
  // --- 여기까지 추가 ---

  // _fetchTopPlaces: Firestore에서 인기 장소 가져와 정렬 후 상태 업데이트
  // 역할: 장소 데이터 조회 및 처리
  // 분류: 로직
  Future<void> _fetchTopPlaces() async {
    try {
      QuerySnapshot placesSnapshot = await _firestore.collection('places').get();
      List<Map<String, dynamic>> places = placesSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        List<Review> reviews = [];
        if (data['reviews'] != null) {
          reviews = (data['reviews'] as List).map((reviewData) {
            return Review(
              userId: reviewData['userId'] as String,
              rating: reviewData['rating']?.toDouble() ?? 0.0,
              comment: reviewData['comment'] as String,
              likes: reviewData['likes']?.toInt() ?? 0,
            );
          }).toList();
        }

        double averageRating = reviews.isNotEmpty
            ? reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length
            : 0.0;

        String? latestReview = reviews.isNotEmpty ? reviews.last.comment : null;

        return {
          'id': doc.id,
          'name': data['name'] as String? ?? 'Unknown',
          'description': data['subcategory'] as String? ?? 'No description',
          'favoritedBy': List<String>.from(data['favoritedBy'] ?? []),
          'isUserAdded': data['isUserAdded'] as bool? ?? false,
          'averageRating': averageRating,
          'latestReview': latestReview,
        };
      }).toList();

      places.sort((a, b) {
        int compare = b['favoritedBy'].length.compareTo(a['favoritedBy'].length);
        if (compare == 0) {
          return a['name'].compareTo(b['name']);
        }
        return compare;
      });

      if (mounted) {
        setState(() {
          _topPlaces = places.take(10).toList();
        });
      }
    } catch (e) {
      print('🔥 인기 장소 로드 실패: $e');
    }
  }

  // _fetchRecentPosts: Firestore에서 최근 3개 게시물 가져와 상태 업데이트
  // 역할: 게시물 데이터 조회
  // 분류: 로직
  Future<void> _fetchRecentPosts() async {
    try {
      QuerySnapshot postSnapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(3)
          .get();

      List<Map<String, dynamic>> posts = postSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'title': data['title'] as String? ?? '제목 없음',
          'content': data['content'] as String? ?? '내용 없음',
          'authorId': data['authorId'] as String? ?? '알 수 없음',
          'authorNickname': data['authorNickname'] as String? ?? '알 수 없음',
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        };
      }).toList();

      if (mounted) {
        setState(() {
          _recentPosts = posts;
        });
      }
    } catch (e) {
      print('🔥 최근 게시물 로드 실패: $e');
    }
  }

  // build: 추천, 인기 장소, 최근 게시물 UI 렌더링
  // 역할: 화면 UI 구성
  // 분류: 디자인
  @override
  Widget build(BuildContext context) {
    // 추천 메시지 생성
    String currentRecommendation = _recommendationService.getRecommendation(
      weatherData: _weatherData,
      batteryLevel: _batteryLevel,
      batteryState: _batteryState,
      connectivityResult: _connectivityResult.isNotEmpty ? _connectivityResult.first : ConnectivityResult.none, // 이제 List<ConnectivityResult>가 전달됩니다.
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // --- 현재 상태 기반 추천 섹션 (수정) ---
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.lightBlue[50],
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '현재 상태 기반 추천',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  currentRecommendation, // 동적으로 생성된 추천 메시지
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // 이제 직접 HomeScreen의 탭 변경 메서드를 호출합니다.
                    widget.onTabChanged(1); // 탭 인덱스 1 (지도 화면)으로 이동
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: Colors.blueAccent, // 버튼 색상
                    foregroundColor: Colors.white, // 텍스트 색상
                  ),
                  child: const Text('관련 장소 지도 보기'), // 버튼 텍스트 변경
                ),
              ],
            ),
          ),
          const SizedBox(height: 20), // 기존 30에서 20으로 변경하여 간격 조절

          // --- 현재 날씨 정보 표시 섹션 추가 ---
          _buildWeatherDisplay(),
          const SizedBox(height: 20),

          // --- 현재 배터리 및 네트워크 상태 정보 표시 섹션 추가 ---
          _buildStatusInfoCard(),
          const SizedBox(height: 30), // 이전에 30 유지

          // 인기 장소 섹션
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '인기 핫스팟 (찜 수 기준 Top 10)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: _topPlaces.isEmpty
                      ? const Center(child: Text('인기 장소가 없습니다.'))
                      : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _topPlaces.length,
                    itemBuilder: (context, index) {
                      final place = _topPlaces[index];
                      return HotspotCard(
                        title: place['name'],
                        description: place['description'],
                        averageRating: place['averageRating'],
                        latestReview: place['latestReview'],
                        onTap: () {
                          // HotspotCard 탭 시 지도 탭으로 이동하며 해당 장소 ID 전달
                          widget.onTabChanged(1, placeId: place['id']);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          TravelMateSection(currentUserId: widget.currentUserId),
          const SizedBox(height: 30),

          // 최근 게시물 섹션
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '최근 게시물',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _recentPosts.isEmpty
                    ? const Text(
                  '게시물이 없습니다.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                )
                    : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentPosts.length,
                  itemBuilder: (context, index) {
                    final post = _recentPosts[index];
                    return ListTile(
                      title: Text(
                        post['title'] ?? '제목 없음',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '작성자: ${post['authorNickname'] ?? '알 수 없음'}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      onTap: () {
                        // 게시물 탭 시 게시판 탭으로 이동
                        widget.onTabChanged(2);
                      },
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // 더 많은 게시물 보기 버튼 탭 시 게시판 탭으로 이동
                    widget.onTabChanged(2);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('더 많은 게시물 보기'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- 날씨 정보 표시 위젯 ---
  Widget _buildWeatherDisplay() {
    if (_isLoadingWeather) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    } else if (_weatherError.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            '날씨 정보 오류: $_weatherError',
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (_weatherData != null) {
      final current = _weatherData!['weather'];
      final temp = current['main']['temp'].toStringAsFixed(1);
      final desc = current['weather'][0]['description'];
      final iconCode = current['weather'][0]['icon'];
      final city = current['name'];
      final iconPath = 'assets/weather/$iconCode.png';

      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$city의 현재 날씨',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$temp°C',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      desc,
                      style: const TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  ],
                ),
                Image.asset(
                  iconPath,
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.cloud, size: 80, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return Container();
  }

  // --- 상태 정보 카드 위젯 ---
  Widget _buildStatusInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '현재 상태 정보',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Divider(color: Colors.white54),
          Text(
            '🔋 배터리 레벨: $_batteryLevel%',
            style: const TextStyle(fontSize: 15, color: Colors.white70),
          ),
          Text(
            '🔌 배터리 상태: ${_batteryState.toString().split('.').last}',
            style: const TextStyle(fontSize: 15, color: Colors.white70),
          ),
          Text(
            '📶 네트워크: ${_connectivityResult.toString().split('.').last}',
            style: const TextStyle(fontSize: 15, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}