import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'companionDetailScreen.dart';
import 'createCompanionScreen.dart';
import '../companionCard.dart';

class CompanionListScreen extends StatefulWidget {
  final String currentUserId;

  const CompanionListScreen({super.key, required this.currentUserId});

  @override
  State<CompanionListScreen> createState() => _CompanionListScreenState();
}

class _CompanionListScreenState extends State<CompanionListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _companions = [];
  bool _showOnlyOpen = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCompanions();
  }

  Future<void> _fetchCompanions() async {
    setState(() => _loading = true);
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

      setState(() {
        _companions = data;
        _loading = false;
      });
    } catch (e) {
      print('🔥 동행 목록 로드 실패: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: const Text('동행 찾기', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '동행 등록',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateCompanionScreen(currentUserId: widget.currentUserId),
                ),
              );
              _fetchCompanions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.filter_alt_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('모집 중인 동행만 보기'),
                    value: _showOnlyOpen,
                    onChanged: (val) {
                      setState(() => _showOnlyOpen = val);
                      _fetchCompanions();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _companions.isEmpty
                ? const Center(child: Text('현재 등록된 동행이 없습니다.'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          children: [
                            Expanded(
                              child: Text(
                                c['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: c['isClosed'] ? Colors.grey[300] : Colors.green[100],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                c['isClosed'] ? '모집 완료' : '모집 중',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: c['isClosed'] ? Colors.grey[600] : Colors.green[800],
                                ),
                              ),
                            ),

                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '📍 ${c['destination']}',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c['content'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '🗓 ${DateFormat('MM/dd').format(c['startDate'])} ~ ${DateFormat('MM/dd').format(c['endDate'])}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              '👥 ${c['currentCount']}/${c['maxCount']}명',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        )
                      ],
                    ),
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
