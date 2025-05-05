import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_for_traveler/screens/loginScreen.dart';

// 마이페이지 화면 StatefulWidget
// 역할: 사용자 프로필 관리 및 찜한 장소 목록 표시
class MyPageScreen extends StatefulWidget {
  final String currentUserId; // 현재 사용자 ID
  final Function(String?) onLogout; // 로그아웃 콜백
  final Function(String) onPlaceSelected; // 장소 선택 콜백

  const MyPageScreen({
    super.key,
    required this.currentUserId,
    required this.onLogout,
    required this.onPlaceSelected,
  });

  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

// MyPageScreen 상태 관리 클래스
// 역할: 닉네임, 찜 목록, 에러 메시지 관리 및 실시간 데이터 리스닝
class _MyPageScreenState extends State<MyPageScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _nickname; // 사용자 닉네임
  String? _errorMessage; // 에러 메시지
  List<String> _favorites = []; // 찜한 장소 ID 목록
  StreamSubscription<DocumentSnapshot>? _userSubscription; // Firestore 실시간 리스너

  // initState: 위젯 초기화, 사용자 데이터 로드 및 실시간 리스너 설정
  // 역할: 초기 데이터 로드 및 리스너 초기화
  // 분류: 로직
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupRealtimeListener();
  }

  // dispose: 리스너 해제 및 리소스 정리
  // 역할: 리스너 종료
  // 분류: 로직
  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  // _loadUserData: Firestore에서 사용자 데이터(닉네임, 찜 목록) 로드
  // 역할: 초기 사용자 데이터 조회 및 상태 업데이트
  // 분류: 로직
  Future<void> _loadUserData() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(widget.currentUserId).get();
      if (userDoc.exists) {
        setState(() {
          _nickname = userDoc['nickname'] ?? widget.currentUserId;
          _nicknameController.text = _nickname!;
          _favorites = List<String>.from(userDoc['favorites'] ?? []);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '사용자 데이터를 불러오는 중 오류가 발생했습니다: $e';
      });
    }
  }

  // _setupRealtimeListener: Firestore 실시간 리스너 설정
  // 역할: 사용자 찜 목록 실시간 업데이트
  // 분류: 로직
  void _setupRealtimeListener() {
    _userSubscription = _firestore.collection('users').doc(widget.currentUserId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _favorites = List<String>.from(snapshot['favorites'] ?? []);
        });
      }
    }, onError: (e) {
      setState(() {
        _errorMessage = '실시간 데이터 감지 중 오류가 발생했습니다: $e';
      });
    });
  }

  // _updateNickname: Firestore에 닉네임 업데이트
  // 역할: 사용자 닉네임 수정 및 저장
  // 분류: 로직
  Future<void> _updateNickname() async {
    String newNickname = _nicknameController.text.trim();
    if (newNickname.isEmpty) {
      setState(() {
        _errorMessage = '닉네임을 입력해주세요.';
      });
      return;
    }

    try {
      await _firestore.collection('users').doc(widget.currentUserId).update({
        'nickname': newNickname,
      });
      setState(() {
        _nickname = newNickname;
        _errorMessage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임이 업데이트되었습니다.')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = '닉네임 업데이트 중 오류가 발생했습니다: $e';
      });
    }
  }

  // _logout: 로그아웃 처리 및 로그인 화면으로 이동
  // 역할: 사용자 로그아웃 및 네비게이션
  // 분류: 로직
  Future<void> _logout() async {
    widget.onLogout(null);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(onLogin: widget.onLogout)),
    );
  }

  // build: 프로필 및 찜 목록 탭 UI 렌더링
  // 역할: 마이페이지 UI 구성
  // 분류: 디자인
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('마이페이지 - ${widget.currentUserId}'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '프로필'),
              Tab(text: '찜한 목록'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 프로필 탭: 닉네임 수정 및 로그아웃 UI
            // 역할: 사용자 프로필 정보 표시 및 수정
            // 분류: 디자인
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '닉네임',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nicknameController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: _updateNickname,
                        child: const Text('수정'),
                      ),
                    ],
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: _logout,
                      child: const Text('로그아웃'),
                    ),
                  ),
                ],
              ),
            ),
            // 찜한 목록 탭: 찜한 장소 목록 표시
            // 역할: 찜한 장소 목록 UI 표시
            // 분류: 디자인
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _favorites.isEmpty
                  ? const Center(child: Text('찜한 목록이 없습니다.'))
                  : ListView.builder(
                      itemCount: _favorites.length,
                      itemBuilder: (context, index) {
                        final placeId = _favorites[index];
                        return ListTile(
                          title: FutureBuilder<DocumentSnapshot>(
                            future: _firestore.collection('places').doc(placeId).get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Text('로딩 중...');
                              }
                              if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                                return Text(placeId);
                              }
                              final placeData = snapshot.data!.data() as Map<String, dynamic>;
                              return Text(placeData['name'] as String? ?? placeId);
                            },
                          ),
                          onTap: () {
                            widget.onPlaceSelected(placeId);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}