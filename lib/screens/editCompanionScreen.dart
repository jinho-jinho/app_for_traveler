import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditCompanionScreen extends StatefulWidget {
  final String companionId;
  final Map<String, dynamic> companionData; // ◀️ 아마도 이름이 이렇게 되어 있을 것입니다.

  const EditCompanionScreen({
    super.key,
    required this.companionId,
    required this.companionData, // ◀️ 이 이름을 확인하세요.
  });

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
    _startDate = (data['startDate'] as Timestamp?)?.toDate(); // null-safety 추가
    _endDate = (data['endDate'] as Timestamp?)?.toDate();     // null-safety 추가
    _maxCountController.text = '${data['maxCount'] ?? 4}';
    _genderCondition = data['genderCondition'] ?? '무관'; // 이 값도 다국어 키로 변경될 수 있음

    if (data['ageCondition'] != null && data['ageCondition']['type'] == '범위') { // '범위'도 다국어 키로 변경될 수 있음
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
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────

    if (!_formKey.currentState!.validate() || _startDate == null || _endDate == null) {
      // 날짜 선택 안 했을 때 에러 메시지 추가 (예시)
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLocalizations.selectStartAndEndDate)), // 다국어 적용
        );
      }
      return;
    }

// 이 아래 if 문이 문제였습니다.
    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar( // <--- 이 라인이 추가되어야 합니다.
        SnackBar(content: Text(appLocalizations.startDateBeforeEndDateError)), // 다국어 적용 (재사용)
      ); // <--- 스낵바 위젯을 닫는 괄호 뒤에 세미콜론이 있어야 합니다.
      return;
    }


    final maxCount = int.tryParse(_maxCountController.text.trim()) ?? 4;

    Map<String, dynamic> ageCondition;
    if (_isAgeUnlimited) {
      ageCondition = {'type': appLocalizations.genderConditionAny}; // '무관' 다국어 키로 변경
    } else {
      final minAge = int.tryParse(_minAgeController.text.trim()) ?? 0;
      final maxAge = int.tryParse(_maxAgeController.text.trim()) ?? 100;
      ageCondition = {'type': appLocalizations.ageConditionRange, 'min': minAge, 'max': maxAge}; // '범위' 다국어 키로 변경
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
        'genderCondition': _genderCondition, // 이 값은 저장 시 다시 다국어 키가 아닌 원본 문자열로 저장
        'ageCondition': ageCondition,
        'isClosed': false,
      });

      // 참가자들의 joinedCompanions 업데이트 로직은 그대로 유지
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${appLocalizations.editFailed}: ${e.toString()}'))); // 다국어 적용
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(appLocalizations.editCompanionInfoTitle, style: const TextStyle(fontWeight: FontWeight.bold)), // 다국어 적용
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
                Text(appLocalizations.editCompanionInfo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // 다국어 적용
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: appLocalizations.titleLabel, border: const OutlineInputBorder(), isDense: true), // 다국어 적용
                  validator: (value) => value == null || value.isEmpty ? appLocalizations.enterTitle : null, // 다국어 적용
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: appLocalizations.additionalDescriptionLabel, // 다국어 적용
                    hintText: appLocalizations.companionDescriptionHint, // 다국어 적용
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _destinationController,
                  decoration: InputDecoration(labelText: appLocalizations.destinationLabel, border: const OutlineInputBorder(), isDense: true), // 다국어 적용
                  validator: (value) => value == null || value.isEmpty ? appLocalizations.enterDestination : null, // 다국어 적용
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(true),
                        child: Text(_startDate == null
                            ? appLocalizations.selectStartDate // 다국어 적용
                            : '${appLocalizations.startDate}: ${DateFormat('yyyy.MM.dd').format(_startDate!)}'), // 다국어 적용
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(false),
                        child: Text(_endDate == null
                            ? appLocalizations.selectEndDate // 다국어 적용
                            : '${appLocalizations.endDate}: ${DateFormat('yyyy.MM.dd').format(_endDate!)}'), // 다국어 적용
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _maxCountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: appLocalizations.recruitCountLabel, border: const OutlineInputBorder(), isDense: true), // 다국어 적용
                  validator: (value) {
                    final n = int.tryParse(value ?? '');
                    if (n == null || n < 2 || n > 50) return appLocalizations.recruitCountError; // 다국어 적용
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Divider(height: 32),
                Text(appLocalizations.setCompanionConditions, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // 다국어 적용
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _genderCondition,
                  decoration: InputDecoration(labelText: appLocalizations.genderConditionLabel, border: const OutlineInputBorder(), isDense: true), // 다국어 적용
                  items: [
                    appLocalizations.genderConditionAny, // '무관' 다국어 적용
                    appLocalizations.genderConditionMaleOnly, // '남성만' 다국어 적용
                    appLocalizations.genderConditionFemaleOnly // '여성만' 다국어 적용
                  ]
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
                    Text(appLocalizations.ageUnlimited), // 다국어 적용
                  ],
                ),
                if (!_isAgeUnlimited) ...[
                  TextFormField(
                    controller: _minAgeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: appLocalizations.minAgeLabel, border: const OutlineInputBorder(), isDense: true), // 다국어 적용
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _maxAgeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: appLocalizations.maxAgeLabel, border: const OutlineInputBorder(), isDense: true), // 다국어 적용
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
                    label: Text(appLocalizations.completeEditButton), // 다국어 적용 (재사용)
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