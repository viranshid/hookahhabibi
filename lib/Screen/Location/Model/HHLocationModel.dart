/// Location Model
class HHLocationModel {
  final String id;
  final String title;
  final String slugUrl;
  final String address;
  final String image;
  final List<String> unavailableDishIds;
  final int displayOrder;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  HHLocationModel({
    required this.id,
    required this.title,
    required this.slugUrl,
    required this.address,
    required this.image,
    required this.unavailableDishIds,
    required this.displayOrder,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory HHLocationModel.fromJson(Map<String, dynamic> json) {
    // Parse unavailable dish IDs
    List<String> unavailableIds = [];
    if (json['unavailable_dish_ids'] != null) {
      if (json['unavailable_dish_ids'] is List) {
        unavailableIds = (json['unavailable_dish_ids'] as List)
            .map((id) => id.toString())
            .toList();
      }
    }

    return HHLocationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slugUrl: json['slug_url']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      unavailableDishIds: unavailableIds,
      displayOrder: int.tryParse(json['display_order']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug_url': slugUrl,
      'address': address,
      'image': image,
      'unavailable_dish_ids': unavailableDishIds,
      'display_order': displayOrder,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isActive => status == 'a';

  bool isDishUnavailable(String dishId) {
    return unavailableDishIds.contains(dishId);
  }

  // Convert to HHLocationCardModel for UI
  dynamic toLocationCardModel({bool isSelected = false}) {
    return {
      'id': id,
      'title': title,
      'subtitle': address,
      'imageUrl': image,
      'isSelected': isSelected,
    };
  }

  @override
  String toString() {
    return 'HHLocationModel(id: $id, title: $title, address: $address)';
  }
}