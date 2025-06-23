import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompanionCard extends StatelessWidget {
  final String title;
  final String destination;
  final String content;
  final int currentCount;
  final int maxCount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isClosed;

  const CompanionCard({
    super.key,
    required this.title,
    required this.destination,
    required this.content,
    required this.currentCount,
    required this.maxCount,
    required this.startDate,
    required this.endDate,
    required this.isClosed,
  });

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MM/dd');
    final dateRange = '${dateFmt.format(startDate)} ~ ${dateFmt.format(endDate)}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 + 모집 상태
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isClosed ? Colors.grey[300] : Colors.green[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isClosed ? '모집 완료' : '모집 중',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isClosed ? Colors.grey[600] : Colors.green[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // 목적지
            Text(
              '📍 $destination',
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 6),

            // 내용
            Text(
              content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 10),

            // 날짜 + 인원수
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🗓 $dateRange',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '👥 $currentCount/$maxCount명',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
