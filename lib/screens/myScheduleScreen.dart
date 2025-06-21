import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'companionDetailScreen.dart';
import 'createPersonalScheduleScreen.dart';
import 'editPersonalScheduleScreen.dart';
import 'personalScheduleDetailScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

    // ──────────────────────────────────────────────────────────────────
    // context가 필요하므로 build 메소드 밖에서는 AppLocalizations.of(context)를 바로 쓸 수 없습니다.
    // 하지만 이 메소드에서 AppLocalizations를 사용하는 부분은 '제목 없음'인데,
    // 이는 이미 noTitle 키로 충분히 대체 가능하며, Firestore에서 데이터를 가져오는 부분이므로
    // 직접 appLocalizations를 참조할 필요가 적습니다.
    // '제목 없음'은 나중에 UI에 표시될 때 AppLocalizations.noTitle로 변환될 수 있습니다.
    // ──────────────────────────────────────────────────────────────────

    // 개인 일정 불러오기
    final personalSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .collection('personalSchedules')
        .get();

    for (var doc in personalSnap.docs) {
      final data = doc.data();
      final start = (data['startDate'] as Timestamp).toDate();
      final end = (data['endDate'] as Timestamp).toDate();

      for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
        final key = DateTime(d.year, d.month, d.day);
        events.putIfAbsent(key, () => []).add({
          ...data,
          'isCompanion': false,
          'scheduleDocId': doc.id,
        });
      }
    }

    // 참여한 동행 일정 불러오기
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

      final companionDoc =
      await FirebaseFirestore.instance.collection('companions').doc(companionId).get();
      final companionData = companionDoc.data();
      final title = companionData?['title'] ?? '제목 없음'; // 이 부분은 UI에 표시될 때 다국어 처리

      for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
        final key = DateTime(d.year, d.month, d.day);
        events.putIfAbsent(key, () => []).add({
          ...data,
          'isCompanion': true,
          'title': title,
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
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────

    final todayEvents = _getEventsForDay(_selectedDay!);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(appLocalizations.myTravelScheduleTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)), // 다국어 적용
        backgroundColor: Colors.grey[100],
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            tooltip: appLocalizations.addPersonalScheduleTooltip, // 새로운 키 추가
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreatePersonalScheduleScreen(userId: widget.currentUserId),
                ),
              );
              _loadSchedules();
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
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
              selectedTextStyle: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: todayEvents.isEmpty
                ? Center(child: Text(appLocalizations.noSchedulesForDate)) // 다국어 적용
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: todayEvents.length,
              itemBuilder: (context, index) {
                final sortedEvents = List<Map<String, dynamic>>.from(todayEvents)
                  ..sort((a, b) {
                    final aDate = (a['startDate'] ?? a['date']) as Timestamp;
                    final bDate = (b['startDate'] ?? b['date']) as Timestamp;
                    return aDate.compareTo(bDate);
                  });

                final event = sortedEvents[index];
                // '제목 없음' 대신 appLocalizations.noTitle 사용
                final actualTitle = event['title'] ?? appLocalizations.noTitle;
                final title = event['isCompanion'] ? appLocalizations.companionSchedulePrefix(actualTitle) : actualTitle; // 다국어 적용 및 동적 문자열 처리
                final subtitle = event['destination'] ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                  ),
                  child: ListTile(
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
                    onTap: () async {
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
                      } else {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PersonalScheduleDetailScreen(
                              userId: widget.currentUserId,
                              scheduleDocId: event['scheduleDocId'],
                            ),
                          ),
                        );
                        _loadSchedules();
                      }
                    },
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