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
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  String _selectedGender = '여성'; // ✅ 기본값 '여성'
  String? _errorMessage;
  bool _isLoginMode = true;

  Future<void> _login() async {
    final id = _idController.text.trim();
    final pw = _passwordController.text.trim();
    if (id.isEmpty || pw.isEmpty) {
      setState(() => _errorMessage = 'ID와 비밀번호를 입력해주세요.');
      return;
    }

    try {
      final query = await _firestore.collection('users').where('id', isEqualTo: id).limit(1).get();
      if (query.docs.isEmpty) {
        setState(() => _errorMessage = 'ID가 존재하지 않습니다.');
        return;
      }
      final userDoc = query.docs.first;
      if (userDoc['password'] != pw) {
        setState(() => _errorMessage = '비밀번호가 일치하지 않습니다.');
        return;
      }

      widget.onLogin(id);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(currentUserId: id, onLogout: widget.onLogin),
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
      final query = await _firestore.collection('users').where('id', isEqualTo: id).limit(1).get();
      if (query.docs.isNotEmpty) {
        setState(() => _errorMessage = '이미 존재하는 ID입니다.');
        return;
      }

      await _firestore.collection('users').doc(id).set({
        'id': id,
        'password': pw,
        'nickname': nickname,
        'gender': _selectedGender,
        'age': age,
        'contact': contact,
        'createdAt': FieldValue.serverTimestamp(),
        'favorites': [],
      });

      widget.onLogin(id);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(currentUserId: id, onLogout: widget.onLogin),
        ),
      );
    } catch (e) {
      setState(() => _errorMessage = '회원가입 오류: $e');
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscure = false, TextInputType? type}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(_isLoginMode ? '로그인' : '회원가입', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField('ID', _idController),
            const SizedBox(height: 12),
            _buildTextField('비밀번호', _passwordController, obscure: true),
            if (!_isLoginMode) ...[
              const SizedBox(height: 12),
              _buildTextField('비밀번호 확인', _confirmPasswordController, obscure: true),
              const SizedBox(height: 12),
              _buildTextField('닉네임', _nicknameController),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                onChanged: (val) => setState(() => _selectedGender = val ?? '여성'),
                decoration: const InputDecoration(labelText: '성별', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: '여성', child: Text('여성')),
                  DropdownMenuItem(value: '남성', child: Text('남성')),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField('나이', _ageController, type: TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField('연락처 (카카오톡ID 또는 이메일)', _contactController),
            ],
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: _isLoginMode ? _login : _signUp,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48), backgroundColor: Colors.black87),
              child: Text(_isLoginMode ? '로그인' : '회원가입', style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoginMode = !_isLoginMode;
                  _errorMessage = null;
                  _idController.clear();
                  _passwordController.clear();
                  _confirmPasswordController.clear();
                  _nicknameController.clear();
                  _ageController.clear();
                  _contactController.clear();
                  _selectedGender = '여성'; // 기본값으로 초기화
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
