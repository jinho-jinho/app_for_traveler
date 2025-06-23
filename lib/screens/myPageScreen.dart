import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_for_traveler/screens/loginScreen.dart';
import 'package:app_for_traveler/screens/postDetailScreen.dart';

import 'myScheduleScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // AppLocalizations 임포트 추가

class MyPageScreen extends StatefulWidget {
  final String currentUserId;
  final Function(String?) onLogout;
  final Function(String) onPlaceSelected;

  const MyPageScreen({
    super.key,
    required this.currentUserId,
    required this.onLogout,
    required this.onPlaceSelected,
  });

  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  String _selectedGender = 'Female'; // (세연)

  String? _nickname;
  List<String> _favorites = [];
  List<DocumentSnapshot> _myPosts = [];
  List<DocumentSnapshot> _myComments = [];
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  List<DocumentSnapshot> _myPlaces = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupRealtimeListener();
    _loadMyPosts();
    _loadMyCommentedPosts();
    _loadMyPlaces();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final doc = await _firestore
        .collection('users')
        .doc(widget.currentUserId)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nickname = data['nickname'] ?? widget.currentUserId;
        _nicknameController.text = _nickname!;
        _selectedGender = data['gender'] ?? '여성';
        _ageController.text = data['age']?.toString() ?? '';
        _contactController.text = data['contact'] ?? '';
        _favorites = List<String>.from(data['favorites'] ?? []);
      });
    }
  }

  void _setupRealtimeListener() {
    _userSubscription = _firestore
        .collection('users')
        .doc(widget.currentUserId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _favorites = List<String>.from(snapshot['favorites'] ?? []);
        });
      }
    });
  }

  Future<void> _loadMyPosts() async {
    final snapshot = await _firestore
        .collection('posts')
        .where('authorId', isEqualTo: widget.currentUserId)
        .get();
    setState(() => _myPosts = snapshot.docs);
  }

  Future<void> _loadMyCommentedPosts() async {
    final commentSnapshot = await _firestore
        .collection('comments')
        .where('authorId', isEqualTo: widget.currentUserId)
        .get();

    final postIds = commentSnapshot.docs
        .map((doc) => doc['postId'] as String)
        .toSet()
        .toList();
    if (postIds.isEmpty) return;

    List<DocumentSnapshot> allPosts = [];
    for (var i = 0; i < postIds.length; i += 10) {
      final chunk = postIds.sublist(i, (i + 10).clamp(0, postIds.length));
      final postSnapshot = await _firestore
          .collection('posts')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      allPosts.addAll(postSnapshot.docs);
    }

    setState(() => _myComments = allPosts);
  }

  Future<void> _loadMyPlaces() async {
    final snapshot = await _firestore
        .collection('user_places')
        .where('submittedBy', isEqualTo: widget.currentUserId)
        .get();
    setState(() {
      _myPlaces = snapshot.docs;
    });
  }

  void _showMyPlaces() {
    final appLocalizations = AppLocalizations.of(context)!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(appLocalizations.myAddedPlaces)), // 다국어 적용
          body: ListView.builder(
            itemCount: _myPlaces.length,
            itemBuilder: (context, index) {
              final data = _myPlaces[index].data() as Map<String, dynamic>;
              final placeId = data['id'] ?? '';

              return ListTile(
                title: Text(data['name'] ?? appLocalizations.noPlaceName), // 다국어 적용
                subtitle: Text(data['category'] ?? ''),
                trailing: Text(
                  data['Added'] == true ? appLocalizations.approvalComplete : appLocalizations.underReview, // 다국어 적용
                  style: TextStyle(
                    color: data['Added'] == true ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onPlaceSelected(placeId);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSimpleList(String title, List<DocumentSnapshot> docs) {
    final appLocalizations = AppLocalizations.of(context)!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            Scaffold(
                backgroundColor: Colors.grey[100],
                appBar: AppBar(title: Text(title), backgroundColor: Colors.grey[100],),
                body: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _buildInfoCard(
                      title: data['title'] ?? appLocalizations.noTitle, // 다국어 적용
                      subtitle: data['content'] ?? '',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailScreen(
                            postId: docs[index].id,
                            title: data['title'],
                            content: data['content'],
                            authorId: data['authorId'],
                            authorNickname: data['authorNickname'],
                            createdAt: (data['createdAt'] as Timestamp).toDate(),
                            currentUserId: widget.currentUserId,
                            currentUserNickname: _nickname,
                          ),
                        ),
                      ),
                    );
                  },
                )
            ),
      ),
    );
  }

  void _showFavorites() {
    final appLocalizations = AppLocalizations.of(context)!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            Scaffold(
                backgroundColor: Colors.grey[100],
                appBar: AppBar(title: Text(appLocalizations.favoritePlaces), backgroundColor: Colors.grey[100],), // 다국어 적용
                body: ListView(
                  children: _favorites.map((placeId) {
                    return FutureBuilder<DocumentSnapshot>(
                      future: _firestore.collection('places').doc(placeId).get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        if (!snapshot.hasData || !snapshot.data!.exists)
                          return _buildInfoCard(title: placeId);

                        final data = snapshot.data!.data() as Map<String, dynamic>;
                        return _buildInfoCard(
                          title: data['name'] ?? placeId,
                          subtitle: data['address'] ?? '',
                          onTap: () => widget.onPlaceSelected(placeId),
                        );
                      },
                    );
                  }).toList(),
                )
            ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final appLocalizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: Text(appLocalizations.editProfileTitle), // 다국어 적용
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(controller: _nicknameController,
                      decoration: InputDecoration(labelText: appLocalizations.nicknameLabel)), // 다국어 적용
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(labelText: appLocalizations.genderLabel), // 다국어 적용
                    items: [appLocalizations.genderFemale, appLocalizations.genderMale].map((value) { // 다국어 적용
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedGender = val);
                    },
                  ),
                  TextField(controller: _ageController,
                      decoration: InputDecoration(labelText: appLocalizations.ageLabel), // 다국어 적용
                      keyboardType: TextInputType.number),
                  TextField(controller: _contactController,
                      decoration: InputDecoration(labelText: appLocalizations.contactLabel)), // 다국어 적용
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context),
                  child: Text(appLocalizations.cancelButton)), // 다국어 적용
              ElevatedButton(
                onPressed: () async {
                  await _firestore
                      .collection('users')
                      .doc(widget.currentUserId)
                      .update({
                    'nickname': _nicknameController.text.trim(),
                    'gender': _selectedGender,
                    'age': int.tryParse(_ageController.text.trim()) ?? 0,
                    'contact': _contactController.text.trim(),
                  });
                  _loadUserData();
                  Navigator.pop(context);
                },
                child: Text(appLocalizations.saveButton), // 다국어 적용
              ),
            ],
          ),
    );
  }

  Future<void> _deleteAccount() async {
    final appLocalizations = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: Text(appLocalizations.deleteAccountTitle), // 다국어 적용
            content: Text(appLocalizations.confirmDeleteAccount), // 다국어 적용
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false),
                  child: Text(appLocalizations.cancelButton)), // 다국어 적용
              ElevatedButton(onPressed: () => Navigator.pop(context, true),
                  child: Text(appLocalizations.deleteButton)), // 다국어 적용
            ],
          ),
    );

    if (confirm == true) {
      await _firestore.collection('users').doc(widget.currentUserId).delete();
      widget.onLogout(null);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => LoginScreen(onLogin: widget.onLogout)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!; //
    return Scaffold(
      backgroundColor: Colors.grey[100], //
      appBar: AppBar(
        backgroundColor: Colors.grey[100], //
        elevation: 0, //
        title: Row(
          children: [
            const Icon(Icons.person_outline, color: Colors.black87), //
            const SizedBox(width: 8), //
            Text(
              appLocalizations.myPageTitle, // 다국어 적용
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18), //
            ),
          ],
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16), //
        children: [
          const SizedBox(height: 5), //

          // 프로필 카드
          _buildProfileCard(), //
          const SizedBox(height: 10), //

          // 카드형 메뉴
          _buildCardItem(appLocalizations.editProfileTitle, Icons.edit, _showEditProfileDialog), // 다국어 적용
          _buildCardItem(appLocalizations.favoritePlaces, Icons.star_border, _showFavorites), // 다국어 적용
          _buildCardItem(appLocalizations.myAddedPlaces, Icons.place_outlined, _showMyPlaces), // 다국어 적용
          _buildCardItem(appLocalizations.travelSchedule, Icons.calendar_month, () { // 다국어 적용
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MyScheduleScreen(currentUserId: widget.currentUserId), //
              ),
            );
          }),
          _buildCardItem(appLocalizations.myPosts, Icons.article_outlined, () => _showSimpleList(appLocalizations.myPosts, _myPosts)), // 다국어 적용
          _buildCardItem(appLocalizations.commentedPosts, Icons.comment_outlined, () => _showSimpleList(appLocalizations.commentedPosts, _myComments)), // 다국어 적용

          const SizedBox(height: 24), //

          // 로그아웃 / 탈퇴 버튼 그룹
          _buildButtonGroup(), //
        ],
      ),
    );
  }


  Widget _buildProfileCard() {
    final appLocalizations = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(30), //
      decoration: BoxDecoration(
        color: Colors.white, //
        borderRadius: BorderRadius.circular(12), //
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), //
            blurRadius: 6, //
            offset: const Offset(0, 3), //
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, //
        children: [
          Text(
            _nickname ?? appLocalizations.noNickname, // 다국어 적용
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), //
          ),
          const SizedBox(height: 6), //
          Text('${appLocalizations.genderLabel}: $_selectedGender'), // 다국어 적용
          Text('${appLocalizations.ageLabel}: ${_ageController.text.isNotEmpty ? _ageController.text : appLocalizations.notEntered}'), // 다국어 적용
          Text('${appLocalizations.contactLabel}: ${_contactController.text.isNotEmpty ? _contactController.text : appLocalizations.notEntered}'), // 다국어 적용
        ],
      ),
    );
  }

  Widget _buildCardItem(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6), //
      decoration: BoxDecoration(
        color: Colors.white, //
        borderRadius: BorderRadius.circular(12), //
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), //
            blurRadius: 6, //
            offset: const Offset(0, 3), //
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), //
        leading: Icon(icon, color: Colors.grey[700], size: 20), //
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14, //
            fontWeight: FontWeight.w500, //
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 18), //
        onTap: onTap, //
      ),
    );
  }


  Widget _buildInfoCard({
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16), //
      decoration: BoxDecoration(
        color: Colors.white, //
        borderRadius: BorderRadius.circular(12), //
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), //
            blurRadius: 6, //
            offset: const Offset(0, 3), //
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), //
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), //
        ),
        subtitle: subtitle != null && subtitle.isNotEmpty
            ? Padding(
          padding: const EdgeInsets.only(top: 4.0), //
          child: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis), //
        )
            : null,
        trailing: const Icon(Icons.chevron_right), //
        onTap: onTap, //
      ),
    );
  }


  Widget _buildButtonGroup() {
    final appLocalizations = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          TextButton(
            onPressed: () {
              widget.onLogout(null); //
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => LoginScreen(onLogin: widget.onLogout)), //
              );
            },
            child: Text(appLocalizations.logoutButton), // 다국어 적용
          ),
          TextButton(
            onPressed: _deleteAccount, //
            child: Text(appLocalizations.deleteAccountButton, style: const TextStyle(color: Colors.red)), // 다국어 적용
          ),
        ],
      ),
    );
  }
}