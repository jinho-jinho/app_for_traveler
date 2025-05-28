import 'package:google_maps_flutter/google_maps_flutter.dart';

class Place {
  final String id;
  final String name;
  final LatLng location;
  final String category;
  final String subcategory;
  final bool isEncrypted;
  final bool isFree; // 무료/유료 여부 (물품 보관함에서 사용)
  final List<Review> reviews;
  final List<String> reports;
  final bool isUserAdded;
  final String? imageUri; // image 추가

  Place({
    required this.id,
    required this.name,
    required this.location,
    required this.category,
    required this.subcategory,
    this.isEncrypted = false,
    this.isFree = true, // 기본값은 무료
    this.reviews = const [],
    this.reports = const [],
    this.isUserAdded = false,
    this.imageUri, // image 추가
  });
}

class Review {
  final String userId;
  final double rating;
  final String comment;
  final int likes;
  final String? imageUri; // 사진 첨부를 위한 URI

  Review({
    required this.userId,
    required this.rating,
    required this.comment,
    this.likes = 0,
    this.imageUri,
  });
}