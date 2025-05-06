import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_for_traveler/screens/homeScreen.dart';
import 'package:app_for_traveler/screens/loginScreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// 앱 진입점
// 역할: Firebase 초기화 및 앱 실행
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase 초기화
  await Firebase.initializeApp(
    
  );
  runApp(const MyApp());
}

// 앱의 루트 StatefulWidget
// 역할: 앱 테마 및 초기 화면 설정, 사용자 세션 관리
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

// MyApp 상태 관리 클래스
// 역할: 현재 사용자 ID 관리 및 초기 화면 결정
class _MyAppState extends State<MyApp> {
  String? _currentUserId; // 현재 사용자 ID

  // initState: 위젯 초기화, 저장된 사용자 ID 로드
  // 역할: 앱 시작 시 사용자 세션 확인
  // 분류: 로직
  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  // _loadCurrentUser: SharedPreferences에서 사용자 ID 로드
  // 역할: 저장된 사용자 ID 가져와 상태 업데이트
  // 분류: 로직
  Future<void> _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('currentUserId');
    });
  }

  // _setCurrentUser: SharedPreferences에 사용자 ID 저장/삭제
  // 역할: 로그인/로그아웃 시 사용자 ID 관리 및 상태 업데이트
  // 분류: 로직
  Future<void> _setCurrentUser(String? userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (userId != null) {
      await prefs.setString('currentUserId', userId);
    } else {
      await prefs.remove('currentUserId');
    }
    setState(() {
      _currentUserId = userId;
    });
  }

  // build: 앱 UI 및 초기 화면 구성
  // 역할: 테마 설정 및 로그인/홈 화면 선택
  // 분류: 디자인
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _currentUserId == null
          ? LoginScreen(onLogin: _setCurrentUser)
          : HomeScreen(currentUserId: _currentUserId!, onLogout: _setCurrentUser),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
    );
  }
}