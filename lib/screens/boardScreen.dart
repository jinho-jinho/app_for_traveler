import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:app_for_traveler/screens/postDetailScreen.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore
      .instance; // Firestore 인스턴스
  bool _isLoading = true; // 데이터 로딩 상태를 나타내는 플래그
  List<Map<String, dynamic>> _posts = []; // 게시물 데이터를 저장하는 리스트

  // 게시물 검색 - 상태 변수
  String _searchQuery = '';

  // 게시물 검색
  List<Map<String, dynamic>> get _filteredPosts {
    if (_searchQuery.isEmpty) return _posts;
    return _posts.where((post) {
      final title = (post['title'] ?? '').toLowerCase();
      final content = (post['content'] ?? '').toLowerCase();
      return title.contains(_searchQuery) || content.contains(_searchQuery);
    }).toList();
  }

  // 위젯 초기화 시 호출
  // 게시물 데이터를 처음 가져오기 위해 _fetchPosts 호출
  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  // Firestore에서 게시물 목록을 가져오는 메소드
  // 최신순으로 정렬된 게시물을 가져와 _posts 리스트에 저장
  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true; // 로딩 시작
    });

    try {
      // Firestore 'posts' 컬렉션에서 최신순으로 데이터 가져오기
      QuerySnapshot postSnapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();

      // 가져온 데이터를 Map 형태로 변환하여 리스트에 저장
      List<Map<String, dynamic>> posts = postSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'title': data['title'] as String? ?? '제목 없음',
          'content': data['content'] as String? ?? '내용 없음',
          'authorId': data['authorId'] as String? ?? '알 수 없음',
          'authorNickname': data['authorNickname'] as String? ?? '알 수 없음',
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate() ??
              DateTime.now(),
        };
      }).toList();

      // 상태 업데이트: 게시물 리스트 저장 및 로딩 종료
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      // 에러 발생 시 로딩 종료 및 에러 메시지 표시
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물 목록을 불러오는 데 실패했습니다.')),
        );
      }
    }
  }

  // 게시판 검색
  Widget _buildPostList() {
    if (_filteredPosts.isEmpty) {
      return const Center(
          child: Text('검색 결과가 없습니다.', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemCount: _filteredPosts.length,
      itemBuilder: (context, index) {
        final post = _filteredPosts[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PostDetailScreen(
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
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      post['authorNickname'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(post['createdAt']),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  post['title'],
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  post['content'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87),
                ),
                if (post['authorId'] == widget.currentUserId)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) =>
                              AlertDialog(
                                title: const Text('게시물 삭제'),
                                content: const Text('정말 이 게시물을 삭제하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('삭제'),
                                  ),
                                ],
                              ),
                        );
                        if (confirm == true) {
                          await _deletePost(post['id']);
                          _fetchPosts(); // 새로고침
                        }
                      },
                    ),
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  // post 삭제
  Future<void> _deletePost(String postId) async {
    try {
      // 댓글 가져오기
      final commentSnapshot = await _firestore
          .collection('comments')
          .where('postId', isEqualTo: postId)
          .get();

      for (final commentDoc in commentSnapshot.docs) {
        final commentId = commentDoc.id;

        // 대댓글 삭제
        final replySnapshot = await _firestore
            .collection('replies')
            .where('commentId', isEqualTo: commentId)
            .get();

        for (final replyDoc in replySnapshot.docs) {
          print('Deleting reply: ${replyDoc.id}');
          await _firestore.collection('replies').doc(replyDoc.id).delete();
        }

        print('Deleting comment: $commentId');
        await _firestore.collection('comments').doc(commentId).delete();
      }

      // 게시글 삭제
      print('Deleting post: $postId');
      await _firestore.collection('posts').doc(postId).delete();

      if (mounted) {
        setState(() => _posts.removeWhere((post) => post['id'] == postId));
      }
    } catch (e) {
      print('Error while deleting: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물 삭제 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  // 새 게시물 작성 다이얼로그를 표시하는 메소드
  // 사용자가 제목과 내용을 입력하여 새 게시물을 Firestore에 저장
  void _showAddPostDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) =>
          AlertDialog(
            title: const Text('새 게시물 작성'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: '제목'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(labelText: '내용'),
                    maxLines: 5,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty &&
                      contentController.text.isNotEmpty) {
                    try {
                      final newDoc = await _firestore.collection('posts').add({
                        'title': titleController.text,
                        'content': contentController.text,
                        'authorId': widget.currentUserId,
                        'authorNickname': widget.currentUserNickname ??
                            widget.currentUserId,
                        'createdAt': Timestamp.now(),
                      });

                      // 먼저 다이얼로그 닫기
                      Navigator.pop(dialogContext);

                      // 프레임 완료 후 전체 다시 불러오기
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          _fetchPosts(); // 목록 전체 새로고침
                        }
                      });
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('게시물 저장 중 오류가 발생했습니다.')),
                        );
                      }
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('제목과 내용을 입력해주세요.')),
                      );
                    }
                  }
                },
                child: const Text('작성'),
              )
            ],
          ),
    );
  }


  // UI를 구성하는 메소드
  // 게시물 목록을 표시하고 새 게시물 작성 버튼 제공
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: const Text('게시판', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: '글 작성',
            onPressed: _showAddPostDialog,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: '검색어를 입력하세요...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
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
    );
  }
}