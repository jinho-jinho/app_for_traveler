import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_for_traveler/screens/loginScreen.dart';
import 'package:app_for_traveler/screens/postDetailScreen.dart';

import 'myScheduleScreen.dart';

class MyPageScreen extends StatefulWidget {
  final String currentUserId;
  final Function(String?) onLogout;
  final Function(String) onPlaceSelected;

  const MyPageScreen({
    super.key,
    required this.currentUserId,
    required this.onLogout,
    required this.onPlaceSelected,
  });

  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController(); // (세연)
  final TextEditingController _contactController = TextEditingController(); // (세연)
  String _selectedGender = '여성'; // (세연)

  String? _nickname;
  List<String> _favorites = [];
  List<DocumentSnapshot> _myPosts = [];
  List<DocumentSnapshot> _myComments = [];
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupRealtimeListener();
    _loadMyPosts();
    _loadMyCommentedPosts();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final doc = await _firestore.collection('users').doc(widget.currentUserId).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nickname = data['nickname'] ?? widget.currentUserId;
        _nicknameController.text = _nickname!;
        _selectedGender = data['gender'] ?? '여성'; // (세연)
        _ageController.text = data['age']?.toString() ?? ''; // (세연)
        _contactController.text = data['contact'] ?? ''; // (세연)
        _favorites = List<String>.from(data['favorites'] ?? []);
      });
    }
  }

  void _setupRealtimeListener() {
    _userSubscription = _firestore.collection('users').doc(widget.currentUserId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _favorites = List<String>.from(snapshot['favorites'] ?? []);
        });
      }
    });
  }

  Future<void> _loadMyPosts() async {
    final snapshot = await _firestore
        .collection('posts')
        .where('authorId', isEqualTo: widget.currentUserId)
        .get();
    setState(() => _myPosts = snapshot.docs);
  }

  Future<void> _loadMyCommentedPosts() async {
    final commentSnapshot = await _firestore
        .collection('comments')
        .where('authorId', isEqualTo: widget.currentUserId)
        .get();

    final postIds = commentSnapshot.docs.map((doc) => doc['postId'] as String).toSet().toList();
    if (postIds.isEmpty) return;

    List<DocumentSnapshot> allPosts = [];
    for (var i = 0; i < postIds.length; i += 10) {
      final chunk = postIds.sublist(i, (i + 10).clamp(0, postIds.length));
      final postSnapshot = await _firestore
          .collection('posts')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      allPosts.addAll(postSnapshot.docs);
    }

    setState(() => _myComments = allPosts);
  }

  void _showSimpleList(String title, List<DocumentSnapshot> docs) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['title'] ?? '제목 없음'),
                subtitle: Text(data['content'] ?? ''),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(
                      postId: docs[index].id,
                      title: data['title'],
                      content: data['content'],
                      authorId: data['authorId'],
                      authorNickname: data['authorNickname'],
                      createdAt: (data['createdAt'] as Timestamp).toDate(),
                      currentUserId: widget.currentUserId,
                      currentUserNickname: _nickname,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('즐겨찾기한 장소')),
          body: ListView(
            children: _favorites.map((placeId) {
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('places').doc(placeId).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const ListTile(title: Text('로딩 중...'));
                  if (!snapshot.hasData || !snapshot.data!.exists) return ListTile(title: Text(placeId));
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(data['name'] ?? placeId),
                    onTap: () => widget.onPlaceSelected(placeId),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('내 정보 수정'), // (세연)
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _nicknameController, decoration: const InputDecoration(labelText: '닉네임')), // (세연)
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: '성별'), // (세연)
                items: ['여성', '남성'].map((value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedGender = val);
                },
              ),
              TextField(controller: _ageController, decoration: const InputDecoration(labelText: '나이'), keyboardType: TextInputType.number), // (세연)
              TextField(controller: _contactController, decoration: const InputDecoration(labelText: '연락처')), // (세연)
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('users').doc(widget.currentUserId).update({
                'nickname': _nicknameController.text.trim(),
                'gender': _selectedGender, // (세연)
                'age': int.tryParse(_ageController.text.trim()) ?? 0, // (세연)
                'contact': _contactController.text.trim(), // (세연)
              });
              _loadUserData();
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async { // (세연)
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: const Text('정말 탈퇴하시겠습니까? 모든 데이터가 삭제됩니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('탈퇴')),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection('users').doc(widget.currentUserId).delete();
      widget.onLogout(null);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen(onLogin: widget.onLogout)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('내 정보 수정'), // (세연)
            trailing: const Icon(Icons.edit),
            onTap: _showEditProfileDialog,
          ),
          ListTile(
            title: const Text('즐겨찾기 한 장소'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showFavorites,
          ),
          ListTile(
            title: const Text('여행 스케줄'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyScheduleScreen(currentUserId: widget.currentUserId),
                ),
              );
            },
          ),

          ListTile(
            title: const Text('내가 쓴 글 조회'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSimpleList('내가 쓴 글', _myPosts),
          ),
          ListTile(
            title: const Text('댓글 단 글 조회'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSimpleList('댓글 단 글', _myComments),
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                TextButton(
                  onPressed: () async {
                    widget.onLogout(null);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen(onLogin: widget.onLogout)),
                    );
                  },
                  child: const Text('로그아웃'),
                ),
                TextButton(
                  onPressed: _deleteAccount,
                  child: const Text('회원 탈퇴', style: TextStyle(color: Colors.red)), // (세연)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
