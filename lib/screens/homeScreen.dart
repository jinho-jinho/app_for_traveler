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

// 언어 선택 위젯을 위한 임포트 추가
import 'package:app_for_traveler/language_selection_widget.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:app_for_traveler/services/recommendation_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // 다국어 지원 임포트
import 'package:app_for_traveler/services/weather_data_fetcher.dart';


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
  String? _mapSearchKeyword;
  Timer? _disasterCheckTimer;
  Set<int> _shownDisasterSNs = {};
  List<Map<String, dynamic>> _disasterAlerts = [];
  List<Map<String, dynamic>> _commentAlerts = [];

  String? _selectedMapCategory;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserNickname();
    _checkAndResetSNsIfNewDay();
    _startDisasterCheckTimer();
    _loadAllAlerts();
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
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
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

  void _onItemTapped(int index, {String? searchKeyword, String? selectedCategory}) {
    setState(() {
      _selectedIndex = index;
      if (index != 1) { // 지도가 아니면 선택된 장소 ID와 검색 키워드, 카테고리 초기화
        _selectedPlaceId = null;
        // _mapSearchKeyword = null; // 이전에 searchKeyword를 직접 MapScreen에 전달하던 방식
        _selectedMapCategory = null; // 카테고리 초기화
      } else { // 지도 화면으로 이동할 경우
        // _mapSearchKeyword = searchKeyword; // 이전에 searchKeyword를 직접 MapScreen에 전달하던 방식
        _selectedMapCategory = selectedCategory; // ⭐️ 전달받은 카테고리 설정 ⭐️
      }
    });
  }

  // 언어 선택 다이얼로그를 보여주는 새로운 메서드
  void _showLanguageSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('언어 선택'), // 다이얼로그 제목
          content: const LanguageSelectionWidget(), // 언어 선택 위젯 삽입
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('닫기'), // 닫기 버튼
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 도우미'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // 지구본 아이콘 버튼 추가
          IconButton(
            icon: const Icon(Icons.language), // 지구본 아이콘
            onPressed: () {
              _showLanguageSelectionDialog(context); // 다이얼로그 팝업
            },
          ),
          IconButton(
            icon: const Icon(Icons.sunny),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WeatherScreen(),
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
      body: _selectedIndex == 0
          ? HomeContent(currentUserId: widget.currentUserId) // HomeContent는 여전히 currentUserId만 받음
          : _selectedIndex == 1
          ? MapScreen(
        currentUserId: widget.currentUserId,
        selectedPlaceId: _selectedPlaceId,
        searchKeyword: _mapSearchKeyword, // ⭐️ MapScreen에 검색 키워드 전달 ⭐️
        //selectedCategory: _selectedMapCategory,
        key: const ValueKey('map_screen'),
      )
          : _selectedIndex == 2
          ? BoardScreen(
        currentUserId: widget.currentUserId,
        currentUserNickname: _currentUserNickname,
      )
          : MyPageScreen(
        currentUserId: widget.currentUserId,
        onLogout: widget.onLogout,
        onPlaceSelected: (placeId) {
          setState(() {
            _selectedIndex = 1;
            _selectedPlaceId = placeId;
          });
        },
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
        onTap: _onItemTapped,
      ),
    );
  }
}



// 홈 화면 콘텐츠 StatefulWidget
// 역할: 추천, 인기 장소, 최근 게시물 표시
class HomeContent extends StatefulWidget {
  final String currentUserId;
  const HomeContent({super.key, required this.currentUserId});

  @override
  _HomeContentState createState() => _HomeContentState();
}


// HomeContent 상태 관리 클래스
// 역할: Firestore 데이터 가져와 UI 업데이트
class _HomeContentState extends State<HomeContent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _topPlaces = [];
  List<Map<String, dynamic>> _recentPosts = [];

  final RecommendationService _recommendationService = RecommendationService();
  final WeatherDataFetcher _weatherDataFetcher = WeatherDataFetcher();

  BatteryState _batteryState = BatteryState.unknown;
  int _batteryLevel = 100;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;

  late StreamSubscription<BatteryState> _batteryStateSubscription;
  //late StreamSubscription<int> _batteryLevelSubscription;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  RecommendationResult _currentRecommendation = RecommendationResult(
    recommendationText: "초기 추천 로딩 중...", // 앱 시작 시 초기 메시지 설정
  );

  Map<String, dynamic>? _weatherData;
  String _weatherError = ''; // 날씨 에러 메시지 저장용

  // initState: 위젯 초기화, 데이터 조회 시작
  // 역할: 데이터 초기화
  // 분류: 로직
  @override
  void initState() {
    super.initState();
    _fetchTopPlaces();
    _fetchRecentPosts();
    _initRecommendationMonitoring();
  }

  void _initRecommendationMonitoring() async {
    final Battery battery = Battery();
    final Connectivity connectivity = Connectivity();

    await _fetchWeatherAndLocation();

    // 초기 상태 가져오기
    _batteryState = await battery.batteryState;
    _batteryLevel = await battery.batteryLevel;
    // checkConnectivity()는 List<ConnectivityResult>를 반환합니다.
    _connectivityResult = (await connectivity.checkConnectivity()).first;

    // 스트림 구독
    _batteryStateSubscription = battery.onBatteryStateChanged.listen((BatteryState state) {
      setState(() {
        _batteryState = state;
        _updateRecommendation(); // 상태 변경 시 추천 업데이트
      });
    });

    _batteryStateSubscription = battery.onBatteryStateChanged.listen((BatteryState state) async {
      // ⭐️ 변경: 배터리 상태가 바뀔 때마다 최신 배터리 레벨을 가져옵니다. ⭐️
      _batteryState = state;
      _batteryLevel = await battery.batteryLevel; // 최신 레벨을 비동기로 가져옵니다.
      setState(() {
        _updateRecommendation(); // 상태 및 레벨 변경 시 추천 업데이트
      });
    });

    _connectivitySubscription = connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() {
          _connectivityResult = results.first;
          _updateRecommendation(); // 상태 변경 시 추천 업데이트
        });
      }
    });

    // 모든 초기 상태를 가져온 후 최초 추천 업데이트
    _updateRecommendation();
  }
  Future<void> _fetchWeatherAndLocation() async {
    setState(() {
      _weatherError = ''; // 새로운 시도 전에 에러 메시지 초기화
    });
    try {
      final position = await _weatherDataFetcher.getCurrentLocation(context);
      if (position != null) {
        final weatherAndForecast = await _weatherDataFetcher.fetchWeatherData(
          position.latitude,
          position.longitude,
        );
        setState(() {
          _weatherData = weatherAndForecast; // weather와 forecast 모두 포함
        });
        print('날씨 데이터 성공적으로 가져옴: $_weatherData');
      } else {
        // 위치를 가져오지 못했으면 WeatherDataFetcher 내부에서 다이얼로그가 표시됩니다.
        // 여기서는 _weatherData를 null로 유지하고, RecommendationService는 null을 받습니다.
        _weatherData = null;
      }
    } catch (e) {
      print('날씨 데이터 로드 실패 (HomeContent): $e');
      setState(() {
        _weatherError = '날씨 정보를 가져오는데 실패했습니다.'; // 사용자에게 친숙한 메시지
        _weatherData = null;
      });
    } finally {
      _updateRecommendation(); // 날씨 데이터를 가져온 후 (성공/실패 무관) 추천 업데이트
    }
  }
  // 추천 문구를 업데이트하는 메서드
  void _updateRecommendation() {
    if (!mounted) return; // 위젯이 트리에 연결되어 있을 때만 실행

    // 로그 출력 (디버깅용)
    print('Updating recommendation in HomeContent:');
    print('  Battery Level: $_batteryLevel');
    print('  Battery State: ${_batteryState.toString().split('.').last}');
    print('  Connectivity: ${_connectivityResult.toString().split('.').last}');
    print('  Weather Data: $_weatherData');

    // RecommendationService 호출 시 context를 전달합니다.
    final RecommendationResult result = _recommendationService.getRecommendation(
      context: context,
      weatherData: _weatherData, // 실제 날씨 데이터를 여기에 전달하세요 (예: WeatherScreen에서 가져와서)
      batteryLevel: _batteryLevel,
      batteryState: _batteryState,
      connectivityResult: _connectivityResult,
    );

    setState(() {
      _currentRecommendation = result;
    });

    // 생성된 추천 결과도 로그로 출력 (디버깅용)
    print('  Generated Recommendation: ${_currentRecommendation.recommendationText}');
    print('  Generated Search Keyword: ${_currentRecommendation.searchKeyword}');
  }

  @override
  void dispose() {
    // ⭐️ 추가: 스트림 구독 해제 ⭐️
    _batteryStateSubscription.cancel();
    _connectivitySubscription.cancel();
    super.dispose();
  }

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
    } catch (e) {}
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
    } catch (e) {}
  }

  // build: 추천, 인기 장소, 최근 게시물 UI 렌더링
  // 역할: 화면 UI 구성
  // 분류: 디자인
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // BuildContext를 사용하여 AppLocalizations 가져오기


    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // 추천 섹션
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
                Text(
                  l10n.recommendationBasedOnCurrentStatus,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                if (_weatherError.isNotEmpty)
                  Text(
                    _weatherError,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  )
                else if (_weatherData == null)
                  const CircularProgressIndicator()
                else
                  Text(
                    _currentRecommendation.recommendationText,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                if (_currentRecommendation.searchKeyword != null) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      final homeState = context.findAncestorStateOfType<_HomeScreenState>();

                      homeState?._onItemTapped(1, selectedCategory: _currentRecommendation.searchKeyword);
                      print('Navigating to MapScreen with category: ${_currentRecommendation.searchKeyword}');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: Text(
                      '${_currentRecommendation.searchKeyword} ${l10n.mapView}',
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 30),
          // 인기 장소 섹션: 찜 수 기준 상위 10개 장소 표시 및 지도 이동
          // 역할: 인기 장소 UI 표시
          // 분류: 디자인
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
                          final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                          homeState?.setState(() {
                            homeState._selectedIndex = 1;
                            homeState._selectedPlaceId = place['id'];
                          });
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
          // 최근 게시물 섹션: 최신 3개 게시물 표시 및 게시판 이동
          // 역할: 게시물 UI 표시
          // 분류: 디자인
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
                        final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                        homeState?._onItemTapped(2);
                      },
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                    homeState?._onItemTapped(2);
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
}