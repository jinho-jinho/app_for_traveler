import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  final _maxCountController = TextEditingController(text: '4');
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  String _genderCondition = '무관'; // 이 값은 Firestore에 저장될 때 사용될 문자열이므로, 다국어 키를 참조할 필요는 없습니다.
  bool _isAgeUnlimited = true;

  Future<void> _submit() async {
    final appLocalizations = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate() || _startDate == null || _endDate == null) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLocalizations.selectStartAndEndDate)), // 다국어 적용 (재사용)
        );
      }
      return;
    }

    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLocalizations.startDateBeforeEndDateError)), // 다국어 적용 (재사용)
      );
      return;
    }


    final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.currentUserId).get();
    if (!userDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appLocalizations.userNotFound))); // 다국어 적용
      return;
    }

    final nickname = userDoc.data()?['nickname'] ?? appLocalizations.anonymous; // 다국어 적용
    final newDoc = FirebaseFirestore.instance.collection('companions').doc();
    final maxCount = int.tryParse(_maxCountController.text.trim()) ?? 4;

    Map<String, dynamic> ageCondition;
    if (_isAgeUnlimited) {
      ageCondition = {'type': appLocalizations.genderConditionAny}; // 다국어 적용 (Firestore 저장 값)
    } else {
      final minAge = int.tryParse(_minAgeController.text.trim()) ?? 0;
      final maxAge = int.tryParse(_maxAgeController.text.trim()) ?? 100;
      ageCondition = {'type': appLocalizations.ageConditionRange, 'min': minAge, 'max': maxAge}; // 다국어 적용 (Firestore 저장 값)
    }

    setState(() => _isLoading = true);

    try {
      await newDoc.set({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'destination': _destinationController.text.trim(),
        'startDate': Timestamp.fromDate(_startDate!),
        'endDate': Timestamp.fromDate(_endDate!),
        'currentCount': 1,
        'maxCount': maxCount,
        'isClosed': false,
        'createdBy': widget.currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
        'leaderName': nickname,
        'genderCondition': _genderCondition, // 실제 Firestore에 저장되는 값은 이 문자열임
        'ageCondition': ageCondition,
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${appLocalizations.registerFailed}: ${e.toString()}'))); // 다국어 적용 (재사용)
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
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(appLocalizations.registerCompanionTitle, style: const TextStyle(fontWeight: FontWeight.bold)), // 다국어 적용
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
                Text(appLocalizations.enterCompanionInfo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // 다국어 적용
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: appLocalizations.titleLabel, border: const OutlineInputBorder(), isDense: true), // 다국어 적용 (재사용)
                  validator: (value) => value == null || value.isEmpty ? appLocalizations.enterTitle : null, // 다국어 적용 (재사용)
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: appLocalizations.additionalDescriptionLabel, // 다국어 적용 (재사용)
                    hintText: appLocalizations.companionDescriptionHint, // 다국어 적용 (재사용)
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _destinationController,
                  decoration: InputDecoration(labelText: appLocalizations.destinationLabel, border: const OutlineInputBorder(), isDense: true), // 다국어 적용 (재사용)
                  validator: (value) => value == null || value.isEmpty ? appLocalizations.enterDestination : null, // 다국어 적용 (재사용)
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(true),
                        child: Text(_startDate == null
                            ? appLocalizations.selectStartDate // 다국어 적용 (재사용)
                            : '${appLocalizations.startDate}: ${DateFormat('yyyy.MM.dd').format(_startDate!)}'), // 다국어 적용 (재사용)
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(false),
                        child: Text(_endDate == null
                            ? appLocalizations.selectEndDate // 다국어 적용 (재사용)
                            : '${appLocalizations.endDate}: ${DateFormat('yyyy.MM.dd').format(_endDate!)}'), // 다국어 적용 (재사용)
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _maxCountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: appLocalizations.recruitCountLabel, border: const OutlineInputBorder(), isDense: true), // 다국어 적용 (재사용)
                  validator: (value) {
                    final n = int.tryParse(value ?? '');
                    if (n == null || n < 2 || n > 50) return appLocalizations.recruitCountError; // 다국어 적용 (재사용)
                    return null;
                  },
                ),

                // 🔻 성별 / 연령 조건 입력
                const SizedBox(height: 24),
                const Divider(height: 32),
                Text(appLocalizations.setCompanionConditions, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // 다국어 적용 (재사용)
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _genderCondition,
                  decoration: InputDecoration(labelText: appLocalizations.genderConditionLabel, border: const OutlineInputBorder(), isDense: true), // 다국어 적용 (재사용)
                  items: [
                    appLocalizations.genderConditionAny, // 다국어 적용 (재사용)
                    appLocalizations.genderConditionMaleOnly, // 다국어 적용 (재사용)
                    appLocalizations.genderConditionFemaleOnly // 다국어 적용 (재사용)
                  ].map((label) => DropdownMenuItem(value: label, child: Text(label))).toList(),
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
                    Text(appLocalizations.ageUnlimited), // 다국어 적용 (재사용)
                  ],
                ),
                if (!_isAgeUnlimited) ...[
                  TextFormField(
                    controller: _minAgeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: appLocalizations.minAgeLabel, border: const OutlineInputBorder(), isDense: true), // 다국어 적용 (재사용)
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _maxAgeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: appLocalizations.maxAgeLabel, border: const OutlineInputBorder(), isDense: true), // 다국어 적용 (재사용)
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
                    label: Text(appLocalizations.registerCompanionButton), // 다국어 적용
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