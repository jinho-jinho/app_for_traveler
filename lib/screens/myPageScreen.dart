import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_for_traveler/screens/loginScreen.dart';
import 'package:app_for_traveler/screens/postDetailScreen.dart';

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
  final TextEditingController _nicknameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(widget.currentUserId).get();
    if (userDoc.exists) {
      setState(() {
        _nickname = userDoc['nickname'] ?? widget.currentUserId;
        _nicknameController.text = _nickname!;
        _favorites = List<String>.from(userDoc['favorites'] ?? []);
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
    setState(() {
      _myPosts = snapshot.docs;
    });
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

    setState(() {
      _myComments = allPosts;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('여행 스케줄'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 여행 스케줄 화면으로 이동
            },
          ),
          ListTile(
            title: const Text('닉네임 설정'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('닉네임 설정'),
                  content: TextField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(hintText: '닉네임 입력'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _firestore.collection('users').doc(widget.currentUserId).update({
                          'nickname': _nicknameController.text.trim(),
                        });
                        setState(() => _nickname = _nicknameController.text.trim());
                        Navigator.pop(context);
                      },
                      child: const Text('저장'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            title: const Text('즐겨찾기 한 장소'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showFavorites,
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
            child: TextButton(
              onPressed: () async {
                widget.onLogout(null);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen(onLogin: widget.onLogout)),
                );
              },
              child: const Text('로그아웃'),
            ),
          ),
        ],
      ),
    );
  }
}
