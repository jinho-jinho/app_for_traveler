import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:app_for_traveler/screens/postDetailScreen.dart';

// 게시판 화면을 나타내는 StatefulWidget
// 사용자 ID와 닉네임을 받아 게시물 목록을 표시하고 새 게시물을 작성할 수 있는 화면 제공
class BoardScreen extends StatefulWidget {
  final String currentUserId; // 현재 로그인한 사용자의 ID
  final String? currentUserNickname; // 현재 로그인한 사용자의 닉네임 (선택적)

  const BoardScreen({
    super.key,
    required this.currentUserId,
    this.currentUserNickname,
  });

  @override
  _BoardScreenState createState() => _BoardScreenState();
}

// BoardScreen의 상태를 관리하는 State 클래스
// Firestore에서 게시물 데이터를 가져오고 UI를 업데이트하며 사용자 상호작용 처리
class _BoardScreenState extends State<BoardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore 인스턴스
  bool _isLoading = true; // 데이터 로딩 상태를 나타내는 플래그
  List<Map<String, dynamic>> _posts = []; // 게시물 데이터를 저장하는 리스트

  // 위젯 초기화 시 호출
  // 게시물 데이터를 처음 가져오기 위해 _fetchPosts 호출
  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  // Firestore에서 게시물 목록을 가져오는 메소드
  // 최신순으로 정렬된 게시물을 가져와 _posts 리스트에 저장
  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true; // 로딩 시작
    });

    try {
      // Firestore 'posts' 컬렉션에서 최신순으로 데이터 가져오기
      QuerySnapshot postSnapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();

      // 가져온 데이터를 Map 형태로 변환하여 리스트에 저장
      List<Map<String, dynamic>> posts = postSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'title': data['title'] as String? ?? '제목 없음',
          'content': data['content'] as String? ?? '내용 없음',
          'authorId': data['authorId'] as String? ?? '알 수 없음',
          'authorNickname': data['authorNickname'] as String? ?? '알 수 없음',
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        };
      }).toList();

      // 상태 업데이트: 게시물 리스트 저장 및 로딩 종료
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      // 에러 발생 시 로딩 종료 및 에러 메시지 표시
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물 목록을 불러오는 데 실패했습니다.')),
        );
      }
    }
  }

  // 새 게시물 작성 다이얼로그를 표시하는 메소드
  // 사용자가 제목과 내용을 입력하여 새 게시물을 Firestore에 저장
  void _showAddPostDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();

    // 다이얼로그 표시
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('새 게시물 작성'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '제목',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: '내용',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // 다이얼로그 닫기
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                // 제목과 내용이 비어 있지 않은 경우 Firestore에 저장
                if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  try {
                    await _firestore.collection('posts').add({
                      'title': titleController.text,
                      'content': contentController.text,
                      'authorId': widget.currentUserId,
                      'authorNickname': widget.currentUserNickname ?? widget.currentUserId,
                      'createdAt': Timestamp.now(),
                    });
                    Navigator.pop(dialogContext); // 다이얼로그 닫기
                    _fetchPosts(); // 게시물 목록 갱신
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('게시물 저장 중 오류가 발생했습니다.')),
                      );
                    }
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('제목과 내용을 입력해주세요.')),
                    );
                  }
                }
              },
              child: const Text('작성'),
            ),
          ],
        );
      },
    ).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물 작성 다이얼로그 표시 중 오류가 발생했습니다.')),
        );
      }
    });
  }

  // UI를 구성하는 메소드
  // 게시물 목록을 표시하고 새 게시물 작성 버튼 제공
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시판'),
        elevation: 0,
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 중일 때 로딩 인디케이터 표시
          : _posts.isEmpty
              ? const Center(child: Text('게시물이 없습니다.', style: TextStyle(color: Colors.grey))) // 게시물이 없을 때 메시지 표시
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white, size: 24),
                      ),
                      title: Row(
                        children: [
                          Text(
                            post['authorNickname'] ?? '알 수 없음',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('yyyy-MM-dd HH:mm').format(post['createdAt']),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post['title'] ?? '제목 없음',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              post['content'] ?? '내용 없음',
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // 게시물 클릭 시 상세 화면으로 이동
                      onTap: () async {
                        print('게시물 탭: ${post['title']}');
                        try {
                          await Future.delayed(Duration.zero);
                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetailScreen(
                                  postId: post['id'],
                                  title: post['title'],
                                  content: post['content'],
                                  authorId: post['authorId'],
                                  authorNickname: post['authorNickname'],
                                  createdAt: post['createdAt'],
                                  currentUserId: widget.currentUserId,
                                  currentUserNickname: widget.currentUserNickname,
                                ),
                              ),
                            ).then((_) {
                              print('PostDetailScreen에서 돌아옴');
                            }).catchError((e) {
                              print('Navigator.push 실패: $e');
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('게시물 상세 화면 이동 중 오류가 발생했습니다.')),
                                );
                              }
                            });
                          } else {
                            print('BoardScreen이 언마운트됨');
                          }
                        } catch (e) {
                          print('화면 전환 중 예외 발생: $e');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('게시물 상세 화면 이동 중 오류가 발생했습니다.')),
                            );
                          }
                        }
                      },
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostDialog, // 새 게시물 작성 다이얼로그 표시
        child: const Icon(Icons.add),
        tooltip: '게시물 작성',
        backgroundColor: Colors.blue,
      ),
    );
  }
}