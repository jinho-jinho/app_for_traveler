import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_for_traveler/screens/loginScreen.dart';
import 'package:app_for_traveler/screens/postDetailScreen.dart';

import 'myScheduleScreen.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';


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
  final TextEditingController _ageController = TextEditingController(); // (세연)
  final TextEditingController _contactController = TextEditingController(); // (세연)
  String _selectedGender = '여성'; // (세연)

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
    _loadMyPosts();
    _loadMyComments();
    _loadMyCommentedPosts();
    _loadMyPlaces(); 
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _nicknameController.dispose();
    _ageController.dispose(); // (세연)
    _contactController.dispose(); // (세연)
    super.dispose();
  }

  Future<void> _loadUserData() async {
    _userSubscription = _firestore.collection('users').doc(widget.currentUserId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final userData = snapshot.data()!;
        setState(() {
          _nickname = userData['nickname'];
          _favorites = List<String>.from(userData['favorites'] ?? []);
          _nicknameController.text = _nickname ?? '';
          _selectedGender = userData['gender'] ?? '여성'; // (세연)
          _ageController.text = userData['age'] ?? ''; // (세연)
          _contactController.text = userData['contact'] ?? ''; // (세연)
        });
      }
    });
  }

  Future<void> _loadMyPosts() async {
    final QuerySnapshot snapshot = await _firestore
        .collection('posts')
        .where('authorId', isEqualTo: widget.currentUserId)
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      _myPosts = snapshot.docs;
    });
  }

  Future<void> _loadMyComments() async {
    final QuerySnapshot snapshot = await _firestore
        .collection('comments')
        .where('authorId', isEqualTo: widget.currentUserId)
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      _myComments = snapshot.docs;
    });
  }

  Future<void> _updateUserInfo() async {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────

    try {
      await _firestore.collection('users').doc(widget.currentUserId).update({
        'nickname': _nicknameController.text,
        'gender': _selectedGender, // (세연)
        'age': _ageController.text, // (세연)
        'contact': _contactController.text, // (세연)
      });
      setState(() {
        _nickname = _nicknameController.text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLocalizations.profileUpdateSuccess)), // 다국어 적용
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${appLocalizations.profileUpdateFailed} $e')), // 다국어 적용
      );
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('내가 추가한 장소')),
          body: ListView.builder(
            itemCount: _myPlaces.length,
            itemBuilder: (context, index) {
              final data = _myPlaces[index].data() as Map<String, dynamic>;
              final placeId = data['id'] ?? '';

              return ListTile(
                title: Text(data['name'] ?? '장소명 없음'),
                subtitle: Text(data['category'] ?? ''),
                trailing: Text(
                  data['Added'] == true ? '승인 완료' : '검토 중',
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
                      title: data['title'] ?? '제목 없음',
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            Scaffold(
                backgroundColor: Colors.grey[100],
              appBar: AppBar(title: const Text('즐겨찾기한 장소'), backgroundColor: Colors.grey[100],),
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
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appLocalizations.editProfileTitle), // 다국어 적용
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nicknameController,
                  decoration: InputDecoration(labelText: appLocalizations.nicknameHint), // 다국어 적용
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  onChanged: (val) => setState(() => _selectedGender = val ?? appLocalizations.genderFemale), // 다국어 적용
                  decoration: InputDecoration(labelText: appLocalizations.genderLabel), // 다국어 적용
                  items: [
                    DropdownMenuItem(value: '여성', child: Text(appLocalizations.genderFemale)), // 다국어 적용
                    DropdownMenuItem(value: '남성', child: Text(appLocalizations.genderMale)), // 다국어 적용
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: appLocalizations.ageHint), // 다국어 적용
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _contactController,
                  decoration: InputDecoration(labelText: appLocalizations.contactHint), // 다국어 적용
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(appLocalizations.cancelButton), // 다국어 적용
            ),
            ElevatedButton(
              onPressed: () {
                _updateUserInfo();
                Navigator.of(context).pop();
              },
              child: Text(appLocalizations.saveButton), // 다국어 적용
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ──────────────────────────────────────────────────────────────────
    final appLocalizations = AppLocalizations.of(context)!;
    // ──────────────────────────────────────────────────────────────────

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.myPageScreenTitle), // 다국어 적용
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, size: 60, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _nickname ?? appLocalizations.loadingText, // 다국어 적용
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.currentUserId,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _showEditProfileDialog,
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(appLocalizations.editProfileButton), // 다국어 적용
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              appLocalizations.myActivitiesHeader, // 다국어 적용
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoCard(
              icon: Icons.favorite_border,
              title: appLocalizations.myFavoritesTitle, // 다국어 적용
              onTap: () {
                // 내 즐겨찾기 목록 보기 기능
              },
            ),
            _buildInfoCard(
              icon: Icons.schedule,
              title: appLocalizations.myScheduleTitle, // 다국어 적용
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyScheduleScreen(currentUserId: widget.currentUserId)),
                );
              },
            ),
            // myPageScreen.dart 파일의 _buildInfoCard 메서드 내부,
// '내 게시물' 섹션의 onTap 콜백:

            _buildInfoCard(
              icon: Icons.article_outlined,
              title: appLocalizations.myPostsTitle, // 다국어 적용
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(appLocalizations.myPostsTitle), // 다국어 적용
                      content: SizedBox(
                        width: double.maxFinite,
                        child: _myPosts.isEmpty
                            ? Center(child: Text(appLocalizations.noMyPosts)) // 다국어 적용
                            : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _myPosts.length,
                          itemBuilder: (context, index) {
                            final postDoc = _myPosts[index]; // DocumentSnapshot을 가져옵니다.
                            final postData = postDoc.data() as Map<String, dynamic>; // 데이터를 Map으로 변환

                            // 필요한 모든 데이터가 있는지 확인하고, 없으면 기본값 제공
                            final String postId = postDoc.id;
                            final String title = postData['title'] ?? appLocalizations.noTitle;
                            final String content = postData['content'] ?? appLocalizations.noContent;
                            final String authorId = postData['authorId'] ?? '';
                            final String authorNickname = postData['authorNickname'] ?? appLocalizations.unknown;
                            // createdAt은 Firestore의 Timestamp일 가능성이 높으므로 DateTime으로 변환
                            final DateTime createdAt = (postData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

                            return ListTile(
                              title: Text(title),
                              subtitle: Text('${appLocalizations.authorPrefix} $authorNickname'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PostDetailScreen(
                                      postId: postId,
                                      title: title,
                                      content: content,
                                      authorId: authorId,
                                      authorNickname: authorNickname,
                                      createdAt: createdAt,
                                      currentUserId: widget.currentUserId,
                                      // currentUserNickname은 필요에 따라 추가 전달
                                      currentUserNickname: _nickname, // 현재 로그인 사용자의 닉네임 (_nickname 변수에 저장되어 있을 것임)
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(appLocalizations.closeButton), // 다국어 적용
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            _buildInfoCard(
              icon: Icons.comment_outlined,
              title: appLocalizations.myCommentsTitle,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(appLocalizations.myCommentsTitle),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: _myComments.isEmpty
                            ? Center(child: Text(appLocalizations.noMyComments))
                            : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _myComments.length,
                          itemBuilder: (context, index) {
                            final comment = _myComments[index].data() as Map<String, dynamic>;

                            final String postId = comment['postId'] ?? '';
                            final String title = comment['postTitle'] ?? appLocalizations.unknownPost; // 댓글 문서에 게시물 제목이 저장되어 있어야 함
                            final String content = ''; // 댓글 문서에는 게시물 내용이 없을 수 있음
                            final String authorId = ''; // 댓글 문서에는 게시물 작성자 ID가 없을 수 있음
                            final String authorNickname = appLocalizations.unknown; // 댓글 문서에는 게시물 작성자 닉네임이 없을 수 있음
                            final DateTime createdAt = DateTime.now(); // 댓글 문서에는 게시물 생성 시간이 없을 수 있음

                            return ListTile(
                              title: Text(comment['content'] ?? appLocalizations.noContent),
                              subtitle: Text(
                                  '${appLocalizations.originalPostPrefix} ${comment['postTitle'] ?? appLocalizations.unknownPost}'),
                              onTap: () {
                                // 댓글이 달린 게시물로 이동 (게시물 ID가 있다면)
                                if (comment['postId'] != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PostDetailScreen(
                                        postId: postId,
                                        title: title,
                                        content: content,
                                        authorId: authorId,
                                        authorNickname: authorNickname,
                                        createdAt: createdAt,
                                        currentUserId: widget.currentUserId,
                                        currentUserNickname: _nickname,
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(appLocalizations.closeButton),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 30),
            Text(
              appLocalizations.settingsHeader, // 다국어 적용
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoCard(
              icon: Icons.notifications_none,
              title: appLocalizations.notificationSettingsTitle, // 다국어 적용
              onTap: () {
                // 알림 설정 화면으로 이동
              },
            ),
            _buildInfoCard(
              icon: Icons.help_outline,
              title: appLocalizations.helpCenterTitle, // 다국어 적용
              onTap: () {
                // 도움말/문의 화면으로 이동
              },
            ),
            _buildInfoCard(
              icon: Icons.info_outline,
              title: appLocalizations.aboutAppTitle, // 다국어 적용
              onTap: () {
                // 앱 정보 화면으로 이동
              },
            ),
            const SizedBox(height: 30),
            _buildButtonGroup(appLocalizations), // 다국어 적용된 appLocalizations 전달
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Icon(icon, color: Colors.grey[700], size: 20),
        title: Text(
          title, // 이미 다국어 적용된 title을 받으므로 변경 없음
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: onTap,
      ),
    );
  }
  // _buildButtonGroup 메서드에 appLocalizations를 파라미터로 추가
  Widget _buildButtonGroup(AppLocalizations appLocalizations) {
    return Center(
      child: Column(
        children: [
          TextButton(
            onPressed: () {
              widget.onLogout(null);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => LoginScreen(onLogin: widget.onLogout)),
              );
            },
            child: Text(appLocalizations.logoutButton), // 다국어 적용
          ),
          TextButton(
            onPressed: () {
              // 계정 삭제 로직 (실제로는 더 복잡한 확인 절차 필요)
            },
            child: Text(appLocalizations.deleteAccountButton), // 다국어 적용
          ),
        ],
      ),
    );
  }
}