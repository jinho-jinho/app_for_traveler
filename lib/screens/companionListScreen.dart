import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'companionDetailScreen.dart';
import 'createCompanionScreen.dart';

class CompanionListScreen extends StatefulWidget {
  final String currentUserId;

  const CompanionListScreen({super.key, required this.currentUserId});

  @override
  State<CompanionListScreen> createState() => _CompanionListScreenState();
}

class _CompanionListScreenState extends State<CompanionListScreen> {
  bool _showOnlyOpen = false;

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
                    activeColor: Colors.black, // 스위치가 켜졌을 때 thumb 색상
                    inactiveThumbColor: Colors.grey, // 꺼졌을 때 thumb 색상
                    inactiveTrackColor: Colors.grey.shade300, // 꺼졌을 때 트랙 색상
                    onChanged: (val) {
                      setState(() => _showOnlyOpen = val);
                    },
                  )
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('companions')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;

                final companions = docs.map((doc) {
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

                if (companions.isEmpty) {
                  return const Center(child: Text('현재 등록된 동행이 없습니다.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  itemCount: companions.length,
                  itemBuilder: (context, index) {
                    final c = companions[index];
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
