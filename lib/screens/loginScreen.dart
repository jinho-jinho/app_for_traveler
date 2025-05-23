// 🔁 기존 import 유지
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_for_traveler/screens/homeScreen.dart';

class LoginScreen extends StatefulWidget {
  final Function(String?) onLogin;

  const LoginScreen({super.key, required this.onLogin});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // ✅ 추가 입력 필드
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  String _selectedGender = '무관'; // ✅ 기본값

  String? _errorMessage;
  bool _isLoginMode = true;

  Future<void> _login() async {
    String id = _idController.text.trim();
    String password = _passwordController.text.trim();

    if (id.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'ID와 비밀번호를 입력해주세요.');
      return;
    }

    try {
      final query = await _firestore
          .collection('users')
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setState(() => _errorMessage = 'ID가 존재하지 않습니다.');
        return;
      }

      final userDoc = query.docs.first;
      if (userDoc['password'] != password) {
        setState(() => _errorMessage = '비밀번호가 일치하지 않습니다.');
        return;
      }

      widget.onLogin(id);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            currentUserId: id,
            onLogout: widget.onLogin,
          ),
        ),
      );
    } catch (e) {
      setState(() => _errorMessage = '로그인 중 오류: $e');
    }
  }

  Future<void> _signUp() async {
    final id = _idController.text.trim();
    final pw = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();
    final nickname = _nicknameController.text.trim();
    final age = _ageController.text.trim();
    final contact = _contactController.text.trim();

    if ([id, pw, confirm, nickname, age, contact].any((e) => e.isEmpty)) {
      setState(() => _errorMessage = '모든 필드를 입력해주세요.');
      return;
    }
    if (pw != confirm) {
      setState(() => _errorMessage = '비밀번호가 일치하지 않습니다.');
      return;
    }
    if (pw.length < 6) {
      setState(() => _errorMessage = '비밀번호는 최소 6자 이상이어야 합니다.');
      return;
    }

    try {
      final query = await _firestore
          .collection('users')
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        setState(() => _errorMessage = '이미 존재하는 ID입니다.');
        return;
      }

      await _firestore.collection('users').doc(id).set({
        'id': id,
        'password': pw,
        'nickname': nickname,
        'gender': _selectedGender, // ✅ 성별
        'age': age, // ✅ 나이
        'contact': contact, // ✅ 연락수단
        'createdAt': FieldValue.serverTimestamp(),
      });

      widget.onLogin(id);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            currentUserId: id,
            onLogout: widget.onLogin,
          ),
        ),
      );
    } catch (e) {
      setState(() => _errorMessage = '회원가입 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLoginMode ? '로그인' : '회원가입')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(labelText: 'ID', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호', border: OutlineInputBorder()),
            ),
            if (!_isLoginMode) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: '비밀번호 확인', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: '닉네임', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                onChanged: (value) => setState(() => _selectedGender = value ?? '여성'),
                items: const [
                  DropdownMenuItem(value: '남성', child: Text('남성')),
                  DropdownMenuItem(value: '여성', child: Text('여성')),
                ],
                decoration: const InputDecoration(labelText: '성별', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '나이', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: '연락수단 (카카오톡ID 또는 이메일)', border: OutlineInputBorder()),
              ),
            ],
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoginMode ? _login : _signUp,
              child: Text(_isLoginMode ? '로그인' : '회원가입'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoginMode = !_isLoginMode;
                  _errorMessage = null;
                  _idController.clear();
                  _passwordController.clear();
                  _confirmPasswordController.clear();
                  _nicknameController.clear(); // ✅ 초기화
                  _ageController.clear();
                  _contactController.clear();
                  _selectedGender = '무관';
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
