import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditPersonalScheduleScreen extends StatefulWidget {
  final String userId;
  final String scheduleDocId;

  const EditPersonalScheduleScreen({
    super.key,
    required this.userId,
    required this.scheduleDocId,
  });

  @override
  State<EditPersonalScheduleScreen> createState() => _EditPersonalScheduleScreenState();
}

class _EditPersonalScheduleScreenState extends State<EditPersonalScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
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
      _descriptionController.text = data['description'] ?? '';
      _destinationController.text = data['destination'] ?? '';
      _startDate = (data['startDate'] as Timestamp).toDate();
      _endDate = (data['endDate'] as Timestamp).toDate();
    });
  }

  Future<void> _pickDate(bool isStart) async {

    final appLocalizations = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? now),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
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

  Future<void> _save() async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────

    if (!_formKey.currentState!.validate() || _startDate == null || _endDate == null) return;

    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLocalizations.startDateBeforeEndDateError)), // 다국어 적용
      );
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
        'description': _descriptionController.text.trim(),
        'destination': _destinationController.text.trim(),
        'startDate': Timestamp.fromDate(_startDate!),
        'endDate': Timestamp.fromDate(_endDate!),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${appLocalizations.editFailed}: $e'))); // 다국어 적용
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
        title: Text(appLocalizations.editScheduleTitle, style: const TextStyle(fontWeight: FontWeight.bold)), // 다국어 적용
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
                Text(appLocalizations.editTravelInfo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // 다국어 적용
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: appLocalizations.scheduleTitleLabel, // 다국어 적용
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (value) => value == null || value.isEmpty ? appLocalizations.enterTitle : null, // 다국어 적용
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: appLocalizations.additionalDescriptionLabel, // 다국어 적용
                    hintText: appLocalizations.descriptionHint, // 다국어 적용
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _destinationController,
                  decoration: InputDecoration(
                    labelText: appLocalizations.destinationLabel, // 다국어 적용
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (value) => value == null || value.isEmpty ? appLocalizations.enterDestination : null, // 다국어 적용
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(true),
                        child: Text(
                          _startDate == null
                              ? appLocalizations.selectStartDate // 다국어 적용
                              : '${appLocalizations.startDate}: ${DateFormat('yyyy.MM.dd').format(_startDate!)}', // 다국어 적용
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(false),
                        child: Text(
                          _endDate == null
                              ? appLocalizations.selectEndDate // 다국어 적용
                              : '${appLocalizations.endDate}: ${DateFormat('yyyy.MM.dd').format(_endDate!)}', // 다국어 적용
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
                    onPressed: _save,
                    label: Text(appLocalizations.completeEditButton), // 다국어 적용
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