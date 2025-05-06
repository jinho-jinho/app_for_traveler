import 'package:flutter/material.dart';
import 'package:app_for_traveler/screens/postDetailScreen.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
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

  String _formatTimestamp(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return DateFormat('yyyy-MM-dd HH:mm').format(time);
  }

  List<Map<String, dynamic>> _mergeAndSortNotifications() {
    final all = [
      for (final e in disasterAlerts) {'type': 'disaster', ...e},
      for (final e in commentAlerts) {'type': 'comment', ...e},
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
      appBar: AppBar(title: const Text('알림')),
      body: allNotifications.isEmpty
          ? const Center(child: Text('알림이 없습니다.'))
          : ListView.builder(
              itemCount: allNotifications.length,
              itemBuilder: (context, index) {
                final notif = allNotifications[index];
                final isDisaster = notif['type'] == 'disaster';
                final timestamp = notif['timestamp'] as DateTime?;

                return ListTile(
                  leading: Icon(
                    isDisaster ? Icons.warning : Icons.comment,
                    color: isDisaster ? Colors.red : Colors.blue,
                  ),
                  title: Text(
                    isDisaster
                        ? (notif['message'] ?? '알 수 없는 재난 메시지')
                        : '${notif['nickname'] ?? '누군가'}님이 댓글을 남겼습니다',
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
                                currentUserId: currentUserId,
                                currentUserNickname: currentUserNickname,
                              ),
                            ),
                          );
                        },
                );
              },
            ),
    );
  }
}
