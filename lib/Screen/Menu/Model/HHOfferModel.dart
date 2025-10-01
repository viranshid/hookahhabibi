/// Offer Image Model
class HHOfferModel {
  final String id;
  final String title;
  final String slugUrl;
  final String image;
  final String? linkUrl;
  final int displayOrder;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  HHOfferModel({
    required this.id,
    required this.title,
    required this.slugUrl,
    required this.image,
    this.linkUrl,
    required this.displayOrder,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory HHOfferModel.fromJson(Map<String, dynamic> json) {
    return HHOfferModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slugUrl: json['slug_url']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      linkUrl: json['link_url']?.toString(),
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
      'image': image,
      'link_url': linkUrl,
      'display_order': displayOrder,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isActive => status == 'a';
  bool get hasLink => linkUrl != null && linkUrl!.isNotEmpty;

  @override
  String toString() {
    return 'HHOfferModel(id: $id, title: $title, image: $image)';
  }
}