import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final String title;
  final String content;
  final String authorId;
  final String authorNickname;
  final DateTime createdAt;
  final String currentUserId;
  final String? currentUserNickname;

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

class _PostDetailScreenState extends State<PostDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _commentController = TextEditingController();
  final Map<String, TextEditingController> _replyControllers = {};
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _replyControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  Future<void> _fetchComments() async {
    setState(() => _isLoading = true);

    try {
      final snapshot = await _firestore
          .collection('comments')
          .where('postId', isEqualTo: widget.postId)
          .orderBy('createdAt', descending: true)
          .get();

      final List<Map<String, dynamic>> loadedComments = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        final repliesSnap = await _firestore
            .collection('replies')
            .where('commentId', isEqualTo: doc.id)
            .orderBy('createdAt', descending: true)
            .get();

        final replies = repliesSnap.docs.map((r) {
          final d = r.data() as Map<String, dynamic>;
          return {
            'id': r.id,
            'content': d['content'] ?? '',
            'authorId': d['authorId'] ?? '',
            'authorNickname': d['authorNickname'] ?? '',
            'createdAt': (d['createdAt'] as Timestamp).toDate(),
          };
        }).toList();

        loadedComments.add({
          'id': doc.id,
          'content': data['content'] ?? '',
          'authorId': data['authorId'] ?? '',
          'authorNickname': data['authorNickname'] ?? '',
          'createdAt': (data['createdAt'] as Timestamp).toDate(),
          'replies': replies,
        });
      }

      setState(() {
        _comments = loadedComments;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글을 불러오지 못했습니다: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글을 입력해주세요.')),
      );
      return;
    }

    try {
      final newDoc = await _firestore.collection('comments').add({
        'postId': widget.postId,
        'content': _commentController.text,
        'authorId': widget.currentUserId,
        'authorNickname': widget.currentUserNickname ?? '익명',
        'createdAt': Timestamp.now(),
      });

      _commentController.clear();
      _fetchComments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 작성 실패: $e')),
      );
    }
  }

  Future<void> _addReply(String commentId) async {
    final controller = _replyControllers[commentId];
    if (controller == null || controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('대댓글을 입력해주세요.')),
      );
      return;
    }

    try {
      await _firestore.collection('replies').add({
        'commentId': commentId,
        'content': controller.text,
        'authorId': widget.currentUserId,
        'authorNickname': widget.currentUserNickname ?? '익명',
        'createdAt': Timestamp.now(),
      });

      controller.clear();
      _fetchComments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('대댓글 작성 실패: $e')),
      );
    }
  }

  Future<void> deleteCommentWithReplies(String postId, String commentId) async {
    try {
      final replySnap = await _firestore
          .collection('replies')
          .where('commentId', isEqualTo: commentId)
          .get();

      for (var r in replySnap.docs) {
        await _firestore.collection('replies').doc(r.id).delete();
      }

      await _firestore.collection('comments').doc(commentId).delete();
      _fetchComments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글 삭제 실패')),
      );
    }
  }

  Future<void> deleteReply(String postId, String commentId, String replyId) async {
    try {
      await _firestore.collection('replies').doc(replyId).delete();
      _fetchComments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('대댓글 삭제 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물 상세'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const CircleAvatar(child: Icon(Icons.person)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.authorNickname, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          Text(DateFormat('yyyy-MM-dd HH:mm').format(widget.createdAt), style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(widget.content, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 24),
                  const Divider(),
                  const Text('댓글', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_comments.isEmpty)
                    const Center(child: Text('댓글이 없습니다.', style: TextStyle(color: Colors.grey))),
                  ..._comments.map((comment) {
                    final commentId = comment['id'];
                    final replies = comment['replies'] as List;
                    _replyControllers[commentId] ??= TextEditingController();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 4)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(comment['authorNickname'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Text(DateFormat('MM/dd HH:mm').format(comment['createdAt']), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              const Spacer(),
                              if (comment['authorId'] == widget.currentUserId)
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('댓글 삭제'),
                                        content: const Text('이 댓글과 대댓글을 삭제할까요?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await deleteCommentWithReplies(widget.postId, commentId);
                                    }
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(comment['content']),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _replyControllers[commentId],
                                  decoration: InputDecoration(
                                    hintText: '대댓글 입력...',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
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
                          const SizedBox(height: 10),
                          ...replies.map((reply) => Padding(
                            padding: const EdgeInsets.only(top: 6, left: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CircleAvatar(radius: 12, child: Icon(Icons.person, size: 14)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(reply['authorNickname'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 8),
                                          Text(DateFormat('MM/dd HH:mm').format(reply['createdAt']), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                          const Spacer(),
                                          if (reply['authorId'] == widget.currentUserId)
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                    title: const Text('대댓글 삭제'),
                                                    content: const Text('이 대댓글을 삭제할까요?'),
                                                    actions: [
                                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                                                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true) {
                                                  await deleteReply(widget.postId, commentId, reply['id']);
                                                }
                                              },
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(reply['content'], style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 4)]),
            child: SafeArea(
              child: Row(
                children: [
                  const CircleAvatar(child: Icon(Icons.person)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: '댓글을 입력하세요...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
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
          )
        ],
      ),
    );
  }
}