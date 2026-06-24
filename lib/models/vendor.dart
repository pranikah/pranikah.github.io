import 'package:cloud_firestore/cloud_firestore.dart';

enum VendorCategory { wo, catering, dekorasi, fotografer, mua, venue, musik, undangan, lainnya }

extension VendorCategoryExt on VendorCategory {
  String get label => switch (this) {
    VendorCategory.wo => 'Wedding Organizer',
    VendorCategory.catering => 'Catering',
    VendorCategory.dekorasi => 'Dekorasi',
    VendorCategory.fotografer => 'Foto & Video',
    VendorCategory.mua => 'MUA',
    VendorCategory.venue => 'Venue',
    VendorCategory.musik => 'Musik',
    VendorCategory.undangan => 'Undangan',
    VendorCategory.lainnya => 'Lainnya',
  };
}

class Vendor {
  final String id;
  final String name;
  final VendorCategory category;
  final String city;
  final String priceRange;
  final String? instagram;

  Vendor({
    required this.id,
    required this.name,
    required this.category,
    required this.city,
    required this.priceRange,
    this.instagram,
  });

  factory Vendor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Vendor(
      id: doc.id,
      name: data['name'] ?? '',
      category: VendorCategory.values[data['category'] ?? 0],
      city: data['city'] ?? '',
      priceRange: data['price_range'] ?? '',
      instagram: data['instagram'],
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'category': category.index,
    'city': city,
    'price_range': priceRange,
    'instagram': instagram,
  };
}
