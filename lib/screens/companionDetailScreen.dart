import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'editCompanionScreen.dart';
// ──────────────────────────────────────────────────────────────────
// AppLocalizations 임포트 추가
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// ──────────────────────────────────────────────────────────────────


class CompanionDetailScreen extends StatefulWidget {
  final String companionId;
  final String currentUserId;
  final String? currentUserNickname; // ◀️ 이 줄을 추가합니다.

  const CompanionDetailScreen({
    super.key,
    required this.companionId,
    required this.currentUserId,
    this.currentUserNickname, // ◀️ 이 줄을 추가합니다.
  });

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
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context); // nullable로 가져옴
    // ──────────────────────────────────────────────────────────────────
    try {
      final doc = await _firestore.collection('companions').doc(widget.companionId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _companionData = {
            'id': doc.id,
            'title': data['title'] ?? (appLocalizations?.noTitle ?? '제목 없음'), // 다국어 적용
            'destination': data['destination'] ?? (appLocalizations?.destinationUndecided ?? '여행지 미정'), // 다국어 적용
            'content': data['content'] ?? (appLocalizations?.noContent ?? '내용 없음'), // 다국어 적용
            'currentCount': data['currentCount'] ?? 1,
            'maxCount': data['maxCount'] ?? 4,
            'leaderId': data['leaderId'],
            'leaderNickname': data['leaderNickname'] ?? (appLocalizations?.unknown ?? '알 수 없음'), // 다국어 적용
            'startDate': (data['startDate'] as Timestamp).toDate(),
            'endDate': (data['endDate'] as Timestamp).toDate(),
            'isClosed': data['isClosed'] is bool ? data['isClosed'] : false,
            'createdAt': (data['createdAt'] as Timestamp).toDate(),
          };
          _isLeader = _companionData!['leaderId'] == widget.currentUserId;
          _isParticipating = _participantList.any((p) => p['id'] == widget.currentUserId);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations?.companionNotFound ?? '동행을 찾을 수 없습니다.'))); // 다국어 적용
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations?.companionLoadError(e.toString()) ?? '동행 로드 실패: $e'))); // 다국어 적용
        Navigator.pop(context);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadComments() async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context); // nullable로 가져옴
    // ──────────────────────────────────────────────────────────────────
    try {
      final snapshot = await _firestore
          .collection('companion_comments')
          .where('companionId', isEqualTo: widget.companionId)
          .orderBy('createdAt', descending: false)
          .get();

      setState(() {
        _comments = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final comment = {
            'id': doc.id,
            'authorId': data['authorId'] as String,
            'authorNickname': data['authorNickname'] as String? ?? (appLocalizations?.unknown ?? '알 수 없음'), // 다국어 적용
            'content': data['content'] as String,
            'createdAt': (data['createdAt'] as Timestamp).toDate(),
            'parentId': data['parentId'] as String?,
            'deleted': data['deleted'] as bool? ?? false,
          };
          _replyControllers[doc.id] = TextEditingController(); // 대댓글 컨트롤러 초기화
          return comment;
        }).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations?.commentsLoadError(e.toString()) ?? '댓글 로드 실패: $e'))); // 다국어 적용
      }
    }
  }

  Future<void> _loadRequests() async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context); // nullable로 가져옴
    // ──────────────────────────────────────────────────────────────────
    try {
      final doc = await _firestore.collection('companions').doc(widget.companionId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final List<dynamic> requests = data['requests'] ?? [];
        final List<dynamic> participants = data['participants'] ?? [];

        List<Map<String, dynamic>> fetchedRequests = [];
        for (String userId in requests) {
          final userDoc = await _firestore.collection('users').doc(userId).get();
          if (userDoc.exists) {
            fetchedRequests.add({
              'id': userId,
              'userName': (userDoc.data() as Map<String, dynamic>)['nickname'] ?? (appLocalizations?.unknown ?? '알 수 없음'), // 다국어 적용
            });
          }
        }

        setState(() {
          _requests = fetchedRequests;
          _hasRequested = requests.contains(widget.currentUserId) && !participants.contains(widget.currentUserId);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations?.requestsLoadError(e.toString()) ?? '신청자 목록 로드 실패: $e'))); // 다국어 적용
      }
    }
  }

  Future<void> _loadParticipants() async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context); // nullable로 가져옴
    // ──────────────────────────────────────────────────────────────────
    try {
      final doc = await _firestore.collection('companions').doc(widget.companionId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final List<dynamic> participants = data['participants'] ?? [];

        List<Map<String, dynamic>> fetchedParticipants = [];
        for (String userId in participants) {
          final userDoc = await _firestore.collection('users').doc(userId).get();
          if (userDoc.exists) {
            fetchedParticipants.add({
              'id': userId,
              'userName': (userDoc.data() as Map<String, dynamic>)['nickname'] ?? (appLocalizations?.unknown ?? '알 수 없음'), // 다국어 적용
            });
          }
        }

        setState(() {
          _participantList = fetchedParticipants;
          _isParticipating = _participantList.any((p) => p['id'] == widget.currentUserId);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations?.participantsLoadError(e.toString()) ?? '참여자 목록 로드 실패: $e'))); // 다국어 적용
      }
    }
  }


  Future<void> _applyForCompanion() async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    if (_companionData == null || _companionData!['isClosed'] || _companionData!['currentCount'] >= _companionData!['maxCount']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.companionApplicationNotPossible))); // 다국어 적용
      return;
    }
    try {
      await _firestore.collection('companions').doc(widget.companionId).update({
        'requests': FieldValue.arrayUnion([widget.currentUserId])
      });
      setState(() {
        _hasRequested = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.applicationSentSuccess))); // 다국어 적용
      }
      _loadRequests(); // 신청자 목록 새로고침
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.applicationSendError(e.toString())))); // 다국어 적용
      }
    }
  }

  Future<void> _cancelApplication() async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    try {
      await _firestore.collection('companions').doc(widget.companionId).update({
        'requests': FieldValue.arrayRemove([widget.currentUserId])
      });
      setState(() {
        _hasRequested = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.applicationCancelledSuccess))); // 다국어 적용
      }
      _loadRequests(); // 신청자 목록 새로고침
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.applicationCancelError(e.toString())))); // 다국어 적용
      }
    }
  }


  Future<void> _addComment([String? parentId]) async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    final controller = parentId == null ? _commentController : _replyControllers[parentId];
    if (controller == null || controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.emptyCommentWarning))); // 다국어 적용
      return;
    }

    try {
      await _firestore.collection('companion_comments').add({
        'companionId': widget.companionId,
        'authorId': widget.currentUserId,
        'authorNickname': widget.currentUserNickname ?? widget.currentUserId,
        'content': controller.text.trim(),
        'createdAt': Timestamp.now(),
        'parentId': parentId,
        'deleted': false,
      });
      controller.clear();
      _loadComments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.commentAddedSuccess))); // 다국어 적용
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.commentAddFailed(e.toString())))); // 다국어 적용
      }
    }
  }

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
      // 대댓글이 없는 경우에만 삭제 (실제 삭제)
      // 대댓글이 있는 경우 content를 "삭제된 댓글입니다"로 변경
      final replySnapshot = await _firestore
          .collection('companion_comments')
          .where('parentId', isEqualTo: commentId)
          .get();

      if (replySnapshot.docs.isEmpty) {
        await _firestore.collection('companion_comments').doc(commentId).delete();
      } else {
        await _firestore.collection('companion_comments').doc(commentId).update({
          'content': appLocalizations.deletedComment, // 다국어 적용
          'deleted': true,
        });
      }

      _loadComments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.commentDeletedSuccess))); // 다국어 적용
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.commentDeleteFailed(e.toString())))); // 다국어 적용
      }
    }
  }

  Future<void> _editComment(String commentId, String currentContent) async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    final TextEditingController editController = TextEditingController(text: currentContent);

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appLocalizations.editCommentTitle), // 다국어 적용
          content: TextField(
            controller: editController,
            decoration: InputDecoration(hintText: appLocalizations.editCommentHint), // 다국어 적용
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(appLocalizations.cancelButton), // 다국어 적용 (재사용)
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(appLocalizations.saveButton), // 다국어 적용
            ),
          ],
        );
      },
    );

    if (confirm == true && editController.text.trim().isNotEmpty) {
      try {
        await _firestore.collection('companion_comments').doc(commentId).update({
          'content': editController.text.trim(),
          'createdAt': Timestamp.now(), // 수정 시간 업데이트 (선택 사항)
        });
        _loadComments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.commentEditedSuccess))); // 다국어 적용
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.commentEditFailed(e.toString())))); // 다국어 적용
        }
      }
    } else if (confirm == true && editController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.emptyCommentWarning))); // 다국어 적용 (재사용)
      }
    }
  }


  Future<void> _acceptRequest(String userId, String userName) async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    if (_companionData == null || _companionData!['isClosed']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.recruitmentClosedWarning))); // 다국어 적용
      return;
    }
    if (_companionData!['currentCount'] >= _companionData!['maxCount']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.maxParticipantsReached))); // 다국어 적용
      return;
    }

    try {
      final docRef = _firestore.collection('companions').doc(widget.companionId);
      await _firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);
        final currentData = docSnapshot.data() as Map<String, dynamic>;
        final currentParticipants = List<String>.from(currentData['participants'] ?? []);
        final currentRequests = List<String>.from(currentData['requests'] ?? []);
        final currentCount = currentData['currentCount'] ?? 1;

        if (!currentParticipants.contains(userId) && currentCount < currentData['maxCount']) {
          currentParticipants.add(userId);
          currentRequests.remove(userId);
          transaction.update(docRef, {
            'participants': currentParticipants,
            'requests': currentRequests,
            'currentCount': currentCount + 1,
            'isClosed': (currentCount + 1 >= currentData['maxCount'])
          });
        }
      });
      _loadData();
      _loadRequests();
      _loadParticipants();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.participantAcceptedSuccess(userName)))); // 다국어 적용
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.acceptRequestFailed(e.toString())))); // 다국어 적용
      }
    }
  }

  Future<void> _rejectRequest(String userId) async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    try {
      await _firestore.collection('companions').doc(widget.companionId).update({
        'requests': FieldValue.arrayRemove([userId])
      });
      _loadRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.requestRejectedSuccess))); // 다국어 적용
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.rejectRequestFailed(e.toString())))); // 다국어 적용
      }
    }
  }

  Future<void> _leaveCompanion() async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appLocalizations.leaveCompanionTitle), // 다국어 적용
          content: Text(appLocalizations.confirmLeaveCompanion), // 다국어 적용
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(appLocalizations.cancelButton), // 다국어 적용 (재사용)
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(appLocalizations.leaveButton), // 다국어 적용
            ),
          ],
        );
      },
    ) ?? false;

    if (!confirm) return;

    try {
      final docRef = _firestore.collection('companions').doc(widget.companionId);
      await _firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);
        final currentData = docSnapshot.data() as Map<String, dynamic>;
        final currentParticipants = List<String>.from(currentData['participants'] ?? []);
        final currentCount = currentData['currentCount'] ?? 1;

        if (currentParticipants.contains(widget.currentUserId)) {
          currentParticipants.remove(widget.currentUserId);
          transaction.update(docRef, {
            'participants': currentParticipants,
            'currentCount': currentCount - 1,
            'isClosed': false, // 인원이 줄면 모집 마감 해제
          });
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.leftCompanionSuccess))); // 다국어 적용
      }
      Navigator.pop(context, true); // 목록 화면으로 돌아가기
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.leaveCompanionFailed(e.toString())))); // 다국어 적용
      }
    }
  }

  Future<void> _deleteCompanion() async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appLocalizations.deleteCompanionTitle), // 다국어 적용
          content: Text(appLocalizations.confirmDeleteCompanion), // 다국어 적용
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
      await _firestore.collection('companions').doc(widget.companionId).delete();
      // 관련 댓글도 삭제
      final commentsSnapshot = await _firestore
          .collection('companion_comments')
          .where('companionId', isEqualTo: widget.companionId)
          .get();
      for (var doc in commentsSnapshot.docs) {
        await doc.reference.delete();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.companionDeletedSuccess))); // 다국어 적용
      }
      Navigator.pop(context, true); // 동행 목록으로 돌아감
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.companionDeleteFailed(e.toString())))); // 다국어 적용
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(appLocalizations.loadingText)), // 다국어 적용
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_companionData == null) {
      return Scaffold(
        appBar: AppBar(title: Text(appLocalizations.errorText)), // 다국어 적용
        body: Center(child: Text(appLocalizations.companionDataNotFound)), // 다국어 적용
      );
    }

    final dateFormat = DateFormat('yyyy.MM.dd');
    final dateRange = '${dateFormat.format(_companionData!['startDate'])} ~ ${dateFormat.format(_companionData!['endDate'])}';

    return Scaffold(
      appBar: AppBar(
        title: Text(_companionData!['title']),
        actions: [
          if (_isLeader)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: appLocalizations.editButton, // 다국어 적용 (재사용)
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditCompanionScreen(
                      companionId: widget.companionId,
                      companionData: _companionData!,
                    ),
                  ),
                );
                if (result == true) {
                  _loadData();
                }
              },
            ),
          if (_isLeader)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: appLocalizations.deleteButton, // 다국어 적용 (재사용)
              onPressed: _deleteCompanion,
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _companionData!['title'],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  appLocalizations.destinationPrefix(_companionData!['destination']), // 다국어 적용
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(Icons.person, appLocalizations.leaderLabel, _companionData!['leaderNickname']), // 다국어 적용
                        _buildInfoRow(Icons.groups, appLocalizations.participantsLabel, '${_companionData!['currentCount']} / ${_companionData!['maxCount']}'), // 다국어 적용
                        _buildInfoRow(Icons.calendar_today, appLocalizations.periodLabel, dateRange), // 다국어 적용
                        if (_companionData!['isClosed'])
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(appLocalizations.recruitmentClosed, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), // 다국어 적용 (재사용)
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  appLocalizations.contentLabel, // 다국어 적용
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_companionData!['content']),
                ),
                if (_isLeader) _buildRequestsAndParticipants(), // 리더에게만 보여지는 신청자 및 참여자 목록
                const SizedBox(height: 24),
                _buildParticipantsList(),
                const SizedBox(height: 24),
                _buildCommentsSection(), // 댓글 섹션
                const SizedBox(height: 80), // 하단 댓글 입력창 때문에 스크롤 가능하게 여유 공간 확보
              ],
            ),
          ),
          _buildCommentInputField(), // 댓글 입력창
        ],
      ),
      bottomNavigationBar: _isLeader
          ? null // 리더는 하단 버튼 없음
          : Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isParticipating)
              ElevatedButton(
                onPressed: _leaveCompanion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(appLocalizations.leaveCompanionButton), // 다국어 적용
              )
            else if (_hasRequested)
              ElevatedButton(
                onPressed: _cancelApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(appLocalizations.cancelApplicationButton), // 다국어 적용
              )
            else
              ElevatedButton(
                onPressed: _applyForCompanion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(appLocalizations.applyForCompanionButton), // 다국어 적용
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsAndParticipants() {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(appLocalizations.applicantsListTitle, style: const TextStyle(fontWeight: FontWeight.bold)), // 다국어 적용
              const SizedBox(height: 8),
              if (_requests.isEmpty) Text(appLocalizations.noApplicants), // 다국어 적용
              ..._requests.map((user) => ListTile(
                title: Text(user['userName'] ?? appLocalizations.unknown), // 다국어 적용 (재사용)
                subtitle: Text('ID: ${user['id']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => _acceptRequest(user['id'], user['userName']),
                      tooltip: appLocalizations.acceptButton, // 다국어 적용
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: () => _rejectRequest(user['id']),
                      tooltip: appLocalizations.rejectButton, // 다국어 적용
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildParticipantsList() {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(appLocalizations.participantsSectionTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // 다국어 적용
        const SizedBox(height: 8),
        if (_participantList.isEmpty) Text(appLocalizations.noParticipants), // 다국어 적용
        ..._participantList.map((user) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              Text(user['userName'] ?? appLocalizations.unknown), // 다국어 적용 (재사용)
              if (user['id'] == _companionData!['leaderId'])
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(appLocalizations.leaderLabel, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)), // 다국어 적용 (재사용)
                ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildCommentsSection() {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    final Map<String, List<Map<String, dynamic>>> groupedComments = {};
    for (var comment in _comments) {
      if (comment['parentId'] == null) {
        groupedComments[comment['id']] = [];
      }
    }
    for (var comment in _comments) {
      if (comment['parentId'] != null && groupedComments.containsKey(comment['parentId'])) {
        groupedComments[comment['parentId']]!.add(comment);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(appLocalizations.commentsSectionTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // 다국어 적용
        const SizedBox(height: 12),
        if (_comments.isEmpty)
          Center(child: Text(appLocalizations.noCommentsYet)), // 다국어 적용
        ...groupedComments.keys.map((commentId) {
          final comment = _comments.firstWhere((c) => c['id'] == commentId);
          final replies = groupedComments[commentId]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCommentItem(comment, isReply: false),
              ...replies.map((reply) => Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: _buildCommentItem(reply, isReply: true),
              )),
              if (!comment['deleted'])
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                  child: TextButton(
                    onPressed: () => _addReply(commentId),
                    child: Text(appLocalizations.replyButton), // 다국어 적용
                  ),
                ),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment, {required bool isReply}) {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    final formattedDate = DateFormat('yyyy.MM.dd HH:mm').format(comment['createdAt']);
    return Card(
      margin: EdgeInsets.only(bottom: 8.0, left: isReply ? 0 : 0),
      elevation: 1,
      color: isReply ? Colors.blueGrey[50] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    comment['authorNickname'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (comment['authorId'] == widget.currentUserId && !comment['deleted'])
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editComment(comment['id'], comment['content']);
                      } else if (value == 'delete') {
                        _deleteComment(comment['id']);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Text(appLocalizations.editButton), // 다국어 적용 (재사용)
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text(appLocalizations.deleteButton), // 다국어 적용 (재사용)
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment['content']),
            if (comment['deleted'])
              Text(
                appLocalizations.deletedCommentIndicator, // 다국어 적용
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            if (isReply && !comment['deleted'])
              TextField(
                controller: _replyControllers[comment['id']],
                decoration: InputDecoration(
                  hintText: appLocalizations.replyHint, // 다국어 적용
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (value) => _addComment(comment['parentId'] ?? comment['id']),
              ),
          ],
        ),
      ),
    );
  }

  void _addReply(String parentId) {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appLocalizations.writeReplyTitle), // 다국어 적용
          content: TextField(
            controller: _replyControllers[parentId],
            decoration: InputDecoration(hintText: appLocalizations.replyContentHint), // 다국어 적용
            maxLines: 3,
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
                _addComment(parentId);
                Navigator.of(context).pop();
              },
              child: Text(appLocalizations.writeButton), // 다국어 적용 (재사용)
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommentInputField() {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.white,
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: appLocalizations.commentInputHint, // 다국어 적용
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addComment,
                child: Text(appLocalizations.addCommentButton), // 다국어 적용
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}