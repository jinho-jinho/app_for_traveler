import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
// ──────────────────────────────────────────────────────────────────
// AppLocalizations 임포트 추가
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// ──────────────────────────────────────────────────────────────────

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

  List<Map<String, dynamic>> _comments = []; // 댓글 목록

  String? _editingCommentId; // 수정 중인 댓글 ID
  String? _replyingToCommentId; // 대댓글 작성 중인 댓글 ID


  @override
  void initState() {
    super.initState();

    _loadComments(); // 댓글 로드
  }

  // _loadComments: Firestore에서 댓글 데이터 가져오기
  Future<void> _loadComments() async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    try {
      final snapshot = await _firestore
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .orderBy('createdAt', descending: false)
          .get();

      final List<Map<String, dynamic>> fetchedComments = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final userDoc = await _firestore.collection('users').doc(data['userId']).get();
        final comment = {
          'id': doc.id,
          'userId': data['userId'],
          'userNickname': userDoc.exists ? userDoc.data()!['nickname'] : appLocalizations.unknown, // 다국어 적용
          'content': data['content'],
          'createdAt': (data['createdAt'] as Timestamp).toDate(),
          'replies': [], // 대댓글 목록 초기화
        };

        // 대댓글 로드
        final repliesSnapshot = await _firestore
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .doc(doc.id)
            .collection('replies')
            .orderBy('createdAt', descending: false)
            .get();

        final List<Map<String, dynamic>> fetchedReplies = [];
        for (var replyDoc in repliesSnapshot.docs) {
          final replyData = replyDoc.data();
          final replyUserDoc = await _firestore.collection('users').doc(replyData['userId']).get();
          fetchedReplies.add({
            'id': replyDoc.id,
            'userId': replyData['userId'],
            'userNickname': replyUserDoc.exists ? replyUserDoc.data()!['nickname'] : appLocalizations.unknown, // 다국어 적용
            'content': replyData['content'],
            'createdAt': (replyData['createdAt'] as Timestamp).toDate(),
          });
        }
        comment['replies'] = fetchedReplies;
        fetchedComments.add(comment);
      }

      setState(() {
        _comments = fetchedComments;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(content: Text(appLocalizations.failedToLoadComments(e.toString()))), // 다국어 적용
        );
      }
    }
  }

  // _addComment: 새 댓글 추가
  Future<void> _addComment() async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLocalizations.commentEmptyWarning)), // 다국어 적용
      );
      return;
    }

    try {
      final newCommentRef = await _firestore.collection('posts').doc(widget.postId).collection('comments').add({
        'userId': widget.currentUserId,
        'content': _commentController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 댓글 작성 성공 시 작성자에게 알림 추가 (자신이 작성한 댓글에는 알림 X)
      if (widget.currentUserId != widget.authorId) {
        await _firestore.collection('users').doc(widget.authorId).collection('notifications').add({
          'type': 'comment',
          'postId': widget.postId,
          'postTitle': widget.title,
          'postContent': widget.content,
          'postAuthorId': widget.authorId,
          'postAuthorNickname': widget.authorNickname,
          'postCreatedAt': widget.createdAt,
          'commentId': newCommentRef.id,
          'nickname': widget.currentUserNickname ?? appLocalizations.unknown, // 다국어 적용 (재사용)
          'message': '${widget.currentUserNickname ?? appLocalizations.unknown} 님이 회원님의 게시물에 댓글을 달았습니다.', // 다국어 적용
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
        });
      }

      _commentController.clear();
      await _loadComments(); // 댓글 새로고침
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLocalizations.commentAddedSuccess)), // 다국어 적용
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLocalizations.failedToAddComment(e.toString()))), // 다국어 적용
        );
      }
    }
  }

  // _editComment: 댓글 수정 시작
  void _editComment(String commentId, String currentContent) {
    setState(() {
      _editingCommentId = commentId;
      _commentController.text = currentContent;
    });
  }

  // _updateComment: 댓글 수정 완료
  Future<void> _updateComment() async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    if (_editingCommentId == null || _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLocalizations.commentEmptyWarning)), // 다국어 적용 (재사용)
      );
      return;
    }

    try {
      await _firestore
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(_editingCommentId)
          .update({'content': _commentController.text.trim()});

      setState(() {
        _editingCommentId = null;
        _commentController.clear();
      });
      await _loadComments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLocalizations.commentUpdatedSuccess)), // 다국어 적용
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLocalizations.failedToUpdateComment(e.toString()))), // 다국어 적용
        );
      }
    }
  }

  // _deleteComment: 댓글 삭제
  Future<void> _deleteComment(String commentId) async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appLocalizations.deleteCommentTitle), // 다국어 적용
          content: Text(appLocalizations.confirmDeleteComment), // 다국어 적용
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(appLocalizations.cancelButton), // 다국어 적용
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(appLocalizations.deleteButton), // 다국어 적용
            ),
          ],
        );
      },
    ) ?? false;

    if (!confirm) return;

    try {
      await _firestore
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      await _loadComments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLocalizations.commentDeletedSuccess)), // 다국어 적용
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLocalizations.failedToDeleteComment(e.toString()))), // 다국어 적용
        );
      }
    }
  }

  // _addReply: 대댓글 추가
  Future<void> _addReply(String commentId) async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    final TextEditingController replyController = _replyControllers[commentId]!;
    if (replyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLocalizations.replyEmptyWarning)), // 다국어 적용
      );
      return;
    }

    try {
      await _firestore
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)

          .collection('replies')
          .add({
        'userId': widget.currentUserId,
        'content': replyController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      replyController.clear();
      setState(() {
        _replyingToCommentId = null; // 대댓글 입력창 닫기
      });
      await _loadComments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLocalizations.replyAddedSuccess)), // 다국어 적용
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLocalizations.failedToAddReply(e.toString()))), // 다국어 적용
        );
      }
    }
  }

  // _editReply: 대댓글 수정 시작
  void _editReply(String commentId, String replyId, String currentContent) {
    setState(() {
      _replyingToCommentId = commentId; // 대댓글 입력창 열기
      _replyControllers.putIfAbsent(commentId, () => TextEditingController()).text = currentContent;
      // 대댓글 수정은 별도의 editingReplyId 상태를 관리하지 않고, 단순히 입력창에 값을 채워넣는 방식으로 진행.
      // 실제 업데이트는 _updateReply 함수에서 처리.
    });
  }


  // _updateReply: 대댓글 수정 완료 (실제 Firestore 업데이트)
  Future<void> _updateReply(String commentId, String replyId) async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    final TextEditingController replyController = _replyControllers[commentId]!;
    if (replyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text(appLocalizations.replyEmptyWarning)), // 다국어 적용 (재사용)

      );
      return;
    }

    try {
      await _firestore
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc(replyId)
          .update({'content': replyController.text.trim()});

      replyController.clear();
      setState(() {
        _replyingToCommentId = null; // 대댓글 입력창 닫기
      });
      await _loadComments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLocalizations.replyUpdatedSuccess)), // 다국어 적용
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLocalizations.failedToUpdateReply(e.toString()))), // 다국어 적용
        );
      }
    }
  }

  // _deleteReply: 대댓글 삭제
  Future<void> _deleteReply(String commentId, String replyId) async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appLocalizations.deleteReplyTitle), // 다국어 적용
          content: Text(appLocalizations.confirmDeleteReply), // 다국어 적용
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(appLocalizations.cancelButton), // 다국어 적용 (재사용)
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(appLocalizations.deleteButton), // 다국어 적용 (재사용)
            ),
          ],
        );
      },
    ) ?? false;

    if (!confirm) return;

    try {
      await _firestore
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc(replyId)
          .delete();

      await _loadComments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLocalizations.replyDeletedSuccess)), // 다국어 적용
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLocalizations.failedToDeleteReply(e.toString()))), // 다국어 적용
        );
      }
    }
  }

  // UI 구성

  @override
  Widget build(BuildContext context) {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    return Scaffold(
      appBar: AppBar(

        title: Text(appLocalizations.postDetailTitle), // 다국어 적용
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),

        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(

            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${appLocalizations.authorLabel}: ${widget.authorNickname} | ${DateFormat('yyyy.MM.dd HH:mm').format(widget.createdAt)}', // 다국어 적용
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const Divider(height: 30),
                  Text(
                    widget.content,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    appLocalizations.commentsTitle, // 다국어 적용
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // 댓글 목록
                  _comments.isEmpty
                      ? Center(child: Text(appLocalizations.noCommentsYet)) // 다국어 적용
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      // 대댓글 컨트롤러 초기화 (없으면 새로 생성)
                      _replyControllers.putIfAbsent(comment['id'], () => TextEditingController());

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    comment['userNickname'],
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    DateFormat('yyyy.MM.dd HH:mm').format(comment['createdAt']),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(comment['content']),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: ButtonBar(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _replyingToCommentId = comment['id'];
                                        });
                                      },
                                      child: Text(appLocalizations.replyButton), // 다국어 적용
                                    ),
                                    if (comment['userId'] == widget.currentUserId) ...[
                                      TextButton(
                                        onPressed: () => _editComment(comment['id'], comment['content']),
                                        child: Text(appLocalizations.editButton), // 다국어 적용
                                      ),
                                      TextButton(
                                        onPressed: () => _deleteComment(comment['id']),
                                        child: Text(appLocalizations.deleteButton), // 다국어 적용
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // 대댓글 목록
                              if (comment['replies'] != null && comment['replies'].isNotEmpty)
                                ...comment['replies'].map<Widget>((reply) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 20.0, top: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${appLocalizations.replyPrefix} ${reply['userNickname']}', // 다국어 적용
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                            Text(
                                              DateFormat('yyyy.MM.dd HH:mm').format(reply['createdAt']),
                                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(reply['content'], style: const TextStyle(fontSize: 14)),
                                        if (reply['userId'] == widget.currentUserId)
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: ButtonBar(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextButton(
                                                  onPressed: () => _editReply(comment['id'], reply['id'], reply['content']),
                                                  child: Text(appLocalizations.editButton), // 다국어 적용 (재사용)
                                                ),
                                                TextButton(
                                                  onPressed: () => _deleteReply(comment['id'], reply['id']),
                                                  child: Text(appLocalizations.deleteButton), // 다국어 적용 (재사용)
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              // 대댓글 입력창
                              if (_replyingToCommentId == comment['id'])
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _replyControllers[comment['id']],
                                          decoration: InputDecoration(
                                            hintText: appLocalizations.enterReplyHint, // 다국어 적용
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
                                        onPressed: () => _addReply(comment['id']),
                                        child: Text(appLocalizations.postButton), // 다국어 적용
                                      ),
                                      if (_replyControllers[comment['id']]!.text.isNotEmpty) // 수정 중일 때만 '수정' 버튼 표시
                                        TextButton(
                                          onPressed: () => _updateReply(comment['id'], _replyControllers[comment['id']]!.text), // TODO: replyId를 전달해야 합니다.
                                          child: Text(appLocalizations.saveButton), // 다국어 적용
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // 댓글 작성 입력창
          Container(

            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),

            child: SafeArea(
              child: Row(
                children: [
                  const CircleAvatar(child: Icon(Icons.person)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(

                        hintText: _editingCommentId != null ? appLocalizations.editCommentHint : appLocalizations.enterCommentHint, // 다국어 적용
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
                    onPressed: _editingCommentId != null ? _updateComment : _addComment,
                    child: Text(_editingCommentId != null ? appLocalizations.saveButton : appLocalizations.postButton, style: const TextStyle(color: Colors.blue)), // 다국어 적용
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