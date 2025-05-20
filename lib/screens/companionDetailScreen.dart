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

      // 모집 상태 판단 로직 추가
      final currentCount = data['currentCount'] ?? 0;
      final maxCount = data['maxCount'] ?? 0;
      final startDate = (data['startDate'] as Timestamp).toDate();
      final now = DateTime.now();

      bool shouldBeClosed = currentCount >= maxCount || now.isAfter(startDate);
      bool shouldReopen = currentCount < maxCount && now.isBefore(startDate);

      if (shouldBeClosed && !(data['isClosed'] ?? false)) {
        await _firestore.collection('companions').doc(widget.companionId).update({
          'isClosed': true,
        });
        data['isClosed'] = true; // 상태 갱신
      } else if (shouldReopen && (data['isClosed'] ?? false)) {
        await _firestore.collection('companions').doc(widget.companionId).update({
          'isClosed': false,
        });
        data['isClosed'] = false; // 상태 갱신
      }

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
          _firestore.collection('users').doc(widget.currentUserId)
              .collection('joinedCompanions')
              .doc(widget.companionId),
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
  Future<void> _deleteCompanion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('정말 이 동행을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('예'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final docRef = _firestore.collection('companions').doc(widget.companionId);
      final subDocs = await docRef.collection('participants').get();

      for (final doc in subDocs.docs) {
        await doc.reference.delete(); // 참여자 하위 문서 삭제
      }

      await docRef.delete(); // 동행 문서 삭제

      if (!mounted) return;
      Navigator.pop(context); // 화면 종료
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: ${e.toString()}')),
      );
    }
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
  Future<void> _leaveCompanion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('참여 취소'),
        content: const Text('이 동행에서 나가시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('아니오')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('예')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final docRef = _firestore.collection('companions').doc(widget.companionId);

      await _firestore.runTransaction((tx) async {
        final snapshot = await tx.get(docRef);
        final data = snapshot.data()!;
        final currentCount = data['currentCount'] ?? 1;

        tx.delete(docRef.collection('participants').doc(widget.currentUserId));

        tx.delete(
          _firestore.collection('users').doc(widget.currentUserId)
              .collection('joinedCompanions').doc(widget.companionId),
        );

        tx.update(docRef, {
          'currentCount': currentCount - 1,
          'isClosed': false,
        });
      });

      _loadData();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('동행 참여가 취소되었습니다.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_companionData == null) return const Scaffold(body: Center(child: Text('동행 정보를 불러올 수 없습니다.')));

    final dateFormat = DateFormat('yyyy.MM.dd');
    final dateRange =
        '${dateFormat.format((_companionData!['startDate'] as Timestamp).toDate())} ~ ${dateFormat.format((_companionData!['endDate'] as Timestamp).toDate())}';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: const Text('동행 상세 정보', style: TextStyle(fontWeight: FontWeight.bold)),
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _companionData!['title'] ?? '',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (_companionData!['isClosed'] ?? false)
                                        ? Colors.grey[300]
                                        : Colors.green[100],
                                    borderRadius: BorderRadius.circular(16), // ← 여기를 16으로 변경
                                  ),
                                  child: Text(
                                    (_companionData!['isClosed'] ?? false) ? '모집 완료' : '모집 중',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: (_companionData!['isClosed'] ?? false)
                                          ? Colors.grey[600]
                                          : Colors.green[800],
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),
                      ),
                      if (_isLeader || _isParticipating)
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditCompanionScreen(companionId: widget.companionId),
                                ),
                              ).then((_) => _loadData());
                            } else if (value == 'delete') {
                              _deleteCompanion();
                            } else if (value == 'leave') {
                              _leaveCompanion();
                            } else if (value == 'toggle_close') {
                              final updated = !(_companionData!['isClosed'] ?? false);
                              await _firestore.collection('companions').doc(widget.companionId).update({
                                'isClosed': updated,
                              });
                              _loadData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(updated ? '모집이 마감되었습니다.' : '모집이 재개되었습니다.')),
                              );
                            }
                          },

                          itemBuilder: (context) => [
                            if (_isLeader) const PopupMenuItem(value: 'edit', child: Text('수정')),
                            if (_isLeader) const PopupMenuItem(value: 'delete', child: Text('삭제')),
                            if (_isLeader) //애매
                              PopupMenuItem(value: 'toggle_close', child: Text(_companionData!['isClosed'] ? '모집 재개' : '모집 마감')),

                            if (!_isLeader && _isParticipating)
                              const PopupMenuItem(value: 'leave', child: Text('동행 참여 취소')),
                          ],
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text('📍 ${_companionData!['destination'] ?? '여행지 미정'}',
                      style: const TextStyle(color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text('🗓 $dateRange', style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 12),
                  Text(_companionData!['content'] ?? '', style: const TextStyle(color: Colors.black87)),
                  const SizedBox(height: 12),
                  Text('파티장: ${_companionData!['leaderName'] ?? ''}',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (!_isParticipating && !(_companionData!['isClosed'] ?? false))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _joinCompanion,
                  icon: const Icon(Icons.group_add),
                  label: const Text('참여하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            Container(
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
                  const Text('댓글', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: '댓글을 입력하세요...',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.teal),
                        onPressed: _postComment,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._comments.map((comment) {
                    final commentId = comment['id'];
                    final controller = _replyControllers.putIfAbsent(commentId, () => TextEditingController());
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(comment['authorNickname'] ?? '알 수 없음',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(comment['text'] ?? ''),
                          const SizedBox(height: 8),
                          if ((comment['reply'] ?? '') != '')
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('답변: ${comment['reply']}',
                                  style: const TextStyle(color: Colors.blue)),
                            )
                          else if (_isLeader)
                            Column(
                              children: [
                                TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(hintText: '답변을 입력하세요...'),
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
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
