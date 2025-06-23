import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'editPersonalScheduleScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final appLocalizations = AppLocalizations.of(context)!;

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.loadFailed(e.toString())))); // 다국어 적용
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSchedule() async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(appLocalizations.deleteScheduleTitle), // 다국어 적용
        content: Text(appLocalizations.confirmDeleteSchedule), // 다국어 적용
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(appLocalizations.cancelButton)), // 다국어 적용 (재사용)
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(appLocalizations.deleteButton, style: const TextStyle(color: Colors.red))), // 다국어 적용
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.scheduleDeleted))); // 다국어 적용
        Navigator.pop(context, true); // 삭제 후 이전 화면으로 true 반환
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.deleteFailed(e.toString())))); // 다국어 적용
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
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.personalScheduleDetailTitle), // 다국어 적용
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
              PopupMenuItem(
                value: 'edit',
                child: Text(appLocalizations.editButton), // 다국어 적용
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(appLocalizations.deleteButton, style: const TextStyle(color: Colors.red)), // 다국어 적용
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _scheduleData == null
          ? Center(child: Text(appLocalizations.cannotLoadSchedule)) // 다국어 적용
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
              '📍: ${_scheduleData!['destination'] ?? ''}', // 이모지는 유지
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '🗓️: ${DateFormat('yyyy.MM.dd').format(_scheduleData!['startDate'])} - ${DateFormat('yyyy.MM.dd').format(_scheduleData!['endDate'])}', // 이모지는 유지
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              appLocalizations.additionalDescriptionPrefix, // 다국어 적용
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              _scheduleData!['description'] ?? appLocalizations.none, // 다국어 적용
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}