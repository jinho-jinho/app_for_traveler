import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_for_traveler/screens/homeScreen.dart';
// ──────────────────────────────────────────────────────────────────
// AppLocalizations 임포트 추가
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // 이 경로가 정확한지 확인하세요.
// ──────────────────────────────────────────────────────────────────

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
    // ──────────────────────────────────────────────────────────────────
    // AppLocalizations 인스턴스 가져오기 (메서드 내에서도 필요할 수 있음)
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────

    final id = _idController.text.trim();
    final pw = _passwordController.text.trim();
    if (id.isEmpty || pw.isEmpty) {
      setState(() => _errorMessage = appLocalizations.loginErrorEmptyFields); // 다국어 적용
      return;
    }

    try {
      final query = await _firestore.collection('users').where('id', isEqualTo: id).limit(1).get();
      if (query.docs.isEmpty) {
        setState(() => _errorMessage = appLocalizations.loginErrorIdNotFound); // 다국어 적용
        return;
      }
      final userDoc = query.docs.first;
      if (userDoc['password'] != pw) {
        setState(() => _errorMessage = appLocalizations.loginErrorPasswordMismatch); // 다국어 적용
        return;
      }

      widget.onLogin(id);
      // HomeScreen으로 이동 시 currentUserId와 onLogout을 전달
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(currentUserId: id, onLogout: widget.onLogin),
        ),
      );
    } catch (e) {
      setState(() => _errorMessage = appLocalizations.loginErrorGeneric(e.toString())); // 다국어 적용 (변수 포함)
    }
  }

  Future<void> _signUp() async {
    // ──────────────────────────────────────────────────────────────────
    // AppLocalizations 인스턴스 가져오기 (메서드 내에서도 필요할 수 있음)
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────

    final id = _idController.text.trim();
    final pw = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();
    final nickname = _nicknameController.text.trim();
    final age = _ageController.text.trim();
    final contact = _contactController.text.trim();

    if ([id, pw, confirm, nickname, age, contact].any((e) => e.isEmpty)) {
      setState(() => _errorMessage = appLocalizations.signUpErrorAllFieldsRequired); // 다국어 적용
      return;
    }
    if (pw != confirm) {
      setState(() => _errorMessage = appLocalizations.signUpErrorPasswordMismatch); // 다국어 적용
      return;
    }
    if (pw.length < 6) {
      setState(() => _errorMessage = appLocalizations.signUpErrorPasswordTooShort); // 다국어 적용
      return;
    }

    try {
      final query = await _firestore.collection('users').where('id', isEqualTo: id).limit(1).get();
      if (query.docs.isNotEmpty) {
        setState(() => _errorMessage = appLocalizations.signUpErrorIdExists); // 다국어 적용
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
      setState(() => _errorMessage = appLocalizations.signUpErrorGeneric(e.toString())); // 다국어 적용 (변수 포함)
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscure = false, TextInputType? type}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label, // 레이블은 이미 파라미터로 받으므로 변경 없음
        border: const OutlineInputBorder(),
        isDense: true,
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ──────────────────────────────────────────────────────────────────
    // AppLocalizations 인스턴스 가져오기
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          _isLoginMode ? appLocalizations.loginScreenTitle : appLocalizations.signUpScreenTitle, // 다국어 적용
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(appLocalizations.idHint, _idController), // 다국어 적용
            const SizedBox(height: 12),
            _buildTextField(appLocalizations.passwordHint, _passwordController, obscure: true), // 다국어 적용
            if (!_isLoginMode) ...[
              const SizedBox(height: 12),
              _buildTextField(appLocalizations.confirmPasswordHint, _confirmPasswordController, obscure: true), // 다국어 적용
              const SizedBox(height: 12),
              _buildTextField(appLocalizations.nicknameHint, _nicknameController), // 다국어 적용
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                onChanged: (val) => setState(() => _selectedGender = val ?? appLocalizations.genderFemale), // 다국어 적용
                decoration: InputDecoration(labelText: appLocalizations.genderLabel, border: const OutlineInputBorder()), // 다국어 적용
                items: [
                  DropdownMenuItem(value: '여성', child: Text(appLocalizations.genderFemale)), // 다국어 적용
                  DropdownMenuItem(value: '남성', child: Text(appLocalizations.genderMale)), // 다국어 적용
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(appLocalizations.ageHint, _ageController, type: TextInputType.number), // 다국어 적용
              const SizedBox(height: 12),
              _buildTextField(appLocalizations.contactHint, _contactController), // 다국어 적용
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
              child: Text(
                _isLoginMode ? appLocalizations.loginButton : appLocalizations.signUpButton, // 다국어 적용
                style: const TextStyle(color: Colors.white),
              ),
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
                  _selectedGender = appLocalizations.genderFemale; // 다국어 적용
                });
              },
              child: Text(_isLoginMode ? appLocalizations.createAccountButton : appLocalizations.goToLoginButton), // 다국어 적용
            ),
          ],
        ),
      ),
    );
  }
}