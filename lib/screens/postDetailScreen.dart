import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// 게시물 상세 화면 StatefulWidget
// 역할: 게시물 내용 및 댓글/대댓글 표시 및 관리
class PostDetailScreen extends StatefulWidget {
  final String postId; // 게시물 ID
  final String title; // 게시물 제목
  final String content; // 게시물 내용
  final String authorId; // 작성자 ID
  final String authorNickname; // 작성자 닉네임
  final DateTime createdAt; // 작성 시간
  final String currentUserId; // 현재 사용자 ID
  final String? currentUserNickname; // 현재 사용자 닉네임

  const PostDetailScreen({
    super.key,
    required this.postId,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorNickname,
    required this.createdAt,
    required this.currentUserId,
    this.currentUserNickname,
  });

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

// PostDetailScreen 상태 관리 클래스
// 역할: 댓글 및 대댓글 데이터 관리 및 UI 상태 제어
class _PostDetailScreenState extends State<PostDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _commentController = TextEditingController();
  final Map<String, TextEditingController> _replyControllers = {};
  List<Map<String, dynamic>> _comments = []; // 댓글 및 대댓글 데이터
  bool _isLoading = true; // 로딩 상태

  // initState: 위젯 초기화, 댓글 데이터 로드
  // 역할: 초기 댓글 데이터 가져오기
  // 분류: 로직
  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  // dispose: 컨트롤러 및 리소스 정리
  // 역할: 텍스트 컨트롤러 해제
  // 분류: 로직
  @override
  void dispose() {
    _commentController.dispose();
    _replyControllers.values.forEach((controller) => controller.dispose());
    _replyControllers.clear();
    super.dispose();
  }

  // _fetchComments: Firestore에서 댓글 및 대댓글 데이터 가져오기
  // 역할: 게시물의 댓글과 대댓글 로드 및 상태 업데이트
  // 분류: 로직
  Future<void> _fetchComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot commentSnapshot = await _firestore
          .collection('comments')
          .where('postId', isEqualTo: widget.postId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      List<Map<String, dynamic>> comments = [];
      for (var doc in commentSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        QuerySnapshot replySnapshot = await _firestore
            .collection('replies')
            .where('commentId', isEqualTo: doc.id)
            .orderBy('createdAt', descending: true)
            .limit(10)
            .get();

        List<Map<String, dynamic>> replies = replySnapshot.docs.map((replyDoc) {
          final replyData = replyDoc.data() as Map<String, dynamic>;
          return {
            'id': replyDoc.id,
            'content': replyData['content'] as String? ?? '내용 없음',
            'authorId': replyData['authorId'] as String? ?? '알 수 없음',
            'authorNickname': replyData['authorNickname'] as String? ?? '알 수 없음',
            'createdAt': (replyData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          };
        }).toList();

        comments.add({
          'id': doc.id,
          'content': data['content'] as String? ?? '내용 없음',
          'authorId': data['authorId'] as String? ?? '알 수 없음',
          'authorNickname': data['authorNickname'] as String? ?? '알 수 없음',
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'replies': replies,
        });
      }

      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글 목록을 불러오는 데 실패했습니다. 에러: $e')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  // _addComment: Firestore에 새 댓글 추가
  // 역할: 댓글 입력 처리 및 저장
  // 분류: 로직
  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      try {
        await _firestore.collection('comments').add({
          'postId': widget.postId,
          'content': _commentController.text,
          'authorId': widget.currentUserId,
          'authorNickname': widget.currentUserNickname ?? widget.currentUserId,
          'createdAt': Timestamp.now(),
        });
        _commentController.clear();
        _fetchComments();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('댓글 저장 중 오류가 발생했습니다. 에러: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글 내용을 입력해주세요.')),
        );
      }
    }
  }

  // _addReply: Firestore에 대댓글 추가
  // 역할: 대댓글 입력 처리 및 저장
  // 분류: 로직
  Future<void> _addReply(String commentId) async {
    final replyController = _replyControllers[commentId];
    if (replyController != null && replyController.text.isNotEmpty) {
      try {
        await _firestore.collection('replies').add({
          'commentId': commentId,
          'content': replyController.text,
          'authorId': widget.currentUserId,
          'authorNickname': widget.currentUserNickname ?? widget.currentUserId,
          'createdAt': Timestamp.now(),
        });
        replyController.clear();
        _fetchComments();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('대댓글 저장 중 오류가 발생했습니다. 에러: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('대댓글 내용을 입력해주세요.')),
        );
      }
    }
  }

  // build: 게시물 상세 및 댓글 UI 렌더링
  // 역할: 게시물 정보, 댓글 목록, 입력 필드 표시
  // 분류: 디자인
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물 상세'),
        elevation: 0,
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 게시물 및 댓글 목록 영역
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 게시물 제목
                          Text(
                            widget.title,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          // 작성자 정보
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.person, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.authorNickname,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    DateFormat('yyyy-MM-dd HH:mm').format(widget.createdAt),
                                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // 게시물 내용
                          Text(
                            widget.content,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          // 댓글 섹션 제목
                          const Text(
                            '댓글',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          // 댓글 목록
                          _comments.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  child: Center(child: Text('댓글이 없습니다.', style: TextStyle(color: Colors.grey))),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _comments.length,
                                  itemBuilder: (context, index) {
                                    final comment = _comments[index];
                                    final commentId = comment['id'] as String;
                                    if (!_replyControllers.containsKey(commentId)) {
                                      _replyControllers[commentId] = TextEditingController();
                                    }
                                    final replies = comment['replies'] as List<dynamic>;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // 댓글 정보
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const CircleAvatar(
                                                radius: 16,
                                                backgroundColor: Colors.grey,
                                                child: Icon(Icons.person, color: Colors.white, size: 20),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          comment['authorNickname'] ?? '알 수 없음',
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          DateFormat('yyyy-MM-dd HH:mm').format(comment['createdAt'] as DateTime),
                                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      comment['content'] ?? '내용 없음',
                                                      style: const TextStyle(fontSize: 14),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    // 대댓글 입력 필드
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: TextField(
                                                            controller: _replyControllers[commentId],
                                                            decoration: InputDecoration(
                                                              hintText: '대댓글 작성...',
                                                              hintStyle: const TextStyle(color: Colors.grey),
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(20),
                                                                borderSide: const BorderSide(color: Colors.grey),
                                                              ),
                                                              contentPadding: const EdgeInsets.symmetric(
                                                                horizontal: 12,
                                                                vertical: 8,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        TextButton(
                                                          onPressed: () => _addReply(commentId),
                                                          child: const Text('작성', style: TextStyle(color: Colors.blue)),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          // 대댓글 목록
                                          Padding(
                                            padding: const EdgeInsets.only(left: 44.0),
                                            child: replies.isEmpty
                                                ? const Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                                    child: Text('대댓글이 없습니다.', style: TextStyle(color: Colors.grey)),
                                                  )
                                                : ListView.builder(
                                                    shrinkWrap: true,
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    itemCount: replies.length,
                                                    itemBuilder: (context, replyIndex) {
                                                      final reply = replies[replyIndex];
                                                      return Padding(
                                                        padding: const EdgeInsets.only(bottom: 8.0),
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            const CircleAvatar(
                                                              radius: 12,
                                                              backgroundColor: Colors.grey,
                                                              child: Icon(Icons.person, color: Colors.white, size: 16),
                                                            ),
                                                            const SizedBox(width: 12),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        reply['authorNickname'] ?? '알 수 없음',
                                                                        style: const TextStyle(
                                                                          fontSize: 12,
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(width: 8),
                                                                      Text(
                                                                        DateFormat('yyyy-MM-dd HH:mm').format(reply['createdAt'] as DateTime),
                                                                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(height: 4),
                                                                  Text(
                                                                    reply['content'] ?? '내용 없음',
                                                                    style: const TextStyle(fontSize: 12),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ),
          ),
          // 댓글 입력 필드
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: '댓글을 입력하세요...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _addComment,
                    child: const Text('작성', style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}