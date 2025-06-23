import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:app_for_traveler/screens/postDetailScreen.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// 게시판 화면을 나타내는 StatefulWidget
// 사용자 ID와 닉네임을 받아 게시물 목록을 표시하고 새 게시물을 작성할 수 있는 화면 제공
class BoardScreen extends StatefulWidget {
  final String currentUserId; // 현재 로그인한 사용자의 ID
  final String? currentUserNickname; // 현재 로그인한 사용자의 닉네임 (선택적)

  const BoardScreen({
    super.key,
    required this.currentUserId,
    this.currentUserNickname,
  });

  @override
  _BoardScreenState createState() => _BoardScreenState();
}

// BoardScreen의 상태를 관리하는 State 클래스
// Firestore에서 게시물 데이터를 가져오고 UI를 업데이트하며 사용자 상호작용 처리
class _BoardScreenState extends State<BoardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore 인스턴스
  bool _isLoading = true; // 데이터 로딩 상태를 나타내는 플래그
  List<Map<String, dynamic>> _posts = []; // 게시물 데이터를 저장하는 리스트

  // 게시물 검색 - 상태 변수
  String _searchQuery = '';

  // 게시물 검색
  List<Map<String, dynamic>> get _filteredPosts {
    if (_searchQuery.isEmpty) return _posts;
    return _posts.where((post) {
      final title = post['title']?.toLowerCase() ?? '';
      final content = post['content']?.toLowerCase() ?? '';
      return title.contains(_searchQuery) || content.contains(_searchQuery);
    }).toList();
  }

  // initState: 위젯 초기화 시 게시물 조회 시작
  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  // dispose: 컨트롤러 해제
  @override
  void dispose() {
    super.dispose();
  }

  // _fetchPosts: Firestore에서 게시물 가져와 상태 업데이트
  // 역할: 게시물 데이터 조회
  // 분류: 로직
  Future<void> _fetchPosts() async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context); // nullable로 가져옴
    // ──────────────────────────────────────────────────────────────────
    setState(() {
      _isLoading = true;
    });
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();
      setState(() {
        _posts = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'title': data['title'] as String? ?? (appLocalizations?.noTitle ?? '제목 없음'), // 다국어 적용
            'content': data['content'] as String? ?? (appLocalizations?.noContent ?? '내용 없음'), // 다국어 적용
            'authorId': data['authorId'] as String,
            'authorNickname': data['authorNickname'] as String? ?? (appLocalizations?.unknown ?? '알 수 없음'), // 다국어 적용
            'createdAt': (data['createdAt'] as Timestamp).toDate(),
          };
        }).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations?.postLoadFailed(e.toString()) ?? '게시물 로드 실패: $e'))); // 다국어 적용
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // _showAddPostDialog: 새 게시물 작성 다이얼로그 표시
  // 역할: 게시물 작성 UI 제공
  // 분류: 디자인
  void _showAddPostDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appLocalizations.createPostTitle), // 다국어 적용
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(hintText: appLocalizations.postTitleHint), // 다국어 적용
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(hintText: appLocalizations.postContentHint), // 다국어 적용
                maxLines: 3,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(appLocalizations.cancelButton), // 다국어 적용 (재사용)
            ),
            TextButton(
              onPressed: () {
                _addPost(titleController.text, contentController.text);
                Navigator.of(context).pop();
              },
              child: Text(appLocalizations.writeButton), // 다국어 적용
            ),
          ],
        );
      },
    );
  }

  // _addPost: Firestore에 새 게시물 추가
  // 역할: 게시물 데이터 저장
  // 분류: 로직
  Future<void> _addPost(String title, String content) async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.emptyPostFieldsWarning))); // 다국어 적용
      return;
    }

    try {
      await _firestore.collection('posts').add({
        'title': title,
        'content': content,
        'authorId': widget.currentUserId,
        'authorNickname': widget.currentUserNickname ?? widget.currentUserId,
        'createdAt': Timestamp.now(),
      });
      _fetchPosts(); // 게시물 추가 후 목록 새로고침
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.postCreatedSuccess))); // 다국어 적용
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.postCreateFailed(e.toString())))); // 다국어 적용
      }
    }
  }

  // _buildPostList: 검색어에 따라 필터링된 게시물 목록을 표시
  // 역할: 게시물 목록 UI 구성
  // 분류: 디자인
  Widget _buildPostList() {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    if (_filteredPosts.isEmpty) {
      return Center(child: Text(appLocalizations.noSearchResults)); // 다국어 적용
    }
    return ListView.builder(
      itemCount: _filteredPosts.length,
      itemBuilder: (context, index) {
        final post = _filteredPosts[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            title: Text(post['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post['content'], maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  appLocalizations.authorAndDate(
                    post['authorNickname'] ?? appLocalizations.unknown, // 다국어 적용
                    DateFormat('yyyy.MM.dd HH:mm').format(post['createdAt']),
                  ),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailScreen(
                    postId: post['id'],
                    title: post['title'],
                    content: post['content'],
                    authorId: post['authorId'],
                    authorNickname: post['authorNickname'],
                    createdAt: post['createdAt'],
                    currentUserId: widget.currentUserId,
                    currentUserNickname: widget.currentUserNickname,
                  ),
                ),
              );
              if (result == true) {
                // 게시물 수정/삭제 후 돌아왔을 때 목록 새로고침
                _fetchPosts();
              }
            },
          ),
        );
      },
    );
  }

  // UI를 구성하는 메소드
  // 게시물 목록을 표시하고 새 게시물 작성 버튼 제공
  @override
  Widget build(BuildContext context) {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.boardTitle), // 다국어 적용
        elevation: 0,
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: appLocalizations.searchHintText, // 다국어 적용
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildPostList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostDialog,
        child: const Icon(Icons.add),
        tooltip: appLocalizations.addPostTooltip, // 다국어 적용
      ),
    );
  }
}