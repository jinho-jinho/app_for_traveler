import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_for_traveler/screens/homeScreen.dart';

// 로그인/회원가입 화면 StatefulWidget
// 역할: 사용자 인증 처리 및 화면 전환
class LoginScreen extends StatefulWidget {
  final Function(String?) onLogin; // 로그인 성공 시 호출되는 콜백

  const LoginScreen({super.key, required this.onLogin});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

// LoginScreen 상태 관리 클래스
// 역할: 입력 필드, 모드(로그인/회원가입), 에러 메시지 관리
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _errorMessage; // 에러 메시지
  bool _isLoginMode = true; // 로그인(true) 또는 회원가입(false) 모드

  // _login: 사용자 로그인 처리
  // 역할: Firestore에서 ID/비밀번호 검증 후 HomeScreen으로 이동
  // 분류: 로직 (인증 및 네비게이션)
  Future<void> _login() async {
    String id = _idController.text.trim();
    String password = _passwordController.text.trim();

    // 입력값 검증
    if (id.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'ID와 비밀번호를 입력해주세요.';
      });
      return;
    }

    try {
      // Firestore에서 ID로 사용자 검색
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setState(() {
          _errorMessage = 'ID가 존재하지 않습니다.';
        });
        return;
      }

      var userDoc = query.docs.first;
      String storedPassword = userDoc['password'];

      if (storedPassword != password) {
        setState(() {
          _errorMessage = '비밀번호가 일치하지 않습니다.';
        });
        return;
      }

      // 로그인 성공 시 ID 저장
      widget.onLogin(id);

      // HomeScreen으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            currentUserId: id,
            onLogout: widget.onLogin,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = '로그인 중 오류가 발생했습니다: $e';
      });
    }
  }

  // _signUp: 사용자 회원가입 처리
  // 역할: 입력 검증 후 Firestore에 사용자 저장, HomeScreen으로 이동
  // 분류: 로직 (인증 및 데이터 저장)
  Future<void> _signUp() async {
    String id = _idController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // 입력값 검증
    if (id.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = '모든 필드를 입력해주세요.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = '비밀번호와 비밀번호 확인이 일치하지 않습니다.';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = '비밀번호는 최소 6자 이상이어야 합니다.';
      });
      return;
    }

    try {
      // ID 중복 확인
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        setState(() {
          _errorMessage = '이미 존재하는 ID입니다.';
        });
        return;
      }

      // Firestore에 사용자 정보 저장
      await _firestore.collection('users').doc(id).set({
        'id': id,
        'password': password,
        'nickname': id,
        'favorites': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 회원가입 성공 시 ID 저장
      widget.onLogin(id);

      // HomeScreen으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            currentUserId: id,
            onLogout: widget.onLogin,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = '회원가입 중 오류가 발생했습니다: $e';
      });
    }
  }

  // build: 로그인/회원가입 화면 UI 렌더링
  // 역할: 입력 필드, 버튼, 에러 메시지 표시
  // 분류: 디자인 (UI 구성)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? '로그인' : '회원가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            if (!_isLoginMode) ...[
              const SizedBox(height: 16.0),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: '비밀번호 확인',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
            const SizedBox(height: 16.0),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isLoginMode ? _login : _signUp,
              child: Text(_isLoginMode ? '로그인' : '회원가입'),
            ),
            const SizedBox(height: 8.0),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoginMode = !_isLoginMode;
                  _errorMessage = null;
                  _idController.clear();
                  _passwordController.clear();
                  _confirmPasswordController.clear();
                });
              },
              child: Text(_isLoginMode ? '회원가입하기' : '로그인하기'),
            ),
          ],
        ),
      ),
    );
  }
}