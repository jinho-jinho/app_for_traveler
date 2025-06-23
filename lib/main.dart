import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_for_traveler/screens/homeScreen.dart';
import 'package:app_for_traveler/screens/loginScreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // 올바른 임포트 경로

// 앱 진입점
// 역할: Firebase 초기화 및 앱 실행, 초기 언어 설정 로드
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 앱 시작 시 저장된 언어 설정 로드
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? savedLocaleCode = prefs.getString('app_locale');
  Locale? initialLocale;
  if (savedLocaleCode != null) {
    initialLocale = Locale(savedLocaleCode);
  }

  runApp(MyApp(initialLocale: initialLocale)); // 초기 언어 전달
}

// 앱의 루트 StatefulWidget
// 역할: 앱 테마 및 초기 화면 설정, 사용자 세션 관리, 언어 변경 관리
class MyApp extends StatefulWidget {
  final Locale? initialLocale; // 초기 언어 설정을 받을 변수
  const MyApp({super.key, this.initialLocale});

  @override
  _MyAppState createState() => _MyAppState();

  // 자식 위젯에서 _MyAppState에 접근하여 언어를 변경할 수 있도록 하는 헬퍼 메서드
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

// MyApp 상태 관리 클래스
// 역할: 현재 사용자 ID 관리 및 초기 화면 결정, 앱 언어 관리
class _MyAppState extends State<MyApp> {
  String? _currentUserId; // 현재 사용자 ID
  Locale? _locale; // 앱의 현재 언어 설정을 저장할 변수

  // initState: 위젯 초기화, 저장된 사용자 ID 및 초기 언어 로드
  @override
  void initState() {
    super.initState();
    _loadCurrentUser(); // 사용자 ID 로드
    _locale = widget.initialLocale; // 전달받은 초기 언어 설정
  }

  // setLocale: 앱 언어를 변경하고 SharedPreferences에 저장
  void setLocale(Locale newLocale) async {
    // 이미 같은 언어면 변경하지 않음
    if (_locale == newLocale) return;

    setState(() {
      _locale = newLocale; // 상태 업데이트
    });

    // 변경된 언어를 SharedPreferences에 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', newLocale.languageCode);
  }

  // _loadCurrentUser: SharedPreferences에서 사용자 ID 로드
  Future<void> _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('currentUserId');
    });
  }

  // _setCurrentUser: SharedPreferences에 사용자 ID 저장/삭제
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.grey, // AppBar 배경 회색
          foregroundColor: Colors.black, // AppBar 텍스트 및 아이콘 색
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.grey, // 주요 색상 회색
        ),
      ),
      locale: _locale,
      home: _currentUserId == null
          ? LoginScreen(onLogin: _setCurrentUser)
          : HomeScreen(currentUserId: _currentUserId!, onLogout: _setCurrentUser),
      localizationsDelegates: const [
        AppLocalizations.delegate,
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