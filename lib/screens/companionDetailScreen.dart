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
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _participantList = [];
  bool _hasRequested = false; // 🔹 신청만 했는지 여부



  @override
  void initState() {
    super.initState();
    _loadData();
    _loadComments();
    _loadRequests();
    _loadParticipants();
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

      final requestDoc = await _firestore
          .collection('companions')
          .doc(widget.companionId)
          .collection('requests')
          .doc(widget.currentUserId)
          .get(); // ✅ 이걸 setState 밖에서 await 해야 함

      // 모집 상태 판단 로직
      final currentCount = data['currentCount'] ?? 0;
      final maxCount = data['maxCount'] ?? 0;
      final startDate = (data['startDate'] as Timestamp).toDate();
      final now = DateTime.now();

      final today = DateTime(now.year, now.month, now.day);
      final start = DateTime(startDate.year, startDate.month, startDate.day);

      bool shouldBeClosed = currentCount >= maxCount || !today.isBefore(start); // now >= startDate
      bool shouldReopen = currentCount < maxCount && today.isBefore(start);     // now < startDate

      if (shouldBeClosed && !(data['isClosed'] ?? false)) {
        await _firestore.collection('companions').doc(widget.companionId).update({'isClosed': true});
        data['isClosed'] = true;
      } else if (shouldReopen && (data['isClosed'] ?? false)) {
        await _firestore.collection('companions').doc(widget.companionId).update({'isClosed': false});
        data['isClosed'] = false;
      }

      // ✅ 모든 비동기 로직 후 setState
      setState(() {
        _companionData = data;
        _isParticipating = participantDoc.exists;
        _isLeader = participantDoc.data()?['isLeader'] == true;
        _hasRequested = requestDoc.exists; // ✅ 신청 여부도 상태에 반영
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


  Future<void> _requestJoin() async {
    final userDoc = await _firestore.collection('users').doc(widget.currentUserId).get();
    final nickname = userDoc.data()?['nickname'] ?? '익명';

    await _firestore
        .collection('companions')
        .doc(widget.companionId)
        .collection('requests')
        .doc(widget.currentUserId)
        .set({
      'userId': widget.currentUserId,
      'userName': nickname,
      'requestedAt': FieldValue.serverTimestamp(),
    });

    // 🔥 신청 후 즉시 UI에 반영되도록!
    setState(() {
      _hasRequested = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('참여 신청 완료')),
    );
  }


  Future<void> _cancelRequest() async {
    try {
      await _firestore
          .collection('companions')
          .doc(widget.companionId)
          .collection('requests')
          .doc(widget.currentUserId)
          .delete();

      setState(() {
        _hasRequested = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('참여 신청이 취소되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('신청 취소 실패: ${e.toString()}')),
      );
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

  Future<void> _loadRequests() async {
    final snapshot = await _firestore
        .collection('companions')
        .doc(widget.companionId)
        .collection('requests')
        .get();

    final requests = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    setState(() => _requests = requests);
  }

  Future<void> _loadParticipants() async {
    final snapshot = await _firestore
        .collection('companions')
        .doc(widget.companionId)
        .collection('participants')
        .get();

    final participants = snapshot.docs.map((doc) => doc.data()).toList();
    setState(() => _participantList = participants);
  }

  Future<void> _acceptRequest(String userId, String userName) async {
    final docRef = _firestore.collection('companions').doc(widget.companionId);

    await _firestore.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);
      final data = snapshot.data()!;
      final currentCount = data['currentCount'] ?? 0;
      final maxCount = data['maxCount'] ?? 0;

      if (currentCount >= maxCount) throw Exception('정원이 가득 찼습니다.');

      tx.set(docRef.collection('participants').doc(userId), {
        'userId': userId,
        'userName': userName,
        'joinedAt': FieldValue.serverTimestamp(),
        'isLeader': false,
      });

      tx.update(docRef, {
        'currentCount': currentCount + 1,
        'isClosed': (currentCount + 1) >= maxCount,
      });

      tx.delete(docRef.collection('requests').doc(userId));
    });

    _loadData();
    _loadRequests();
    _loadParticipants();
  }

  Future<void> _rejectRequest(String userId) async {
    await _firestore
        .collection('companions')
        .doc(widget.companionId)
        .collection('requests')
        .doc(userId)
        .delete();
    _loadRequests();
  }

  Future<void> _kickParticipant(String userId) async {
    final docRef = _firestore.collection('companions').doc(widget.companionId);

    await _firestore.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);
      final data = snapshot.data()!;
      final currentCount = data['currentCount'] ?? 1;

      tx.delete(docRef.collection('participants').doc(userId));

      tx.update(docRef, {
        'currentCount': currentCount - 1,
        'isClosed': false,
      });
    });

    _loadData();
    _loadParticipants();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_companionData == null) return const Scaffold(body: Center(child: Text('동행 정보를 불러올 수 없습니다.')));

    final dateFormat = DateFormat('yyyy.MM.dd');
    final dateRange =
        '${dateFormat.format((_companionData!['startDate'] as Timestamp).toDate())} ~ ${dateFormat.format((_companionData!['endDate'] as Timestamp).toDate())}';

    Widget buttonWidget = const SizedBox.shrink(); // 기본값 (안 보임)
    if (_isParticipating) {
      // ✅ 참여자
      buttonWidget = ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check, color: Colors.black87),
        label: const Text('참여 중'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black87,
          minimumSize: const Size(double.infinity, 48),
        ),
      );
    } else if (_hasRequested) {
      // ✅ 신청 완료 → 신청 취소 가능
      buttonWidget = ElevatedButton.icon(
        onPressed: _cancelRequest,
        icon: const Icon(Icons.cancel),
        label: const Text('신청 취소'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[200],
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
        ),
      );
    } else if (!(_companionData!['isClosed'] ?? false)) {
      // ✅ 신청 전 → 신청하기 가능
      buttonWidget = ElevatedButton.icon(
        onPressed: _requestJoin,
        icon: const Icon(Icons.group_add),
        label: const Text('참여 신청하기'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black54,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
        ),
      );
    } else {
      buttonWidget = const SizedBox.shrink();
    }



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
            _buildCompanionInfo(dateRange),
            const SizedBox(height: 16),

            // 💡 조건에 따른 참여 버튼 표시
            if (!_isLeader) buttonWidget,

            const SizedBox(height: 24),

            // ✅ 신청자 및 참여자 목록은 파티장일 경우에만
            // if (_isLeader) _buildRequestsAndParticipants(),
            if (_isParticipating || _isLeader) _buildParticipantsOnlySection(),

            const SizedBox(height: 24),

            // ✅ 댓글 섹션은 가장 아래에 위치
            _buildCommentSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsOnlySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('파티원 목록', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._participantList.map((user) => ListTile(
            title: Text('👤  ${user['userName']}'), // 닉네임만 표시
            trailing: const Icon(Icons.info_outline),
            onTap: () async {
              final userDetail = await _firestore.collection('users').doc(user['userId']).get();
              final detail = userDetail.data();
              if (detail != null) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('참여자 정보'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${detail['id'] ?? '없음'}'),
                        Text('성별: ${detail['gender'] ?? '모름'}'),
                        Text('나이: ${detail['age']?.toString() ?? '모름'}'),
                        Text('연락처: ${detail['contact'] ?? '미공개'}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('닫기'),
                      ),
                    ],
                  ),
                );
              }
            },
          )),
        ],
      ),
    );
  }


  Widget _buildCompanionInfo(String dateRange) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('companions').doc(widget.companionId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final currentCount = data['currentCount'] ?? 0;
        final maxCount = data['maxCount'] ?? 0;


        final ageConditionRaw = data['ageCondition'];
        String ageText = '연령 무관';

        if (ageConditionRaw is Map && ageConditionRaw['type'] == '범위') {
          final min = ageConditionRaw['min'] ?? '?';
          final max = ageConditionRaw['max'] ?? '?';
          ageText = '$min세 ~ $max세';
        } else if (ageConditionRaw is String) {
          ageText = ageConditionRaw;
        }



        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(data['title'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (data['isClosed'] ?? false) ? Colors.grey[300] : Colors.green[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      (data['isClosed'] ?? false) ? '모집 완료' : '모집 중',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: (data['isClosed'] ?? false) ? Colors.grey[600] : Colors.green[800],
                      ),
                    ),
                  ),

                  if (_isLeader || _isParticipating)
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await Navigator.push(context,
                            MaterialPageRoute(builder: (_) => EditCompanionScreen(companionId: widget.companionId)),
                          );
                          _loadData();
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
                        if (_isLeader)
                          PopupMenuItem(
                            value: 'toggle_close',
                            child: Text(_companionData!['isClosed'] ? '모집 재개' : '모집 마감'),
                          ),
                        if (!_isLeader && _isParticipating)
                          const PopupMenuItem(value: 'leave', child: Text('동행 참여 취소')),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 8),
              Text('📍 ${data['destination'] ?? '여행지 미정'}', style: const TextStyle(color: Colors.black87)),

              const SizedBox(height: 12),
              Text(data['content'] ?? '', style: const TextStyle(color: Colors.black87)),

              const SizedBox(height: 4),
              Text('🗓 $dateRange', style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              Text('👥 $currentCount / $maxCount', style: const TextStyle(color: Colors.black54)),




              // 모집 조건 표시
              Text('✅ 참여 조건: '
                  '${data['genderCondition'] ?? '무관'} / $ageText',
                style: const TextStyle(color: Colors.black87),
              ),



              const SizedBox(height: 12),
              Text('파티장: ${data['leaderName'] ?? ''}', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        );
      },
    );
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

      // 하위 컬렉션 삭제 (participants, comments, requests)
      final participantDocs = await docRef.collection('participants').get();
      for (final doc in participantDocs.docs) {
        await doc.reference.delete();
      }

      final commentDocs = await docRef.collection('comments').get();
      for (final doc in commentDocs.docs) {
        await doc.reference.delete();
      }

      final requestDocs = await docRef.collection('requests').get();
      for (final doc in requestDocs.docs) {
        await doc.reference.delete();
      }

      // 메인 companion 문서 삭제
      await docRef.delete();

      if (!mounted) return;
      Navigator.pop(context); // 현재 페이지 종료
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: ${e.toString()}')),
      );
    }
  }

  Future<void> _replyToComment(String commentId) async {
    final controller = _replyControllers[commentId];
    if (controller == null || controller.text.trim().isEmpty) return;

    try {
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('답변 등록 실패: ${e.toString()}')),
      );
    }
  }


  Widget _buildCommentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
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
                icon: const Icon(Icons.send, color: Colors.black54),
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
                  Text(comment['authorNickname'] ?? '알 수 없음', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(comment['text'] ?? ''),
                  const SizedBox(height: 8),
                  if ((comment['reply'] ?? '') != '')
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('답변: ${comment['reply']}', style: const TextStyle(color: Colors.blue)),
                    )
                  else if (_isLeader)
                    Column(
                      children: [
                        TextField(controller: controller, decoration: const InputDecoration(hintText: '답변을 입력하세요...')),
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
    );
  }

  // Widget _buildRequestsAndParticipants() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const SizedBox(height: 24),
  //       Container(
  //         padding: const EdgeInsets.all(16),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(12),
  //           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const Text('신청자 목록', style: TextStyle(fontWeight: FontWeight.bold)),
  //             const SizedBox(height: 8),
  //             if (_requests.isEmpty) const Text('현재 신청자가 없습니다.'),
  //             ..._requests.map((user) => ListTile(
  //               title: Text(user['userName'] ?? '알 수 없음'),
  //               subtitle: Text('ID: ${user['id']}'),
  //               trailing: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   IconButton(
  //                     icon: const Icon(Icons.check, color: Colors.green),
  //                     onPressed: () => _acceptRequest(user['id'], user['userName']),
  //                   ),
  //                   IconButton(
  //                     icon: const Icon(Icons.clear, color: Colors.red),
  //                     onPressed: () => _rejectRequest(user['id']),
  //                   ),
  //                 ],
  //               ),
  //             )),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(height: 24),
  //       Container(
  //         padding: const EdgeInsets.all(16),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(12),
  //           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const Text('참여자 목록', style: TextStyle(fontWeight: FontWeight.bold)),
  //             const SizedBox(height: 8),
  //             ..._participantList.map((user) => ListTile(
  //               title: Text(user['userName']), // 닉네임만 표시
  //               onTap: () async {
  //                 final userDoc = await _firestore.collection('users').doc(user['userId']).get();
  //                 final userInfo = userDoc.data();
  //
  //                 if (userInfo == null) return;
  //
  //                 showDialog(
  //                   context: context,
  //                   builder: (_) => AlertDialog(
  //                     title: const Text('참여자 정보'),
  //                     content: Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text('ID: ${userInfo['id']}'),
  //                         Text('성별: ${userInfo['gender'] ?? '미입력'}'),
  //                         Text('나이: ${userInfo['age'] ?? '미입력'}세'),
  //                         Text('연락처: ${userInfo['contact'] ?? '미입력'}'),
  //                       ],
  //                     ),
  //                     actions: [
  //                       TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기')),
  //                     ],
  //                   ),
  //                 );
  //               },
  //               trailing: _isLeader && !user['isLeader']
  //                   ? IconButton(
  //                 icon: const Icon(Icons.person_remove, color: Colors.red),
  //                 onPressed: () => _kickParticipant(user['userId']),
  //               )
  //                   : null,
  //             )),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
