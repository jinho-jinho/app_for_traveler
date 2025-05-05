import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// 인기 장소 카드를 표시하는 StatelessWidget
// 역할: 장소 정보(제목, 설명, 별점, 최근 리뷰)를 카드 형태로 보여줌
class HotspotCard extends StatelessWidget {
  final String title; // 장소 제목
  final String description; // 장소 설명
  final double averageRating; // 평균 별점
  final String? latestReview; // 가장 최근 리뷰
  final VoidCallback onTap; // 카드 클릭 시 호출되는 콜백

  const HotspotCard({
    super.key,
    required this.title,
    required this.description,
    required this.averageRating,
    this.latestReview,
    required this.onTap,
  });

  // build: 장소 정보 카드 UI 렌더링
  // 역할: 제목, 설명, 별점, 리뷰를 포함한 카드 UI 구성
  // 분류: 디자인
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // 카드 클릭 시 콜백 실행
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 장소 제목
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // 장소 설명
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // 평균 별점 표시
            RatingBarIndicator(
              rating: averageRating,
              itemBuilder: (context, index) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              itemCount: 5,
              itemSize: 16.0,
              direction: Axis.horizontal,
            ),
            const SizedBox(height: 8),
            // 가장 최근 리뷰
            Text(
              latestReview != null ? latestReview! : '리뷰 없음',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}