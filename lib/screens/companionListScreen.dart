import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'companionDetailScreen.dart';
import 'createCompanionScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompanionListScreen extends StatefulWidget {
  final String currentUserId;

  const CompanionListScreen({super.key, required this.currentUserId});

  @override
  State<CompanionListScreen> createState() => _CompanionListScreenState();
}

class _CompanionListScreenState extends State<CompanionListScreen> {
  bool _showOnlyOpen = false;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(appLocalizations.findCompanionTitle, style: const TextStyle(fontWeight: FontWeight.bold)), // 다국어 적용
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: appLocalizations.registerCompanionTooltip, // 다국어 적용
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateCompanionScreen(currentUserId: widget.currentUserId),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.filter_alt_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(
                    child: SwitchListTile(
                      title: Text(appLocalizations.showOnlyOpenCompanions), // 다국어 적용
                      value: _showOnlyOpen,
                      activeColor: Colors.black,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.shade300,
                      onChanged: (val) {
                        setState(() => _showOnlyOpen = val);
                      },
                    )
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('companions')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;

                final companions = docs.map((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  return {
                    'id': doc.id,
                    'title': d['title'] ?? appLocalizations.noTitle, // 다국어 적용
                    'destination': d['destination'] ?? appLocalizations.destinationUndecided, // 다국어 적용
                    'content': d['content'] ?? '',
                    'currentCount': d['currentCount'] ?? 0,
                    'maxCount': d['maxCount'] ?? 0,
                    'startDate': (d['startDate'] as Timestamp).toDate(),
                    'endDate': (d['endDate'] as Timestamp).toDate(),
                    'isClosed': d['isClosed'] ?? false,
                  };
                }).where((item) => !_showOnlyOpen || !(item['isClosed'] ?? true)).toList();

                if (companions.isEmpty) {
                  return Center(child: Text(appLocalizations.noCompanionsRegistered)); // 다국어 적용
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  itemCount: companions.length,
                  itemBuilder: (context, index) {
                    final c = companions[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CompanionDetailScreen(
                              companionId: c['id'],
                              currentUserId: widget.currentUserId,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    c['title'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: c['isClosed'] ? Colors.grey[300] : Colors.green[100],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    c['isClosed'] ? appLocalizations.recruitmentComplete : appLocalizations.recruiting, // 다국어 적용
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: c['isClosed'] ? Colors.grey[600] : Colors.green[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '📍 ${c['destination']}', // 📍는 이모지이므로 그대로 유지
                              style: const TextStyle(color: Colors.black87),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              c['content'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '🗓 ${DateFormat('MM/dd').format(c['startDate'])} ~ ${DateFormat('MM/dd').format(c['endDate'])}', // 🗓 이모지 유지
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  '👥 ${c['currentCount']}/${c['maxCount']}${appLocalizations.personUnit}', // '명' 다국어 적용
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}