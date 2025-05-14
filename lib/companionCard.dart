import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompanionCard extends StatelessWidget {
  final String destination;
  final String content;
  final int currentCount;
  final int maxCount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isClosed;

  const CompanionCard({
    super.key,
    required this.destination,
    required this.content,
    required this.currentCount,
    required this.maxCount,
    required this.startDate,
    required this.endDate,
    required this.isClosed, required title,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy.MM.dd');
    final dateRange = '${dateFormat.format(startDate)} ~ ${dateFormat.format(endDate)}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.groups, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      destination,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text('$currentCount / $maxCount', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(dateRange, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 10),
                Text(content, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
          if (isClosed)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: const Text(
                  '모집 마감',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
