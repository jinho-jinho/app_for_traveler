import 'package:cloud_firestore/cloud_firestore.dart';
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
  final _maxCountController = TextEditingController(text: '4');
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  String _genderCondition = '무관';
  bool _isAgeUnlimited = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final doc = await FirebaseFirestore.instance.collection('companions').doc(widget.companionId).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    _titleController.text = data['title'] ?? '';
    _contentController.text = data['content'] ?? '';
    _destinationController.text = data['destination'] ?? '';
    _startDate = (data['startDate'] as Timestamp).toDate();
    _endDate = (data['endDate'] as Timestamp).toDate();
    _maxCountController.text = '${data['maxCount'] ?? 4}';
    _genderCondition = data['genderCondition'] ?? '무관';

    if (data['ageCondition'] != null && data['ageCondition']['type'] == '범위') {
      _isAgeUnlimited = false;
      _minAgeController.text = '${data['ageCondition']['min'] ?? ''}';
      _maxAgeController.text = '${data['ageCondition']['max'] ?? ''}';
    } else {
      _isAgeUnlimited = true;
    }

    setState(() {});
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _startDate == null || _endDate == null) return;

    final maxCount = int.tryParse(_maxCountController.text.trim()) ?? 4;

    Map<String, dynamic> ageCondition;
    if (_isAgeUnlimited) {
      ageCondition = {'type': '무관'};
    } else {
      final minAge = int.tryParse(_minAgeController.text.trim()) ?? 0;
      final maxAge = int.tryParse(_maxAgeController.text.trim()) ?? 100;
      ageCondition = {'type': '범위', 'min': minAge, 'max': maxAge};
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('companions').doc(widget.companionId).update({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'destination': _destinationController.text.trim(),
        'startDate': Timestamp.fromDate(_startDate!),
        'endDate': Timestamp.fromDate(_endDate!),
        'maxCount': maxCount,
        'genderCondition': _genderCondition,
        'ageCondition': ageCondition,
        'isClosed': false,
      });

      final participants = await FirebaseFirestore.instance
          .collection('companions')
          .doc(widget.companionId)
          .collection('participants')
          .get();

      for (var p in participants.docs) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(p.id)
            .collection('joinedCompanions')
            .doc(widget.companionId)
            .update({
          'destination': _destinationController.text.trim(),
          'startDate': Timestamp.fromDate(_startDate!),
          'endDate': Timestamp.fromDate(_endDate!),
        });
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('수정 실패: ${e.toString()}')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('동행 정보 수정', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('동행 정보 수정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: '제목 *', border: OutlineInputBorder(), isDense: true),
                  validator: (value) => value == null || value.isEmpty ? '제목을 입력하세요' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '부가 설명',
                    hintText: '예) 조용한 여행 선호해요 / mbti i이신 분들 환영합니다',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _destinationController,
                  decoration: const InputDecoration(labelText: '여행지 *', border: OutlineInputBorder(), isDense: true),
                  validator: (value) => value == null || value.isEmpty ? '여행지를 입력하세요' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(true),
                        child: Text(_startDate == null
                            ? '출발일 선택'
                            : '출발일: ${DateFormat('yyyy.MM.dd').format(_startDate!)}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(false),
                        child: Text(_endDate == null
                            ? '도착일 선택'
                            : '도착일: ${DateFormat('yyyy.MM.dd').format(_endDate!)}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _maxCountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '모집 인원 수 *', border: OutlineInputBorder(), isDense: true),
                  validator: (value) {
                    final n = int.tryParse(value ?? '');
                    if (n == null || n < 2 || n > 50) return '2~50 사이 숫자를 입력하세요';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Divider(height: 32),
                const Text('동행 조건 설정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _genderCondition,
                  decoration: const InputDecoration(labelText: '성별 조건', border: OutlineInputBorder(), isDense: true),
                  items: ['무관', '남성만', '여성만']
                      .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _genderCondition = value);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: _isAgeUnlimited,
                      onChanged: (value) => setState(() => _isAgeUnlimited = value ?? true),
                    ),
                    const Text('연령 무관'),
                  ],
                ),
                if (!_isAgeUnlimited) ...[
                  TextFormField(
                    controller: _minAgeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '최소 나이', border: OutlineInputBorder(), isDense: true),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _maxAgeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '최대 나이', border: OutlineInputBorder(), isDense: true),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check),
                    label: const Text('수정 완료'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black54,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
