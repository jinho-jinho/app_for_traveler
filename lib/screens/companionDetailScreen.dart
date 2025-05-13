import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'editCompanionScreen.dart';

class CompanionDetailScreen extends StatefulWidget {
  final String companionId;
  final String currentUserId;

  const CompanionDetailScreen({super.key, required this.companionId, required this.currentUserId});

  @override
  State<CompanionDetailScreen> createState() => _CompanionDetailScreenState();
}

class _CompanionDetailScreenState extends State<CompanionDetailScreen> {
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _companionData;
  bool _isLoading = true;
  bool _isLeader = false;
  bool _isParticipating = false;
  List<Map<String, dynamic>> _comments = [];
  final _commentController = TextEditingController();
  final Map<String, TextEditingController> _replyControllers = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadComments();
  }

  Future<void> _loadData() async {
    try {
      final doc = await _firestore.collection('companions').doc(widget.companionId).get();
      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('동행 정보를 찾을 수 없습니다.')));
        setState(() => _isLoading = false);
        return;
      }

      final data = doc.data()!;
      final participantDoc = await _firestore
          .collection('companions')
          .doc(widget.companionId)
          .collection('participants')
          .doc(widget.currentUserId)
          .get();

      setState(() {
        _companionData = data;
        _isParticipating = participantDoc.exists;
        _isLeader = participantDoc.data()?['isLeader'] == true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: ${e.toString()}')));
    }
  }

  Future<void> _loadComments() async {
    final snapshot = await _firestore
        .collection('companions')
        .doc(widget.companionId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .get();

    final comments = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).cast<Map<String, dynamic>>().toList();
    setState(() => _comments = comments);
  }

  Future<void> _joinCompanion() async {
    if (_companionData == null) return;

    final userDoc = await _firestore.collection('users').doc(widget.currentUserId).get();
    final nickname = userDoc.data()?['nickname'] ?? '익명';

    final docRef = _firestore.collection('companions').doc(widget.companionId);

    try {
      await _firestore.runTransaction((tx) async {
        final snapshot = await tx.get(docRef);
        final data = snapshot.data()!;
        final currentCount = data['currentCount'] ?? 0;
        final maxCount = data['maxCount'] ?? 4;

        if (currentCount >= maxCount || (data['isClosed'] ?? false)) {
          throw Exception('모집이 마감되었습니다.');
        }

        tx.set(
          docRef.collection('participants').doc(widget.currentUserId),
          {
            'userId': widget.currentUserId,
            'userName': nickname,
            'joinedAt': FieldValue.serverTimestamp(),
            'isLeader': false,
          },
        );

        tx.set(
          _firestore.collection('users').doc(widget.currentUserId).collection('joinedCompanions').doc(widget.companionId),
          {
            'companionId': widget.companionId,
            'destination': data['destination'],
            'joinedAt': FieldValue.serverTimestamp(),
            'startDate': data['startDate'],
            'endDate': data['endDate'],
          },
        );

        tx.update(docRef, {
          'currentCount': currentCount + 1,
          'isClosed': (currentCount + 1) >= maxCount,
        });
      });

      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('참여 완료')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('참여 실패: ${e.toString()}')));
    }
  }

  Future<void> _deleteCompanion() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('정말 이 동행을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('아니오')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('예')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final docRef = _firestore.collection('companions').doc(widget.companionId);
      final subDocs = await docRef.collection('participants').get();
      for (final doc in subDocs.docs) {
        await doc.reference.delete();
      }
      await docRef.delete();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('삭제 실패: ${e.toString()}')));
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;
    final userDoc = await _firestore.collection('users').doc(widget.currentUserId).get();
    final nickname = userDoc.data()?['nickname'] ?? '익명';

    await _firestore
        .collection('companions')
        .doc(widget.companionId)
        .collection('comments')
        .add({
      'authorId': widget.currentUserId,
      'authorNickname': nickname,
      'text': _commentController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'reply': null,
      'repliedBy': null,
    });

    _commentController.clear();
    _loadComments();
  }

  Future<void> _replyToComment(String commentId) async {
    final controller = _replyControllers[commentId];
    if (controller == null || controller.text.trim().isEmpty) return;

    await _firestore
        .collection('companions')
        .doc(widget.companionId)
        .collection('comments')
        .doc(commentId)
        .update({
      'reply': controller.text.trim(),
      'repliedBy': widget.currentUserId,
    });

    controller.clear();
    _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_companionData == null) return const Scaffold(body: Center(child: Text('동행 정보를 불러올 수 없습니다.')));

    final dateFormat = DateFormat('yyyy.MM.dd');
    final dateRange = '${dateFormat.format((_companionData!['startDate'] as Timestamp).toDate())} ~ ${dateFormat.format((_companionData!['endDate'] as Timestamp).toDate())}';

    return Scaffold(
      appBar: AppBar(title: const Text('동행 상세 정보')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_companionData!['title'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_companionData!['destination'] ?? ''),
            Text(dateRange),
            Text(_companionData!['content'] ?? ''),
            const SizedBox(height: 8),
            Text('파티장: ${_companionData!['leaderName'] ?? ''}'),
            const SizedBox(height: 16),
            if (!_isParticipating && !(_companionData!['isClosed'] ?? false))
              ElevatedButton(onPressed: _joinCompanion, child: const Text('참여하기')),
            if (_isLeader)
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditCompanionScreen(
                            companionId: widget.companionId,
                          ),
                        ),
                      ).then((_) => _loadData());
                    },
                    child: const Text('수정'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _deleteCompanion, child: const Text('삭제')),
                ],
              ),
            const Divider(height: 32),
            const Text('댓글', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: '댓글 작성...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _postComment,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ..._comments.map((comment) {
              final commentId = comment['id'];
              final controller = _replyControllers.putIfAbsent(commentId, () => TextEditingController());
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(comment['authorNickname'] ?? '알 수 없음', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(comment['text'] ?? ''),
                      const SizedBox(height: 8),
                      if ((comment['reply'] ?? '') != '')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            Text('답변: ${comment['reply']}', style: const TextStyle(color: Colors.blue)),
                          ],
                        )
                      else if (_isLeader)
                        Column(
                          children: [
                            TextField(
                              controller: controller,
                              decoration: const InputDecoration(hintText: '답변 작성...'),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => _replyToComment(commentId),
                                child: const Text('답변 달기'),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
