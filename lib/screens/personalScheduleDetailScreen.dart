import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'editPersonalScheduleScreen.dart';

class PersonalScheduleDetailScreen extends StatefulWidget {
  final String userId;
  final String scheduleDocId;

  const PersonalScheduleDetailScreen({
    super.key,
    required this.userId,
    required this.scheduleDocId,
  });

  @override
  State<PersonalScheduleDetailScreen> createState() => _PersonalScheduleDetailScreenState();
}

class _PersonalScheduleDetailScreenState extends State<PersonalScheduleDetailScreen> {
  Map<String, dynamic>? _scheduleData;
  bool _isLoading = true;

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('personalSchedules')
          .doc(widget.scheduleDocId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _scheduleData = {
            ...data,
            'startDate': (data['startDate'] as Timestamp).toDate(),
            'endDate': (data['endDate'] as Timestamp).toDate(),
          };
        });
      } else {
        // 문서가 없으면 뒤로가기
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('불러오기 실패: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSchedule() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('일정 삭제'),
        content: const Text('정말 이 일정을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('personalSchedules')
          .doc(widget.scheduleDocId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('일정이 삭제되었습니다.')));
        Navigator.pop(context, true); // 삭제 후 이전 화면으로 true 반환
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('개인 일정 상세'),
        backgroundColor: Colors.grey[100],
        actions: _scheduleData == null
            ? null
            : [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'edit') {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditPersonalScheduleScreen(
                      userId: widget.userId,
                      scheduleDocId: widget.scheduleDocId,
                    ),
                  ),
                );
                if (result == true) {
                  _loadSchedule();
                }
              } else if (value == 'delete') {
                await _deleteSchedule();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('수정'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _scheduleData == null
          ? const Center(child: Text('일정을 불러올 수 없습니다.'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _scheduleData!['title'] ?? '',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '📍: ${_scheduleData!['destination'] ?? ''}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '🗓️: ${DateFormat('yyyy.MM.dd').format(_scheduleData!['startDate'])} - ${DateFormat('yyyy.MM.dd').format(_scheduleData!['endDate'])}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '부가 설명: ',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              _scheduleData!['description'] ?? '없음',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}