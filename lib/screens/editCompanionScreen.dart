import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditCompanionScreen extends StatefulWidget {
  final String companionId;

  const EditCompanionScreen({super.key, required this.companionId});

  @override
  State<EditCompanionScreen> createState() => _EditCompanionScreenState();
}

class _EditCompanionScreenState extends State<EditCompanionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _destinationController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  int _maxCount = 4;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCompanionData();
  }

  Future<void> _loadCompanionData() async {
    final doc = await FirebaseFirestore.instance.collection('companions').doc(widget.companionId).get();
    if (!doc.exists) return;
    final data = doc.data()!;

    setState(() {
      _titleController.text = data['title'] ?? '';
      _contentController.text = data['content'] ?? '';
      _destinationController.text = data['destination'] ?? '';
      _startDate = (data['startDate'] as Timestamp).toDate();
      _endDate = (data['endDate'] as Timestamp).toDate();
      _maxCount = data['maxCount'] ?? 4;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _startDate == null || _endDate == null) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('companions').doc(widget.companionId).update({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'destination': _destinationController.text.trim(),
        'startDate': Timestamp.fromDate(_startDate!),
        'endDate': Timestamp.fromDate(_endDate!),
        'maxCount': _maxCount,
        'isClosed': false,
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('수정 실패: ${e.toString()}')));
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
      appBar: AppBar(title: const Text('동행 정보 수정')),
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
                child: const Text('수정 완료'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}