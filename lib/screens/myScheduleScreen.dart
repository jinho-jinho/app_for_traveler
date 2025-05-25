import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'companionDetailScreen.dart';
import 'createPersonalScheduleScreen.dart';

class MyScheduleScreen extends StatefulWidget {
  final String currentUserId;

  const MyScheduleScreen({super.key, required this.currentUserId});

  @override
  State<MyScheduleScreen> createState() => _MyScheduleScreenState();
}

class _MyScheduleScreenState extends State<MyScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final events = <DateTime, List<Map<String, dynamic>>>{};

    // 🔹 1. 개인 일정 (startDate ~ endDate)
    final personalSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .collection('personalSchedules')
        .get();

    for (var doc in personalSnap.docs) {
      final data = doc.data();
      final start = (data['startDate'] as Timestamp).toDate();
      final end = (data['endDate'] as Timestamp).toDate();

      for (var d = start;
      !d.isAfter(end);
      d = d.add(const Duration(days: 1))) {
        final key = DateTime(d.year, d.month, d.day);
        events.putIfAbsent(key, () => []).add({
          ...data,
          'isCompanion': false,
        });
      }
    }

    // 🔹 2. 참여한 동행 일정 (joinedCompanions 기준)
    final joinedSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .collection('joinedCompanions')
        .get();

    for (var doc in joinedSnap.docs) {
      final data = doc.data();
      final start = (data['startDate'] as Timestamp).toDate();
      final end = (data['endDate'] as Timestamp).toDate();
      final companionId = data['companionId'];

      // 🔸 companionId로 companions에서 title 가져오기
      final companionDoc = await FirebaseFirestore.instance.collection('companions').doc(companionId).get();
      final companionData = companionDoc.data();
      final title = companionData?['title'] ?? '제목 없음';

      for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
        final key = DateTime(d.year, d.month, d.day);
        events.putIfAbsent(key, () => []).add({
          ...data,
          'isCompanion': true,
          'title': title, // 🔸 여기서 title 저장
          'companionId': companionId,
        });
      }
    }



    setState(() {
      _events = events;
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _events[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final todayEvents = _getEventsForDay(_selectedDay!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 여행 스케줄'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CreatePersonalScheduleScreen(userId: widget.currentUserId),
                ),
              );
              _loadSchedules(); // 새로고침
            },
          )
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2023),
            lastDay: DateTime(2030),
            calendarFormat: CalendarFormat.month,
            headerStyle: const HeaderStyle(formatButtonVisible: false),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: todayEvents.isEmpty
                ? const Center(child: Text('해당 날짜에 등록된 일정이 없습니다.'))
                : ListView(
              children: () {
                final sortedEvents =
                List<Map<String, dynamic>>.from(todayEvents);
                sortedEvents.sort((a, b) {
                  final aDate = (a['startDate'] ?? a['date']) as Timestamp;
                  final bDate = (b['startDate'] ?? b['date']) as Timestamp;
                  return aDate.compareTo(bDate);
                });
                return sortedEvents.map((event) {
                  final title = event['isCompanion'] ? '[동행] ${event['title']}' : event['title'];
                  final subtitle = event['destination'] ?? '';
                  return ListTile(
                    title: Text(title),
                    subtitle: Text(subtitle),
                    onTap: () {
                      if (event['isCompanion']) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CompanionDetailScreen(
                              companionId: event['companionId'],
                              currentUserId: widget.currentUserId,
                            ),
                          ),
                        );
                      }
                    },
                  );
                }).toList();
              }(),
            ),
          ),
        ],
      ),
    );
  }
}
