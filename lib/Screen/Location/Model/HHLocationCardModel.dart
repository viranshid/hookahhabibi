class HHLocationCardModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool isSelected;

  HHLocationCardModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.isSelected = false,
  });

  // Factory constructor for JSON parsing
  factory HHLocationCardModel.fromJson(Map<String, dynamic> json) {
    return HHLocationCardModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      isSelected: json['isSelected'] ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'isSelected': isSelected,
    };
  }

  // Copy with method for updating selection state
  HHLocationCardModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    bool? isSelected,
  }) {
    return HHLocationCardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HHLocationCardModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'HHLocationCardModel(id: $id, title: $title, subtitle: $subtitle, imageUrl: $imageUrl, isSelected: $isSelected)';
  }
}