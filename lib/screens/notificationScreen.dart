import 'package:flutter/material.dart';
import 'package:app_for_traveler/screens/postDetailScreen.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  final List<Map<String, dynamic>> disasterAlerts;
  final List<Map<String, dynamic>> commentAlerts;
  final String currentUserId;
  final String? currentUserNickname;

  const NotificationScreen({
    super.key,
    required this.disasterAlerts,
    required this.commentAlerts,
    required this.currentUserId,
    required this.currentUserNickname,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _formatTimestamp(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return DateFormat('yyyy-MM-dd HH:mm').format(time);
  }

  List<Map<String, dynamic>> _mergeAndSortNotifications() {
    final all = [
      for (final e in widget.disasterAlerts) {'type': 'disaster', ...e},
      for (final e in widget.commentAlerts) {'type': 'comment', ...e},
    ];

    all.sort((a, b) {
      final aTime = a['timestamp'] as DateTime?;
      final bTime = b['timestamp'] as DateTime?;
      return (bTime ?? DateTime(0)).compareTo(aTime ?? DateTime(0));
    });

    return all;
  }

  @override
  Widget build(BuildContext context) {
    final allNotifications = _mergeAndSortNotifications();

    return Scaffold(
      backgroundColor: Colors.grey[100],  // MyPageScreen과 동일한 배경
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Row(
          children: [
            Icon(Icons.notifications_none, color: Colors.black87),
            SizedBox(width: 8),
            Text(
              '알림',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      body: allNotifications.isEmpty
          ? const Center(child: Text('No notifications available.'))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: allNotifications.length,
          itemBuilder: (context, index) {
            final notif = allNotifications[index];
            final isDisaster = notif['type'] == 'disaster';
            final timestamp = notif['timestamp'] as DateTime?;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
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
              child: ListTile(
                leading: Icon(
                  isDisaster ? Icons.warning : Icons.comment,
                  color: isDisaster ? Colors.red : Colors.blue,
                ),
                title: Text(
                  isDisaster
                      ? ((notif['message']?.toString().trim().isNotEmpty ?? false)
                      ? notif['message']
                      : notif['msg'] ?? '📢 재난 메시지 수신 (내용 없음)')
                      : '${notif['nickname'] ?? 'Someone'} commented on your post',
                ),

                subtitle: Text(
                  _formatTimestamp(timestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: isDisaster
                    ? null
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(
                        postId: notif['postId'],
                        title: notif['postTitle'],
                        content: notif['postContent'],
                        authorId: notif['postAuthorId'],
                        authorNickname: notif['postAuthorNickname'],
                        createdAt: notif['postCreatedAt'],
                        currentUserId: widget.currentUserId,
                        currentUserNickname: widget.currentUserNickname,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),

    );
  }
}