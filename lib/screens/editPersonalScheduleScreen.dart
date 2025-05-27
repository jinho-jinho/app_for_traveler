import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditPersonalScheduleScreen extends StatefulWidget {
  final String userId;
  final String scheduleDocId;

  const EditPersonalScheduleScreen({super.key, required this.userId, required this.scheduleDocId});

  @override
  State<EditPersonalScheduleScreen> createState() => _EditPersonalScheduleScreenState();
}

class _EditPersonalScheduleScreenState extends State<EditPersonalScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _memoController = TextEditingController();
  final _destinationController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadScheduleData();
  }

  Future<void> _loadScheduleData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('personalSchedules')
        .doc(widget.scheduleDocId)
        .get();

    if (!doc.exists) return;
    final data = doc.data()!;
    setState(() {
      _titleController.text = data['title'] ?? '';
      _memoController.text = data['description'] ?? '';
      _destinationController.text = data['destination'] ?? '';
      _startDate = (data['startDate'] as Timestamp).toDate();
      _endDate = (data['endDate'] as Timestamp).toDate();
    });
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? now),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked;
        else _endDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('날짜를 모두 선택하세요.')));
      return;
    }

    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('출발일은 도착일 이전이어야 합니다.')));
      return;
    }

    setState(() => _isLoading = true);


    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('personalSchedules')
          .doc(widget.scheduleDocId)
          .update({
        'title': _titleController.text.trim(),
        'description': _memoController.text.trim(),
        'destination': _destinationController.text.trim(),
        'startDate': Timestamp.fromDate(_startDate!),
        'endDate': Timestamp.fromDate(_endDate!),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('수정 실패: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('개인 일정 수정')),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목 *',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (val) => val == null || val.isEmpty ? '제목을 입력하세요' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: '여행지 *',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (val) => val == null || val.isEmpty ? '여행지를 입력하세요' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _memoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '부가 설명',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(true),
                      child: Text(
                        _startDate == null
                            ? '출발일 선택'
                            : '출발일: ${DateFormat('yyyy.MM.dd').format(_startDate!)}',
                        style: TextStyle(color: Colors.grey[100]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(false),
                      child: Text(
                        _endDate == null
                            ? '도착일 선택'
                            : '도착일: ${DateFormat('yyyy.MM.dd').format(_endDate!)}',
                        style: TextStyle(color: Colors.grey[100]),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300], // 연한 회색
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('취소', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700], // 진한 회색
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _save,
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Text('저장', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
