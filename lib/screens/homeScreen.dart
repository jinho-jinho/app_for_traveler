import 'package:flutter/material.dart';
import 'package:app_for_traveler/screens/mapScreen.dart';
import 'package:app_for_traveler/hotspotCard.dart';
import 'package:app_for_traveler/screens/myPageScreen.dart';
import 'package:app_for_traveler/screens/boardScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_for_traveler/models/place.dart';

// 앱의 메인 화면 StatefulWidget
// 역할: 네비게이션 바로 홈, 지도, 게시판, 마이페이지 전환 관리
class HomeScreen extends StatefulWidget {
  final String currentUserId; // 현재 사용자 ID
  final Function(String?) onLogout; // 로그아웃 콜백

  const HomeScreen({
    super.key,
    required this.currentUserId,
    required this.onLogout,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// HomeScreen 상태 관리 클래스
// 역할: 네비게이션 상태와 사용자 닉네임 관리
class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 현재 네비게이션 인덱스
  String? _selectedPlaceId; // 지도 화면 장소 ID
  String? _currentUserNickname; // 사용자 닉네임

  // initState: 위젯 초기화, 닉네임 조회 시작
  // 역할: 데이터 초기화
  // 분류: 로직
  @override
  void initState() {
    super.initState();
    _fetchCurrentUserNickname();
  }

  // _fetchCurrentUserNickname: Firestore에서 닉네임 가져와 상태 업데이트
  // 역할: 사용자 데이터 조회
  // 분류: 로직
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

  // _onItemTapped: 네비게이션 바 탭 처리, 인덱스 및 장소 ID 업데이트
  // 역할: 네비게이션 관리
  // 분류: 로직
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 1) {
        _selectedPlaceId = null;
      }
    });
  }

  // build: AppBar, 네비게이션 바, 선택된 화면 UI 렌더링
  // 역할: 화면 UI 구성
  // 분류: 디자인
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 도우미'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? const HomeContent()
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
  const HomeContent({super.key});

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