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
import 'notificationScreen.dart';
import 'companionDetailScreen.dart'; // 기존에 작성한 동행 상세 페이지 가져오기
import 'weatherScreen.dart';
import 'package:app_for_traveler/screens/companionListScreen.dart';



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
  Timer? _disasterCheckTimer;
  Set<int> _shownDisasterSNs = {};
  List<Map<String, dynamic>> _disasterAlerts = [];
  List<Map<String, dynamic>> _commentAlerts = [];

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
    _disasterCheckTimer = Timer.periodic(const Duration(seconds: 60), (_) async {
      try {
        final disasters = await DisasterApiService.fetchTodayDisasterMessages();
        for (final item in disasters) {
          final int sn = item['sn'];
          final String translatedMsg = item['translated'] ?? item['msg']; // 🔁 번역 결과 우선 사용

          if (!_shownDisasterSNs.contains(sn)) {
            _shownDisasterSNs.add(sn);
            await _saveShownDisasterSNs();
            if (mounted) _showDisasterAlert(translatedMsg); // ✅ 번역 메시지 출력
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
        title: const Text('📢 New disaster message received'),
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

    // 재난문자 (영어 번역 포함) 가져오기
    final disasters = await DisasterApiService.fetchTodayDisasterMessages();

    // timestamp 저장
    for (var d in disasters) {
      final snStr = d['sn'].toString();
      if (!timeMap.containsKey(snStr)) {
        timeMap[snStr] = (d['timestamp'] as DateTime).toIso8601String();
      }
    }

    await prefs.setString('sn_time_map', jsonEncode(timeMap));

    // 이미 본 SN만 필터링하고 영어 번역된 메시지만 리턴
    return disasters
        .where((d) => savedSnList.contains(d['sn'].toString()))
        .map((d) {
      final snStr = d['sn'].toString();
      final t = DateTime.tryParse(timeMap[snStr] ?? '') ?? d['timestamp'];
      return {
        'sn': d['sn'],
        'message': d['translated'] ?? d['msg'], // ✅ 영어 메시지만 사용
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 1) {
        _selectedPlaceId = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 도우미', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[100], //세연
        foregroundColor: Colors.black, //세연
        actions: [
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
            onPressed: () async {
              await _loadAllAlerts();
              if (!mounted) return;
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
          ? HomeContent(currentUserId: widget.currentUserId) // 🔥 여기에 전달
          : _selectedIndex == 1
          ? MapScreen(
        currentUserId: widget.currentUserId,
        selectedPlaceId: _selectedPlaceId,
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

  // initState: 위젯 초기화, 데이터 조회 시작
  // 역할: 데이터 초기화
  // 분류: 로직
  @override
  void initState() {
    super.initState();
    _fetchTopPlaces();
    _fetchRecentPosts();
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // 추천 섹션: 날씨 기반 활동 제안 및 지도 화면 이동 버튼
          // 역할: 추천 UI 표시
          // 분류: 디자인
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
                const Text(
                  '비가 오니 실내 활동을 추천드려요!',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                    homeState?._onItemTapped(1);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('실내 카페 추천 지도 보기'),
                ),
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