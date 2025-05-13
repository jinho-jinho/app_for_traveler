import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateCompanionScreen extends StatefulWidget {
  final String currentUserId;

  const CreateCompanionScreen({super.key, required this.currentUserId});

  @override
  State<CreateCompanionScreen> createState() => _CreateCompanionScreenState();
}

class _CreateCompanionScreenState extends State<CreateCompanionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _destinationController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  int _maxCount = 4;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _startDate == null || _endDate == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.currentUserId).get();
    if (!userDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보를 찾을 수 없습니다.')),
      );
      return;
    }

    final nickname = userDoc.data()?['nickname'] ?? '익명';
    final newDoc = FirebaseFirestore.instance.collection('companions').doc();

    setState(() => _isLoading = true);

    try {
      await newDoc.set({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'destination': _destinationController.text.trim(),
        'startDate': Timestamp.fromDate(_startDate!),
        'endDate': Timestamp.fromDate(_endDate!),
        'currentCount': 1,
        'maxCount': _maxCount,
        'isClosed': false,
        'createdBy': widget.currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
        'leaderName': nickname,
      });

      await newDoc.collection('participants').doc(widget.currentUserId).set({
        'userId': widget.currentUserId,
        'userName': nickname,
        'joinedAt': FieldValue.serverTimestamp(),
        'isLeader': true,
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .collection('joinedCompanions')
          .doc(newDoc.id)
          .set({
        'companionId': newDoc.id,
        'destination': _destinationController.text.trim(),
        'joinedAt': FieldValue.serverTimestamp(),
        'startDate': Timestamp.fromDate(_startDate!),
        'endDate': Timestamp.fromDate(_endDate!),
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록 실패: ${e.toString()}')));
    }

    setState(() => _isLoading = false);
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked;
        else _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('동행 등록')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '제목 *'),
                validator: (value) => value == null || value.isEmpty ? '제목을 입력하세요' : null,
              ),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: '부가 설명'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(labelText: '여행지 *'),
                validator: (value) => value == null || value.isEmpty ? '여행지를 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _pickDate(true),
                      child: Text(_startDate == null
                          ? '출발일 선택'
                          : '출발일: ${DateFormat('yyyy-MM-dd').format(_startDate!)}'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _pickDate(false),
                      child: Text(_endDate == null
                          ? '도착일 선택'
                          : '도착일: ${DateFormat('yyyy-MM-dd').format(_endDate!)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('모집 인원: '),
                  Expanded(
                    child: Slider(
                      value: _maxCount.toDouble(),
                      min: 2,
                      max: 10,
                      divisions: 8,
                      label: '$_maxCount명',
                      onChanged: (val) => setState(() => _maxCount = val.toInt()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _submit,
                child: const Text('동행 등록'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
