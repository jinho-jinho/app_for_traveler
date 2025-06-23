import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreatePersonalScheduleScreen extends StatefulWidget {
  final String userId;

  const CreatePersonalScheduleScreen({super.key, required this.userId});

  @override
  State<CreatePersonalScheduleScreen> createState() => _CreatePersonalScheduleScreenState();
}

class _CreatePersonalScheduleScreenState extends State<CreatePersonalScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _destinationController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  Future<void> _pickDate(bool isStart) async {
    final appLocalizations = AppLocalizations.of(context)!;

    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      // 언어 설정이 적용된 Text 표시 (선택 사항)
      // helpText: isStart ? appLocalizations.selectStartDate : appLocalizations.selectEndDate,
      // cancelText: appLocalizations.cancelButton,
      // confirmText: appLocalizations.confirmButton,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) _endDate = null;
        } else {
          _endDate = picked;
        }
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

    // 출발일이 도착일보다 늦은 경우 처리 추가 (EditPersonalScheduleScreen과 동일하게)
    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLocalizations.startDateBeforeEndDateError)), // 다국어 적용 (재사용)
      );
      return;
    }


    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('personalSchedules')
          .add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'destination': _destinationController.text.trim(),
        'startDate': Timestamp.fromDate(_startDate!),
        'endDate': Timestamp.fromDate(_endDate!),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${appLocalizations.registerFailed}: ${e.toString()}')), // 다국어 적용
      );
    } finally {
      setState(() => _isLoading = false);
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
        title: Text(appLocalizations.registerTripTitle, style: const TextStyle(fontWeight: FontWeight.bold)), // 다국어 적용
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
                Text(appLocalizations.enterTripInfo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // 다국어 적용
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: appLocalizations.scheduleTitleLabel, // 다국어 적용 (재사용)
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (value) => value == null || value.isEmpty ? appLocalizations.enterTitle : null, // 다국어 적용 (재사용)
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: appLocalizations.additionalDescriptionLabel, // 다국어 적용 (재사용)
                    hintText: appLocalizations.tripDescriptionHint, // 다국어 적용
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _destinationController,
                  decoration: InputDecoration(
                    labelText: appLocalizations.destinationLabel, // 다국어 적용 (재사용)
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (value) => value == null || value.isEmpty ? appLocalizations.enterDestination : null, // 다국어 적용 (재사용)
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(true),
                        child: Text(
                          _startDate == null
                              ? appLocalizations.selectStartDate // 다국어 적용 (재사용)
                              : '${appLocalizations.startDate}: ${DateFormat('yyyy.MM.dd').format(_startDate!)}', // 다국어 적용 (재사용)
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(false),
                        child: Text(
                          _endDate == null
                              ? appLocalizations.selectEndDate // 다국어 적용 (재사용)
                              : '${appLocalizations.endDate}: ${DateFormat('yyyy.MM.dd').format(_endDate!)}', // 다국어 적용 (재사용)
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check),
                    label: Text(appLocalizations.registerTripButton), // 다국어 적용
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black54,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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