import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'companionDetailScreen.dart';
import 'createCompanionScreen.dart';
import '../companionCard.dart';

class CompanionListScreen extends StatefulWidget {
  final String currentUserId; // 🔥 Firestore user ID 전달받기

  const CompanionListScreen({super.key, required this.currentUserId});

  @override
  State<CompanionListScreen> createState() => _CompanionListScreenState();
}

class _CompanionListScreenState extends State<CompanionListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _companions = [];
  bool _showOnlyOpen = false;

  @override
  void initState() {
    super.initState();
    _fetchCompanions();
  }

  Future<void> _fetchCompanions() async {
    try {
      Query query = _firestore.collection('companions').orderBy('createdAt', descending: true);

      final snapshot = await query.get();
      final data = snapshot.docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'title': d['title'] ?? '제목 없음',
          'destination': d['destination'] ?? '여행지 미정',
          'content': d['content'] ?? '',
          'currentCount': d['currentCount'] ?? 0,
          'maxCount': d['maxCount'] ?? 0,
          'startDate': (d['startDate'] as Timestamp).toDate(),
          'endDate': (d['endDate'] as Timestamp).toDate(),
          'isClosed': d['isClosed'] ?? false,
        };
      }).where((item) => !_showOnlyOpen || !(item['isClosed'] ?? true)).toList();

      setState(() => _companions = data);
    } catch (e) {
      print('🔥 동행 목록 로드 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('전체 동행 목록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '동행 등록',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateCompanionScreen(currentUserId: widget.currentUserId),
                ),
              ).then((_) => _fetchCompanions());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          CheckboxListTile(
            title: const Text('모집 중인 동행만 보기'),
            value: _showOnlyOpen,
            onChanged: (val) {
              setState(() {
                _showOnlyOpen = val ?? false;
              });
              _fetchCompanions();
            },
          ),
          Expanded(
            child: _companions.isEmpty
                ? const Center(child: Text('현재 등록된 동행이 없습니다.'))
                : ListView.builder(
              itemCount: _companions.length,
              itemBuilder: (context, index) {
                final c = _companions[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CompanionDetailScreen(
                          companionId: c['id'],
                          currentUserId: widget.currentUserId,
                        ),
                      ),
                    );
                  },
                  child: CompanionCard(
                    title: c['title'],
                    destination: c['destination'],
                    content: c['content'],
                    currentCount: c['currentCount'],
                    maxCount: c['maxCount'],
                    startDate: c['startDate'],
                    endDate: c['endDate'],
                    isClosed: c['isClosed'],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}