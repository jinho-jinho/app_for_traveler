import 'package:google_maps_flutter/google_maps_flutter.dart';

class Place {
  final String id;
  final String name;
  final LatLng location;
  final String category;
  final String subcategory;
  final bool isEncrypted;
  final bool isFree;
  final bool isUserAdded;
  final List<Review> reviews;
  final List<String> reports;
  String? address; // 주소 필드 추가

  Place({
    required this.id,
    required this.name,
    required this.location,
    required this.category,
    required this.subcategory,
    this.isEncrypted = false,
    this.isFree = true,
    this.isUserAdded = false,
    this.reviews = const [],
    this.reports = const [],
    this.address,
  });
}

class Review {
  final String userId;
  final double rating;
  final String comment;
  int likes;
  final String? imageUri; // 사진 첨부를 위한 URI

  Review({
    required this.userId,
    required this.rating,
    required this.comment,
    this.likes = 0,
    this.imageUri,
  });
}